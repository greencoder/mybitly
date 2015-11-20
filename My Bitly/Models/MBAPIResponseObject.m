//
//  MBAPIResponseObject.m
//  My Bitly
//
//  Created by Scott Newman on 11/20/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import "MBAPIResponseObject.h"

static NSString *const MB_API_ERROR_DOMAIN = @"MBAPIErrorDomain";

@implementation MBAPIResponseObject

- (instancetype)init
{
    self = [super init];
    DDLogError(@"You should be using initWithResponseObject:");
    return self;
}

- (instancetype)initWithResponseObject:(id)responseObject httpResponse:(NSHTTPURLResponse *)response
{
    self = [super init];
    if (self)
    {
        // Most of the time, the response will be JSON, but we can't be sure
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *jsonDict = (NSDictionary *)responseObject;
            
            // Make sure data, status_code, and status_txt are present
            if (!jsonDict[@"data"] || !jsonDict[@"status_code"] || !jsonDict[@"status_txt"])
            {
                NSString *errorMsg = @"The response JSON was missing data, status_code, or status_txt";
                DDLogError(errorMsg, nil);
                NSError *error = [NSError errorWithDomain:MB_API_ERROR_DOMAIN
                                                     code:MBAPIResponseErrorIncompleteJSON
                                                 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
                self.error = error;
                self.statusText = @"";
                self.apiStatusCode = -1;
            }
            
            // We had good keys in the JSON

            else
            {
                self.error = nil;
                self.statusText = jsonDict[@"status_txt"];
                self.apiStatusCode = [jsonDict[@"status_code"] integerValue];
                self.dataDict = jsonDict[@"data"];
            }
            
        }
        
        self.httpStatusCode = response.statusCode;
        self.mimeType = response.allHeaderFields[@"Content-Type"];

    }
    return self;
}

@end
