//
//  MCEModelEditingProxy.m
//  MCEModelEditingProxy
//
//  Created by Milan Cermak on 1. 12. 2013.
//  Copyright (c) 2013 Milan Cermak. All rights reserved.
//

#include <objc/runtime.h>
#include <stdlib.h>
#import "MCEModelEditingProxy.h"

void alloc_storage_for_property(void **storage, objc_property_t property) {
    char *property_type = property_copyAttributeValue(property, "T"); // get the type encoding (i.e. @encode) value of the property
    NSUInteger storageSize;
    NSGetSizeAndAlignment(property_type, &storageSize, NULL);
    free(property_type);
    *storage = malloc(storageSize);
}

bool is_object_type(objc_property_t property) {
    char *property_type = property_copyAttributeValue(property, "T");
    bool is_object = strncmp(property_type, @encode(id), 1) == 0;
    free(property_type);
    return is_object;
}

bool is_property_readwrite(objc_property_t property) {
  char *readonly = property_copyAttributeValue(property, "R");
  if (readonly) {
    free(readonly);
    return false;
  }
  return true;
}

@interface MCEModelEditingProxy ()

@property (nonatomic, weak) id<MCEModelEditing> modelObject;

- (BOOL)isGetterForWritableProperty:(NSString *)selectorAsString;
- (BOOL)isSetterForWritableProperty:(NSString *)selectorAsString;
- (void)storePrimitiveValue:(NSString *)propertyName fromInvocation:(NSInvocation *)invocation;

@end

@implementation MCEModelEditingProxy {
    NSDictionary *_getters;
    NSDictionary *_setters;
    NSMutableDictionary *_propertiesNewValues;
}

- (id)initWithModel:(id<MCEModelEditing>)modelObject {
    if (self) {
        self.modelObject = modelObject;

        unsigned int properties_count = 0;
        objc_property_t *properties_list = class_copyPropertyList([modelObject class], &properties_count);
        NSAssert(properties_count, @"No properties found in class %@", [modelObject class]);

        // collect names of getter and setter method names for properties, that are
        // declared as readwrite on the model object; key in the dictionary is the
        // property name, value is an array of 2, the getter and setter names
        NSMutableDictionary *getters = [NSMutableDictionary dictionaryWithCapacity:properties_count];
        NSMutableDictionary *setters = [NSMutableDictionary dictionaryWithCapacity:properties_count];

        for (NSUInteger property_index = 0; property_index < properties_count; property_index++) {
            objc_property_t property = properties_list[property_index];
            if (is_property_readwrite(property)) {
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                NSString *getter, *setter;

                char *property_getter = property_copyAttributeValue(property, "G");
                if (property_getter) {
                    getter = [NSString stringWithUTF8String:property_getter];
                    free(property_getter);
                } else {
                    getter = propertyName;
                }
                getters[getter] = propertyName;

                char *property_setter = property_copyAttributeValue(property, "S");
                if (property_setter) {
                    setter = [NSString stringWithUTF8String:property_setter];
                    free(property_setter);
                } else {
                    setter = [NSString stringWithFormat:@"set%@%@:",
                                       [[propertyName substringToIndex:1] uppercaseString],
                                       [propertyName substringFromIndex:1]];
                }
                setters[setter] = propertyName;
            }
        }
        free(properties_list);

        _getters = [NSDictionary dictionaryWithDictionary:getters];
        _setters = [NSDictionary dictionaryWithDictionary:setters];
        _propertiesNewValues = [NSMutableDictionary dictionaryWithCapacity:[_setters count]];
    }
    return self;
}

#pragma mark - NSObject

