//
//  CampfireAppDelegate.m
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "CampfireAppDelegate.h"
#import "RoomViewController.h"
#import "ResourceBundle.h"
#import "CredentialViewController.h"
#import "AccountViewController.h"
#import "CampfireModels.h"
#import "ReadonlyCoreData.h"

@interface CampfireAppDelegate (PrivateMethods)

- (void) fetchAll:(CFCredential*)credential;

@end


@implementation CampfireAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize queue;


#pragma mark -
#pragma mark Memory management

- (void)dealloc {    
	[reachability release];
	[navigationController release];
	[window release];
	self.queue = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {  
    if([ResourceBundle isResetDatabase]) {
        [ResourceBundle setCredentialID:0];
        [ResourceBundle setResetDatabase:NO];
		// reset the database
    }
	
	self.queue = [NSOperationQueue new];
	navigationController = [[UINavigationController alloc] init];
	
	AccountViewController* accountViewController = [AccountViewController new];
	[navigationController pushViewController:accountViewController animated:NO];
	[accountViewController release];
	
	// if we already have a credential, display the rooms
	if ([ResourceBundle credentialID] >= 0) {
		CFCoreData* coreData = [CFCoreData new];
		CFCredential* credential = [coreData find:@"CFCredential" withPredicate:[NSPredicate predicateWithFormat:@"me.userID=%d", [ResourceBundle credentialID]]];
		
		if (credential) {
			RoomViewController* roomViewController = [RoomViewController new];
			roomViewController.credentialID = credential.objectID;
			[navigationController pushViewController:roomViewController animated:NO];
			[roomViewController release];			
		}
		
		[coreData release];
	}
	
    // Override point for customization after app launch    
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	//Change the host name here to change the server your monitoring
	reachability = [[Reachability reachabilityWithHostName:@"campfirenow.com"] retain];
	[reachability startNotifer];
	
	[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(onApplicationDidStart:) userInfo:nil repeats:NO];    
}

- (void) onApplicationDidStart:(id)sender {
	if([self.navigationController.topViewController isKindOfClass:[AccountViewController class]]) {
		CredentialViewController* credentialViewController = [CredentialViewController new];
		credentialViewController.delegate = self;
		[navigationController presentModalViewController:credentialViewController animated:YES];   
		[credentialViewController release];		
	}
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )notification {
    // start polling for messages
	if([self networkAvailable] && !online && [ResourceBundle credentialID] > 0) {
		online = !online;
		
		CFCoreData* coreData = [CFCoreData new];
		CFCredential* credential = [coreData find:@"CFCredential" withPredicate:[NSPredicate predicateWithFormat:@"me.userID=%d", [ResourceBundle credentialID]]];
		[self fetchAll:credential];
		[coreData release];
	}
}

- (void) onLogin:(CFCredential*)credential {
	[self fetchAll:credential];
}

- (void) fetchAll:(CFCredential*)credential {
	// edge case for rooms
	[ResourceBundle setCredentialID:[credential.me.userID intValue]];	
	RoomViewController* roomViewController = (RoomViewController*)navigationController.topViewController;
	roomViewController.credentialID = credential.objectID;
	[roomViewController fetch];
	[CFRoom fetch:credential];
}

- (BOOL) networkAvailable {
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired= [reachability connectionRequired];
	
    BOOL isNetworkStatus = networkStatus != NotReachable;
    BOOL isConnectionRequired = !connectionRequired;
    
    return isNetworkStatus && isConnectionRequired;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
}

@end

