//
//  CFRoom.h
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CFCredential;
@class CFMessage;
@class CFUpload;
@class CFUser;

@interface CFRoom :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * openToGuests;
@property (nonatomic, retain) NSNumber * roomID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * full;
@property (nonatomic, retain) NSString * activeTokenValue;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSNumber * membershipLimit;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* users;
@property (nonatomic, retain) CFCredential * credential;
@property (nonatomic, retain) NSSet* messages;
@property (nonatomic, retain) NSSet* uploads;
@property (nonatomic, retain) NSDate * fetchedAt;

@end


@interface CFRoom (CoreDataGeneratedAccessors)
- (void)addUsersObject:(CFUser *)value;
- (void)removeUsersObject:(CFUser *)value;
- (void)addUsers:(NSSet *)value;
- (void)removeUsers:(NSSet *)value;

- (void)addMessagesObject:(CFMessage *)value;
- (void)removeMessagesObject:(CFMessage *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

- (void)addUploadsObject:(CFUpload *)value;
- (void)removeUploadsObject:(CFUpload *)value;
- (void)addUploads:(NSSet *)value;
- (void)removeUploads:(NSSet *)value;

@end

