//
//  DummyModel.h
//  MCEModelEditingProxy
//
//  Created by Milan Cermak on 1. 12. 2013.
//  Copyright (c) 2013 Milan Cermak. All rights reserved.
//

#import "MCEModelEditingProxy.h"

@interface DummyModel : NSObject <MCEModelEditing>

@property (nonatomic, assign) BOOL aBool;
@property (nonatomic, assign) char aChar;
@property (nonatomic, assign) double aDouble;
@property (nonatomic, assign) float aFloat;
@property (nonatomic, assign) int anInt;
@property (nonatomic, assign) long aLong;
@property (nonatomic, assign) long long aLongLong;
@property (nonatomic, assign) short aShort;
@property (nonatomic, assign) unsigned char anUChar;
@property (nonatomic, assign) unsigned int anUInt;
@property (nonatomic, assign) unsigned long anULong;
@property (nonatomic, assign) unsigned long long anULongLong;
@property (nonatomic, assign) unsigned short anUShort;

@property (nonatomic, copy) NSArray *anArray;
@property (nonatomic, copy) NSDictionary *aDict;
@property (nonatomic, copy) NSNumber *aNumber;

@property (nonatomic, getter=getTheValue, strong) NSNumber *value;
@property (nonatomic, setter=rememberIt:, copy) NSArray *csArray;

@end
