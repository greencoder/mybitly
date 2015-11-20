//
//  MBAddLinkViewController.m
//  My Bitly
//
//  Created by Scott Newman on 11/18/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBAddLinkViewController.h"
#import "MBAPIManager.h"

#import "MMKeychain.h"
#import "SVProgressHUD.h"

@interface MBAddLinkViewController ()

@property (nonatomic, weak) IBOutlet UIView *entryBGView;
@property (nonatomic, weak) IBOutlet UIView *successBGView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *successViewTopConstraint;

@end

@implementation MBAddLinkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Disable the shorten button by default
    [self toggleShortenButton];

    // Set the focus to the link field
    [self.linkEntryField becomeFirstResponder];

    // Make sure the background views don't have a bg color
    // (we set one in IB for clarity at design time)
    self.entryBGView.backgroundColor = [UIColor clearColor];
    self.successBGView.backgroundColor = [UIColor clearColor];

    // Hide the done button to start
    [self makeDoneButtonHidden:YES];
    
    // Hide the success view to start
    self.successBGView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Move the success view to the top of the view (we move it
    // down in IB for clarity at design-time)
    self.successViewTopConstraint.constant = 0;
}

- (void)makeCancelButtonHidden:(BOOL)hidden
{
    if (hidden) {
        self.cancelButton.enabled = NO;
        self.cancelButton.tintColor = [UIColor clearColor];
    }
    else {
        self.cancelButton.enabled = YES;
        self.cancelButton.tintColor = [UIColor blackColor];
    }
}

- (void)makeDoneButtonHidden:(BOOL)hidden
{
    if (hidden) {
        self.doneButton.enabled = NO;
        self.doneButton.tintColor = [UIColor clearColor];
    }
    else {
        self.doneButton.enabled = YES;
        self.doneButton.tintColor = [UIColor blackColor];
    }
}


#pragma mark - UI Methods

- (IBAction)didPressCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressDoneButton:(id)sender
{
    [self.delegate didAddLink];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressShortenButton:(id)sender
{
    if ([self stringIsValidURL:self.linkEntryField.text])
    {
        DDLogVerbose(@"Link is a valid URL");
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"Shortening Link"];

        // Get the access token from the keychain
        NSString *token = [MMKeychain stringForKey:@"authToken"];
        
        MBAPIManager *manager = [MBAPIManager sharedManager];
        [manager saveLinkWithToken:token linkString:self.linkEntryField.text completion:^(NSString *newLink, MBAPILinkSaveResponse linkSaveResponse, NSError *error) {
            
            if (linkSaveResponse == MBAPILinkSaveResponseOk)
            {
                // Hide the progress HUD
                [SVProgressHUD dismissWithDelay:0.25];

                // Assign the new link to the label
                self.linkNewField.text = newLink;
                
                // Show the done button, hide the cancel button
                [self makeCancelButtonHidden:YES];
                [self makeDoneButtonHidden:NO];
                
                // Hide the entry view
                self.entryBGView.hidden = YES;
                
                // Show the success view
                self.successBGView.alpha = 0.0;
                self.successBGView.hidden = NO;
                
                // Fade in the success view
                [UIView animateWithDuration:0.25 animations:^{
                    self.successBGView.alpha = 1.0;
                }];
                
            }
            
            else if (linkSaveResponse == MBAPILinkSaveResponseAlreadyExists) {
                [SVProgressHUD showErrorWithStatus:@"Error! That link already exists."];
            }
            else if (linkSaveResponse == MBAPILinkSaveResponseInvalidURI) {
                [SVProgressHUD showErrorWithStatus:@"Error! Invalid link."];
            }
            else if (linkSaveResponse == MBAPILinkSaveResponseNon200 || linkSaveResponse == MBAPILinkSaveResponseNotOk) {
                [SVProgressHUD showErrorWithStatus:@"An error occurred. Link was not saved."];
            }
            else if (linkSaveResponse == MBAPILinkSaveResponseNetworkError) {
                [SVProgressHUD showErrorWithStatus:@"Connection error. Please check your network connection."];
            }
            else {
                [SVProgressHUD dismiss];
            }
            
        }];
    
    }
    else
    {
        DDLogError(@"Link is not a valid URL");
        NSString *alertMessage = @"The link you entered does not appear to be valid.";
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Invalid Link"
                                              message:alertMessage
                                              preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)toggleShortenButton
{
    // If the length of either text field is zero, disable the button
    if (self.linkEntryField.text.length == 0)
    {
        self.shortenButton.enabled = NO;
        self.shortenButton.alpha = 0.3f;
    }
    else
    {
        self.shortenButton.enabled = YES;
        self.shortenButton.alpha = 1.0f;
    }
}

#pragma mark - Validation Methods

- (BOOL)stringIsValidURL:(NSString *)string
{
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:string];
}

#pragma mark - UITextFieldDelegate Methods

- (IBAction)editingChanged:(UITextField *)textField
{
    [self toggleShortenButton];
}

@end
