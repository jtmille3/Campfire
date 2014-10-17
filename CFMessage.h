//
//  CFMessage.h
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CFCredential;
@class CFRoom;
@class CFUser;

@interface CFMessage :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) CFRoom * room;
@property (nonatomic, retain) CFCredential * credential;
@property (nonatomic, retain) CFUser * user;
@property (nonatomic, retain) NSDate * fetchedAt;

@end



