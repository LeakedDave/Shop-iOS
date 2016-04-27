//
//  AmazonProductViewController.h
//  Shop
//
//  Created by David Anderson on 4/27/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmazonProductViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *productScrollView;
@property (strong, nonatomic) IBOutlet UIButton *addToCartBtn;
@property (strong, nonatomic) NSDictionary *amazonProduct;

@end
