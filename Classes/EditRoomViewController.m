//
//  EditRoomViewController.m
//  Campfire
//
//  Created by Jeff Miller on 24/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditRoomViewController.h"
#import "CFCoreData.h"
#import "CampfireModels.h"
#import "CampfireAppDelegate.h"


@implementation EditRoomViewController

@synthesize tableView;

@synthesize nameCell;
@synthesize topicCell;
@synthesize lockCell;

@synthesize nameTextField;
@synthesize topicTextField;
@synthesize lockSwitch;
@synthesize roomID;
@synthesize credentialID;

- (void) dealloc {
	self.tableView = nil;
	self.nameCell = nil;
	self.topicCell = nil;
	self.lockCell = nil;
	self.nameTextField = nil;
	self.topicTextField = nil;
	self.lockSwitch = nil;
	self.roomID = nil;
	self.credentialID = nil;
	[super dealloc];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Edit";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onSave:)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel:)];
}

- (void) onCancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) onSave:(id)sender {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	if(![appDelegate networkAvailable]) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:@"Failed to edit the room because no network connection was found" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		CFCoreData* cd = [CFCoreData new];
		CFRoom* room = [cd entityByID:roomID];
		room.name = self.nameTextField.text;
		room.topic = self.topicTextField.text;
		[room update];
		[cd commit];
		[cd release];	
	}	
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	CFCoreData* cd = [CFCoreData new];
	CFRoom* room = [cd entityByID:roomID];
	self.nameTextField.text = room.name;
	self.topicTextField.text = room.topic;
	[cd release];
	
	[self.nameTextField becomeFirstResponder];
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		return self.nameCell;
	} else {
		return self.topicCell;
	}
}

@end
