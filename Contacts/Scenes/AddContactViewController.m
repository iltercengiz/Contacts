//
//  AddContactViewController.m
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactsStorage.h"
#import <libPhoneNumber-iOS/NBAsYouTypeFormatter.h>
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

@interface AddContactViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@property (nonatomic) NBPhoneNumberUtil *util;
@property (nonatomic) NBAsYouTypeFormatter *formatter;
@property (nonatomic) NBPhoneNumber *phoneNumber;

@property (nonatomic) ContactRepresentation *contactRepresentation;

@end

@implementation AddContactViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contactRepresentation = [ContactRepresentation new];
    self.util = [NBPhoneNumberUtil new];
    self.formatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:[NSLocale currentLocale].localeIdentifier];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UnwindAddContactSegue"]) {
        [self.view endEditing:YES]; // Resign all responders
    }
}

#pragma mark - IBAction

- (IBAction)didTapSaveBarButton:(id)sender {
    void (^addContactBlock)() = ^{
        if ([self.delegate respondsToSelector:@selector(addContactViewController:didAddContact:)]) {
            [self.delegate addContactViewController:self didAddContact:self.contactRepresentation];
        }
        [self performSegueWithIdentifier:@"UnwindAddContactSegue" sender:sender];
    };
    if ([[ContactsStorage sharedInstance] hasContactWithPhoneNumber:self.contactRepresentation.phoneNumber]) {
        NSString *title = NSLocalizedString(@"Confirm new contact", @"Shown when a new contact with a phone number that's already in list is tried to be added");
        NSString *message = [NSString stringWithFormat:@"%@\n\n%@\n\n%@",
                             NSLocalizedString(@"A contact with the following phone number is already present.", @"Shown when a new contact with a phone number that's already in list is tried to be added"),
                             self.contactRepresentation.phoneNumber,
                             NSLocalizedString(@"Would you like to add again?", @"Shown when a new contact with a phone number that's already in list is tried to be added")];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"App wide 'Cancel' button") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", @"Used in confirmation alert on Add Contact scene") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            addContactBlock();
        }];
        [alert addAction:continueAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        addContactBlock();
    }
}

- (IBAction)didChangeEditing:(id)sender {
    // Update contactRepresentation
    if (sender == self.firstNameTextField) {
        self.contactRepresentation.firstName = self.firstNameTextField.text;
    } else if (sender == self.lastNameTextField) {
        self.contactRepresentation.lastName = self.lastNameTextField.text;
    } else if (sender == self.phoneNumberTextField) {
        self.contactRepresentation.phoneNumber = [self.util format:self.phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil];
    }
    [self updateSaveBarButtonStateIfNeeded];
}

- (IBAction)didTapReturnOnKeyboard:(id)sender {
    if (sender == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (sender == self.lastNameTextField) {
        [self.phoneNumberTextField becomeFirstResponder];
    } else if (sender == self.phoneNumberTextField) {
        [self.phoneNumberTextField resignFirstResponder];
    }
}

#pragma mark - Private methods

- (void)updateSaveBarButtonStateIfNeeded {
    BOOL shouldEnable = [self.contactRepresentation isValid];
    self.saveBarButtonItem.enabled = shouldEnable;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.phoneNumberTextField) {
        BOOL shouldChangeCharactersInRange = YES;
        NSCharacterSet *digitsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789+"];
        NSString *digitsString = @"";
        for (NSInteger index = 0; index < string.length; index++) { // Clear any unwanted characters
            char character = [string characterAtIndex:index];
            if ([digitsCharacterSet characterIsMember:character]) {
                digitsString = [digitsString stringByAppendingFormat:@"%c", character];
            }
        }
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:digitsString];
        if (string.length > 0) {
            if (digitsString.length < 1) {
                return NO;
            }
            if (range.location >= textField.text.length) {
                [self.formatter clear];
                textField.text = [self.formatter inputString:newString];
                shouldChangeCharactersInRange = NO;
            }
        }
        BOOL tryingToDeleteWhiteSpace = (string.length == 0) && ([[textField.text substringWithRange:range] isEqualToString:@" "]);
        NSError *error = nil;
        self.phoneNumber = [self.util parse:newString defaultRegion:[NSLocale currentLocale].localeIdentifier error:&error];
        if (!error) {
            if ([self.util isValidNumber:self.phoneNumber]) {
                NSString *formattedPhoneNumberString = [self.util format:self.phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&error];
                if (!error) {
                    textField.text = formattedPhoneNumberString;
                    if (newString.length == formattedPhoneNumberString.length) {
                        UITextPosition *position = [textField positionFromPosition:[textField beginningOfDocument] offset:(range.location + string.length)];
                        [textField setSelectedTextRange:[textField textRangeFromPosition:position toPosition:position]];
                    } else if ((newString.length == (formattedPhoneNumberString.length - 1)) && tryingToDeleteWhiteSpace) {
                        UITextPosition *position = [textField positionFromPosition:[textField beginningOfDocument] offset:(range.location)];
                        [textField setSelectedTextRange:[textField textRangeFromPosition:position toPosition:position]];
                    }
                    [self didChangeEditing:textField]; // Manually call -didChangeEditing: as it won't be called when NO is returned from this method
                    return NO;
                }
            }
        }
        if (!shouldChangeCharactersInRange) {
            [self didChangeEditing:textField]; // Manually call -didChangeEditing: as it won't be called when NO is returned from this method
        }
        return shouldChangeCharactersInRange;
    }
    return YES;
}

@end
