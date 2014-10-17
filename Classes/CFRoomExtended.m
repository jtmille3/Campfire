//
//  RoomExtended.m
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFRoomExtended.h"
#import "CFRoomParser.h"
#import "CFMessageParser.h"
#import "CampfireAppDelegate.h"
#import "RoomOperation.h"
#import "CFUploadParser.h"



@implementation CFRoom (CFRoomExtended)


- (void) fetchMessagesOperationForDate:(NSDate*)date {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	RoomOperation* operation = [[RoomOperation alloc] initWithObjectID:self.objectID operation:kFetchMessagesByDate];
	operation.date = date;
	[appDelegate.queue addOperation:operation];
	[operation release];
}

- (id) fetchMessagesForDate:(NSDate*)date {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
	NSInteger day = [components day];
	NSInteger month = [components month];
	NSInteger year = [components year];
	NSString* action = [NSString stringWithFormat:@"room/%d/transcript/%d/%d/%d.xml", [self.roomID intValue], year, month, day];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"GET" action:action payload:nil context:self.credential.objectID];
	[rest setTarget:self withCallback:@selector(onMessages:)];
	[rest start];
	return rest;
}

- (void) fetchMessagesOperationForText:(NSString*)text {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	RoomOperation* operation = [[RoomOperation alloc] initWithObjectID:self.objectID operation:kFetchMessagesByText];
	operation.text = text;
	[appDelegate.queue addOperation:operation];
	[operation release];
}

- (id) fetchMessagesForText:(NSString*)text {
	NSString* urlEncode = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString* action = [NSString stringWithFormat:@"search/%@.xml", urlEncode];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"GET" action:action payload:nil context:self.credential.objectID];
	[rest setTarget:self withCallback:@selector(onMessages:)];
	[rest start];
	return rest;
}

- (void) fetchMessagesOperation {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	RoomOperation* operation = [[RoomOperation alloc] initWithObjectID:self.objectID operation:kFetchMessages];
	[appDelegate.queue addOperation:operation];
	[operation release];
}

- (id) fetchMessages {
	NSString* action = [NSString stringWithFormat:@"room/%d/transcript.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"GET" action:action payload:nil context:self.credential.objectID];
	[rest setTarget:self withCallback:@selector(onMessages:)];
	[rest start];
	return rest;
}

- (void) onMessages:(REST*)rest {
	if([rest.response statusCode] == 200) {
		NSString* xml = [[NSString alloc] initWithData:rest.receivedData encoding:NSUTF8StringEncoding];
		NSManagedObjectID* objectID = rest.context;
		CFMessageParser* parser = [[CFMessageParser alloc] initWithCredentialID:objectID];
		[parser deserialize:xml];
		[parser release];
	} else {
		// error handling
	}
}

- (void) fetchUploadsOperation {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	RoomOperation* operation = [[RoomOperation alloc] initWithObjectID:self.objectID operation:kFetchUploads];
	[appDelegate.queue addOperation:operation];
	[operation release];
}

- (id) fetchUploads {
	NSString* action = [NSString stringWithFormat:@"room/%d/uploads.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"GET" action:action payload:nil context:self.credential.objectID];
	[rest setTarget:self withCallback:@selector(onUploads:)];
	[rest start];
	return rest;
}

- (void) onUploads:(REST*)rest {
	if([rest.response statusCode] == 200) {
		NSString* xml = [[NSString alloc] initWithData:rest.receivedData encoding:NSUTF8StringEncoding];
		NSManagedObjectID* objectID = rest.context;
		CFUploadParser* parser = [[CFUploadParser alloc] initWithCredentialID:objectID];
		[parser deserialize:xml];
		[parser release];
	} else {
		// error handling
	}
}

+ (void) fetch:(CFCredential*)credential {
	REST* rest = [[REST alloc] initWithCredential:credential method:@"GET" action:@"rooms.xml" payload:nil context:credential.objectID];
	[rest setTarget:self withCallback:@selector(onFetch:)];
	[rest start];
}

+ (void) onFetch:(REST*)rest {
	if([rest.response statusCode] == 200) {
		NSString* xml = [[NSString alloc] initWithData:rest.receivedData encoding:NSUTF8StringEncoding];
		NSManagedObjectID* objectID = rest.context;
		CFRoomParser* parser = [[CFRoomParser alloc] initWithCredentialID:objectID];
		[parser deserialize:xml];
		[parser release];
	} else {
		// error handling
	}
	[rest release];
}

- (void) fetch {
	NSString* action = [NSString stringWithFormat:@"room/%d.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"GET" action:action payload:nil context:self.credential.objectID];
	[rest setTarget:self withCallback:@selector(onFetch:)];
	[rest start];
}

- (void) onFetch:(REST*)rest {
	if([rest.response statusCode] == 200) {
		NSString* xml = [[NSString alloc] initWithData:rest.receivedData encoding:NSUTF8StringEncoding];
		NSManagedObjectID* objectID = rest.context;
		CFRoomParser* parser = [[CFRoomParser alloc] initWithCredentialID:objectID];
		[parser deserializeObject:xml];
		[parser release];
	} else {
		// error handling
	}
	[rest release];
}

- (void) join {
	NSString* action = [NSString stringWithFormat:@"room/%d/join.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"POST" action:action payload:nil context:self.credential.objectID];
	[rest start];
}

- (void) join:(id)sender action:(SEL)callback {
	NSString* action = [NSString stringWithFormat:@"room/%d/join.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"POST" action:action payload:nil context:self.credential.objectID];
	[rest setTarget:sender withCallback:callback];
	[rest start];	
}

- (void) leave {
	NSString* action = [NSString stringWithFormat:@"room/%d/leave.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"POST" action:action payload:nil context:self.credential.objectID];
	[rest start];	
}

- (void) lock {
	NSString* action = [NSString stringWithFormat:@"room/%d/lock.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"POST" action:action payload:nil context:self.credential.objectID];
	[rest start];
}

- (void) unlock {
	NSString* action = [NSString stringWithFormat:@"room/%d/unlock.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"POST" action:action payload:nil context:self.credential.objectID];
	[rest start];
}

- (void) update {
	CFRoomParser* parser = [[CFRoomParser alloc] initWithCredentialID:self.credential.objectID];
	NSData* xml = [[parser serialize:self] dataUsingEncoding:NSUTF8StringEncoding];
	NSString* action = [NSString stringWithFormat:@"room/%d.xml", [self.roomID intValue]];
	REST* rest = [[REST alloc] initWithCredential:self.credential method:@"PUT" action:action payload:xml context:self.credential.objectID];
	[rest start];
	[parser release];
}

@end
