//
//  CFRoomParser.h
//  Campfire
//
//  Created by Jeff Miller on 17/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFParser.h"

@interface CFRoomParser : CFParser {
	NSMutableDictionary* roomDictionary;
	NSMutableDictionary* userDictionary;
	CFRoom* room;
	CFUser* user;
}

@property (nonatomic,assign) CFRoom* room;
@property (nonatomic,assign) CFUser* user;
@property (nonatomic,retain) NSMutableDictionary* roomDictionary;
@property (nonatomic,retain) NSMutableDictionary* userDictionary;

- (void) deserializeObject:(NSString *)xml;
@end
