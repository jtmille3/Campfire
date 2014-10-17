//
//  RootViewController.h
//  Campfire
//
//  Created by Jeff Miller on 13/02/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "CFCoreData.h"
#import "ShadowedTableView.h"

@interface RootViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate> {
	@public
	ShadowedTableView* tableView;
	
	NSFetchedResultsController *fetchedResultsController;
	
	NSManagedObjectID* credentialID;
}

@property (nonatomic,retain) IBOutlet ShadowedTableView* tableView;
@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,readonly) CFCoreData* coreData;
@property (nonatomic,retain) NSManagedObjectID* credentialID;
@property (nonatomic,readonly) CFCredential* credential;

- (void) fetch;

@end
