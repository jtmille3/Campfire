//
//  CredentialViewController.m
//  Campfire
//
//  Created by Jeff Miller on 15/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CredentialViewController.h"
#import "DeviceDetection.h"
#import "CampfireModels.h"
#import "REST.h"
#import "CFUserParser.h"
#import "CFCoreData.h"
#import "ResourceBundle.h"
#import "CampfireAppDelegate.h"


@implementation CredentialViewController

@synthesize tableView;
@synthesize accountCell;
@synthesize usernameCell;
@synthesize passwordCell;
@synthesize buttonCell;
@synthesize accountTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize credentialID;
@synthesize delegate;


- (void)dealloc {
	self.tableView = nil;
	self.accountCell = nil;
	self.usernameCell = nil;
	self.passwordCell = nil;
	self.buttonCell = nil;
	self.accountTextField = nil;
	self.usernameTextField = nil;
	self.passwordTextField = nil;
	self.credentialID = nil;
	self.delegate = nil;
    [super dealloc];
}

- (IBAction) login:(id)sender {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	if(![appDelegate networkAvailable]) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:@"Login failed because no network connection was found" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[self dismissModalViewControllerAnimated:YES];
		return;
	}
	
	CFCoreData* coreData = [CFCoreData new];
	CFCredential* credential;
	if(self.credentialID == nil)
		credential = [coreData entity:@"CFCredential"];
	else 
		credential = [coreData entityByID:self.credentialID];
	
	credential.account = self.accountTextField.text;
	credential.username = self.usernameTextField.text;
	credential.password = self.passwordTextField.text;
	credential.me = nil;
	[coreData commit];
	self.credentialID = credential.objectID;
	REST* rest = [[REST alloc] initWithCredential:credential method:@"GET" action:@"users/me.xml" payload:nil context:self];
	[rest setTarget:self withCallback:@selector(onLogin:)];
	[rest start];
	[coreData release];
}

- (void) onLogin:(REST*)rest {
	CFCoreData* coreData = [CFCoreData new];
	CFCredential* credential = [coreData entityByID:self.credentialID];
	
	if([rest.response statusCode] == 200) {
		NSString* xml = [[NSString alloc] initWithData:rest.receivedData encoding:NSUTF8StringEncoding];
		CFUserParser* parser = [[CFUserParser alloc] initWithCredentialID:self.credentialID];
		[parser deserialize:xml];
		
		CFUser* user = [coreData entityByID:parser.user.objectID];
		credential.password = nil;
		credential.me = user;
		[ResourceBundle setCredentialID:[user.userID intValue]];
		
		[parser release];

		if(self.delegate) {
			[self.delegate onLogin:credential];			
		}
		[self dismissModalViewControllerAnimated:YES];
	} else {
		CFCredential* credential = [coreData entityByID:self.credentialID];
		[coreData deleteObject:credential];
		
		// error handling
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Problem" message:@"Login failed." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[coreData commit];
	[coreData release];
	[rest release];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.accountTextField becomeFirstResponder];
	
	if(self.credentialID) {
		CFCoreData* coredata = [CFCoreData new];
		CFCredential* credential = [coredata entityByID:self.credentialID];
		self.accountTextField.text = credential.account;
		self.usernameTextField.text = credential.username;
		self.passwordTextField.text = nil;
		[coredata release];	
		[self.passwordTextField becomeFirstResponder];
	} else {
		[self.accountTextField becomeFirstResponder];
	}	
}

#pragma mark UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
    if([DeviceDetection detectDevice] == MODEL_IPHONE_SIMULATOR) {
        if(textField == accountTextField) {
            [self.usernameTextField becomeFirstResponder];
        } else if(textField == usernameTextField) {
            [self.passwordTextField becomeFirstResponder];
        } else if(textField == passwordTextField) {
            [self login:self];            
        }
    } else {
        [self login:self];
    }
    
	return YES;
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
		return 1;
	else if(section == 2)
		return 1;
	else 
		return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		return accountCell;
	} else if(indexPath.section == 2) {
		return buttonCell;
	} else {
		if(indexPath.row == 0) {
			return usernameCell;
		} else {
			return passwordCell;
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
