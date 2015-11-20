//
//  MBReachabilityManager.h
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface MBReachabilityManager : NSObject

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, assign) BOOL isWatching;

+ (MBReachabilityManager *)sharedManager;

- (BOOL)isReachable;
- (BOOL)isUnreachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;
- (void)startWatchingNetwork;

@end
