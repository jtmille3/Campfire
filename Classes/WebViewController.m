//
//  WebViewController.m
//  Campfire
//
//  Created by Jeff Miller on 14/03/2010.
//  Copyright 2010 Cloud9. All rights reserved.
//

#import "WebViewController.h"
#import "CampfireModels.h"
#import "CFCoreData.h"
#import "ReadonlyCoreData.h"


@implementation WebViewController

@synthesize webView;
@synthesize messageLabel;
@synthesize messageID;
@synthesize credentialID;

- (void) viewDidLoad {
	[super viewDidLoad];
	self.title = @"Upload";
	self.webView.backgroundColor = [UIColor blackColor];
	if(self.upload) {
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.upload.fullUrl]]];	
	} else {
		self.messageLabel.hidden = NO;
	}
}

- (void)dealloc {
	self.credentialID = nil;
	self.messageID = nil;
	self.messageLabel = nil;
	self.webView = nil;
    [super dealloc];
}

- (CFCoreData*) coreData {
	return [ReadonlyCoreData sharedManager];
}

- (CFMessage*) message {
	return [self.coreData entityByID:self.messageID];
}

- (CFUpload*) upload {
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"room=%@ and user=%@ and credential=%@ and name=%@", self.message.room, self.message.user, self.message.credential, self.message.body];
	return [self.coreData find:@"CFUpload" withPredicate:predicate];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	// start indicator
	UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[activityView startAnimating];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	[activityView release];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// stop indicator
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	self.navigationItem.rightBarButtonItem = nil;
	// stop indicator
	//[self print:error];
}

#pragma mark -
#pragma mark Error Helpers

- (void) print:(NSError*)error {
    ALog(@"Unresolved error %@\n%@\n%@\n%@\n%@\n%@", error, [error userInfo], [error localizedDescription], [error localizedRecoveryOptions], [error localizedFailureReason], [error localizedRecoverySuggestion]);
    NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors != nil && [detailedErrors count] > 0) {
        for(NSError* detailedError in detailedErrors) {
            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
        }
    }
    else {
        NSLog(@"  %@", [error userInfo]);
    }
}


@end
