//
//  DataController.m
//  Top100PaidAppsLaura
//
//  Created by Laura Smith on 2016-01-06.
//  Copyright © 2016 Laura Smith. All rights reserved.
//

#import "AppCategory.h"
#import "DataController.h"

#define DATA_SOURCE_URL @"https://itunes.apple.com/us/rss/toppaidapplications/limit=100/json"
#define ENTITY_NAME @"App"

@implementation DataController

- (void)setupCoreDataStack
{
    // create core data stack
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Top100PaidAppsLaura" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    self.psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    // Main thread context
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:self.psc];
    [self setMainContext:moc];
    
    self.backgroundPsc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    // Background thread context
    NSManagedObjectContext *backgroundMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundMoc setPersistentStoreCoordinator:self.backgroundPsc];
    [self setBackgroundContext:backgroundMoc];
    
    // Note: an XML store type would have also worked for this small data set
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
    NSError *error = nil;
    
    [self.mainContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                              configuration:nil
                                                                        URL:storeURL
                                                                    options:nil
                                                                      error:&error];
    
    [self.backgroundContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                    configuration:nil
                                                                              URL:storeURL
                                                                          options:nil
                                                                            error:&error];
}

-(void)downloadData {
    // perform data download and processing on background thread with NSOperationQueue
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [myQueue addOperationWithBlock:^{
        NSString *str =  DATA_SOURCE_URL;
        NSURL *url=[NSURL URLWithString:str];
        NSData *data=[NSData dataWithContentsOfURL:url];

        NSError *error=nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData: data
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: &error];
        
        NSArray *appItems = [[jsonDict objectForKey:@"feed"] objectForKey:@"entry"];
        
        // Deleting old top 100 apps
        // Note: if more time, an update rather than deleting may work better
        // I'm wondering how simple/fast it would be to compare the old list to the new one and make changes accordingly
        // Would the task of comparing the lists, finding the objects to delete or udpate(ex. if the price of an app changes) and inserting new ones be faster or slower than simply overwriting all the objects? And which option would be better for large data sets?
        
        // If we were wanting to compare pricing overtime, it would be useful to keep old records
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        
        // execute on background thread
        [self.backgroundContext performBlock:^{
            NSError *deleteError = nil;
            [self.backgroundPsc executeRequest:delete withContext:self.backgroundContext error:&deleteError];
            [self parseAndSaveToCoreData:appItems];
        }];
    }];
}

-(void)parseAndSaveToCoreData:(NSArray*)dataArray {
    for (NSDictionary *appDict in dataArray) {
        float price = [[[[appDict objectForKey:@"im:price"]
                         objectForKey:@"attributes"]
                        objectForKey:@"amount"] floatValue];
        
        NSString *category = [[[appDict objectForKey:@"category"]
                               objectForKey:@"attributes"]
                              objectForKey:@"term"];
        
        // Note: I realized the app name isn't needed in this case
        // I added this initially to avoid duplicate app names if we were updating the list, but is now uneccessary since deleting objects before saving new
        // Also, the App Id would be a better key to save if we were updating the list, since names may change
        NSString *appName = [[appDict objectForKey:@"im:name"]
                             objectForKey:@"label"];
        
        // Note: We could calculate app averages before saving to core data and save as category objects
        // However, that option would not be as scalable if we were only updating the list instead of over-writing each time (eg. insertint or deleting only a few apps from the list or altering their prices)
        NSManagedObject *app = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                             inManagedObjectContext:self.backgroundContext];
        [app setValue:[NSNumber numberWithFloat:price] forKey:@"price"];
        [app setValue:category forKey:@"category"];
        [app setValue:appName forKey:@"name"];
    }
    
    [self saveContext];
}

- (void)saveContext {
    if (self.backgroundContext != nil) {
        NSError *error = nil;
        if (![self.backgroundContext save:&error]) {
             NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        } else {
            // Signal to main thread that it can now fetch and display the information from Core Data
            // Note: wondering whether the background and main contexts need to be merged?
            // Note: would a listener on the main thread for context saves have been better than explicity calling the main thread after saves?
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                if ([self.delegate respondsToSelector:@selector(finishedDownloadingApps)]) {
                    [self.delegate finishedDownloadingApps];
                }
            }];
        }
    }
}

-(NSArray*)fetchAppValues {
    // Fetch request to core data
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:self.mainContext]];
    
    NSError *error = nil;
    NSArray *results = [self.mainContext executeFetchRequest:request error:&error];
    // Note: if this were a large data set, this fetch may need to be on a background thread if this can become a slow operation?
    
    NSMutableDictionary *categoryPriceDictionary = [[NSMutableDictionary alloc] init];
    for (NSManagedObject *appObject in results) {
        if (![categoryPriceDictionary objectForKey:[appObject valueForKey:@"category"]]) {
            // no object for this category
            AppCategory *appCategory = [[AppCategory alloc] init];
            appCategory.categoryName = [appObject valueForKey:@"category"];
            appCategory.totalPrices = [[appObject valueForKey:@"price"] floatValue];
            appCategory.numberApps = 1;
            [categoryPriceDictionary setObject:appCategory forKey:appCategory.categoryName];
        } else {
            // increment total pricing and number of apps for this exisiting cateogy
            AppCategory *appCategory = [categoryPriceDictionary objectForKey:[appObject valueForKey:@"category"]];
            appCategory.totalPrices += [[appObject valueForKey:@"price"] floatValue];
            appCategory.numberApps += 1;
            [categoryPriceDictionary setObject:appCategory forKey:appCategory.categoryName];
        }
    }
    
    return [categoryPriceDictionary allValues];
}

@end
