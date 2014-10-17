//
//  CFUserParser.h
//  Campfire
//
//  Created by Jeff Miller on 15/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFParser.h"

@interface CFUserParser : CFParser {
	NSMutableDictionary* dictionary;
	CFUser* user;
}

@property (nonatomic,assign) CFUser* user;
@property (nonatomic,retain) NSMutableDictionary* dictionary;

@end
