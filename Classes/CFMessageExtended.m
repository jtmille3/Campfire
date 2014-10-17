//
//  MessageExtended.m
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFMessageExtended.h"
#import "CFMessageParser.h"
#import "REST.h"


@implementation CFMessage (CFMessageExtended)

- (void) create {
	CFMessageParser* parser = [[CFMessageParser alloc] initWithCredentialID:self.credential.objectID];
	NSData* xml = [[parser serialize:self] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString* action = [NSString stringWithFormat:@"room/%d/speak.xml", [self.room.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"POST" action:action payload:xml context:self.credential.objectID];
	[rest setTarget:self withCallback:@selector(onCreate:)];
	[rest start];
	
	[parser release];
}

- (void) onCreate:(REST*)rest {
	if([rest.response statusCode] == 201) {
		NSString* xml = [[NSString alloc] initWithData:rest.receivedData encoding:NSUTF8StringEncoding];
		NSManagedObjectID* objectID = rest.context;
		CFMessageParser* parser = [[CFMessageParser alloc] initWithCredentialID:objectID];
		[parser deserialize:xml];
		[parser release];		
		[xml release];
	} else {
		// error handling
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Problem" message:@"Communication failed." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[rest release];
}

@end
