//
//  CFUploadParser.h
//  Campfire
//
//  Created by Jeff Miller on 14/03/2010.
//  Copyright 2010 Cloud9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFParser.h"

@interface CFUploadParser : CFParser {
	NSMutableDictionary* dictionary;
	CFUpload* upload;
	CFRoom* room;
	CFUser* user;
}

@property (nonatomic,assign) CFUpload* upload;
@property (nonatomic,assign) CFRoom* room;
@property (nonatomic,assign) CFUser* user;
@property (nonatomic,retain) NSMutableDictionary* dictionary;

@end
