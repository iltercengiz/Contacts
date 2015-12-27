//
//  AddContactViewController.m
//  Contacts
//
//  Created by Ilter Cengiz on 20/12/2015.
//  Copyright © 2015 Ilter Cengiz. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactRepresentation.h"
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
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UnwindAddContactSegue"]) {
        [self.view endEditing:YES]; // Resign all responders
    }
}

#pragma mark - IBAction

- (IBAction)didTapSaveBarButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addContactViewController:didAddContact:)]) {
        [self.delegate addContactViewController:self didAddContact:self.contactRepresentation];
    }
    [self performSegueWithIdentifier:@"UnwindAddContactSegue" sender:sender];
}

- (IBAction)didChangeEditing:(id)sender {
    // Update contactRepresentation
    if (sender == self.firstNameTextField) {
        self.contactRepresentation.firstName = self.firstNameTextField.text;
    } else if (sender == self.lastNameTextField) {
        self.contactRepresentation.lastName = self.lastNameTextField.text;
    } else if (sender == self.phoneNumberTextField) {
        self.contactRepresentation.phoneNumber = [self.util format:self.phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
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

#pragma mark - Getter

- (NBPhoneNumberUtil *)util {
    if (!_util) {
        _util = [NBPhoneNumberUtil new];
    }
    return _util;
}

- (NBAsYouTypeFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:[NSLocale currentLocale].localeIdentifier];
    }
    return _formatter;
}

#pragma mark - Private methods

- (void)updateSaveBarButtonStateIfNeeded {
    BOOL shouldEnable = YES;
    shouldEnable &= (self.firstNameTextField.text.length > 0);
    shouldEnable &= (self.lastNameTextField.text.length > 0);
    shouldEnable &= (self.phoneNumberTextField.text.length > 0);
    shouldEnable &= [self.util isValidNumber:self.phoneNumber];
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
