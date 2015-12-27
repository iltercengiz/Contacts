//
//  ContactsStorageTests.m
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactsStorage.h"

@interface ContactsStorageTests : XCTestCase

@property (nonatomic) NSInteger currentContactsCount;

@end

@implementation ContactsStorageTests

- (void)setUp {
    [super setUp];
    self.currentContactsCount = [ContactsStorage sharedInstance].contacts.count;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAddContact {
    ContactRepresentation *representation = [ContactRepresentation new];
    representation.firstName = @"Ilter";
    representation.lastName = @"Cengiz";
    representation.phoneNumber = @"+905322173890";
    
    XCTAssertNotNil([[ContactsStorage sharedInstance] addContact:representation], @"Adding contact failed!");
    XCTAssertEqual([ContactsStorage sharedInstance].contacts.count, (self.currentContactsCount + 1), @"Adding contact failed!");
}

- (void)testAddInvalidContact {
    ContactRepresentation *representation = [ContactRepresentation new];
    representation.firstName = @"Ilter";
    representation.lastName = @"Cengiz";
    representation.phoneNumber = @"1231235322173890";
    
    XCTAssertNil([[ContactsStorage sharedInstance] addContact:representation], @"Invalid contact has been added!");
    XCTAssertEqual([ContactsStorage sharedInstance].contacts.count, self.currentContactsCount, @"Invalid contact has been added!");
}

- (void)testHasContact {
    ContactRepresentation *representation = (ContactRepresentation *)[ContactsStorage sharedInstance].contacts.firstObject;
    XCTAssertTrue([[ContactsStorage sharedInstance] hasContactWithPhoneNumber:representation.phoneNumber], @"Failed to find contact!");
}

- (void)testRemoveContact {
    NSArray *contacts = [ContactsStorage sharedInstance].contacts;
    ContactRepresentation *representation = (ContactRepresentation *)contacts.firstObject;
    
    XCTAssertNotNil(representation, @"Retrieving contact failed!");
    
    representation = [[ContactsStorage sharedInstance] removeContact:representation];
    
    XCTAssertNotNil(representation, @"Removing contact failed!");
    XCTAssertEqual([ContactsStorage sharedInstance].contacts.count, (self.currentContactsCount - 1), @"There're still contacts even removal!");
}

@end