- (Class)class {
    return [self.modelObject class];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<MCEModelEditingProxy: %p> {\nmodel: <%@ %p>\nwritable properties: %@\n}",
                     self, [self.modelObject class], self.modelObject, [_setters allKeys]];
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [self.modelObject respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    NSString *selectorAsString = NSStringFromSelector(selector);
    if ([self isGetterForWritableProperty:selectorAsString] ||
        [self isSetterForWritableProperty:selectorAsString] ||
        [selectorAsString isEqualToString:@"valueForKey:"]) {
        // intercepting valueForKey: as well to get KVC
        return self;
    }
    return self.modelObject;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [(NSObject *)self.modelObject methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *selectorAsString = NSStringFromSelector(invocation.selector);
    if (([self isGetterForWritableProperty:selectorAsString] ||
         [selectorAsString isEqualToString:@"valueForKey:"])
        && self.isUpdated) {
        // intercepting the getter - if the value was already edited, return it,
        // otherwise forward the method invocation to the original model

        NSString *propertyName = _getters[selectorAsString];
        if ([selectorAsString isEqualToString:@"valueForKey:"]) {
            [invocation getArgument:&propertyName atIndex:2];
        }

        id value = [_propertiesNewValues valueForKey:propertyName];
        if (value) {
            objc_property_t property = class_getProperty([self.modelObject class], [propertyName UTF8String]);
            if (is_object_type(property) || [selectorAsString isEqualToString:@"valueForKey:"]) {
                [invocation setReturnValue:&value];
            } else {
                void *storage = NULL;
                alloc_storage_for_property(&storage, property);
                [value getValue:storage];
                [invocation setReturnValue:storage];
                free(storage);
            }
        } else {
            [invocation invokeWithTarget:self.modelObject];
        }
    } else if ([self isSetterForWritableProperty:selectorAsString]) {
        // intercepting the setter - save the value into the internal storage object
        NSString *propertyName = _setters[selectorAsString];
        objc_property_t property = class_getProperty([self.modelObject class], [propertyName UTF8String]);

        // objects and primitive C values have to be treated differently
        // when extracting their values from the invocation
        if (is_object_type(property)) {
            __unsafe_unretained id objectValue = nil;
            [invocation getArgument:&objectValue atIndex:2];
            _propertiesNewValues[propertyName] = objectValue;
        } else {
            [self storePrimitiveValue:propertyName fromInvocation:invocation];
        }
        _updates = YES;
    } else {
        [invocation invokeWithTarget:self.modelObject];
    }
}

#pragma mark - Public

- (NSDictionary *)newValues {
    return [NSDictionary dictionaryWithDictionary:_propertiesNewValues];
}

- (void)reset {
    _updates = NO;
    _propertiesNewValues = [NSMutableDictionary dictionaryWithCapacity:[_setters count]];
}

#pragma mark - Private

- (BOOL)isGetterForWritableProperty:(NSString *)selectorAsString {
    return _getters[selectorAsString] != nil;
}

- (BOOL)isSetterForWritableProperty:(NSString *)selectorAsString {
    return _setters[selectorAsString] != nil;
}

- (void)storePrimitiveValue:(NSString *)propertyName fromInvocation:(NSInvocation *)invocation {
    objc_property_t property = class_getProperty([self.modelObject class], [propertyName UTF8String]);
    char *property_type = property_copyAttributeValue(property, "T");

    // try to wrap the value into NSNumber, using the appropriate method
    // types from:
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/DataTypes.html#//apple_ref/doc/uid/20002171-BAJEAIEE

    if (strncmp(property_type, @encode(char), 1) == 0) {
        // this branch also handles BOOL types, since
        // in Objective-C BOOL is a typedef of signed char
        char val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithChar:val];
    } else if (strncmp(property_type, @encode(double), 1) == 0) {
        double val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithDouble:val];
    } else if (strncmp(property_type, @encode(float), 1) == 0) {
        float val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithFloat:val];
    } else if (strncmp(property_type, @encode(int), 1) == 0) {
        int val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithChar:val];
    } else if (strncmp(property_type, @encode(long), 1) == 0) {
        long val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithLong:val];
    } else if (strncmp(property_type, @encode(long long), 1) == 0) {
        long long val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithLongLong:val];
    } else if (strncmp(property_type, @encode(short), 1) == 0) {
        short val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithShort:val];
    } else if (strncmp(property_type, @encode(unsigned char), 1) == 0) {
        unsigned char val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithChar:val];
    } else if (strncmp(property_type, @encode(unsigned int), 1) == 0) {
        unsigned int val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithUnsignedInt:val];
    } else if (strncmp(property_type, @encode(unsigned long), 1) == 0) {
        unsigned long val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithUnsignedLong:val];
    } else if (strncmp(property_type, @encode(unsigned long long), 1) == 0) {
        unsigned long long val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithUnsignedLongLong:val];
    } else if (strncmp(property_type, @encode(unsigned short), 1) == 0) {
        unsigned short val;
        [invocation getArgument:&val atIndex:2];
        _propertiesNewValues[propertyName] = [NSNumber numberWithUnsignedShort:val];
    } else {
        // if the primitive value can't be stored as NSNumber, use NSValue
        void *primitiveValue = NULL;
        alloc_storage_for_property(&primitiveValue, property);
        [invocation getArgument:primitiveValue atIndex:2];
        NSValue *value = [NSValue valueWithBytes:primitiveValue objCType:property_type];
        _propertiesNewValues[propertyName] = value;
        free(primitiveValue);
    }
    free(property_type);
}

@end
