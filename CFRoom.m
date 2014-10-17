// 
//  CFRoom.m
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CFRoom.h"

#import "CFCredential.h"
#import "CFMessage.h"
#import "CFUpload.h"
#import "CFUser.h"

@implementation CFRoom 

@dynamic openToGuests;
@dynamic roomID;
@dynamic updatedAt;
@dynamic updated;
@dynamic full;
@dynamic activeTokenValue;
@dynamic topic;
@dynamic membershipLimit;
@dynamic createdAt;
@dynamic name;
@dynamic users;
@dynamic credential;
@dynamic messages;
@dynamic uploads;
@dynamic fetchedAt;

@end
