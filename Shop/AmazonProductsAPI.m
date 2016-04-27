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

static AFHTTPRequestOperation *currentOperation = nil;

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
 Request products from Amazon
 @param requestParams NSDictionary of Amazon response
 @return NSArray contains Amazon products data
 */
- (NSArray *)parseResponse:(NSDictionary *)responseDict {
    NSMutableArray *responseArray = [[NSMutableArray alloc] init];
    
    if ([responseDict objectForKey:@"Items"] && [[responseDict objectForKey:@"Items"] objectForKey:@"Item"]) {
        NSArray *items = [[responseDict objectForKey:@"Items"] objectForKey:@"Item"];
        
        for (NSDictionary *item in items) {
            // Skip entries that are missing important attributes
            if (![item objectForKey:@"ASIN"]) {
                continue;
            }
            
            if (![item objectForKey:@"ItemAttributes"]) {
                continue;
            }
            
            NSDictionary *itemAttributes = [item objectForKey:@"ItemAttributes"];
            
            if (![itemAttributes objectForKey:@"Title"]) {
                continue;
            }
            
            if (![itemAttributes objectForKey:@"Brand"]) {
                continue;
            }
            
            
            // Make sure there is a lowest new price
            if (![item objectForKey:@"OfferSummary"] || ![[item objectForKey:@"OfferSummary"] objectForKey:@"LowestNewPrice"] || ![[[item objectForKey:@"OfferSummary"] objectForKey:@"LowestNewPrice"] objectForKey:@"FormattedPrice"]) {
                continue;
            }
            
            
            // Setup Amazon product Dictionary
            NSMutableDictionary *amazonProduct = [[NSMutableDictionary alloc] init];
            amazonProduct[@"asin"] = [NSNumber numberWithInt:[[item objectForKey:@"ASIN"] intValue]];
            amazonProduct[@"title"] = [itemAttributes objectForKey:@"Title"];
            amazonProduct[@"price"] = [[[item objectForKey:@"OfferSummary"] objectForKey:@"LowestNewPrice"] objectForKey:@"FormattedPrice"];
            
            
            // Store any available image sizes
            if ([item objectForKey:@"SmallImage"]) {
                amazonProduct[@"small_image"] = [[item objectForKey:@"SmallImage"] objectForKey:@"URL"];
            }
            
            if ([item objectForKey:@"MediumImage"]) {
                amazonProduct[@"medium_image"] = [[item objectForKey:@"MediumImage"] objectForKey:@"URL"];
            }
            
            if ([item objectForKey:@"LargeImage"]) {
                amazonProduct[@"large_image"] = [[item objectForKey:@"LargeImage"] objectForKey:@"URL"];
            }
            
            
            [responseArray addObject:amazonProduct];
        }
        
    }
    
    return responseArray;
}

/**
 Request products from Amazon
 @param requestParams NSDictionary with additional parameters
 */
- (void)requestWithParams:(NSDictionary *)requestParams {
    // Cancel current operation
    if (currentOperation != nil) {
        [currentOperation cancel];
    }
    
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
    
    currentOperation = [manager enqueueRequestOperationWithMethod:@"GET" parameters:[params copy] success:^(id responseObject) {
        // Parse the XML Response into a Dictionary
        NSDictionary *responseDict = [[[XMLDictionaryParser alloc] init] dictionaryWithParser:responseObject];
        
        // Parse the response Dictionary into a more simplified Dictionary
        NSArray *amazonProducts = [self parseResponse:responseDict];
        
        // TODO notify delegate
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

@end
