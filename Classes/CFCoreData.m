//
//  CFCoreData.m
//  Bungalow
//
//  Created by Jeff Miller on 02/09/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import "CFCoreData.h"
#import "ReadonlyCoreData.h"

static NSPersistentStoreCoordinator* persistentStoreCoordinator = nil;
static NSMutableArray* coreDataListener = nil;

@implementation CFCoreData

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)moc {
    if(self = [super init]) {
        managedObjectContext = [moc retain];
    }
    return self;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator == nil) {
        
        NSString* storePath = nil;
        if([DeviceDetection detectDevice] == MODEL_IPHONE_SIMULATOR) {
            storePath = @"/tmp/Firelight.sqlite";
        } else {
            storePath = [[CFCoreData applicationDocumentsDirectory] stringByAppendingPathComponent: @"Firelight.sqlite"];   
        }
        
        NSURL *storeUrl = storeUrl = [NSURL fileURLWithPath:storePath];
        
        NSError *error;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
            // Handle error
            ALog(@"Error with persistent store");
        }
    }
	
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
+ (NSString *)applicationDocumentsDirectory {	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {	
    if (managedObjectContext == nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:[CFCoreData persistentStoreCoordinator]];
        [managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
    }
	
    return managedObjectContext;
}

- (id) entity:(NSString*) entityDescription{
    return [NSEntityDescription insertNewObjectForEntityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
}

- (id) entityByID:(NSManagedObjectID*) managedObjectID {
	if(!managedObjectID)
		return nil;
	
    NSError* error;
    id entity = [self.managedObjectContext existingObjectWithID:managedObjectID error:&error];
    if(!entity) {
        [self print:error];
    }
    return entity;
}

/**
 If the data is faulted it may or may not retrieve it from the persistent store depending on the 
 MOC cache.  Otherwise it retrieves the data from the MOC cache.
 */
- (NSManagedObjectID*) managedObjectID:(NSString*)managedObjectIDString {    
    NSURL* url = [NSURL URLWithString:managedObjectIDString];    
    NSManagedObjectID* objectID = [[CFCoreData persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];    
    return objectID;
}

/**
 Always fetch the model from the persistent store.
 */
- (id) find:(NSManagedObjectID*)managedObjectID {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];    
    [request setEntity:managedObjectID.entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self==%@", managedObjectID];    
    [request setPredicate:predicate];
    
    NSError *error = nil;    
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (array.count > 0) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

- (id) find:(NSString*)entity withPredicate:(NSPredicate*)predicate {
    NSEntityDescription *entityDescription = [NSEntityDescription                                              
                                              entityForName:entity inManagedObjectContext:self.managedObjectContext];    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];    
    [request setEntity:entityDescription];    
    
    if(predicate)
        [request setPredicate:predicate];        
    
    NSError *error = nil;    
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];    
    if (array.count > 0) {        
        return [array objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSArray*) findAllEntities:(NSString*)entity withPredicate:(NSPredicate*)predicate {
    NSEntityDescription *entityDescription = [NSEntityDescription                                              
                                              entityForName:entity inManagedObjectContext:self.managedObjectContext];    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];    
    [request setEntity:entityDescription];    
    
    if(predicate)
        [request setPredicate:predicate];
    
    NSError *error = nil;    
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];    
    
    return array;
}

- (NSArray*) findAllEntities:(NSString*)entity withPredicate:(NSPredicate*)predicate sortBy:(NSArray*)sorts {
    NSEntityDescription *entityDescription = [NSEntityDescription                                              
                                              entityForName:entity inManagedObjectContext:self.managedObjectContext];    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];    
    [request setEntity:entityDescription];    
    
    if(predicate)
        [request setPredicate:predicate];
    
    if(sorts)
        [request setSortDescriptors:sorts];
    
    NSError *error = nil;    
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];    
    
    return array;
}

- (NSError*) commit {
    NSError *error = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCoreDataDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    @try {
        if (![self.managedObjectContext save:&error]) {
            // Handle error
            [self print:error];
        }   
    } @catch (NSException* e) {
        ALog(@"\n%@\n%@", [e name], [e reason]);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    return error;
}

#pragma mark -
#pragma mark Core Data stack

- (void) onCoreDataDidSave:(NSNotification*)notification {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(onCoreDataDidSave:) withObject:notification waitUntilDone:NO];    
		return;
    }
	
    [[CFCoreData persistentStoreCoordinator] lock];
    
    // merge into view controllers
    ReadonlyCoreData* instance = [ReadonlyCoreData sharedManager];
    [instance.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    
    // merge any changes into listening core data objects (for fetches really)
    @synchronized(coreDataListener) {
        for(CFCoreData* coreData in coreDataListener) {
            if(coreData != self)
                [coreData.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }        
    }
    
    [[CFCoreData persistentStoreCoordinator] unlock];
}

+ (void) addCoreDataListener:(CFCoreData*)coreData {
    @synchronized(coreDataListener) {
        if(coreDataListener == nil)
            coreDataListener = [[NSMutableArray alloc] init];
        [coreDataListener addObject:coreData];   
    }
}

+ (void) removeCoreDataListener:(CFCoreData*)coreData {
    @synchronized(coreDataListener) {
         [coreDataListener removeObject:coreData];   
    }
}


#pragma mark -
#pragma mark Error Helpers

- (void) print:(NSError*)error {
    ALog(@"Unresolved error %@\n%@\n%@\n%@\n%@\n%@", error, [error userInfo], [error localizedDescription], [error localizedRecoveryOptions], [error localizedFailureReason], [error localizedRecoverySuggestion]);
    NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors != nil && [detailedErrors count] > 0) {
        for(NSError* detailedError in detailedErrors) {
            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
        }
    }
    else {
        NSLog(@"  %@", [error userInfo]);
    }
}

-(void) rollback {
    [self.managedObjectContext rollback];   
}

- (void) cleanup { 
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges]) {
            [self commit];
        } 
    }
}

- (void) deleteObject:(NSManagedObject*)managedObject {   
	if(!managedObject)
		return;
    [self.managedObjectContext deleteObject:managedObject];
}

- (void) deleteAllObjects: (NSString *) entityDescription withPredicate:(NSPredicate*)predicate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if(predicate)
        [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in items) {
		ALog(@"deleting %@", managedObject);
        [self deleteObject:managedObject];
    }
}

- (void)dealloc {
    [managedObjectContext release];
    [super dealloc];
}


@end
