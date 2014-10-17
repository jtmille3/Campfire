//
//  CFCredentialExtended.h
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFCredential.h"


@interface CFCredential (CFCredentialExtended)

- (NSURL*) action:(NSString*)fragment;
- (NSString*) basicAuth;

@end
