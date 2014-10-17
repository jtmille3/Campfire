//
//  AccountViewController.m
//  Campfire
//
//  Created by Jeff Miller on 15/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"
#import "CampfireModels.h"
#import "RoomViewController.h"
#import "CredentialViewController.h"
#import "GradientCell.h"


@implementation AccountViewController

#pragma mark UIViewController

- (id) init {
	if(self = [super init]) {
		self.title = @"Accounts";
	}
	
	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAdd:)];
}

- (IBAction) onAdd:(id)sender {
	CredentialViewController* credentialViewController = [CredentialViewController new];
	credentialViewController.delegate = self;
	credentialViewController.credentialID = nil;
	[ResourceBundle setCredentialID:0];
	[self presentModalViewController:credentialViewController animated:YES];
	[credentialViewController release];
}

- (void) onLogin:(id)sender {

}

#pragma mark UITableView

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CFCredential";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GradientCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	// Configure the cell.
	CFCredential *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = managedObject.username;
	cell.detailTextLabel.text = managedObject.account;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CFCredential *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	[ResourceBundle setCredentialID:[selectedObject.me.userID intValue]];
	if(self.editing) {
		CredentialViewController* credentialViewController = [CredentialViewController new];
		credentialViewController.delegate = self;
		credentialViewController.credentialID = selectedObject.objectID;
		[self presentModalViewController:credentialViewController animated:YES];
		[credentialViewController release];
	} else {
		[ResourceBundle setCredentialID:[selectedObject.me.userID intValue]];	
		RoomViewController* roomViewController = [RoomViewController new];
		roomViewController.credentialID = selectedObject.objectID;
		[CFRoom fetch:selectedObject];
		[self.navigationController pushViewController:roomViewController animated:YES];
		[roomViewController release];		
	}
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			ALog(@"Error during delete");
		}
		
		[ResourceBundle setCredentialID:0];
	}   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if(self.editing != editing) {
		[super setEditing:editing animated:animated];
		[self.tableView setEditing:editing animated:animated];
	}
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CFCredential" inManagedObjectContext:self.coreData.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"account" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreData.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

@end
