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
    [self updateContactCount];
    [self updateEmptyStateVisibility];
    [self.tableView reloadData];
}

- (void)updateContactCount {
    NSInteger numberOfContacts = self.contacts.count;
    self.contactsCountLabel.text = [NSString stringWithFormat:@"%li %@", numberOfContacts, NSLocalizedString(@"contacts", @"")];
    BOOL hidesContactsCount = (numberOfContacts == 0);
    self.contactsCountLabel.hidden = hidesContactsCount;
}

- (void)updateEmptyStateVisibility {
    NSInteger numberOfContacts = self.contacts.count;
    BOOL shouldShowEmptyStateView = (numberOfContacts == 0);
    self.tableView.backgroundView = shouldShowEmptyStateView ? self.emptyStateView : nil;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ContactRepresentation *representation = self.contacts[indexPath.row];
        [[ContactsStorage sharedInstance] removeContact:representation];
        self.contacts = [ContactsStorage sharedInstance].contacts;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self updateContactCount];
        [self updateEmptyStateVisibility];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIApplication *application = [UIApplication sharedApplication];
    ContactRepresentation *representation = self.contacts[indexPath.row];
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", representation.formattedPhoneNumber]];
    if ([application canOpenURL:phoneNumberURL]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm calling", @"Shown just before calling for confirmation")
                                                                       message:representation.phoneNumber
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"App wide 'Cancel' button") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", @"App wide 'Continue' button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [application openURL:phoneNumberURL];
        }];
        [alert addAction:continueAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Call error", @"Shown when calling is not possible")
                                                                       message:NSLocalizedString(@"This device doesn't support phone functionality.", @"Shown when calling is not possible")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"App wide 'Dismiss' button") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

@end
