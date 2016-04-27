//
//  ProductListViewController.h
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, AmazonProductsAPIDelegate, UISearchBarDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *productsTableView;
@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) NSString *searchIndex;
@property (nonatomic) int selectedIndex;

@end

