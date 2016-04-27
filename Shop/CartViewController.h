//
//  CartViewController.h
//  Shop
//
//  Created by David Anderson on 4/27/16.
//  Copyright © 2016 David Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) IBOutlet UITableView *cartTableView;
@property (strong, nonatomic) IBOutlet UIButton *emptyCartBtn;
@property (strong, nonatomic) IBOutlet UILabel *fallbackLabel;
@property (nonatomic) int selectedIndex;

@end
