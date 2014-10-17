//
//  CFCredentialExtended.m
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFCredentialExtended.h"
#import "ResourceBundle.h"
#import "CFUser.h"
#import "NSData-Base64.h"


@implementation CFCredential (CFCredentialExtended)

- (NSURL*) action:(NSString*)fragment {
	NSString* protocol = [ResourceBundle ssl] ? @"https" : @"http";
	NSString* urlString = [NSString stringWithFormat:@"%@://%@.campfirenow.com/%@", protocol , self.account, fragment];
	return [NSURL URLWithString:urlString];
}

- (NSString*) basicAuth {
	NSString* credentialsString = nil;
	
	if(self.me.apiAuthToken) {
		credentialsString = [[self.me.apiAuthToken stringByAppendingString:@":"] stringByAppendingString:@"X"];	
	} else {
		credentialsString = [[self.username stringByAppendingString:@":"] stringByAppendingString:self.password];	
	}
	
	NSData* credentialsData = [credentialsString dataUsingEncoding:NSUTF8StringEncoding];
	NSString* encodedCredentials = [credentialsData base64Encoding];
	NSString* authorizationString = [@"Basic " stringByAppendingString:encodedCredentials];            
	return authorizationString;
}

@end
