//
//  CFOperation.m
//  Campfire
//
//  Created by Jeff Miller on 01/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFOperation.h"


@implementation CFOperation

@synthesize objectID;
@synthesize coreData;

- (void) dealloc {
	self.objectID = nil;
	self.coreData = nil;
	[super dealloc];
}

- (id) initWithObjectID:(NSManagedObjectID*)theObjectID {
	if(self = [super init]) {
		self.objectID = theObjectID;
		self.coreData = [CFCoreData new];
	}
	return self;
}

- (id) init {
	@throw [NSException exceptionWithName:@"Not implemented" reason:@"Not implemented" userInfo:nil];
}

- (void) main {
	@throw [NSException exceptionWithName:@"Override" reason:@"Override" userInfo:nil];
}

@end
