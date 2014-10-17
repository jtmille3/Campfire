//
//  REST.h
//  Basecamp
//
//  Created by Jeff Miller on 08/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CampfireModels.h"

@interface REST : NSObject {
	NSMutableData* receivedData;
	NSMutableURLRequest* request;
	NSHTTPURLResponse* response;
	NSURLConnection* connection;
	
	id context;
	
	SEL callback;
	id target;
	
	NSError* error;
	
	BOOL finished;
}

@property (nonatomic,retain) NSMutableData* receivedData;
@property (nonatomic,retain) NSMutableURLRequest* request;
@property (nonatomic,retain) NSHTTPURLResponse* response;
@property (nonatomic,retain) NSURLConnection* connection;
@property (nonatomic,retain) id context;
@property (nonatomic,retain) id target;
@property (nonatomic) SEL callback;
@property (nonatomic,retain) NSError* error;
@property (nonatomic) BOOL finished;

- (id) initWithCredential:(CFCredential*)credential method:(NSString*)method action:(NSString*)action payload:(NSData*)payload context:(id)context;
- (void) setTarget:(id)target withCallback:(SEL)callback;
- (void) start;

@end
