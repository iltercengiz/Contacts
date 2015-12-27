//
//  ContactRepresentationTests.m
//  Contacts
//
//  Created by Ilter Cengiz on 27/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactRepresentation.h"

@interface ContactRepresentationTests : XCTestCase

@end

@implementation ContactRepresentationTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testValidity {
    ContactRepresentation *representation = [ContactRepresentation new];
    XCTAssertFalse([representation isValid], @"Validation should not pass!");
    representation.firstName = @"Ilter";
    XCTAssertFalse([representation isValid], @"Validation should not pass!");
    representation.lastName = @"Cengiz";
    XCTAssertFalse([representation isValid], @"Validation should not pass!");
    representation.phoneNumber = @"+90 532 217";
    XCTAssertFalse([representation isValid], @"Validation should not pass!");
    representation.phoneNumber = @"+90 532 217 3890";
    XCTAssertTrue([representation isValid], @"Validation should pass!");
}

@end
