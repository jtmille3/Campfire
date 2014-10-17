//
//  BungaloXMLParser.h
//  Bungalow
//
//  Created by Jeff Miller on 08/07/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFCoreData.h"
#import "CampfireModels.h"
#import "CFCredential.h"


@interface CFParser : NSObject {
    NSXMLParser* parser;
	NSString* currentStringValue;
    
    NSDateFormatter* df;
    NSDateFormatter* sf;
    
    NSDate* fetched;
    
    CFCoreData* coreData;
	NSManagedObjectID* credentialID;
	NSDate* fetchedAt;
}

@property (nonatomic, retain) NSXMLParser* parser;
@property (nonatomic, retain) NSString* currentStringValue;

@property (nonatomic, retain) NSDate* fetchedAt;

@property (nonatomic, retain) CFCoreData* coreData;
@property (nonatomic, readonly) CFCredential* credential;
@property (nonatomic, retain) NSManagedObjectID* credentialID;

- (id) initWithCredentialID:(NSManagedObjectID*)theCredentialID;
- (NSString*) serialize:(id)object;
- (void) deserialize:(NSString*)xml;

@end
