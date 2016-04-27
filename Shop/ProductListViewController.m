//
//  ProductListViewController.m
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "ProductListViewController.h"
#import "AmazonProductViewController.h"

@implementation ProductListViewController

@synthesize searchBar, productsTableView, tableData, searchIndex, selectedIndex;

/**
 Prepare the ViewController and fetch initial Amazon products
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    tableData = [[NSArray alloc] init];

    
    // Update search index based on category
    if (searchIndex == nil) {
        searchIndex = @"All";
    } else {
        // Set the navigation title to the category name
        [self.navigationItem setTitle:searchIndex];
    }

    
    // Set delegates
    [searchBar setDelegate:self];
    [productsTableView setDelegate:self];
    [productsTableView setDataSource:self];
    
    
    // Fetch Amazon products
    [[AmazonProductsAPI sharedInstance] setDelegate:self];
    [[AmazonProductsAPI sharedInstance] fetchAllProductsWithSearchIndex:searchIndex];

    
    // Dismiss keyboard on tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self updateCartBadge];
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
        [[AmazonProductsAPI sharedInstance] fetchAllProductsWithSearchIndex:searchIndex];
    } else {
        [[AmazonProductsAPI sharedInstance] searchProducts:searchText withSearchIndex:searchIndex];
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
    
    // Go to Product controller
    selectedIndex = (int) indexPath.row;
    [self performSegueWithIdentifier:@"ProductSegue" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set the Product data for the destination controller
    AmazonProductViewController *viewController = segue.destinationViewController;
    [viewController setAmazonProduct:[tableData objectAtIndex:selectedIndex]];
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
