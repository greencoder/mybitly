//
//  ViewController.m
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBAddLinkViewcontroller.h"
#import "MBLinkTableViewCell.h"
#import "MBLoginViewController.h"
#import "MBRootViewController.h"
#import "MBLinkDetailViewController.h"

#import "SVProgressHUD.h"

#import "MBAPIManager.h"
#import "MBAPIResponseObject.h"

#import "MBLinkEntry.h"
#import "MBAPIResponseObject.h"

@interface MBRootViewController () <MBAddLinkDelegate>

@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *authToken;

@end


@implementation MBRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Prepare the date formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"MMM dd, YYYY";
    _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    // Initialize the default array
    _links = @[];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Load the auth token from the keychain
    self.authToken = [[MBAPIManager sharedManager] loadAccessToken];;

    // If we don't have a stored access token, we aren't logged in. If
    // we do, load the links
    if (self.authToken == nil)
        [self showLoginPage];
    else
        [self loadLinks];

}

- (void)loadLinks
{
    // Show the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    MBAPIManager *manager = [MBAPIManager sharedManager];
    
    [manager fetchLinkHistoryWithToken:self.authToken completion:^(NSArray *links, NSError *error) {
        
        // Hide the refresh control (in case it's showing)
        [[self refreshControl] endRefreshing];
        
        // Stop the network activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // If no error, we got a good response
        if (error == nil)
        {
            // Save the response and reload the table view
            self.links = links;
            
            // Make sure the reload data call is on the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        // See if we got an invalid token response
        else if (error && error.code == MBAPIResponseErrorInvalidToken)
        {
            [self showLoginPage];
        }
        
        // Another error occurred
        else
        {
            [SVProgressHUD showErrorWithStatus:@"An error occurred. Please try again later."];
        }

    }];

}

- (void)showLoginPage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavController"];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UI Methods

- (IBAction)didRefresh:(id)sender
{
    [self loadLinks];
}

- (IBAction)logoutButtonPressed:(id)sender
{
    [self showLoginPage];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.links.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell" forIndexPath:indexPath];

    MBLinkEntry *linkEntry = self.links[indexPath.row];
    
    // Show the title if we have one
    if (![linkEntry.title isEqualToString:@""])
        cell.titleLabel.text = linkEntry.title;
    else
        cell.titleLabel.text = linkEntry.longLink;

    // Use the "Shortened At" date as the subtitle
    NSString *shortened = [self.dateFormatter stringFromDate:linkEntry.createdAt];
    cell.shortenedLabel.text = [NSString stringWithFormat:@"Shortened %@", shortened];
 
    return cell;
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddLinkSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        MBAddLinkViewController *destinationVC = navController.childViewControllers.firstObject;
        destinationVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"DetailSegue"])
    {
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        MBLinkDetailViewController *destinationVC = segue.destinationViewController;
        destinationVC.linkEntry = self.links[selectedIndexPath.row];
    }
}


#pragma mark - MBAddLinkDelegate methods

- (void)didAddLink
{
    DDLogVerbose(@"We added a link. Reloading the links.");
    [self loadLinks];
}


@end
