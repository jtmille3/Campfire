// 
//  CFUser.m
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFUser.h"

#import "CFCredential.h"
#import "CFMessage.h"
#import "CFRoom.h"
#import "CFUpload.h"

@implementation CFUser 

@dynamic emailAddress;
@dynamic userID;
@dynamic apiAuthToken;
@dynamic type;
@dynamic admin;
@dynamic createdAt;
@dynamic name;
@dynamic credential;
@dynamic messages;
@dynamic uploads;
@dynamic rooms;
@dynamic fetchedAt;

@end
