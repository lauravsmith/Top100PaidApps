//
//  ViewController.m
//  Top100PaidAppsLaura
//
//  Created by Laura Smith on 2016-01-06.
//  Copyright © 2016 Laura Smith. All rights reserved.
//

#import "AppCategory.h"
#import "ViewController.h"

#define HEADER_TEXT @"Average Pricing by Category \nTop 100 Paid Apps";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
    
    self.appCategoriesArray = [[NSMutableArray alloc] init];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 30.0) / 2.0, (self.view.frame.size.height - 30.0) / 2.0, 30.0, 30.0)];
    [self.activityIndicator setColor:[UIColor blackColor]];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)updateCategoriesArray:(NSArray*)array {
    self.appCategoriesArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(AppCategory*)a categoryName];
        NSString *second = [(AppCategory*)b categoryName];
        return [first compare:second];
    }];
    [self.activityIndicator stopAnimating];
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = HEADER_TEXT;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    CGRect rect = [label.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20.0, 1000.0)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes: @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]}
                                           context:nil];
    label.frame = CGRectMake((self.view.frame.size.width - rect.size.width) / 2.0, 10.0, rect.size.width, rect.size.height);
    [view addSubview:label];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *str = HEADER_TEXT;
    CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20.0, 1000.0)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes: @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]}
                                           context:nil];
    return rect.size.height + 20.0;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.appCategoriesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Note: custom cell unecessary since only one label in this layout
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    AppCategory *appCategory = [self.appCategoriesArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - $%@", appCategory.categoryName, [NSString stringWithFormat:@"%.02f", appCategory.totalPrices / appCategory.numberApps]]];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0] range:NSMakeRange(0, appCategory.categoryName.length)];
    cell.textLabel.attributedText = attributedStr;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
