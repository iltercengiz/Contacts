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
    
#ifdef DEBUG
    /***** TESTING *****/
    BOOL hasInitialData = /* NO // */ YES;
    if (hasInitialData) {
        // Add initial contacts for demonstration
        NSArray *firstNames = @[@"John", @"Eliot", @"Steve", @"Joe", @"Emily", @"Amy", @"Marcus", @"Marc"];
        NSArray *lastNames = @[@"Roberto", @"Sophia", @"Antje", @"Tomislava", @"Eliana", @"Christine", @"Roscoe", @"Ovidio"];
        NSArray *phoneNumbers = @[@"+1-202-555-0114", @"+1-202-555-0118", @"+1-202-555-0180", @"+44 7700 900354", @"+44 7700 900286", @"+1-613-555-0178", @"+1-613-555-0139", @"+61 1900 654 321"];
        [phoneNumbers enumerateObjectsUsingBlock:^(NSString *phoneNumber, NSUInteger index, BOOL *stop) {
            ContactRepresentation *representation = [ContactRepresentation new];
            representation.phoneNumber = phoneNumber;
            representation.firstName = firstNames[(arc4random() % phoneNumbers.count)];
            representation.lastName = lastNames[(arc4random() % phoneNumbers.count)];
            [[ContactsStorage sharedInstance] addContact:representation];
        }];
    }
    /***** TESTING *****/
#endif
    
    [self refreshContacts];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddContactSegue"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        navigationController.modalPresentationStyle = UIModalPresentationCustom;
        navigationController.transitioningDelegate = self.transitioningDelegate;
        AddContactViewController *addContactViewController = (AddContactViewController *)navigationController.topViewController;
        addContactViewController.delegate = self;
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
    [self.tableView reloadData];
}

#pragma mark - AddContactDelegate

- (void)addContactViewController:(AddContactViewController *)addContactViewController didAddContact:(ContactRepresentation *)contactRepresentation {
    contactRepresentation = [[ContactsStorage sharedInstance] addContact:contactRepresentation];
    if (contactRepresentation) {
        [self refreshContacts];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
