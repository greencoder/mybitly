//
//  My_BitlyTests.m
//  My BitlyTests
//
//  Created by Scott Newman on 11/19/15.
//  Copyright © 2015 Newman Creative. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MBAPIManager.h"
#import "MBAPIResponseObject.h"
#import "MBLinkEntry.h"

#define _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_ 1

#define ACCESS_TOKEN @"9999999999999999999999999999999999999999"
#define USERNAME @"gooduser"
#define PASSWORD @"goodpass"

@interface My_BitlyTests : XCTestCase
@property (nonatomic, strong) MBAPIManager *manager;
@end

@implementation My_BitlyTests

- (void)setUp
{
    [super setUp];
    _manager = [MBAPIManager sharedManager];
    _manager.isDebuggingMode = YES;
}

- (void)testLogins
{
    // Test good login
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Good Login"];
    [self.manager loginWithUsername:USERNAME password:PASSWORD completion:^(NSString *token, NSError *error) {
        XCTAssertTrue([token isEqualToString:ACCESS_TOKEN]);
        NSLog(@"Token: %@", token);
        XCTAssertNil(error);
        [expectation1 fulfill];
    }];

    // Test bad login
     XCTestExpectation *expectation2 = [self expectationWithDescription:@"Bad Login"];
    [self.manager loginWithUsername:@"BAD" password:@"BAD" completion:^(NSString *token, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, MBAPILoginResponseInvalidLogin);
        [expectation2 fulfill];
    }];

    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];

}

- (void)testLinkEntryLoadJSON
{
    NSDictionary *jsonDict = @{
                           @"aggregate_link": @"http://bit.ly/1NG4gKL",
                           @"archived": @"0",
                           @"campaign_ids": @[],
                           @"keyword_link": @"foo",
                           @"client_id": @"a5e8cebb233c5d07e5c553e917dffb92fec5264d",
                           @"created_at": @(1447982274),
                           @"link": @"http://bit.ly/1NG4gKK",
                           @"long_url": @"http://www.google.com/sports/",
                           @"modified_at": @(1447982276),
                           @"private": @"1",
                           @"tags": @[],
                           @"title": @"foo title",
                           @"user_ts": @(1447982276),
                           };
    
    MBLinkEntry *linkEntry = [[MBLinkEntry alloc] initWithJSONDict:jsonDict];
    
    XCTAssertTrue([linkEntry.aggregateLink isEqualToString:@"http://bit.ly/1NG4gKL"]);
    XCTAssertTrue([linkEntry.clientID isEqualToString:@"a5e8cebb233c5d07e5c553e917dffb92fec5264d"]);
    XCTAssertTrue([linkEntry.keywordLink isEqualToString:@"foo"]);
    XCTAssertTrue([linkEntry.link isEqualToString:@"http://bit.ly/1NG4gKK"]);
    XCTAssertTrue([linkEntry.longLink isEqualToString:@"http://www.google.com/sports/"]);
    XCTAssertTrue([linkEntry.title isEqualToString:@"foo title"]);
    
    XCTAssertFalse(linkEntry.isArchived);
    XCTAssertTrue(linkEntry.isPrivate);
    
    XCTAssertEqual(linkEntry.createdTS, 1447982274);
    XCTAssertEqual(linkEntry.modifiedTS, 1447982276);
    XCTAssertEqual(linkEntry.userTS, 1447982276);
    
    XCTAssertTrue([linkEntry.createdAt isKindOfClass:[NSDate class]]);
    XCTAssertTrue([linkEntry.modifiedAt isKindOfClass:[NSDate class]]);
}

- (void)testLinkHistory
{
    // Test good access token
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Good token for history"];
    [self.manager fetchLinkHistoryWithToken:ACCESS_TOKEN completion:^(NSArray *links, NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue([links isKindOfClass:[NSArray class]]);
        [expectation1 fulfill];
    }];
    
    // Test bad access token
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Bad token for history"];
    [self.manager fetchLinkHistoryWithToken:@"BAD" completion:^(NSArray *links, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertNil(links);
        XCTAssertEqual(error.code, MBAPIResponseErrorInvalidToken);
        [expectation2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testLinkClickCount
{
    // Test good access token
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Good click count"];
    [self.manager fetchLinkClickCountWithToken:ACCESS_TOKEN
                                          link:@"http://foo.com"
                                        period:MBAPILinkClickPeriodDay
                                         units:30
                                    completion:^(NSUInteger clickCount, NSError *error)
    {
        XCTAssertNil(error);
        XCTAssertEqual(clickCount, 1);
        [expectation1 fulfill];
    }];
    
    // Test bad access token
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Bad click count"];
    [self.manager fetchLinkClickCountWithToken:@"BAD"
                                          link:@"http://foo.com"
                                        period:MBAPILinkClickPeriodDay
                                         units:30
                                    completion:^(NSUInteger clickCount, NSError *error)
     {
         XCTAssertNotNil(error);
         XCTAssertEqual(error.code, MBAPIResponseErrorInvalidToken);
         XCTAssertEqual(clickCount, -1);
         [expectation2 fulfill];
     }];
    
    // Test bad link
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"Bad click, missing link"];
    [self.manager fetchLinkClickCountWithToken:ACCESS_TOKEN
                                          link:@"http://bar.com"
                                        period:MBAPILinkClickPeriodDay
                                         units:30
                                    completion:^(NSUInteger clickCount, NSError *error)
     {
         XCTAssertNotNil(error);
         XCTAssertEqual(error.code, MBAPILinkClickResponseNotFound);
         XCTAssertEqual(clickCount, -1);
         [expectation3 fulfill];
     }];
    
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void)testLinkSave
{
    // Test bad access token
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Bad token for save"];
    [self.manager saveLinkWithToken:@"BAD" linkString:@"http://foo.com/1" completion:^(NSString *newLink, MBAPILinkSaveResponse saveResponse, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(saveResponse, MBAPILinkSaveResponseNotOk);
        XCTAssertNil(newLink);
        XCTAssertEqual(error.code, MBAPIResponseErrorInvalidToken);
        [expectation1 fulfill];
    }];
    
    // Test link already exists
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Link exists already for save"];
    [self.manager saveLinkWithToken:ACCESS_TOKEN linkString:@"http://foo.com/2" completion:^(NSString *newLink, MBAPILinkSaveResponse saveResponse, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(saveResponse, MBAPILinkSaveResponseAlreadyExists);
        XCTAssertNil(newLink);
        XCTAssertEqual(error.code, MBAPILinkSaveResponseAlreadyExists);
        [expectation2 fulfill];
    }];

    // Test malformed URI
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"Link malformed for save"];
    [self.manager saveLinkWithToken:ACCESS_TOKEN linkString:@"http://foo/3" completion:^(NSString *newLink, MBAPILinkSaveResponse saveResponse, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(saveResponse, MBAPILinkSaveResponseInvalidURI);
        XCTAssertNil(newLink);
        XCTAssertEqual(error.code, MBAPILinkSaveResponseInvalidURI);
        [expectation3 fulfill];
    }];
    
    // Test good save
    XCTestExpectation *expectation4 = [self expectationWithDescription:@"Link malformed for save"];
    [self.manager saveLinkWithToken:ACCESS_TOKEN linkString:@"http://foo.com/1" completion:^(NSString *newLink, MBAPILinkSaveResponse saveResponse, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqual(saveResponse, MBAPILinkSaveResponseOk);
        XCTAssertTrue([newLink isEqualToString:@"http://foo.it/abc123"]);
        [expectation4 fulfill];
    }];

    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
