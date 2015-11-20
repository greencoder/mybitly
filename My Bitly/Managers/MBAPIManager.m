//
//  MBAPIManager.m
//  My Bitly
//
//  Created by Scott Newman on 11/17/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

#import "MBAPIManager.h"
#import "MBReachabilityManager.h"

#import "MBLinkEntry.h"
#import "MBAPIResponseObject.h"

#import "MMKeychain.h"

// Used when declaring custom errors inside our manager
static NSString *const MB_ERROR_DOMAIN = @"MBAPIManagerErrorDomain";

@interface MBAPIManager ()

@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic, strong) NSURLSession *session;

@end


@implementation MBAPIManager

+ (MBAPIManager *)sharedManager
{
    static MBAPIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MBAPIManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:_sessionConfig];
        
        // The return queue is the main queue by default. It can be overridden
        // if necessary and the API calls will return on it
        _returnQueue = dispatch_get_main_queue();
        
        // By default, we are not in debugging mode (this can be overridden
        // in our unit tests)
        _isDebuggingMode = NO;
    }
    return self;
}

#pragma mark - Auth Methods

- (NSString *)loadAccessToken
{
    NSString *token = [MMKeychain stringForKey:@"authToken"];
    return token;
}

- (BOOL)saveAccessToken:(NSString *)token
{
    return [MMKeychain setString:token forKey:@"authToken"];
}

- (BOOL)removeAccessToken
{
    return [MMKeychain deleteStringForKey:@"authToken"];
}

- (NSString *)urlBase
{
    if (_isDebuggingMode)
        return @"http://localhost:5000";
    else
        return @"https://api-ssl.bitly.com";
}

#pragma mark - Bitly API Methods

- (NSError *)reachabilityError
{
    NSString *errorMsg = @"The network was not reachable";
    NSError *connectionError = [NSError errorWithDomain:MB_ERROR_DOMAIN
                                                   code:MBAPIResponseErrorNetworkError
                                               userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
    return connectionError;
}

- (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)errorCode
{
    NSError *error = [NSError errorWithDomain:MB_ERROR_DOMAIN
                                                   code:errorCode
                                               userInfo:@{NSLocalizedDescriptionKey:message}];
    return error;
}

- (AFHTTPRequestOperationManager *)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void(^)(NSString *token, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"%@/oauth/access_token", self.urlBase];
    
    // Make sure the network is reachable before continuing
    if (![[MBReachabilityManager sharedManager] isReachable])
    {
        NSError *connectionError = [self reachabilityError];
        DDLogError(@"%@", connectionError.description);
        dispatch_async(self.returnQueue, ^{
            completion(nil, connectionError);
        });
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // This is required because the API can return a non-JSON response for success
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", nil];

    // Use Basic Auth
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    [manager POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        MBAPIResponseObject *apiResponse = [[MBAPIResponseObject alloc] initWithResponseObject:responseObject
                                                                                  httpResponse:operation.response];
        
        // If the returned content type is application/json, there's a login error
        if ([apiResponse.mimeType hasPrefix:@"application/json"])
        {
            NSError *error = [self errorWithMessage:@"The Login API returned a failure"
                                               code:MBAPILoginResponseInvalidLogin];
            DDLogError(error.description, nil);
            dispatch_async(self.returnQueue, ^{
                completion(nil, error);
            });
            return;
        }

        // Good responses from the login API arrive as text/plain
        else if ([apiResponse.mimeType isEqualToString:@"text/plain; charset=utf-8"])
        {
            NSString *token = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            dispatch_async(self.returnQueue, ^{
                completion(token, nil);
            });
            return;
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"The login API returned a failure: %@", error.description);
        dispatch_async(self.returnQueue, ^{
            completion(nil, error);
        });
        return;
    }];

    return manager;
}

