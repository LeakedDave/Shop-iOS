//
//  CategoriesViewController.m
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import "CategoriesViewController.h"

@implementation CategoriesViewController

@synthesize categoriesTableView;

NSArray *tableData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    
    [[cell textLabel] setText:[tableData objectAtIndex:indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // TODO go to category controller
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
