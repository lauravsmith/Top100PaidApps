//
//  AppDelegate.m
//  Top100PaidAppsLaura
//
//  Created by Laura Smith on 2016-01-06.
//  Copyright © 2016 Laura Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate () <DataControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.dataController = [[DataController alloc] init];
    self.dataController.delegate = self;
    [self.dataController setupCoreDataStack];
    [self.dataController downloadData];
    // Note: if more time, I would fetch and display from current core data store before download, then check for changes once new data is downloaded, saved and fetched again and update view accordingly
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    // Note: this is uneccesary here since the user can't change the data, and the data isn't changing within the session
    [self.dataController saveContext];
}

#pragma mark DataControllerDelegate

-(void)finishedDownloadingApps {
    NSArray *array = [self.dataController fetchAppValues];
    ViewController *vc = (ViewController*)self.window.rootViewController;
    [vc updateCategoriesArray:array];
}

@end
