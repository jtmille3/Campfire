//
//  CFUserParser.m
//  Campfire
//
//  Created by Jeff Miller on 15/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFUserParser.h"
#import "CampfireModels.h"
#import "ResourceBundle.h"


@implementation CFUserParser

@synthesize dictionary;
@synthesize user;

- (void) dealloc {
	self.user = nil;
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
	if ( [elementName isEqualToString:@"user"] ) {
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
	
	if( [elementName isEqualToString:@"user"] ) {       
        NSInteger userID = [[self.dictionary objectForKey:@"id"] intValue];
        NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"userID=%d AND credential=%@", userID, self.credential];
        self.user = [self.coreData find:@"CFUser" withPredicate:userPredicate];
        
        if(!self.user)
            self.user = [self.coreData entity:@"CFUser"];
		
        self.user.userID = [NSNumber numberWithInt:userID];
        self.user.name = [self.dictionary objectForKey:@"name"];
        self.user.emailAddress = [self.dictionary objectForKey:@"email-address"];
		self.user.admin = [NSNumber numberWithBool:[[self.dictionary objectForKey:@"admin"] boolValue]];
        self.user.createdAt = [df dateFromString:[self.dictionary objectForKey:@"created-at"]];
        self.user.type = [self.dictionary objectForKey:@"type"];
		
		if ([self.dictionary objectForKey:@"api-auth-token"]) {
			self.user.apiAuthToken = [self.dictionary objectForKey:@"api-auth-token"];			
		}
		
		if(self.credential)
			self.user.credential = self.credential;
		
		self.user.fetchedAt = self.fetchedAt;
	}
    
    [self.dictionary setValue:self.currentStringValue forKey:elementName];	
    self.currentStringValue = nil;	
}


@end
