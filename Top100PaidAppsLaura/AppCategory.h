//
//  AppCategory.h
//  Top100PaidAppsLaura
//
//  Created by Laura Smith on 2016-01-07.
//  Copyright © 2016 Laura Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppCategory : NSObject
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, assign) float totalPrices;
@property (nonatomic, assign) int numberApps;
@end
