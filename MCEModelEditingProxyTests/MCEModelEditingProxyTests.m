//
//  MCEModelEditingProxyTests.m
//  MCEModelEditingProxyTests
//
//  Created by Milan Cermak on 1. 12. 2013.
//  Copyright (c) 2013 Milan Cermak. All rights reserved.
//

// Every test* method creates its own modelProxy instance, instead
// of having it as an ivar and creating it in -setUp. The latter
// method didn't work (running the test suite resulted in a
// doesNotRecognizeSelector: error). Honestly, I don't know why.

#import <XCTest/XCTest.h>
#import "DummyModel.h"

@interface MCEModelEditingProxyTests : XCTestCase
@end

@implementation MCEModelEditingProxyTests {
    DummyModel *model;
}

- (void)setUp {
    [super setUp];

    model = [DummyModel new];
    model.aBool = NO;
    model.aChar = 'c';
    model.aDouble = 0.99;
    model.aFloat = 0.42f;
    model.anInt = 1;
    model.aLong = 10L;
    model.aLongLong = 100LL;
    model.aShort = (short) 1;
    model.anUChar = (unsigned char) 'u';
    model.anUInt = 1U;
    model.anULong = 10UL;
    model.anULongLong = 100ULL;
    model.anUShort = (unsigned short) 1;

    model.anArray = @[@1, @2, @3];
    model.aDict = @{@"foo": @"pancakes"};
    model.aNumber = @99;

    model.value = @1;
    model.csArray = @[@"circle"];
}

- (void)testSettingPrimitiveValues {
    DummyModel *modelProxy = [model modelProxy];

    BOOL newBool = YES;
    char newChar = 'i';
    double newDouble = 0.1;
    float newFloat = 0.24f;
    int newInt = -1;
    long newLong = -10L;
    long long newLongLong = -100LL;
    short newShort = (short) -1;
    unsigned char newUChar = (unsigned char ) 'n';
    unsigned int newUInt = 2U;
    unsigned long newULong = 20UL;
    unsigned long long newULongLong = 200ULL;
    unsigned short newUShort = (unsigned short) 2;

    modelProxy.aBool = newBool;
    modelProxy.aChar = newChar;
    modelProxy.aDouble = newDouble;
    modelProxy.aFloat = newFloat;
    modelProxy.anInt = newInt;
    modelProxy.aLong = newLong;
    modelProxy.aLongLong = newLongLong;
    modelProxy.aShort = newShort;
    modelProxy.anUChar = newUChar;
    modelProxy.anUInt = newUInt;
    modelProxy.anULong = newULong;
    modelProxy.anULongLong = newULongLong;
    modelProxy.anUShort = newUShort;

    XCTAssertEqual(modelProxy.aBool, newBool, @"BOOL values not equal");
    XCTAssertEqual(modelProxy.aChar, newChar, @"Char values not equal");
    XCTAssertEqual(modelProxy.aDouble, newDouble, @"Double values not equal");
    XCTAssertEqual(modelProxy.aFloat, newFloat, @"Float values not equal");
    XCTAssertEqual(modelProxy.anInt, newInt, @"Int values not equal");
    XCTAssertEqual(modelProxy.aLong, newLong, @"Long values not equal");
    XCTAssertEqual(modelProxy.aLongLong, newLongLong, @"Long long values not equal");
    XCTAssertEqual(modelProxy.aShort, newShort, @"Short values not equal");
    XCTAssertEqual(modelProxy.anUChar, newUChar, @"Unsigned char values not equal");
    XCTAssertEqual(modelProxy.anUInt, newUInt, @"Unsigned int values not equal");
    XCTAssertEqual(modelProxy.anULong, newULong, @"Unsigned long values not equal");
    XCTAssertEqual(modelProxy.anULongLong, newULongLong, @"Unsigned long long values not equal");
    XCTAssertEqual(modelProxy.anUShort, newUShort, @"Unsigned short values not equal");

    NSDictionary *newValues = [modelProxy newValues];
    XCTAssertNotNil(newValues[@"aBool"], @"Missing BOOL value");
    XCTAssertNotNil(newValues[@"aChar"], @"Missing char value");
    XCTAssertNotNil(newValues[@"aDouble"], @"Missing double value");
    XCTAssertNotNil(newValues[@"aFloat"], @"Missing float value");
    XCTAssertNotNil(newValues[@"anInt"], @"Missing int value");
    XCTAssertNotNil(newValues[@"aLong"], @"Missing long value");
    XCTAssertNotNil(newValues[@"aLongLong"], @"Missing long long value");
    XCTAssertNotNil(newValues[@"aShort"], @"Missing short value");
    XCTAssertNotNil(newValues[@"anUChar"], @"Missing unsigned char value");
    XCTAssertNotNil(newValues[@"anUInt"], @"Missing unsigned int value");
    XCTAssertNotNil(newValues[@"anULong"], @"Missing unsigned long value");
    XCTAssertNotNil(newValues[@"anULongLong"], @"Missing unsigned long long value");
    XCTAssertNotNil(newValues[@"anUShort"], @"Missing unsigned short value");
}

- (void)testSettingObjectValues {
    DummyModel *modelProxy = [model modelProxy];

    NSArray *newArray = @[@"a", @"b", @"c"];
    NSDictionary *newDict = @{@"foo": @"cookies"};
    NSNumber *newNumber = @1;

    modelProxy.anArray = newArray;
    modelProxy.aDict = newDict;
    modelProxy.aNumber = newNumber;

    XCTAssertTrue([modelProxy.anArray isEqualToArray:newArray], @"Arrays not equal");
    XCTAssertTrue([modelProxy.aDict isEqualToDictionary:newDict], @"Dictionaries not equal");
    XCTAssertTrue([modelProxy.aNumber isEqualToNumber:newNumber], @"Numbers not equal");

    NSDictionary *newValues = [modelProxy newValues];
    XCTAssertNotNil(newValues[@"anArray"], @"Missing NSArray value");
    XCTAssertNotNil(newValues[@"aDict"], @"Missing NSDictionary value");
    XCTAssertNotNil(newValues[@"aNumber"], @"Missing NSNumber value");
}

