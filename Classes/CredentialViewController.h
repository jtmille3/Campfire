//
//  CredentialViewController.h
//  Campfire
//
//  Created by Jeff Miller on 15/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFCoreData.h"

@protocol CredentialDelegate

- (void) onLogin:(CFCredential*)credential;

@end



@interface CredentialViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView* tableView;
	
	UITableViewCell* accountCell;
	UITableViewCell* usernameCell;
	UITableViewCell* passwordCell;
	UITableViewCell* buttonCell;
	
	UITextField* accountTextField;
	UITextField* usernameTextField;
	UITextField* passwordTextField;	
	
	id<CredentialDelegate> delegate;
	
	NSManagedObjectID* credentialID;
}

@property (nonatomic,retain) IBOutlet UITableView* tableView;
@property (nonatomic,retain) IBOutlet UITableViewCell* accountCell;
@property (nonatomic,retain) IBOutlet UITableViewCell* usernameCell;
@property (nonatomic,retain) IBOutlet UITableViewCell* passwordCell;
@property (nonatomic,retain) IBOutlet UITableViewCell* buttonCell;
@property (nonatomic,retain) IBOutlet UITextField* accountTextField;
@property (nonatomic,retain) IBOutlet UITextField* usernameTextField;
@property (nonatomic,retain) IBOutlet UITextField* passwordTextField;

@property (nonatomic,retain) id<CredentialDelegate> delegate;

@property (nonatomic,retain) NSManagedObjectID* credentialID;

- (IBAction) login:(id)sender;

@end
