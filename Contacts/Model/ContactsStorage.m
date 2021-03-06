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
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

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
    
    NBPhoneNumberUtil *util = [NBPhoneNumberUtil new];
    NSError *error = nil;
    NBPhoneNumber *phoneNumber = [util parse:contactRepresentation.phoneNumber defaultRegion:[NSLocale currentLocale].localeIdentifier error:&error];
    if (!error) {
        NSString *phoneNumberString = [util format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:&error];
        if (!error) {
            Contact *contact = [Contact new];
            contact.identifier = [NSUUID UUID].UUIDString;
            contact.firstName = contactRepresentation.firstName;
            contact.lastName = contactRepresentation.lastName;
            contact.phoneNumber = phoneNumberString;
            contact.createdDate = [NSDate date];
            [self.mutableContacts addObject:contact];
            
            contactRepresentation.identifier = contact.identifier;
            return contactRepresentation;
        }
    }
    
    return nil;
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

- (BOOL)hasContactWithPhoneNumber:(NSString *)phoneNumberString {
    __block BOOL hasContact = NO;
    NBPhoneNumberUtil *util = [NBPhoneNumberUtil new];
    NSError *error = nil;
    NBPhoneNumber *phoneNumber = [util parse:phoneNumberString defaultRegion:[NSLocale currentLocale].localeIdentifier error:&error];
    if (!error) {
        phoneNumberString = [util format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:&error];
        if (!error) {
            [self.mutableContacts enumerateObjectsUsingBlock:^(Contact *contact, NSUInteger index, BOOL *stop) {
                if ([contact.phoneNumber isEqualToString:phoneNumberString]) {
                    *stop = YES;
                    hasContact = YES;
                }
            }];
        }
    }
    return hasContact;
}

@end
