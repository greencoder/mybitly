//
//  MBLinkDetailViewController.h
//  My Bitly
//
//  Created by Scott Newman on 11/18/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBLinkEntry.h"

@interface MBLinkDetailViewController : UITableViewController

@property (nonatomic, strong) MBLinkEntry *linkEntry;

@end
