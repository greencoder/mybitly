//
//  MBAddLinkViewController.h
//  My Bitly
//
//  Created by Scott Newman on 11/18/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBAddLinkDelegate
- (void)didAddLink;
@end

@interface MBAddLinkViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *linkEntryField;
@property (nonatomic, weak) IBOutlet UITextField *linkNewField;
@property (nonatomic, weak) IBOutlet UIButton *shortenButton;

@property (nonatomic, weak) id<MBAddLinkDelegate> delegate;

@end
