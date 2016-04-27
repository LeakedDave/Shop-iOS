//
//  AmazonProductsAPI.h
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWMAmazonProductAdvertisingManager.h"

@protocol AmazonProductsAPIDelegate <NSObject>

- (void)fetchedAmazonProducts:(NSArray *) amazonProducts;

@end

@interface AmazonProductsAPI : NSObject<NSXMLParserDelegate>

@property (nonatomic, strong) id <AmazonProductsAPIDelegate> delegate;
@property (nonatomic, strong) AFHTTPRequestOperation *currentOperation;

+ (AmazonProductsAPI *)sharedInstance;
- (void)fetchAllProducts;
- (void)searchProducts:(NSString *)q;

@end
