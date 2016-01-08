//
//  AppDelegate.h
//  Top100PaidAppsLaura
//
//  Created by Laura Smith on 2016-01-06.
//  Copyright © 2016 Laura Smith. All rights reserved.
//

#import "DataController.h"

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DataController *dataController;

@end

