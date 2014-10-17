//
//  RoomViewController.m
//  Campfire
//
//  Created by Jeff Miller on 17/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RoomViewController.h"
#import "CampfireModels.h"
#import "ChatViewController.h"
#import "REST.h"
#import "CFRoomParser.h"
#import "GradientCell.h"
#import "EditRoomViewController.h"


@implementation RoomViewController

#pragma mark UIViewController

- (id) init {
	if(self = [super init]) {
		self.title = @"Rooms";
	}
	
	return self;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if([self.credential.me.admin boolValue])
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark UITableView

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CFRoom";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GradientCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
	// Configure the cell.
	CFRoom *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = managedObject.name;
	cell.detailTextLabel.text = managedObject.topic;
	
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleInsert;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if(self.editing != editing) {
		[super setEditing:editing animated:animated];
		[self.tableView setEditing:editing animated:animated];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CFRoom *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if(self.editing) {
		EditRoomViewController* editRoomViewController = [EditRoomViewController new];
		editRoomViewController.roomID = selectedObject.objectID;
		editRoomViewController.credentialID = self.credentialID;
		[self.navigationController pushViewController:editRoomViewController animated:YES];
		[editRoomViewController release];
	} else {
		ChatViewController* chatViewController = [ChatViewController new];
		chatViewController.roomID = selectedObject.objectID;
		chatViewController.credentialID = self.credentialID;
		[self.navigationController pushViewController:chatViewController animated:YES];
		[chatViewController release];			
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CFRoom" inManagedObjectContext:self.coreData.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"credential=%@", self.credential];
	[fetchRequest setPredicate:predicate];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
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
