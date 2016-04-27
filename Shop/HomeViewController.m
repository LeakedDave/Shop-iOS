//
//  HomeViewController.m
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

@synthesize searchBar, productsTableView, tableData;

/**
 Prepare the ViewController and fetch initial Amazon products
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    tableData = [[NSArray alloc] init];
    
    // Set delegates
    [searchBar setDelegate:self];
    [productsTableView setDelegate:self];
    [productsTableView setDataSource:self];
    
    // Fetch Amazon products
    [[AmazonProductsAPI sharedInstance] setDelegate:self];
    [[AmazonProductsAPI sharedInstance] fetchAllProducts];

    
    // Dismiss keyboard on tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}


/**
 Delegate received response from Amazon
 */
- (void)fetchedAmazonProducts:(NSArray *)amazonProducts {
    // Refresh the table and scroll to top
    tableData = amazonProducts;
    [productsTableView setContentOffset:CGPointZero];
    [productsTableView reloadData];
}


/**
 Search for products from Amazon
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [[AmazonProductsAPI sharedInstance] fetchAllProducts];
    } else {
        [[AmazonProductsAPI sharedInstance] searchProducts:searchText];
    }
}


/**
 Load cell from custom XIB and populate with Amazon product data
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AmazonProductTableCell"];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AmazonProductTableCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Prepare views
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:1];
    UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
    UILabel *brandLabel = (UILabel *) [cell viewWithTag:3];
    UILabel *priceLabel = (UILabel *) [cell viewWithTag:4];
    
    // Render product data
    NSDictionary *amazonProduct = [tableData objectAtIndex:indexPath.row];
    [titleLabel setText:amazonProduct[@"title"]];
    [brandLabel setText:[NSString stringWithFormat:@"by %@", amazonProduct[@"brand"]]];
    [priceLabel setText:amazonProduct[@"price"]];
    
    // Clear existing image and start loading new image
    // TODO fall back to small_image/large_image if medium_image doesn't exist?
    [imageView setImage:nil];
    [imageView setImageWithURL:[NSURL URLWithString:amazonProduct[@"medium_image"]]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // TODO go to product page
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}


// Handle keyboard dismissing
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self dismissKeyboard];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissKeyboard];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
