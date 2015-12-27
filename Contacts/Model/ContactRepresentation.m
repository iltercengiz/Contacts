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

@dynamic fullName;

- (instancetype)init {
    return [self initWithContact:nil];
}

- (instancetype)initWithContact:(Contact *)contact {
    self = [super init];
    if (!self) {
        return nil;
    }
    if (contact) {
        NBPhoneNumberUtil *util = [NBPhoneNumberUtil new];
        NSError *error = nil;
        NBPhoneNumber *phoneNumber = [util parse:contact.phoneNumber defaultRegion:[NSLocale currentLocale].localeIdentifier error:&error];
        if (!error) {
            NSString *phoneNumberString = [util format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&error];
            if (!error) {
                self.phoneNumber = phoneNumberString;
                self.firstName = contact.firstName;
                self.lastName = contact.lastName;
                self.identifier = contact.identifier;
                self.contact = contact;
            }
        }
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

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
