//
//  RoomOperation.h
//  Campfire
//
//  Created by Jeff Miller on 01/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFOperation.h"

typedef enum {
	kFetchMessages = 0,
	kFetchMessagesByDate,
	kFetchMessagesByText,
	kFetchUploads
} RoomOperations;

@interface RoomOperation : CFOperation {
	NSDate* date;
	NSString* text;
	
	RoomOperations operation;
}

@property (nonatomic,retain) NSDate* date;
@property (nonatomic,retain) NSString* text;
@property (nonatomic) RoomOperations operation;

- (id) initWithObjectID:(NSManagedObjectID*)theObjectID operation:(RoomOperations)theOperation;

@end
