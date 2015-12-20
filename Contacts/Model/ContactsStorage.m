//
//  ContactsStorage.m
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import "ContactsStorage.h"
#import "Contact.h"
#import <BlocksKit/NSArray+BlocksKit.h>

@interface ContactsStorage ()

@property (nonatomic) NSMutableArray *mutableContacts;

@end

@implementation ContactsStorage

@dynamic contacts;

+ (instancetype)sharedInstance {
    static ContactsStorage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ContactsStorage new];
    });
    return sharedInstance;
}

#pragma mark - Getter

- (NSMutableArray *)mutableContacts {
    if (!_mutableContacts) {
        _mutableContacts = [NSMutableArray array];
    }
    return _mutableContacts;
}

- (NSArray *)contacts {
    return [self.mutableContacts bk_map:^ContactRepresentation *(Contact *contact) {
        return [[ContactRepresentation alloc] initWithContact:contact];
    }];
}

#pragma mark - Public methods

- (ContactRepresentation *)addContact:(ContactRepresentation *)contactRepresentation {
    if (!contactRepresentation) {
        return nil;
    }
    if (![contactRepresentation isValid]) {
        return nil;
    }
    
    Contact *contact = [Contact new];
    contact.identifier = [NSUUID UUID].UUIDString;
    contact.firstName = contactRepresentation.firstName;
    contact.lastName = contactRepresentation.lastName;
    contact.phoneNumber = contactRepresentation.phoneNumber;
    contact.createdDate = [NSDate date];
    [self.mutableContacts addObject:contact];
    
    contactRepresentation.identifier = contact.identifier;
    return contactRepresentation;
}

- (ContactRepresentation *)removeContact:(ContactRepresentation *)contactRepresentation {
    if (!contactRepresentation) {
        return nil;
    }
    
    Contact *contact = [self.mutableContacts bk_match:^BOOL(Contact *contact) {
        return [contact.identifier isEqualToString:contactRepresentation.identifier];
    }];
    [self.mutableContacts removeObject:contact];
    
    return contactRepresentation;
}

@end
