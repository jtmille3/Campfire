//
//  RoomExtended.h
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFRoom.h"
#import "REST.h"


@interface CFRoom (CFRoomExtended)

- (void) fetchUploadsOperation;
- (void) fetchMessagesOperation;
- (void) fetchMessagesOperationForDate:(NSDate*)date;
- (void) fetchMessagesOperationForText:(NSString*)text;
- (id) fetchUploads;
- (id) fetchMessages;
- (id) fetchMessagesForDate:(NSDate*)date;
- (id) fetchMessagesForText:(NSString*)text;
+ (void) fetch:(CFCredential*)credential;
- (void) fetch;
- (void) join:(id)sender action:(SEL)action;
- (void) join;
- (void) leave;
- (void) lock;
- (void) unlock;
- (void) update;

@end
