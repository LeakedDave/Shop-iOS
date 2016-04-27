//
//  HomeViewController.h
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmazonProductsAPI.h"

@interface HomeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, AmazonProductsAPIDelegate, UISearchBarDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *productsTableView;

@end

