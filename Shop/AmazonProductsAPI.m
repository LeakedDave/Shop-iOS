//
//  AmazonProductsAPI.m
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "AmazonProductsAPI.h"
#import "RWMAmazonProductAdvertisingManager.h"
#import <CommonCrypto/CommonHMAC.h>
#import <XMLDictionary/XMLDictionary.h>


static NSString *AWS_ACCESS_KEY = @"AKIAJQDFUCVUAUN4QDKA";
static NSString *AWS_SECRET_KEY = @"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";
static NSString *ASSOCIATE_TAG = @"whialaclo-20";
static NSString *ENDPOINT = @"webservices.amazon.com";
static NSString *URI = @"/onca/xml";


@implementation AmazonProductsAPI


/**
 Get the shared Instance of the AmazonProductsAPI
 @return AmazonProductsAPI instance
 */
+ (AmazonProductsAPI *)sharedInstance {
    static AmazonProductsAPI *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AmazonProductsAPI alloc] init];
    });
    return sharedInstance;
}


- (void)fetchAllProducts {
    NSDictionary *requestParams = @{@"Keywords":@"Featured"};
    
    [self requestWithParams:requestParams];
}

- (void)searchProducts:(NSString *)q {
    NSDictionary *requestParams = @{@"Keywords":q};
    
    [self requestWithParams:requestParams];
}


/**
 Generates a signature using the AWS Key for the request
 @param input NSString to sign
 @return NSString signature
 */
- (void)requestWithParams:(NSDictionary *)requestParams {
    // Prepare parameters
       NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"Service"] = @"AWSECommerceService";
    params[@"Operation"] = @"ItemSearch";
    params[@"AssociateTag"] = ASSOCIATE_TAG;
    params[@"SearchIndex"] = @"All";
    params[@"ResponseGroup"] = @"Images,ItemAttributes,Offers,EditorialReview";
    for (NSString *key in requestParams) {
        params[key] = [requestParams objectForKey:key];
    }
    
    // Fetch products from Amazon
    RWMAmazonProductAdvertisingManager *manager = [[RWMAmazonProductAdvertisingManager alloc] initWithAccessKeyID:AWS_ACCESS_KEY secret:AWS_SECRET_KEY];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    [manager enqueueRequestOperationWithMethod:@"GET" parameters:[params copy] success:^(id responseObject) {
        // Parse the XML Response into a Dictionary
        NSDictionary *responseDict = [[[XMLDictionaryParser alloc] init] dictionaryWithParser:responseObject];
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:responseDict options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"%@",myString);
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

@end
