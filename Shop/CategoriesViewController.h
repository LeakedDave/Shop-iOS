//
//  CategoriesViewController.h
//  Shop
//
//  Created by David Anderson on 4/26/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoriesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *categoriesTableView;

@end

