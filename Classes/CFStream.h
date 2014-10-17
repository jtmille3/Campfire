//
//  NSStreamExtended.h
//  Campfire
//
//  Created by Jeff Miller on 26/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CampfireModels.h"

@protocol CFStreamDelegate

- (void) onReadEvent:(NSData*)data;
- (void) onErrorEvent;
- (void) onEndEvent;

@end


@interface CFStream : NSObject {	
	NSInputStream *iStream;
	NSOutputStream *oStream;
	
	id<CFStreamDelegate> delegate;
	
	NSString* basicAuth;
	NSURL* url;
}

@property (nonatomic,retain) NSInputStream* iStream;
@property (nonatomic,retain) NSOutputStream* oStream;

@property (nonatomic,retain) id<CFStreamDelegate> delegate;

@property (nonatomic,retain) NSString* basicAuth;
@property (nonatomic,retain) NSURL* url;

- (void) start:(CFRoom*)room;
- (void) disconnect;
- (void) writeToServer:(const uint8_t *) buf;

@end
