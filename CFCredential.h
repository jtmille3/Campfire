//
//  CFCredential.h
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CFMessage;
@class CFRoom;
@class CFUpload;
@class CFUser;

@interface CFCredential :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet* messages;
@property (nonatomic, retain) NSSet* uploads;
@property (nonatomic, retain) CFUser * me;
@property (nonatomic, retain) NSSet* rooms;
@property (nonatomic, retain) NSSet* users;

@end


@interface CFCredential (CoreDataGeneratedAccessors)
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

- (void)addUsersObject:(CFUser *)value;
- (void)removeUsersObject:(CFUser *)value;
- (void)addUsers:(NSSet *)value;
- (void)removeUsers:(NSSet *)value;

@end

