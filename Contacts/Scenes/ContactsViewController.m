//
//  ContactsViewController.m
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddContactViewController.h"
#import "ContactsStorage.h"
#import "PopupTransitioningDelegate.h"

@interface ContactsViewController () <AddContactDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *emptyStateView;
@property (weak, nonatomic) IBOutlet UILabel *contactsCountLabel;

@property (nonatomic) NSArray *contacts;
@property (nonatomic) PopupTransitioningDelegate *transitioningDelegate;

@end

@implementation ContactsViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshContacts];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddContactSegue"]) {
        AddContactViewController *addContactViewController = (AddContactViewController *)segue.destinationViewController;
        addContactViewController.modalPresentationStyle = UIModalPresentationCustom;
        addContactViewController.transitioningDelegate = self.transitioningDelegate;
    }
}

- (IBAction)unwindToContactsViewController:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Getter

- (PopupTransitioningDelegate *)transitioningDelegate {
    if (!_transitioningDelegate) {
        _transitioningDelegate = [PopupTransitioningDelegate new];
    }
    return _transitioningDelegate;
}

#pragma mark - Private methods

- (void)refreshContacts {
    self.contacts = [ContactsStorage sharedInstance].contacts;
    NSInteger numberOfContacts = self.contacts.count;
    self.contactsCountLabel.text = [NSString stringWithFormat:@"%li %@", numberOfContacts, NSLocalizedString(@"contacts", @"")];
    BOOL hidesContactsCount = (numberOfContacts == 0);
    self.contactsCountLabel.hidden = hidesContactsCount;
    self.tableView.backgroundView = hidesContactsCount ? self.emptyStateView : nil;
}

#pragma mark - AddContactDelegate

- (void)addContactViewController:(AddContactViewController *)addContactViewController didAddContact:(ContactRepresentation *)contactRepresentation {
    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    ContactRepresentation *representation = self.contacts[indexPath.row];
    cell.textLabel.text = representation.fullName;
    cell.detailTextLabel.text = representation.phoneNumber;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

#pragma mark - UITableViewDelegate

@end
