//
//  MBLinkDetailViewController.m
//  My Bitly
//
//  Created by Scott Newman on 11/18/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBLinkDetailViewController.h"
#import "MBAPIManager.h"

@interface MBLinkDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *shortenedLabel;
@property (nonatomic, weak) IBOutlet UILabel *urlLongLabel;
@property (nonatomic, weak) IBOutlet UILabel *urlShortLabel;
@property (nonatomic, weak) IBOutlet UILabel *weekClicksLabel;
@property (nonatomic, weak) IBOutlet UILabel *monthClicksLabel;

@end

@implementation MBLinkDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Link Detail";
    
    // Load the auth token
    NSString *authToken = [[MBAPIManager sharedManager] loadAccessToken];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM dd, YYYY";
    self.shortenedLabel.text = [dateFormatter stringFromDate:self.linkEntry.createdAt];
    
    // Some link entries will not have a title, so make sure we display
    // a default "No title saved" value if that happens
    if ([self.linkEntry.title isEqualToString:@""]) {
        self.titleLabel.text = @"No title saved";
        self.titleLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        self.titleLabel.text = self.linkEntry.title;
        self.titleLabel.textColor = [UIColor blackColor];
    }
    
    self.urlLongLabel.text = self.linkEntry.longLink;
    self.urlShortLabel.text = self.linkEntry.link;
    
    MBAPIManager *manager = [MBAPIManager sharedManager];

    // Fetch the number of clicks this week
    [manager fetchLinkClickCountWithToken:authToken link:self.linkEntry.link period:MBAPILinkClickPeriodWeek units:1 completion:^(NSUInteger clickCount, NSError *error) {
        // If there was an error, just display "Unavailable"
        if (error || clickCount == -1)
            self.weekClicksLabel.text = @"This week: Unavailable";
        else
            self.weekClicksLabel.text = [NSString stringWithFormat:@"This week: %lu", clickCount];
    }];

    // Fetch the number of clicks this month
    [manager fetchLinkClickCountWithToken:authToken link:self.linkEntry.link period:MBAPILinkClickPeriodMonth units:1 completion:^(NSUInteger clickCount, NSError *error) {
        // If there was an error, just display "Unavailable"
        if (error || clickCount == -1)
            self.monthClicksLabel.text = @"This month: Unavailable";
        else
            self.monthClicksLabel.text = [NSString stringWithFormat:@"This month: %lu", clickCount];
    }];
    
}

- (IBAction)didPressActionButton:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose an Action"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Copy Short Link to Clipboard"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              DDLogVerbose(@"Copying link to pasteboard");
                                                              UIPasteboard *pb = [UIPasteboard generalPasteboard];
                                                              [pb setString:self.linkEntry.link];
                                                          }];

    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Open in Safari"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               DDLogVerbose(@"Opening Link in Safari");
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.linkEntry.link]];
                                                           }];

    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               DDLogVerbose(@"Cancel Pressed");
                                                           }];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}

@end
