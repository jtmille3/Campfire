//
//  CFMessageParser.h
//  Campfire
//
//  Created by Jeff Miller on 17/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFParser.h"


@interface CFMessageParser : CFParser {
	NSMutableDictionary* dictionary;
	CFMessage* message;
	CFUser* user;
	CFRoom* room;
	
	NSDateFormatter* df2;
}

@property (nonatomic,assign) CFMessage* message;
@property (nonatomic,assign) CFUser* user;
@property (nonatomic,assign) CFRoom* room;
@property (nonatomic,retain) NSMutableDictionary* dictionary;

@end
