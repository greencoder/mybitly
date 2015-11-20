//
//  MBAPIResponseObject.h
//  My Bitly
//
//  Created by Scott Newman on 11/20/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MBAPIResponseError) {
    MBAPIResponseErrorUnknown = 0,
    MBAPIResponseErrorWasEmpty,
    MBAPIResponseErrorMalformedJSON,
    MBAPIResponseErrorIncompleteJSON,
    MBAPIResponseErrorNetworkError,
    MBAPIResponseErrorNon200,
    MBAPIResponseErrorInvalidToken,
};

@interface MBAPIResponseObject : NSObject

@property (nonatomic, assign) NSInteger apiStatusCode;
@property (nonatomic, assign) NSInteger httpStatusCode;

@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) NSString *statusText;
@property (nonatomic, strong) NSString *mimeType;

@property (nonatomic, strong) NSError *error;

- (instancetype)initWithResponseObject:(id)responseObject httpResponse:(NSHTTPURLResponse *)response;

@end
