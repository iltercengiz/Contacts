//
//  ContactsStorage.h
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactRepresentation.h"

@interface ContactsStorage : NSObject

@property (nonatomic, readonly) NSArray *contacts;

+ (instancetype)sharedInstance;
- (ContactRepresentation *)addContact:(ContactRepresentation *)contactRepresentation;
- (ContactRepresentation *)removeContact:(ContactRepresentation *)contactRepresentation;
- (BOOL)hasContactWithPhoneNumber:(NSString *)phoneNumberString;

@end
