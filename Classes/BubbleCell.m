//
//  BubbleCell.m
//  Campfire
//
//  Created by Jeff Miller on 21/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BubbleCell.h"


@implementation BubbleCell

@synthesize text;
@synthesize name;
@synthesize createdAt;
@synthesize sender;

- (void) setFrame:(CGRect)rect {
	[super setFrame:rect];
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
	NSDateFormatter* formatter = [NSDateFormatter new];
	[formatter setDateFormat:@"h:mm a"];
	//NSString* date = [formatter stringFromDate:self.createdAt];
	NSString* title = self.name; //[NSString stringWithFormat:@"%@ posted at %@", self.name, date];
	[formatter release];
	
	const int MAX_WIDTH = 250;
	
	UIFont* textFont = [UIFont systemFontOfSize:12];
	UIFont* nameFont = [UIFont systemFontOfSize:12];
	
	CGSize textSize = [self.text sizeWithFont:textFont constrainedToSize:CGSizeMake(MAX_WIDTH, UINT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize nameSize = [title sizeWithFont:nameFont constrainedToSize:CGSizeMake(MAX_WIDTH, UINT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	
	if(textSize.width < 10) {
		textSize = CGSizeMake(10, textSize.height);
	}
	
	if(self.sender) {
		[[UIColor lightGrayColor] set];
		[title drawAtPoint:CGPointMake(20, 0) withFont:nameFont];
		UIImage* image = [[UIImage imageNamed:@"balloon_2.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:16];
		[image drawInRect:CGRectMake(0, nameSize.height, textSize.width + 32, textSize.height + 16)];
		
		[[UIColor whiteColor] set];
		[self.text drawInRect:CGRectMake(20, nameSize.height + 6, textSize.width, textSize.height) withFont:textFont];	
		[[UIColor blackColor] set];
		[self.text drawInRect:CGRectMake(20, nameSize.height + 5, textSize.width, textSize.height) withFont:textFont];	
	} else {
		[[UIColor lightGrayColor] set];
		[title drawAtPoint:CGPointMake(rect.size.width - nameSize.width - 32 + 15, 0) withFont:nameFont];
		UIImage* image = [[UIImage imageNamed:@"balloon_1.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16];
		[image drawInRect:CGRectMake(rect.size.width - textSize.width - 32, nameSize.height, textSize.width + 32, textSize.height + 16)];

		[[UIColor whiteColor] set];
		[self.text drawInRect:CGRectMake(rect.size.width - textSize.width - 32 + 15, nameSize.height + 6, textSize.width, textSize.height) withFont:textFont];	
		[[UIColor blackColor] set];
		[self.text drawInRect:CGRectMake(rect.size.width - textSize.width - 32 + 15, nameSize.height + 5, textSize.width, textSize.height) withFont:textFont];	
	}
}

- (void) setMessage:(CFMessage*)message {
	self.text = message.body;
	self.name = message.user.name;
	self.createdAt = message.createdAt;
	self.sender = [message.user.userID intValue] == [message.credential.me.userID intValue];
	[self setNeedsDisplay];
}

- (void) dealloc {
	self.name = nil;
	self.createdAt = nil;
	self.text = nil;
	[super dealloc];
}

@end
