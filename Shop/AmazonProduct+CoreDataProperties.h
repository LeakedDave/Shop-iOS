//
//  AmazonProduct+CoreDataProperties.h
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AmazonProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmazonProduct (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *asin;
@property (nullable, nonatomic, retain) NSString *brand;
@property (nullable, nonatomic, retain) NSString *small_image;
@property (nullable, nonatomic, retain) NSString *medium_image;
@property (nullable, nonatomic, retain) NSNumber *in_cart;
@property (nullable, nonatomic, retain) NSString *large_image;
@property (nullable, nonatomic, retain) NSString *review;
@property (nullable, nonatomic, retain) NSString *price;

@end

NS_ASSUME_NONNULL_END
