//
//  WebViewController.h
//  Campfire
//
//  Created by Jeff Miller on 14/03/2010.
//  Copyright 2010 Cloud9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface WebViewController : UIViewController<UIWebViewDelegate> {
	UIWebView* webView;
	UILabel* messageLabel;
	NSManagedObjectID* messageID;
	NSManagedObjectID* credentialID;
}

@property (nonatomic,retain) IBOutlet UIWebView* webView;
@property (nonatomic,retain) IBOutlet UILabel* messageLabel;
@property (nonatomic,retain) NSManagedObjectID* messageID;
@property (nonatomic,retain) NSManagedObjectID* credentialID;
@property (nonatomic,readonly) CFMessage* message;
@property (nonatomic,readonly) CFUpload* upload;
@property (nonatomic,readonly) CFCoreData* coreData;

@end
