//
//  BungalowCoreData.h
//  Bungalow
//
//  Created by Jeff Miller on 11/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CFCoreData.h"


@interface ReadonlyCoreData : CFCoreData { 
}



/*! Shared singlestone instance. */
+ (id)sharedManager;
+ (id)allocWithZone:(NSZone *)zone;

@end
