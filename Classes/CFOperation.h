//
//  CFOperation.h
//  Campfire
//
//  Created by Jeff Miller on 01/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFCoreData.h"


@interface CFOperation : NSOperation {
	NSManagedObjectID* objectID;
	CFCoreData* coreData;
}

@property (nonatomic,retain) NSManagedObjectID* objectID;
@property (nonatomic,retain) CFCoreData* coreData;

- (id) initWithObjectID:(NSManagedObjectID*)objectID;
- (void) main;

@end
