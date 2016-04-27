//
//  AmazonProductsAPI.m
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "AmazonProductsAPI.h"
#import <CommonCrypto/CommonHMAC.h>
#import <XMLDictionary/XMLDictionary.h>

static NSString *AWS_ACCESS_KEY = @"AKIAJQDFUCVUAUN4QDKA";
static NSString *AWS_SECRET_KEY = @"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";
static NSString *ASSOCIATE_TAG = @"whialaclo-20";
static NSString *ENDPOINT = @"webservices.amazon.com";
static NSString *URI = @"/onca/xml";

@implementation AmazonProductsAPI

@synthesize delegate, currentOperation;


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


/**
 Fetch products from Amazon (search for 'Feature')
 @param searchIndex NSString of product category
 */
- (void)fetchAllProductsWithSearchIndex:(NSString *)searchIndex {
    searchIndex = [searchIndex stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *requestParams = @{@"Keywords":@"Feature", @"SearchIndex":searchIndex};
    
    [self requestWithParams:requestParams];
}


/**
 Search for products from Amazon
 @param q NSString of search query
 @param searchIndex NSString of product category
 */
- (void)searchProducts:(NSString *)q withSearchIndex:(NSString *)searchIndex {
    searchIndex = [searchIndex stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *requestParams = @{@"Keywords":q, @"SearchIndex":searchIndex};
    
    [self requestWithParams:requestParams];
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
        
        if (delegate != nil) {
            [delegate fetchedAmazonProducts:amazonProducts];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}


/**
 Parses the XML Dictionary into a more simple NSDictionary
 @param responseDict NSDictionary of Amazon response
 @return NSArray contains Amazon products data
 */
- (NSArray *)parseResponse:(NSDictionary *)responseDict {
    NSMutableArray *responseArray = [[NSMutableArray alloc] init];
    
    if ([responseDict objectForKey:@"Items"] && [[responseDict objectForKey:@"Items"] objectForKey:@"Item"]) {
        NSArray *items = [[responseDict objectForKey:@"Items"] objectForKey:@"Item"];
        
        for (NSDictionary *item in items) {
            // Skip entries that are missing important attributes
            if (![item respondsToSelector:@selector(objectForKey:)]) {
                continue;
            }
            
            if (![item objectForKey:@"ASIN"]) {
                continue;
            }
            
            if (![item objectForKey:@"ItemAttributes"]) {
                continue;
            }
            
            id itemAttributes = [item objectForKey:@"ItemAttributes"];
            
            if (![itemAttributes respondsToSelector:@selector(objectForKey:)]) {
                continue;
            }
            
            if (![itemAttributes objectForKey:@"Title"]) {
                continue;
            }
            
            if (![itemAttributes objectForKey:@"Brand"]) {
                continue;
            }
            
            
            // Make sure there is a lowest new price
            if (![item objectForKey:@"OfferSummary"]) {
                continue;
            }
            
            id offerSummary = [item objectForKey:@"OfferSummary"];
            if (![offerSummary respondsToSelector:@selector(objectForKey:)]) {
                continue;
            }
            
            if (![offerSummary objectForKey:@"LowestNewPrice"] || ![[offerSummary objectForKey:@"LowestNewPrice"] objectForKey:@"FormattedPrice"]) {
                continue;
            }
            
            
            // Setup Amazon product Dictionary
            NSMutableDictionary *amazonProduct = [[NSMutableDictionary alloc] init];
            amazonProduct[@"asin"] = [item objectForKey:@"ASIN"];
            amazonProduct[@"title"] = [itemAttributes objectForKey:@"Title"];
            amazonProduct[@"brand"] = [itemAttributes objectForKey:@"Brand"];
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
            
            if ([item objectForKey:@"EditorialReviews"] && [[item objectForKey:@"EditorialReviews"] objectForKey:@"EditorialReview"]) {
                if ([[[item objectForKey:@"EditorialReviews"] objectForKey:@"EditorialReview"] respondsToSelector:@selector(objectForKey:)]) {
                    amazonProduct[@"review"] = [[[item objectForKey:@"EditorialReviews"] objectForKey:@"EditorialReview"] objectForKey:@"Content"];
                } else {
                    amazonProduct[@"review"] = [[[[item objectForKey:@"EditorialReviews"] objectForKey:@"EditorialReview"] objectAtIndex:0] objectForKey:@"Content"];
                }
            } else {
                amazonProduct[@"review"] = [itemAttributes objectForKey:@"title"];
            }
            
            [responseArray addObject:amazonProduct];
        }
        
    }
    
    return responseArray;
}

@end
