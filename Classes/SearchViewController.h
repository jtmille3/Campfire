//
//  SearchViewController.h
//  Campfire
//
//  Created by Jeff Miller on 07/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"


@interface SearchViewController : ChatViewController<UISearchBarDelegate> {
	UISearchBar* searchBar;
	UIDatePicker* datePicker;
}

@property (nonatomic,retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic,retain) IBOutlet UIDatePicker* datePicker;

- (IBAction) onDateChanged:(id)sender;

@end