- (AFHTTPRequestOperationManager *)saveLinkWithToken:(NSString *)token linkString:(NSString *)linkString completion:(void(^)(NSString *newLink, MBAPILinkSaveResponse saveResponse, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"%@/v3/user/link_save", self.urlBase];
    
    // Make sure the network is reachable before continuing
    if (![[MBReachabilityManager sharedManager] isReachable])
    {
        NSError *connectionError = [self reachabilityError];
        DDLogError(@"%@", connectionError.description);
        dispatch_async(self.returnQueue, ^{
            completion(nil, MBAPILinkSaveResponseNetworkError, connectionError);
        });
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSDictionary *parameters = @{
                                 @"access_token": token,
                                 @"longUrl": linkString,
                                 };
    
    [manager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {

        MBAPIResponseObject *apiResponse = [[MBAPIResponseObject alloc] initWithResponseObject:responseObject
                                                                                  httpResponse:operation.response];
        
        // See if there was an error in the response decoding
        if (apiResponse.error)
        {
            dispatch_async(self.returnQueue, ^{
                completion(nil, MBAPILinkSaveResponseNotOk, apiResponse.error);
            });
            return;
        }
        
        // The response JSON looked okay
        else
        {
            // Return the new link if we had a good save
            if (apiResponse.apiStatusCode == 200)
            {
                NSString *newLink = apiResponse.dataDict[@"link_save"][@"link"];
                dispatch_async(self.returnQueue, ^{
                    completion(newLink, MBAPILinkSaveResponseOk, nil);
                });
                return;
            }

            // See if the link already exists
            else if (apiResponse.apiStatusCode == 304)
            {
                NSError *error = [self errorWithMessage:@"The link already exists"
                                                   code:MBAPILinkSaveResponseAlreadyExists];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(nil, MBAPILinkSaveResponseAlreadyExists, error);
                });
                return;
            }
            
            // See if we got a 403 invalid token
            else if (apiResponse.apiStatusCode == 403 && [apiResponse.statusText isEqualToString:@"INVALID_ACCESS_TOKEN"])
            {
                NSError *error = [self errorWithMessage:@"Invalid Access Token" code:MBAPIResponseErrorInvalidToken];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(nil, MBAPILinkSaveResponseNotOk, error);
                });
                return;
            }

            // Check for an Invalid URI
            else if (apiResponse.apiStatusCode == 500)
            {
                NSError *error = [self errorWithMessage:@"Invalid URI" code:MBAPILinkSaveResponseInvalidURI];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(nil, MBAPILinkSaveResponseInvalidURI, error);
                });
                return;
            }
            
            // Something else went wrong, but we don't know what
            else
            {
                NSError *error = [self errorWithMessage:@"The link was not saved" code:MBAPILinkSaveResponseNotOk];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(nil, MBAPILinkSaveResponseNotOk, error);
                });
                return;
            }

        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        DDLogError(@"The link save API returned a failure");
        dispatch_async(self.returnQueue, ^{
            completion(nil, MBAPILinkSaveResponseNon200, error);
        });
        return;
    }];
    
    return manager;
}

- (AFHTTPRequestOperationManager *)fetchLinkClickCountWithToken:(NSString *)token link:(NSString *)shortLink period:(MBAPILinkClickPeriod)period units:(int)units completion:(void(^)(NSUInteger clickCount, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"%@/v3/link/clicks", self.urlBase];
    
    // Make sure the network is reachable before continuing
    if (![[MBReachabilityManager sharedManager] isReachable])
    {
        NSError *connectionError = [self reachabilityError];
        DDLogError(@"%@", connectionError.description);
        dispatch_async(self.returnQueue, ^{
            completion(-1, connectionError);
        });
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // Turn the enum value into the string value that the API accepts
    NSString *periodName;
    switch (period)
    {
        case MBAPILinkClickPeriodDay:
            periodName = @"day";
            break;
        case MBAPILinkClickPeriodHour:
            periodName = @"hour";
            break;
        case MBAPILinkClickPeriodMinute:
            periodName = @"minute";
            break;
        case MBAPILinkClickPeriodMonth:
            periodName = @"month";
            break;
        case MBAPILinkClickPeriodWeek:
            periodName = @"week";
            break;
        default:
            periodName = @"day";
            break;
    }
    
    NSDictionary *parameters = @{
                                 @"access_token": token,
                                 @"unit": periodName,
                                 @"units": [[NSNumber numberWithInt:units] stringValue],
                                 @"link": shortLink,
                                 };

    [manager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        MBAPIResponseObject *apiResponse = [[MBAPIResponseObject alloc] initWithResponseObject:responseObject
                                                                                  httpResponse:operation.response];
        
        // See if there was an error in the response decoding
        if (apiResponse.error)
        {
            dispatch_async(self.returnQueue, ^{
                completion(-1, apiResponse.error);
            });
            return;
        }

        // The response JSON looked okay
        else
        {
            // Return the click count if we got a 200
            if (apiResponse.apiStatusCode == 200)
            {
                NSInteger clickCount = [apiResponse.dataDict[@"link_clicks"] integerValue];
                dispatch_async(self.returnQueue, ^{
                    completion(clickCount, nil);
                });
                return;
            }
            
            // See if we got a 403 invalid token
            else if (apiResponse.apiStatusCode == 403 && [apiResponse.statusText isEqualToString:@"INVALID_ACCESS_TOKEN"])
            {
                NSError *error = [self errorWithMessage:@"Invalid Access Token" code:MBAPIResponseErrorInvalidToken];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(-1, error);
                });
                return;
            }
            
            // See if we got a 404
            else if (apiResponse.apiStatusCode == 404 && [apiResponse.statusText isEqualToString:@"NOT_FOUND"])
            {
                NSError *error = [self errorWithMessage:@"Invalid Link" code:MBAPILinkClickResponseNotFound];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(-1, error);
                });
                return;
            }
            
            // We didn't get a 200
            else
            {
                NSString *msg = [NSString stringWithFormat:@"Did not recieve a click count: %@", apiResponse.statusText];
                NSError *error = [self errorWithMessage:msg code:MBAPIResponseErrorNon200];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(-1, error);
                });
                return;
            }
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        DDLogError(@"The click count API returned a failure");
        dispatch_async(self.returnQueue, ^{
            completion(-1, error);
        });
        return;
    }];
    
    return manager;
}

