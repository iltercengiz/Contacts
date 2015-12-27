//
//  AddContactViewController.h
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactRepresentation;
@protocol AddContactDelegate;

@interface AddContactViewController : UITableViewController

@property (weak, nonatomic) id<AddContactDelegate> delegate;

@end

@protocol AddContactDelegate <NSObject>

@optional
- (void)addContactViewController:(AddContactViewController *)addContactViewController didAddContact:(ContactRepresentation *)contactRepresentation;

@end
