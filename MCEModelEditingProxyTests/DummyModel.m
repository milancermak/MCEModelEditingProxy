//
//  DummyModel.m
//  MCEModelEditingProxy
//
//  Created by Milan Cermak on 1. 12. 2013.
//  Copyright (c) 2013 Milan Cermak. All rights reserved.
//

#import "DummyModel.h"
#import "MCEModelEditingProxy.h"

@implementation DummyModel

- (id)modelProxy {
    return [[MCEModelEditingProxy alloc] initWithModel:self];
}

@end
