//
//  MBUnderlinedTextField.m
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBUnderlinedTextField.h"

@interface MBUnderlinedTextField ()
@property (nonatomic, strong) UIView *lineView;
@end

@implementation MBUnderlinedTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.layer.masksToBounds = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.lineView == nil)
    {
        self.lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.lineView setBackgroundColor:[UIColor colorWithRed:0.78 green:0.78 blue:0.81 alpha:0.5]];
        [self addSubview:self.lineView];
    }

    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat onePixelHeight = 2.0f / [[UIScreen mainScreen] scale];

    self.lineView.frame = CGRectMake(0, height+5, width, onePixelHeight);
    
}

@end
