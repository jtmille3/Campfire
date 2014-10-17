//
//  BungalowCoreData.m
//  Bungalow
//
//  Created by Jeff Miller on 11/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReadonlyCoreData.h"

static ReadonlyCoreData* sharedManager = nil;

@implementation ReadonlyCoreData

+ (id)sharedManager {
    @synchronized(self) {		
        if (sharedManager == nil) {			
            [[self alloc] init]; // assignment not done here
        }		
    }	
    return sharedManager;	
}

+ (id)allocWithZone:(NSZone *)zone {	
    @synchronized(self) {		
        if (sharedManager == nil) {			
            sharedManager = [super allocWithZone:zone];	
            //[[NSNotificationCenter defaultCenter] addObserver:sharedManager selector:@selector(onCoreDataDidSave:) name:NSManagedObjectContextDidSaveNotification object:sharedManager.managedObjectContext];
            return sharedManager;  // assignment and return on first allocation
        }		
    }	
    return nil; //on subsequent allocation attempts return nil	
}

- (id)copyWithZone:(NSZone *)zone {	
    return self;	
}

- (id)retain {	
    return self;	
}

- (unsigned)retainCount {	
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {	
    //do nothing	
}

- (id)autorelease {	
    return self;	
}

- (NSError*) commit {
    @throw [NSException exceptionWithName:@"Readonly Context" reason:@"Used by the view controllers." userInfo:nil];
}

- (void) onCoreDataDidSave:(NSNotification*)notification {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(onCoreDataDidSave:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    //ReadonlyCoreData* instance = [ReadonlyCoreData sharedManager];
    //[instance.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

@end
