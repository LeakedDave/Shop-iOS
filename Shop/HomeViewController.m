//
//  HomeViewController.m
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "HomeViewController.h"
#import "AmazonProductsAPI.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize searchBar, productsTableView;

NSArray *tableData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    tableData = [[NSArray alloc] init];
    [[AmazonProductsAPI sharedInstance] fetchAllProducts];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AmazonProductTableCell"];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AmazonProductTableCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:1];
    UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
    UILabel *brandLabel = (UILabel *) [cell viewWithTag:2];
    UILabel *priceLabel = (UILabel *) [cell viewWithTag:2];
    
    NSDictionary *amazonProduct = [tableData objectAtIndex:indexPath.row];
    [titleLabel setText:amazonProduct[@"title"]];
    [brandLabel setText:amazonProduct[@"brand"]];
    [priceLabel setText:amazonProduct[@"price"]];
    
    [imageView setImage:nil];
    [imageView setImageWithURL:[NSURL URLWithString:amazonProduct[@"medium_image"]]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