- (AFHTTPRequestOperationManager *)fetchLinkHistoryWithToken:(NSString *)token completion:(void(^)(NSArray *links, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"%@/v3/user/link_history", self.urlBase];
    
    // Make sure the network is reachable before continuing
    if (![[MBReachabilityManager sharedManager] isReachable])
    {
        NSError *connectionError = [self reachabilityError];
        DDLogError(@"%@", connectionError.description);
        dispatch_async(self.returnQueue, ^{
            completion(nil, connectionError);
        });
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"access_token": token};

    [manager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        MBAPIResponseObject *apiResponse = [[MBAPIResponseObject alloc] initWithResponseObject:responseObject
                                                                                  httpResponse:operation.response];
        
        // See if there was an error in the response decoding
        if (apiResponse.error)
        {
            dispatch_async(self.returnQueue, ^{
                completion(nil, apiResponse.error);
            });
            return;
        }
        
        // The response JSON looked okay
        else
        {
            // Return the click count if we got a 200
            if (apiResponse.apiStatusCode == 200)
            {
                NSMutableArray *entries = [[NSMutableArray alloc] init];
                
                // Iterate through the response and create entries
                for (NSDictionary *entryDict in apiResponse.dataDict[@"link_history"])
                {
                    MBLinkEntry *entry = [[MBLinkEntry alloc] initWithJSONDict:entryDict];
                    [entries addObject:entry];
                }

                // Return an immutable copy of the array
                NSArray *immutableEntries = [NSArray arrayWithArray:entries];
            
                dispatch_async(self.returnQueue, ^{
                    completion(immutableEntries, nil);
                });
                return;
            }
            
            // See if we got a 403 invalid token
            else if (apiResponse.apiStatusCode == 403 && [apiResponse.statusText isEqualToString:@"INVALID_ACCESS_TOKEN"])
            {
                NSError *error = [self errorWithMessage:@"Invalid Access Token" code:MBAPIResponseErrorInvalidToken];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(nil, error);
                });
                return;
            }
            
            // We got some other response
            else
            {
                NSString *msg = [NSString stringWithFormat:@"Non-200 Status Code: (%lu) %@",
                                 apiResponse.apiStatusCode, apiResponse.statusText];
                NSError *error = [self errorWithMessage:msg code:MBAPIResponseErrorNon200];
                DDLogError(error.description, nil);
                dispatch_async(self.returnQueue, ^{
                    completion(nil, error);
                });
                return;
            }

        }

    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        DDLogError(@"The link history API returned a failure");
        dispatch_async(self.returnQueue, ^{
            completion(nil, error);
        });
        return;
    }];

    return manager;
}


@end
