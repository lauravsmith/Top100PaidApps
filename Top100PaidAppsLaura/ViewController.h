//
//  ViewController.h
//  Top100PaidAppsLaura
//
//  Created by Laura Smith on 2016-01-06.
//  Copyright © 2016 Laura Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableViewController *tableViewController;
@property (nonatomic, strong) NSArray *appCategoriesArray;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
-(void)updateCategoriesArray:(NSArray*)array;

@end

