//
//  MBLinkTableViewCell.h
//  My Bitly
//
//  Created by Scott Newman on 11/18/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBLinkTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *shortenedLabel;

@end
