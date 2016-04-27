//
//  CartViewController.m
//  Shop
//
//  Created by David Anderson on 4/27/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "CartViewController.h"
#import "AmazonProductViewController.h"

@implementation CartViewController

@synthesize tableData, cartTableView, emptyCartBtn, fallbackLabel, selectedIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableData = [[NSArray alloc] init];
    
    // Setup delegates
    [cartTableView setDelegate:self];
    [cartTableView setDataSource:self];
    
    [emptyCartBtn addTarget:self action:@selector(emptyCart:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)emptyCart:(id)sender {
    [AmazonProduct MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"in_cart > 0"]];
    
    // Save the data context
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self refreshCart];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshCart];
}

- (void)refreshCart {
    tableData = [AmazonProduct MR_findByAttribute:@"in_cart" withValue:[NSNumber numberWithInt:1]];
    
    // Adjust visible elements based on cart
    if ([tableData count] > 0) {
        [cartTableView setHidden:NO];
        [emptyCartBtn setHidden:NO];
        [fallbackLabel setHidden:YES];
    } else {
        [cartTableView setHidden:YES];
        [emptyCartBtn setHidden:YES];
        [fallbackLabel setHidden:NO];
    }
    
    [cartTableView reloadData];
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
    AmazonProduct *amazonProduct = [tableData objectAtIndex:indexPath.row];
    [titleLabel setText:amazonProduct.title];
    [brandLabel setText:[NSString stringWithFormat:@"by %@", amazonProduct.brand]];
    [priceLabel setText:amazonProduct.price];
    
    // Clear existing image and start loading new image
    // TODO fall back to small_image/large_image if medium_image doesn't exist?
    [imageView setImage:nil];
    [imageView setImageWithURL:[NSURL URLWithString:amazonProduct.medium_image]];
    
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
    
    AmazonProduct *cartProduct = [tableData objectAtIndex:selectedIndex];
   
    // Convert to dictionary
    NSMutableDictionary *amazonProduct = [[NSMutableDictionary alloc] init];
    amazonProduct[@"asin"] = cartProduct.asin;
    amazonProduct[@"title"] = cartProduct.title;
    amazonProduct[@"brand"] = cartProduct.brand;
    amazonProduct[@"price"] = cartProduct.price;
    amazonProduct[@"review"] = cartProduct.review;
    amazonProduct[@"small_image"] = cartProduct.small_image;
    amazonProduct[@"medium_image"] = cartProduct.medium_image;
    amazonProduct[@"large_image"] = cartProduct.large_image;
    
    [viewController setAmazonProduct:amazonProduct];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
