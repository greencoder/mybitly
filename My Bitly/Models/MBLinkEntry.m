//
//  MBLinkEntry.m
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBLinkEntry.h"

@implementation MBLinkEntry

- (instancetype)init
{
    self = [super init];
    DDLogError(@"You should be using initWithJSONDict for MBLinkEntry objects");
    return self;
}

- (instancetype)initWithJSONDict:(NSDictionary *)jsonDict
{
    self = [super init];
    if (self)
    {
        self.aggregateLink = jsonDict[@"aggregate_link"];
        self.clientID = jsonDict[@"client_id"];
        self.keywordLink = jsonDict[@"keyword_link"];
        self.link = jsonDict[@"link"];
        self.longLink = jsonDict[@"long_url"];
        self.title = jsonDict[@"title"];
        
        self.isArchived = [jsonDict[@"archived"] boolValue];
        self.isPrivate = [jsonDict[@"private"] boolValue];
        
        self.createdTS = [jsonDict[@"created_at"] longValue];
        self.modifiedTS = [jsonDict[@"modified_at"] longValue];
        self.userTS = [jsonDict[@"user_ts"] longValue];
        
        self.createdAt = [NSDate dateWithTimeIntervalSince1970:self.createdTS];
        self.modifiedAt = [NSDate dateWithTimeIntervalSince1970:self.modifiedTS];

    }
    return self;
}

- (NSString *)description
{
    return self.link;
}

@end
