//
//  CFUser.h
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CFCredential;
@class CFMessage;
@class CFRoom;
@class CFUpload;

@interface CFUser :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * apiAuthToken;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * admin;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CFCredential * credential;
@property (nonatomic, retain) NSSet* messages;
@property (nonatomic, retain) NSSet* uploads;
@property (nonatomic, retain) NSSet* rooms;
@property (nonatomic, retain) NSDate * fetchedAt;

@end


@interface CFUser (CoreDataGeneratedAccessors)
- (void)addMessagesObject:(CFMessage *)value;
- (void)removeMessagesObject:(CFMessage *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

- (void)addUploadsObject:(CFUpload *)value;
- (void)removeUploadsObject:(CFUpload *)value;
- (void)addUploads:(NSSet *)value;
- (void)removeUploads:(NSSet *)value;

- (void)addRoomsObject:(CFRoom *)value;
- (void)removeRoomsObject:(CFRoom *)value;
- (void)addRooms:(NSSet *)value;
- (void)removeRooms:(NSSet *)value;

@end

