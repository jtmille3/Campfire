//
//  NSStreamExtended.m
//  Campfire
//
//  Created by Jeff Miller on 26/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFStream.h"
#import "ResourceBundle.h"


@implementation CFStream

@synthesize oStream;
@synthesize iStream;
@synthesize delegate;
@synthesize basicAuth;
@synthesize url;

CFReadStreamRef readStream = NULL;
CFWriteStreamRef writeStream = NULL;

- (void) start:(CFRoom*)room
{
	NSString* protocol = [ResourceBundle ssl] ? @"https" : @"http";
	NSInteger port = [ResourceBundle ssl] ? 443 : 80;
	NSString* action = [NSString stringWithFormat:@"%@://streaming.campfirenow.com/room/%d/live.xml", protocol, [room.roomID intValue]];
	NSURL* theUrl = [NSURL URLWithString:action];
	
	self.basicAuth = [room.credential basicAuth];
	self.url = theUrl;
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[self.url host], port, &readStream, &writeStream);
	
	self.iStream = (NSInputStream *)readStream;
	if([ResourceBundle ssl])
		[self.iStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
	self.oStream = (NSOutputStream *)writeStream;
	[self.iStream setDelegate:self];
	[self.oStream setDelegate:self];
	[self.iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.iStream open];
	[self.oStream open];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {	
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            if (stream == self.oStream) {
                NSString * str = [NSString stringWithFormat:
								  @"GET %@ HTTP/1.0\r\nAuthorization: %@\r\n\r\n", 
								  [self.url relativePath], self.basicAuth];
				//ALog(@"%@", str);
                const uint8_t * rawstring = (const uint8_t *)[str UTF8String];
                [self.oStream write:rawstring maxLength:strlen(rawstring)];
                [self.oStream close];
            }
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[1024];
            unsigned int length = 0;
            length = [(NSInputStream *)stream read:buf maxLength:1024];
            if(length) {
				NSMutableData* data = [[NSMutableData alloc] init];
                [data appendBytes:(const void *)buf length:length];
				int bytesRead;
                // bytesRead is an instance variable of type NSNumber.
                bytesRead += length;
				
				if(self.delegate)
					[self.delegate onReadEvent:data];
				[data release];
            } else {
                NSLog(@"no buffer!");
            }
            break;
        }
		NSStreamEventEndEncountered:
		{
			if(self.delegate)
				[self.delegate onEndEvent];			
			[self disconnect];
			break;
		}
		NSStreamEventErrorOccurred:
		{
			if(self.delegate)
				[self.delegate onErrorEvent];
			NSLog(@"Error Occurred");
			break;
		}
		NSStreamEventOpenCompleted:
		{
		
		}
			// continued
	}
}

- (void) writeToServer:(const uint8_t *) buf {
    [self.oStream write:buf maxLength:strlen((char*)buf)];    
}

- (void) disconnect {
    [self.iStream close];
    [self.oStream close];
}

- (void)dealloc {
    [self disconnect];
	
	self.url = nil;
	self.basicAuth = nil;
	self.delegate = nil;
	self.iStream = nil;
	self.oStream = nil;
    
    if (readStream) CFRelease(readStream);
    if (writeStream) CFRelease(writeStream);
	
    [super dealloc];
}


@end
