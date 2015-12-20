//
//  ContactRepresentation.m
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import "ContactRepresentation.h"
#import "Contact.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

@interface ContactRepresentation ()

@property (nonatomic) Contact *contact;

@end

@implementation ContactRepresentation

- (instancetype)init {
    return [self initWithContact:nil];
}

- (instancetype)initWithContact:(Contact *)contact {
    self = [super init];
    if (!self) {
        return nil;
    }
    if (contact) {
        self.contact = contact;
        self.identifier = contact.identifier;
        self.firstName = contact.firstName;
        self.lastName = contact.lastName;
        self.phoneNumber = contact.phoneNumber;
    }
    return self;
}

- (BOOL)isValid {
    if ((self.firstName.length < 1) ||
        (self.lastName.length < 1) ||
        (self.phoneNumber.length < 1)) {
        return NO;
    }
    NBPhoneNumberUtil *util = [NBPhoneNumberUtil new];
    NSError *error = nil;
    NBPhoneNumber *phoneNumber = [util parse:self.phoneNumber defaultRegion:[NSLocale currentLocale].localeIdentifier error:&error];
    if (error) {
        return NO;
    }
    return [util isValidNumber:phoneNumber];
}

@end
