//
//  MBReachabilityManager.m
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBReachabilityManager.h"
#import "Reachability.h"

static NSString *const HOST = @"bitly.com";

@implementation MBReachabilityManager

+ (MBReachabilityManager *)sharedManager
{
    static MBReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (BOOL)isReachable
{
    return [[[MBReachabilityManager sharedManager] reachability] isReachable];
}

- (BOOL)isUnreachable
{
    return ![[[MBReachabilityManager sharedManager] reachability] isReachable];
}

- (BOOL)isReachableViaWWAN
{
    return [[[MBReachabilityManager sharedManager] reachability] isReachableViaWWAN];
}

- (BOOL)isReachableViaWiFi
{
    return [[[MBReachabilityManager sharedManager] reachability] isReachableViaWiFi];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.reachability = [Reachability reachabilityWithHostname:HOST];
    }
    return self;
}

- (void)startWatchingNetwork
{
    // If we aren't already watching, start doing so
    if (!self.isWatching) {
        [self.reachability startNotifier];
        self.isWatching = YES;
    }
}


@end
