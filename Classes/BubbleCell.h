//
//  BubbleCell.h
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CampfireModels.h"


@interface BubbleCell : UITableViewCell {
	NSString* text;
	NSString* name;
	NSDate* createdAt;
	BOOL sender;
}

@property (nonatomic,retain) NSString* text;
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSDate* createdAt;
@property (nonatomic) BOOL sender;

- (void) setMessage:(CFMessage*)message;

@end
