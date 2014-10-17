//
//  REST.m
//  Basecamp
//
//  Created by Jeff Miller on 08/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "REST.h"
#import "CFUser.h"
#import "NSData-Base64.h"
#import "ResourceBundle.h"
#import "CampfireAppDelegate.h"

@interface REST (PrivateMethods)

- (void) printResponse;
- (void) print:(NSError*)theError;

@end



@implementation REST

@synthesize request;
@synthesize response;
@synthesize connection;
@synthesize receivedData;
@synthesize context;
@synthesize target;
@synthesize callback;
@synthesize error;
@synthesize finished;

- (void) dealloc {
	self.request = nil;
	self.response = nil;
	self.connection = nil;
	self.receivedData = nil;
	self.target = nil;
	self.callback = nil;
	self.context = nil;
	self.error = nil;
	
	[super dealloc];
}

- (id) initWithCredential:(CFCredential*)credential method:(NSString*)theMethod action:(NSString*)theAction payload:(NSData*)thePayload context:(id)theContext {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	if(![appDelegate networkAvailable]) {
		return nil;
	}
	
	if(self = [super init]) {
		NSURL* url = [credential action:theAction];
		
		self.request = [NSMutableURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:60.0];
		
		[self.request setHTTPMethod:theMethod];
		[self.request addValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
		[self.request addValue:@"application/xml" forHTTPHeaderField:@"Accept"];
		[self.request addValue:[credential basicAuth] forHTTPHeaderField:@"Authorization"];
		[self.request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
		[self.request addValue:@"" forHTTPHeaderField:@"Cookie"];
		[self.request setHTTPBody:thePayload];
		self.context = theContext;
	}
	
	return self;
}

- (void) setTarget:(id)theTarget withCallback:(SEL)theCallback {
	self.target = theTarget;
	self.callback = theCallback;
}

- (void) start {    	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		self.receivedData= [NSMutableData data];
	} else {
		// inform the user that the download could not be made
	}
}

- (void) cancel {
	[self.connection cancel];
}

- (NSURLRequest *)connection:(NSURLConnection *)theConnection willSendRequest:(NSURLRequest *)theRequest redirectResponse:(NSURLResponse *)redirectResponse {
	NSString* method = [self.request HTTPMethod];
    self.request = [[self.request mutableCopy] autorelease];
    [self.request setHTTPMethod:method];
    
    if(redirectResponse) {
		[ResourceBundle setSSL:![ResourceBundle ssl]];
    }		

    return theRequest;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse {
	self.response = (NSHTTPURLResponse*)theResponse;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)thisData {
    [self.receivedData appendData:thisData];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)theError { 
	[self print:theError];
	[self printResponse];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if(self.target && [self.target respondsToSelector:callback]) {
		[self.target performSelector:callback withObject:self];
	}
	
	self.finished = YES;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)theConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {  
  	[self printResponse];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if(self.target && [self.target respondsToSelector:callback]) {
		[self.target performSelector:callback withObject:self];
	}
	
	self.finished = YES;
}

- (void) printResponse {
	NSString* string = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
	//ALog(@"%@", string);
	[string release];
}

- (void) print:(NSError*)theError {
    ALog(@"Unresolved error %@\n%@\n%@\n%@\n%@\n%@", theError, [theError userInfo], [theError localizedDescription], [theError localizedRecoveryOptions], [theError localizedFailureReason], [theError localizedRecoverySuggestion]);
    NSLog(@"Failed to save to data store: %@", [theError localizedDescription]);
    NSArray* detailedErrors = [[theError userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors != nil && [detailedErrors count] > 0) {
        for(NSError* detailedError in detailedErrors) {
            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
        }
    }
    else {
        NSLog(@"  %@", [theError userInfo]);
    }
}

@end
