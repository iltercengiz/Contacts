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

@property (nonatomic) ContactRepresentation *representation;

@end

@implementation ContactRepresentationTests

- (void)setUp {
    [super setUp];
    self.representation = [ContactRepresentation new];
    self.representation.firstName = @"Ilter";
    self.representation.lastName = @"Cengiz";
    self.representation.phoneNumber = @"+90 532 217 3890";
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

- (void)testFullName {
    XCTAssertEqualObjects(self.representation.fullName, @"Ilter Cengiz", @"Failed to concat first and last name!");
}

- (void)testFormattedPhoneNumber {
    XCTAssertEqualObjects(self.representation.formattedPhoneNumber, @"+905322173890", @"Failed to format phone number!");
}

@end
