//
//  UserExtended.m
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFUserExtended.h"
#import "REST.h"
#import "CFUserParser.h"


@implementation CFUser (CFUserExtended)

- (void) fetch {
	NSString* action = [NSString stringWithFormat:@"users/%d.xml", [self.userID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"GET" action:action payload:nil context:self.credential.objectID];
	[rest setTarget:self withCallback:@selector(onFetch:)];
	[rest start];
}

- (void) onFetch:(REST*)rest {
	if([rest.response statusCode] == 200) {
		NSString* xml = [[NSString alloc] initWithData:rest.receivedData encoding:NSUTF8StringEncoding];
		NSManagedObjectID* objectID = rest.context;
		CFUserParser* parser = [[CFUserParser alloc] initWithCredentialID:objectID];
		[parser deserialize:xml];
		[parser release];
	} else {
		// error handling
	}
	[rest release];
}

@end
