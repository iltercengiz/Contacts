//
//  ContactRepresentation.h
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contact;

@interface ContactRepresentation : NSObject

@property (nonatomic) NSString *identifier; // Non-nil when initialized with -initWithContact:
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *phoneNumber;
@property (nonatomic, readonly) NSString *fullName;

- (instancetype)initWithContact:(Contact *)contact NS_DESIGNATED_INITIALIZER;
- (BOOL)isValid;

@end
