//
//  AccountViewController.m
//  Campfire
//
//  Created by Jeff Miller on 15/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "CampfireAppDelegate.h"
#import "ReadonlyCoreData.h"


@implementation RootViewController

@synthesize tableView;
@synthesize fetchedResultsController;
@synthesize credentialID;

- (void)dealloc {
	self.tableView = nil;
	self.fetchedResultsController = nil;
	self.credentialID = nil;

    [super dealloc];
}

#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	[self fetch];	
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) fetch {
	NSError *error;
	self.fetchedResultsController = nil;
	BOOL success = [self.fetchedResultsController performFetch:&error];
	if(!success) {
		ALog(@"%@", error);
	}
	else {
		[self.tableView reloadData];
	}	
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName:@"Override" reason:@"Override" userInfo:nil];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    @throw [NSException exceptionWithName:@"Override" reason:@"Override" userInfo:nil];
}    


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[self.tableView reloadData];
}

- (CFCoreData*) coreData {
	return [ReadonlyCoreData sharedManager];
}

- (CFCredential*) credential {
	return [self.coreData entityByID:self.credentialID];
}


@end