- (void)testPropertyWithCustomGetter {
    DummyModel *modelProxy = [model modelProxy];

    NSNumber *newValue = @2;
    modelProxy.value = newValue;

    XCTAssertTrue([modelProxy.getTheValue isEqualToNumber:newValue], @"Numbers not equal");
    NSDictionary *newValues = [modelProxy newValues];
    XCTAssertNotNil(newValues[@"value"], @"Missing NSNumber value with custom getter");
}

- (void)testPropertyWithCustomSetter {
    DummyModel *modelProxy = [model modelProxy];

    NSArray *newArray = @[@"square"];
    [modelProxy rememberIt:newArray];

    XCTAssertTrue([modelProxy.csArray isEqualToArray:newArray], @"Arrays set by custom setter not equal");
    NSDictionary *newValues = [modelProxy newValues];
    XCTAssertNotNil(newValues[@"csArray"], @"Missing NSArray value with custom setter");
}

- (void)testCommit {
    DummyModel *modelProxy = [model modelProxy];

    BOOL newBool = YES;
    char newChar = 'i';
    double newDouble = 0.1;
    float newFloat = 0.24f;
    int newInt = -1;
    long newLong = -10L;
    long long newLongLong = -100LL;
    short newShort = (short) -1;
    unsigned char newUChar = (unsigned char ) 'n';
    unsigned int newUInt = 2U;
    unsigned long newULong = 20UL;
    unsigned long long newULongLong = 200ULL;
    unsigned short newUShort = (unsigned short) 2;

    NSArray *newArray = @[@"pyramid"];
    NSDictionary *newDict = @{@"joke": @"Why did the hipster drown? Because he swam against the main stream."};
    NSNumber *newNumber = @2;

    modelProxy.aBool = newBool;
    modelProxy.aChar = newChar;
    modelProxy.aDouble = newDouble;
    modelProxy.aFloat = newFloat;
    modelProxy.anInt = newInt;
    modelProxy.aLong = newLong;
    modelProxy.aLongLong = newLongLong;
    modelProxy.aShort = newShort;
    modelProxy.anUChar = newUChar;
    modelProxy.anUInt = newUInt;
    modelProxy.anULong = newULong;
    modelProxy.anULongLong = newULongLong;
    modelProxy.anUShort = newUShort;

    [modelProxy rememberIt:newArray];
    modelProxy.aDict = newDict;
    modelProxy.value = newNumber;

    [modelProxy commit];

    XCTAssertTrue(model.aBool == newBool, @"Model BOOL value not updated after committing");
    XCTAssertTrue(model.aChar == newChar, @"Model char value not updated after committing");
    NSLog(@"double: %f", model.aDouble);
    XCTAssertTrue(model.aDouble == newDouble, @"Model double value not updated after committing");
    XCTAssertTrue(model.aFloat == newFloat, @"Model float value not updated after committing");
    XCTAssertTrue(model.anInt == newInt, @"Model int value not updated after committing");
    XCTAssertTrue(model.aLong == newLong, @"Model long value not updated after committing");
    XCTAssertTrue(model.aLongLong == newLongLong, @"Model long long value not updated after committing");
    XCTAssertTrue(model.aShort == newShort, @"Model short value not updated after committing");
    XCTAssertTrue(model.anUChar == newUChar, @"Model unsigned char value not updated after committing");
    XCTAssertTrue(model.anUInt == newUInt, @"Model unsigned int value not updated after committing");
    XCTAssertTrue(model.anULong == newULong, @"Model unsigned long value not updated after committing");
    XCTAssertTrue(model.anULongLong == newULongLong, @"Model unsigned long long value not updated after committing");
    XCTAssertTrue(model.anUShort == newUShort, @"Model unsigned short value not updated after committing");

    XCTAssertTrue([model.csArray isEqualToArray:newArray], @"Model array with custom setter not updated after committing");
    XCTAssertTrue([model.aDict isEqualToDictionary:newDict], @"Model dictionary not updated after committing");
    XCTAssertTrue([model.getTheValue isEqualToNumber:newNumber], @"Model number with custom getter not updated after committing");
    XCTAssertFalse([modelProxy isUpdated], @"Model proxy reporting as updated after commit");
    XCTAssertTrue(0 == [[modelProxy newValues] count], @"Model proxy reporting new values after commit");
}

- (void)testReset {
    DummyModel *modelProxy = [model modelProxy];

    NSArray *newArray = @[@"one", @"two"];
    double newDouble = 0.12;

    XCTAssertFalse([modelProxy isUpdated], @"Model proxy reporting wrong updated status");
    XCTAssertTrue(0 == [[modelProxy newValues] count], @"New values set even though no updates happened");

    modelProxy.anArray = newArray;
    modelProxy.aDouble = newDouble;

    XCTAssertTrue([modelProxy isUpdated], @"Model proxy reporting wrong updated status");
    XCTAssertTrue(2 == [[modelProxy newValues] count], @"Incorrect new values set: %@", [modelProxy newValues]);

    [modelProxy reset];
    XCTAssertFalse([modelProxy isUpdated], @"Model proxy reporting wrong updated status");
    XCTAssertTrue(0 == [[modelProxy newValues] count], @"New values set even though no updates happened");
}

@end
