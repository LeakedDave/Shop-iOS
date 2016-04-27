//
//  AmazonProductViewController.m
//  Shop
//
//  Created by David Anderson on 4/27/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "AmazonProductViewController.h"

@implementation AmazonProductViewController

@synthesize amazonProduct, productScrollView, addToCartBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (amazonProduct == nil) return;
    
    [self.navigationItem setTitle:amazonProduct[@"title"]];
    [addToCartBtn addTarget:self action:@selector(cartBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    
    // Add Amazon product XIB to scrollview
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AmazonProductView" owner:self options:nil];
    UIView *productView = [topLevelObjects objectAtIndex:0];
    [productScrollView addSubview:productView];
    
    
    // Render product data in view
    UIImageView *imageView = (UIImageView *) [productView viewWithTag:1];
    UILabel *titleLabel = (UILabel *) [productView viewWithTag:2];
    UILabel *brandLabel = (UILabel *) [productView viewWithTag:3];
    UILabel *priceLabel = (UILabel *) [productView viewWithTag:4];
    UILabel *reviewLabel = (UILabel *) [productView viewWithTag:5];
    
    [imageView setImageWithURL:[NSURL URLWithString:amazonProduct[@"large_image"]]];
    [titleLabel setText:amazonProduct[@"title"]];
    [brandLabel setText:[NSString stringWithFormat:@"by %@", amazonProduct[@"brand"]]];
    [priceLabel setText:amazonProduct[@"price"]];
    
    
    // Handle HTML reviews
    NSString *htmlString = [NSString stringWithFormat:@"<span style=\"font-family: HelveticaNeue-Light; font-size: 15\">%@</span>", amazonProduct[@"review"]];

    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    [reviewLabel setAttributedText:attrStr];
    
    [self checkInCart];
}

- (IBAction)cartBtnPressed:(id)sender {
    AmazonProduct *cartProduct = [AmazonProduct MR_findFirstByAttribute:@"asin" withValue:amazonProduct[@"asin"]];
    
    // Create new AmazonProduct
    if (!cartProduct) {
        cartProduct = [AmazonProduct MR_createEntity];
        cartProduct.asin = amazonProduct[@"asin"];
        cartProduct.title = amazonProduct[@"title"];
        cartProduct.brand = amazonProduct[@"brand"];
        cartProduct.price = amazonProduct[@"price"];
        cartProduct.review = amazonProduct[@"review"];
        cartProduct.small_image = amazonProduct[@"small_image"];
        cartProduct.medium_image = amazonProduct[@"medium_image"];
        cartProduct.large_image = amazonProduct[@"large_image"];
    }
    
    if ([cartProduct.in_cart intValue] > 0) {
        cartProduct.in_cart = [NSNumber numberWithInt:0];
    } else {
        cartProduct.in_cart = [NSNumber numberWithInt:1];
    }
    
    // Save the data context
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self checkInCart];
    }];
}

- (void)checkInCart {
    // Adjust button apperance based on cart status
    AmazonProduct *cartProduct = [AmazonProduct MR_findFirstByAttribute:@"asin"
                                                              withValue:amazonProduct[@"asin"]];
    if (cartProduct && [cartProduct.in_cart intValue] > 0) {
        [addToCartBtn setBackgroundImage:[UIImage imageNamed:@"red"] forState:UIControlStateNormal];
        [addToCartBtn setTitle:@"Remove from Cart" forState:UIControlStateNormal];
    } else {
        [addToCartBtn setBackgroundImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
        [addToCartBtn setTitle:@"Add to Cart" forState:UIControlStateNormal];
    }
    
    [self updateCartBadge];
}

- (void)viewWillLayoutSubviews {
    // Set Product view size based on review label height
    UIView *productView = [[productScrollView subviews] objectAtIndex:0];
    UILabel *reviewLabel = (UILabel *) [productView viewWithTag:5];
    
    CGRect frame = productScrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.height = reviewLabel.frame.origin.y + reviewLabel.frame.size.height + 8.0f;
    
    [productView setFrame:frame];
    
    // Set the scrollview size
    [productScrollView setContentSize:frame.size];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkInCart];
}

- (void)updateCartBadge {
    NSArray *cartProducts = [AmazonProduct MR_findByAttribute:@"in_cart" withValue:[NSNumber numberWithInt:1]];
    
    NSString *cartBadgeString = nil;
    if ([cartProducts count] > 0) {
        cartBadgeString = [NSString stringWithFormat:@"%i", (int)[cartProducts count]];
    }
    
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:2] setBadgeValue:cartBadgeString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
