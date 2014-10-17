//
//  CFUpload.h
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CFCredential;
@class CFRoom;
@class CFUser;

@interface CFUpload :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSNumber * uploadID;
@property (nonatomic, retain) NSString * fullUrl;
@property (nonatomic, retain) NSNumber * byteSize;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CFRoom * room;
@property (nonatomic, retain) CFCredential * credential;
@property (nonatomic, retain) CFUser * user;
@property (nonatomic, retain) NSDate * fetchedAt;

@end



