// 
//  CFMessage.m
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFMessage.h"

#import "CFCredential.h"
#import "CFRoom.h"
#import "CFUser.h"

@implementation CFMessage 

@dynamic messageID;
@dynamic createdAt;
@dynamic body;
@dynamic type;
@dynamic room;
@dynamic credential;
@dynamic user;
@dynamic fetchedAt;

@end
