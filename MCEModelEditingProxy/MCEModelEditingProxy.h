//
//  MCEModelEditingProxy.h
//  MCEModelEditingProxy
//
//  Created by Milan Cermak on 1. 12. 2013.
//  Copyright (c) 2013 Milan Cermak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCEModelEditing <NSObject>

- (id)modelProxy;

// The following optional methods are to silence the compiler
// when the class is used (see README for details). You don't
// need to implement any of them. They mimick the actual interface
// of the MCEModelEditingProxy class and "expose" it on your models.

@optional

- (BOOL)isUpdated;
- (NSDictionary *)newValues;
- (void)reset;

@end

@interface MCEModelEditingProxy : NSProxy

@property (nonatomic, getter=isUpdated, readonly) BOOL updates;

- (id)initWithModel:(id<MCEModelEditing>)modelObject;

// Returns an NSDictionary holding new values of properties
// that were set on the model since initialization.
- (NSDictionary *)newValues;

// Call this method to throw away all recorded changes
// made to the model.
- (void)reset;

@end
