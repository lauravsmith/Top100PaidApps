//
//  DataController.h
//  Top100PaidAppsLaura
//
//  Created by Laura Smith on 2016-01-06.
//  Copyright © 2016 Laura Smith. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreData/NSManagedObjectModel.h>
#import <Foundation/Foundation.h>

@protocol DataControllerDelegate;

@interface DataController : NSObject

@property (nonatomic, weak) id<DataControllerDelegate> delegate;
@property (strong) NSManagedObjectContext *mainContext;
@property (strong) NSManagedObjectContext *backgroundContext;
@property (strong) NSPersistentStoreCoordinator *psc;
@property (strong) NSPersistentStoreCoordinator *backgroundPsc;

-(void)downloadData;
- (void)setupCoreDataStack;
- (void)saveContext;
-(NSArray*)fetchAppValues;

@end

@protocol DataControllerDelegate <NSObject>
-(void)finishedDownloadingApps;
@end