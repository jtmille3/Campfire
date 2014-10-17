//
//  ChatViewController.h
//  Campfire
//
//  Created by Jeff Miller on 17/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "CFStream.h"


@interface ChatViewController : RootViewController<UITextViewDelegate,CFStreamDelegate,UISearchBarDelegate> {
@protected
	NSManagedObjectID* roomID;
	
	UITextView *chatBox;
	UIImageView* chatView;
	
	CFStream* stream;
	
	NSMutableData* messageData;
}

@property (nonatomic, retain) NSManagedObjectID* roomID;
@property (nonatomic, readonly) CFRoom* room;

@property (nonatomic, retain) IBOutlet UITextView *chatBox;
@property (nonatomic, retain) IBOutlet UIImageView *chatView;
@property (nonatomic, retain) CFStream* stream;
@property (nonatomic, retain) NSMutableData* messageData;

@end
