//
//  CFMessageParser.m
//  Campfire
//
//  Created by Jeff Miller on 17/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFMessageParser.h"


@implementation CFMessageParser

@synthesize dictionary;
@synthesize message;
@synthesize room;
@synthesize user;

- (void) dealloc {
	self.message = nil;
	self.room = nil;
	self.user = nil;
    self.dictionary = nil;
    
	[df2 release];
    [super dealloc];
}

- (id) initWithCredentialID:(NSManagedObjectID *)theCredentialID {
	if(self = [super initWithCredentialID:theCredentialID]) {
		df2 = [[NSDateFormatter alloc] init];
		[df2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	}
	return self;
}

#pragma mark -
#pragma mark Campfire Parser methods

- (NSString*) serialize:(CFMessage*)object {
	NSMutableString* xml = [[NSMutableString alloc] init];
	
	[xml appendString:@"<message>"];
	
	[xml appendFormat:@"<type>%@</type>", object.type];
	[xml appendFormat:@"<body><![CDATA[%@]]></body>", object.body];
	
	[xml appendString:@"</message>"];
	return xml;
}

- (void) deserialize:(NSString*)xml {    
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

#pragma mark -
#pragma mark NSXMLParser methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {		
	if ( [elementName isEqualToString:@"message"] ) {
        self.dictionary = [NSMutableDictionary dictionary];
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
	
	if( [elementName isEqualToString:@"message"] ) {     
        NSInteger messageID = [[self.dictionary objectForKey:@"id"] intValue];
        NSPredicate* messagePredicate = [NSPredicate predicateWithFormat:@"messageID=%d AND credential=%@", messageID, self.credential];
        self.message = [self.coreData find:@"CFMessage" withPredicate:messagePredicate];
        
        if(!self.message)
            self.message = [self.coreData entity:@"CFMessage"];
        
        self.message.messageID = [NSNumber numberWithInt:messageID];
        self.message.body = [self.dictionary objectForKey:@"body"];
        self.message.type = [self.dictionary objectForKey:@"type"];
        self.message.createdAt = [df dateFromString:[self.dictionary objectForKey:@"created-at"]]; // 2010-03-18T07:33:38Z
		if (!self.message.createdAt) 
			self.message.createdAt = [df2 dateFromString:[self.dictionary objectForKey:@"created-at"]];; // 2010-03-18 07:33:38
		if(!self.message.createdAt)
			self.message.createdAt = [NSDate date];
		
		if(self.credential)
			self.message.credential = self.credential;
		
		self.message.fetchedAt = self.fetchedAt;
		
		// todo room
 		NSInteger roomID = [[self.dictionary objectForKey:@"room-id"] intValue];
        NSPredicate* roomPredicate = [NSPredicate predicateWithFormat:@"roomID=%d AND credential=%@", roomID, self.credential];
        self.room = [self.coreData find:@"CFRoom" withPredicate:roomPredicate];
        
        if(!self.room)
			self.room = [self.coreData entity:@"CFRoom"];
		
		self.room.roomID = [NSNumber numberWithInt:roomID];
		self.room.credential = self.credential;
		self.message.room = self.room;
		
		// only assign if the user-id > 0
		NSInteger userID = [[self.dictionary objectForKey:@"user-id"] intValue];
		if(userID > 0) {
			NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"userID=%d AND credential=%@", userID, self.credential];
			self.user = [self.coreData find:@"CFUser" withPredicate:userPredicate];
			
			if(!self.user) {
				self.user = [self.coreData entity:@"CFUser"];	
				self.user.name = @"Unknown";
			}  
			
			self.user.userID = [NSNumber numberWithInt:userID];
			self.user.credential = self.credential;		
			self.message.user = self.user;			
		}     
	}
    
	[self.dictionary setValue:self.currentStringValue forKey:elementName];
    self.currentStringValue = nil;	
}


@end
