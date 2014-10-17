//
//  RoomOperation.m
//  Campfire
//
//  Created by Jeff Miller on 01/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RoomOperation.h"

@implementation RoomOperation

@synthesize date;
@synthesize text;
@synthesize operation;

- (id) initWithObjectID:(NSManagedObjectID*)theObjectID operation:(RoomOperations)theOperation {
	if(self = [super initWithObjectID:theObjectID]) {
		self.operation = theOperation;
	}
	return self;
}

- (void) main {	
	// test for internet connection here
	@try {
		CFRoom* room = [self.coreData entityByID:self.objectID];
		
		REST* rest = nil;
		
		switch(operation) {				
			case kFetchMessagesByDate:
				rest = [room fetchMessagesForDate:self.date];
				break;
			case kFetchMessagesByText:
				rest = [room fetchMessagesForText:self.text];
				break;
			case kFetchUploads:
				rest = [room fetchUploads];
				break;
			default:
				rest = [room fetchMessages];			
				break;				
		}

		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!rest.finished);	
		[rest release];
	}
	@catch (NSException * e) {
		
	}
	@finally {
		
	}
}

- (void) dealloc {
	self.date = nil;
	self.text = nil;
	[super dealloc];
}

@end
