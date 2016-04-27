//
//  CategoriesViewController.m
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "CategoriesViewController.h"
#import "ProductListViewController.h"

@implementation CategoriesViewController

@synthesize categoriesTableView, selectedIndex, tableData;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Preset category data
    tableData = @[@"Appliances",
                  @"Arts and Crafts",
                  @"Automotive",
                  @"Baby",
                  @"Beauty",
                  @"Blended",
                  @"Books",
                  @"Collectibles",
                  @"Electronics",
                  @"Fashion",
                  @"Gift Cards",
                  @"Grocery",
                  @"Health Personal Care",
                  @"Home Garden",
                  @"Industrial",
                  @"Lawn and Garden",
                  @"Luggage",
                  @"Magazines",
                  @"Mobile Apps",
                  @"Movies",
                  @"Music",
                  @"Office Products",
                  @"Pet Supplies",
                  @"Software",
                  @"Sporting Goods",
                  @"Tools",
                  @"Toys",
                  @"Video Games",
                  @"Wine",
                  @"Wireless"];
    
    
    // Set delegates
    [categoriesTableView setDelegate:self];
    [categoriesTableView setDataSource:self];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryCell"];
    
    // Set category label text
    [[cell textLabel] setText:[tableData objectAtIndex:indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = (int) indexPath.row;
    
    // Go to Category controller
    [self performSegueWithIdentifier:@"CategorySegue" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set the Category for the destination controller
    ProductListViewController *viewController = segue.destinationViewController;
    [viewController setSearchIndex:[tableData objectAtIndex:selectedIndex]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
