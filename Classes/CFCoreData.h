//
//  BCoreData.h
//  Bungalow
//
//  Created by Jeff Miller on 02/09/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DeviceDetection.h"
#import "ResourceBundle.h"
#import "CampfireModels.h"


@interface CFCoreData : NSObject {
    NSManagedObjectContext *managedObjectContext;
}

@property (retain, readonly) NSManagedObjectContext *managedObjectContext;

+ (NSPersistentStoreCoordinator*) persistentStoreCoordinator;
+ (NSString*) applicationDocumentsDirectory;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)moc;

- (id) entity:(NSString*) entityDescription;
- (id) entityByID:(NSManagedObjectID*) managedObjectID;
- (NSManagedObjectID*) managedObjectID:(NSString*)managedObjectIDString;
- (id) find:(NSManagedObjectID*)managedObjectID;
- (id) find:(NSString*)entity withPredicate:(NSPredicate*)predicate;
- (NSArray*) findAllEntities:(NSString*)entity withPredicate:(NSPredicate*)predicate;
- (NSArray*) findAllEntities:(NSString*)entity withPredicate:(NSPredicate*)predicate sortBy:(NSArray*)sorts;
- (NSError*) commit;
- (void) rollback;
- (void) cleanup;
- (void) deleteObject:(NSManagedObject*)managedObject;
- (void) deleteAllObjects: (NSString *) entityDescription withPredicate:(NSPredicate*)predicate;

- (void) print:(NSError*)error;

+ (void) addCoreDataListener:(CFCoreData*)coreData;
+ (void) removeCoreDataListener:(CFCoreData*)coreData;

@end
