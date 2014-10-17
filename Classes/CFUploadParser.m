//
//  CFUploadParser.m
//  Campfire
//
//  Created by Jeff Miller on 14/03/2010.
//  Copyright 2010 Cloud9. All rights reserved.
//

#import "CFUploadParser.h"


@implementation CFUploadParser

@synthesize dictionary;
@synthesize upload;
@synthesize user;
@synthesize room;

- (void) dealloc {
	self.user = nil;
	self.room = nil;
	self.upload = nil;
    self.dictionary = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Campfire Parser methods

- (NSString*) serialize:(id)object {
    @throw [NSException exceptionWithName:@"Parsing Exception" reason:@"Readonly" userInfo:nil];
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
	if ( [elementName isEqualToString:@"upload"] ) {
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
	
	if( [elementName isEqualToString:@"upload"] ) {       
        NSInteger uploadID = [[self.dictionary objectForKey:@"id"] intValue];
        NSPredicate* uploadPredicate = [NSPredicate predicateWithFormat:@"uploadID=%d AND credential=%@", uploadID, self.credential];
        self.upload = [self.coreData find:@"CFUpload" withPredicate:uploadPredicate];
        
        if(!self.upload)
            self.upload = [self.coreData entity:@"CFUpload"];
		
        self.upload.uploadID = [NSNumber numberWithInt:uploadID];
        self.upload.byteSize = [NSNumber numberWithInt:[[self.dictionary objectForKey:@"byte-size"] intValue]];
		self.upload.contentType = [self.dictionary objectForKey:@"content-type"];
		self.upload.createdAt = [df dateFromString:[self.dictionary objectForKey:@"created-at"]];
		self.upload.fullUrl = [self.dictionary objectForKey:@"full-url"];
		self.upload.name = [self.dictionary objectForKey:@"name"];
		
		if(self.credential)
			self.upload.credential = self.credential;
		
		self.upload.fetchedAt = self.fetchedAt;
		
		// todo room
 		NSInteger roomID = [[self.dictionary objectForKey:@"room-id"] intValue];
        NSPredicate* roomPredicate = [NSPredicate predicateWithFormat:@"roomID=%d AND credential=%@", roomID, self.credential];
        self.room = [self.coreData find:@"CFRoom" withPredicate:roomPredicate];
        
        if(!self.room)
			self.room = [self.coreData entity:@"CFRoom"];
		
		self.room.roomID = [NSNumber numberWithInt:roomID];
		self.room.credential = self.credential;
		self.upload.room = self.room;
		
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
			self.upload.user = self.user;	
		}  
	}
    
    [self.dictionary setValue:self.currentStringValue forKey:elementName];	
    self.currentStringValue = nil;	
}


@end
