//
//  EditRoomViewController.h
//  Campfire
//
//  Created by Jeff Miller on 24/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"


@interface EditRoomViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView* tableView;
	
	UITableViewCell* nameCell;
	UITableViewCell* topicCell;
	UITableViewCell* lockCell;
	
	UITextField* nameTextField;
	UITextField* topicTextField;
	
	UISwitch* lockSwitch;
	
	NSManagedObjectID* roomID;
	NSManagedObjectID* credentialID;
}

@property (nonatomic,retain) IBOutlet UITableView* tableView;

@property (nonatomic,retain) IBOutlet UITableViewCell* nameCell;
@property (nonatomic,retain) IBOutlet UITableViewCell* topicCell;
@property (nonatomic,retain) IBOutlet UITableViewCell* lockCell;

@property (nonatomic,retain) IBOutlet UITextField* nameTextField;
@property (nonatomic,retain) IBOutlet UITextField* topicTextField;

@property (nonatomic,retain) IBOutlet UISwitch* lockSwitch;

@property (nonatomic,retain) NSManagedObjectID* roomID;
@property (nonatomic,retain) NSManagedObjectID* credentialID;

@end
