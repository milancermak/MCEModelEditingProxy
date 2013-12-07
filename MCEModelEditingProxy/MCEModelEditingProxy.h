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

// TODO: add some comments/documentation to each method

@interface MCEModelEditingProxy : NSProxy

@property (nonatomic, getter=isUpdated, readonly) BOOL updates;

- (id)initWithModel:(id<MCEModelEditing>)modelObject;
- (NSDictionary *)newValues;
- (void)reset;

@end
