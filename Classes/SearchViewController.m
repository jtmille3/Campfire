//
//  SearchViewController.m
//  Campfire
//
//  Created by Jeff Miller on 07/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "BubbleCell.h"
#import "CampfireAppDelegate.h"


@implementation SearchViewController

@synthesize searchBar;
@synthesize datePicker;

- (void)dealloc {
	self.searchBar = nil;
	self.datePicker = nil;
    [super dealloc];
}

- (id) init {
	if(self = [super init]) {
		self.title = @"Search";
	}
	
	return self;
}

- (void) viewDidLoad {
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.scrollEnabled = YES;
	self.navigationItem.rightBarButtonItem = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	self.datePicker.date = [NSDate date];
	[self.room fetchMessagesOperationForDate:self.datePicker.date];
	[self fetch];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.frame = CGRectMake(0, 0, 320, 480);
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	self.tableView.frame = CGRectMake(0, 0, 320, 200);
}

- (IBAction) onDateChanged:(id)sender {
	[self.room fetchMessagesOperationForDate:self.datePicker.date];
	[self fetch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
	if(![appDelegate networkAvailable]) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:@"Search failed because no network connection was found" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	NSString* filter = [self.searchBar.text stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	[self.room fetchMessagesOperationForText:filter];	
	[self fetch];
}

- (UITableViewCell*) bubbleCell {
    static NSString *CellIdentifier = @"CFMessageBubble";
    
    UITableViewCell *cell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[BubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;		
    }
	
	return cell;
}

- (UITableViewCell*) normalCell {
    static NSString *CellIdentifier = @"CFMessage";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.textLabel.textColor = [UIColor lightGrayColor];
    }
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self fetch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self fetch];	
}

#pragma mark -
#pragma mark Fetched results controller

// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[super controllerDidChangeContent:controller];
	[self.searchDisplayController.searchResultsTableView reloadData];
}

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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CFMessage" inManagedObjectContext:self.coreData.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// do date comparison if it's being used.  Otherwise used text search
	if([self.searchBar.text length] > 0) {
		NSString* like = [NSString stringWithFormat:@"*%@*", self.searchBar.text];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"credential=%@ AND room=%@ AND body LIKE[cd] %@", self.credential, self.room, like];
		[fetchRequest setPredicate:predicate];
	} else {
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.datePicker.date];
		NSDate *from = [gregorian dateFromComponents:components];
		[components setDay:[components day] + 1];
		NSDate* to = [gregorian dateFromComponents:components];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"credential=%@ AND room=%@ AND createdAt >= %@ AND createdAt < %@", self.credential, self.room, from, to];
		[fetchRequest setPredicate:predicate];		
	}
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreData.managedObjectContext sectionNameKeyPath:nil cacheName:@"createdAt"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
} 

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}


@end
