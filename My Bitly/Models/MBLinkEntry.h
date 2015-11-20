//
//  MBLinkEntry.h
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBLinkEntry : NSObject

@property (nonatomic, assign) BOOL isArchived;
@property (nonatomic, assign) BOOL isPrivate;

@property (nonatomic, strong) NSString *aggregateLink;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *keywordLink;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *longLink;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) long createdTS;
@property (nonatomic, assign) long modifiedTS;
@property (nonatomic, assign) long userTS;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *modifiedAt;

- (instancetype)initWithJSONDict:(NSDictionary *)jsonDict;

@end
