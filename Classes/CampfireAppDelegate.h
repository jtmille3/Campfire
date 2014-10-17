//
//  CampfireAppDelegate.h
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Reachability.h"
#import "CFCoreData.h"
#import "CredentialViewController.h"

@interface CampfireAppDelegate : NSObject <UIApplicationDelegate,CredentialDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	
	Reachability* reachability;
	
	BOOL online;
	
	NSOperationQueue* queue;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSOperationQueue* queue;

- (BOOL) networkAvailable;

@end

