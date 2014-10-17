//
//  CFRoomParser.m
//  Campfire
//
//  Created by Jeff Miller on 17/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFRoomParser.h"


@implementation CFRoomParser

@synthesize room;
@synthesize user;
@synthesize roomDictionary;
@synthesize userDictionary;

- (void) dealloc {
	self.room = nil;
	self.user = nil;
    self.roomDictionary = nil;
	self.userDictionary = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Campfire Parser methods

- (NSString*) serialize:(CFRoom*)object {
	NSMutableString* xml = [[NSMutableString alloc] init];
	
	[xml appendString:@"<room>"];
	
	[xml appendFormat:@"<name>%@</name>", object.name == nil ? @"" : object.name];
	[xml appendFormat:@"<topic>%@</topic>", object.topic == nil ? @"" : object.topic];
	
	[xml appendString:@"</room>"];
	return xml;
}

- (void) deserializeObject:(NSString *)xml {
    self.parser = [[NSXMLParser alloc] initWithData:[[xml dataUsingEncoding:NSUTF8StringEncoding] autorelease]];
    [self.parser setDelegate:self];	
    [self.parser setShouldResolveExternalEntities:YES];	
	
    if([self.parser parse]) {		
        [self.coreData commit];
    } else {
        @throw [NSException exceptionWithName:@"Parsing Exception" reason:@"Failed to parse tasks." userInfo:nil];
    }
	
    self.parser = nil;
	
}

- (void) deserialize:(NSString*)xml {  	
    self.parser = [[NSXMLParser alloc] initWithData:[[xml dataUsingEncoding:NSUTF8StringEncoding] autorelease]];
    [self.parser setDelegate:self];	
    [self.parser setShouldResolveExternalEntities:YES];	
	
    if([self.parser parse]) {
		NSPredicate* stalePredicate = [NSPredicate predicateWithFormat:@"fetchedAt < %@ AND credential=%@", self.fetchedAt, self.credential];
		[self.coreData deleteAllObjects:@"CFRoom" withPredicate:stalePredicate];
		
        [self.coreData commit];
    } else {
        @throw [NSException exceptionWithName:@"Parsing Exception" reason:@"Failed to parse tasks." userInfo:nil];
    }
	
    self.parser = nil;
}

#pragma mark -
#pragma mark NSXMLParser methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {		
	if ( [elementName isEqualToString:@"room"]) {
        self.roomDictionary = [NSMutableDictionary dictionary];
	}
	
	if ( [elementName isEqualToString:@"user"]) {
        self.userDictionary = [NSMutableDictionary dictionary];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
    if (self.currentStringValue == nil) {		
        self.currentStringValue = [NSString string];		
    }	
    
    self.currentStringValue = [self.currentStringValue stringByAppendingString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {		
    if(self.currentStringValue)
        self.currentStringValue = [self.currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if( [elementName isEqualToString:@"room"] ) {       
        NSInteger roomID = [[self.roomDictionary objectForKey:@"id"] intValue];
        NSPredicate* roomPredicate = [NSPredicate predicateWithFormat:@"roomID=%d AND credential=%@", roomID, self.credential];
        self.room = [self.coreData find:@"CFRoom" withPredicate:roomPredicate];
        
        if(!self.room)
            self.room = [self.coreData entity:@"CFRoom"];
        
        self.room.roomID = [NSNumber numberWithInt:roomID];
        self.room.name = [self.roomDictionary objectForKey:@"name"];
        self.room.topic = [self.roomDictionary objectForKey:@"topic"];
		self.room.membershipLimit = [NSNumber numberWithBool:[[self.roomDictionary objectForKey:@"membership-limit"] intValue]];
		self.room.full = [NSNumber numberWithBool:[[self.roomDictionary objectForKey:@"full"] boolValue]];
		self.room.openToGuests = [NSNumber numberWithBool:[[self.roomDictionary objectForKey:@"open-to-guests"] boolValue]];			
        self.room.createdAt = [df dateFromString:[self.roomDictionary objectForKey:@"created-at"]];
		self.room.updatedAt = [df dateFromString:[self.roomDictionary objectForKey:@"updated-at"]];
		
		if ([self.roomDictionary objectForKey:@"active-token-value"]) {
			self.room.activeTokenValue = [self.roomDictionary objectForKey:@"active-token-value"];
		}
		
		if(![self.room.users containsObject:self.credential.me]) {
			[self.room addUsersObject:self.credential.me];	
		}	
		
		if(self.credential)
			self.room.credential = self.credential;
		
		self.room.fetchedAt = self.fetchedAt;
	
		self.roomDictionary = nil;
	}
	
	// only useful on /room/%d.xml
	if( [elementName isEqualToString:@"user"] ) {       
        NSInteger userID = [[self.userDictionary objectForKey:@"id"] intValue];
        NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"userID=%d AND credential=%@", userID, self.credential];
        self.user = [self.coreData find:@"CFUser" withPredicate:userPredicate];
        
        if(!self.user)
            self.user = [self.coreData entity:@"CFUser"];
        
        self.user.userID = [NSNumber numberWithInt:userID];
        self.user.name = [self.userDictionary objectForKey:@"name"];
		self.user.emailAddress = [self.userDictionary objectForKey:@"email-address"];
		self.user.admin = [NSNumber numberWithBool:[[self.userDictionary objectForKey:@"admin"] boolValue]];
        self.user.createdAt = [df dateFromString:[self.userDictionary objectForKey:@"created-at"]];
        self.user.type = [self.userDictionary objectForKey:@"type"];
		
		if ([self.userDictionary objectForKey:@"api-auth-token"]) {
			self.user.apiAuthToken = [self.userDictionary objectForKey:@"api-auth-token"];			
		}
		
		if(self.credential)
			self.user.credential = self.credential;
		
		self.user.fetchedAt = self.fetchedAt;
		
		NSInteger roomID = [[self.roomDictionary objectForKey:@"id"] intValue];
        NSPredicate* roomPredicate = [NSPredicate predicateWithFormat:@"roomID=%d AND credential=%@", roomID, self.credential];
        self.room = [self.coreData find:@"CFRoom" withPredicate:roomPredicate];
        
        if(!self.room)
            self.room = [self.coreData entity:@"CFRoom"];
		
		if(self.credential)
			self.room.credential = self.credential;        
		
        self.room.roomID = [NSNumber numberWithInt:roomID];
		[self.room addUsersObject:self.user];
		
		self.userDictionary = nil;
	}
    
	if(self.userDictionary) {
		[self.userDictionary setValue:self.currentStringValue forKey:elementName];		
	} else if(self.roomDictionary) {
		[self.roomDictionary setValue:self.currentStringValue forKey:elementName];
	}

    self.currentStringValue = nil;	
}

@end
