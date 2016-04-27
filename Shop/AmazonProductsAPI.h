//
//  AmazonProductsAPI.h
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmazonProductsAPI : NSObject<NSXMLParserDelegate>

+ (AmazonProductsAPI *)sharedInstance;
- (void)fetchAllProducts;

@end
