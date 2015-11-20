//
//  MBAPIManager.h
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager;

/*
typedef NS_ENUM(NSInteger, MBAPIResponseError) {
    MBAPIResponseUnknown = 0,
    MBAPIResponseWasEmpty,
    MBAPIResponseMalformedJSON,
    MBAPIResponseIncompleteJSON,
    MBAPIResponseNetworkError,
    MBAPIResponseNon200,
    MBAPIResponseInvalidToken,
};
*/

typedef NS_ENUM(NSInteger, MBAPILoginResponse) {
    MBAPILoginResponseSuccessfulLogin,
    MBAPILoginResponseInvalidLogin,
};

typedef NS_ENUM(NSInteger, MBAPILinkSaveResponse) {
    MBAPILinkSaveResponseOk,
    MBAPILinkSaveResponseNotOk,
    MBAPILinkSaveResponseInvalidURI,
    MBAPILinkSaveResponseAlreadyExists,
    MBAPILinkSaveResponseNetworkError,
    MBAPILinkSaveResponseNon200,
};

typedef NS_ENUM(NSInteger, MBAPILinkClickResponse) {
    MBAPILinkClickResponseNotFound,
};

typedef NS_ENUM(NSInteger, MBAPILinkClickPeriod) {
    MBAPILinkClickPeriodMinute,
    MBAPILinkClickPeriodHour,
    MBAPILinkClickPeriodDay,
    MBAPILinkClickPeriodWeek,
    MBAPILinkClickPeriodMonth,
};

@interface MBAPIManager : NSObject

@property (nonatomic, assign) dispatch_queue_t returnQueue;
@property (nonatomic, assign) BOOL isDebuggingMode;
@property (nonatomic, readonly) NSString *urlBase;

+ (MBAPIManager *)sharedManager;

- (AFHTTPRequestOperationManager *)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void(^)(NSString *token, NSError *error))completion;
- (AFHTTPRequestOperationManager *)fetchLinkHistoryWithToken:(NSString *)token completion:(void(^)(NSArray *links, NSError *error))completion;
- (AFHTTPRequestOperationManager *)saveLinkWithToken:(NSString *)token linkString:(NSString *)linkString completion:(void(^)(NSString *newLink, MBAPILinkSaveResponse saveResponse, NSError *error))completion;
- (AFHTTPRequestOperationManager *)fetchLinkClickCountWithToken:(NSString *)token link:(NSString *)shortLink period:(MBAPILinkClickPeriod)period units:(int)units completion:(void(^)(NSUInteger clickCount, NSError *error))completion;

- (BOOL)saveAccessToken:(NSString *)token;
- (NSString *)loadAccessToken;
- (BOOL)removeAccessToken;

@end
