//
//  BungalowXMLParser.m
//  Bungalow
//
//  Created by Jeff Miller on 08/07/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import "CFParser.h"
#import "CampfireAppDelegate.h"

@implementation CFParser

@synthesize parser;
@synthesize currentStringValue;
@synthesize coreData;
@synthesize credentialID;
@synthesize fetchedAt;


- (id) initWithCredentialID:(NSManagedObjectID*)theCredentialID {
    if(self = [super init]) {
        df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		sf = [[NSDateFormatter alloc] init];
		[sf setDateFormat:@"yyyy-MM-dd"];
        
        self.coreData = [[CFCoreData alloc] init];
		self.credentialID = theCredentialID;
		self.fetchedAt = [NSDate date];
    }
    
    return self;
}

- (NSString*) serialize:(id)object {
    @throw [NSException exceptionWithName:@"Override Me!" reason:@"Abstract" userInfo:nil];
}

- (void) deserialize:(NSString*)xml {
    @throw [NSException exceptionWithName:@"Override Me!" reason:@"Abstract" userInfo:nil];    
}

- (CFCredential*) credential {
	return [self.coreData entityByID:self.credentialID];
}

#pragma mark -
#pragma mark SQL Credential

- (void) dealloc {
	self.credentialID;
    self.parser = nil;
    self.currentStringValue = nil;
    self.coreData = nil;
	self.fetchedAt = nil;
    
    [df release];
    [sf release];
    
    [super dealloc];
}

@end
