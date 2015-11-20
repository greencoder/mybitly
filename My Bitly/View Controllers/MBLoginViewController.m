//
//  MBLoginViewController.m
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBLoginViewController.h"
#import "MBAPIManager.h"
#import "SVProgressHUD.h"

@interface MBLoginViewController () <UITextFieldDelegate>

@end

@implementation MBLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Delete any stored token - if we have never logged in, it
    // will be blank anyway. If the user is logging out, we can
    // show the login page and this will destroy any saved tokens
    [[MBAPIManager sharedManager] removeAccessToken];

    // The signin button should be disabled by default
    [self toggleSigninButton];
    
    // Set the focus to the link field
    [self.usernameField becomeFirstResponder];
}

- (void)toggleSigninButton
{
    // If the length of either text field is zero, disable the button
    if (self.usernameField.text.length == 0 || self.passwordField.text.length == 0)
    {
        self.loginButton.enabled = NO;
        self.loginButton.alpha = 0.3f;
    }
    else
    {
        self.loginButton.enabled = YES;
        self.loginButton.alpha = 1.0f;
    }
}

#pragma mark - UITextFieldDelegate Methods

- (IBAction)editingChanged:(UITextField *)textField
{
    [self toggleSigninButton];
}

#pragma mark - UI Methods

- (IBAction)didPressSigninButton:(id)sender
{
    MBAPIManager *apiManager = [MBAPIManager sharedManager];

    // Show the progress hud
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Logging In"];
    
    [apiManager loginWithUsername:self.usernameField.text
                         password:self.passwordField.text
                       completion:^(NSString *token, NSError *error)
    {
        if (error == nil && token)
        {
            [SVProgressHUD dismiss];
            DDLogInfo(@"Successful Login");
            
            // Save the credentials in the keychain
            [[MBAPIManager sharedManager] saveAccessToken:token];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if (error && error.code == MBAPILoginResponseInvalidLogin)
        {
            DDLogError(@"Login Error: %@", error);
            [SVProgressHUD showErrorWithStatus:@"Invalid Login"];
        }
        else
        {
            DDLogError(@"An error occurred during login: %@", error.description);
            [SVProgressHUD showErrorWithStatus:@"An error occurred. Please try again."];
        }
        
    }];
    
}

@end
