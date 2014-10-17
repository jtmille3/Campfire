//
//  ChatViewController.m
//  Campfire
//
//  Created by Jeff Miller on 17/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChatViewController.h"
#import "REST.h"
#import "CFMessageParser.h"
#import "BubbleCell.h"
#import "EditRoomViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CFStream.h"
#import "SearchViewController.h"
#import "RoomViewController.h"
#import "CampfireAppDelegate.h"
#import "WebViewController.h"


@interface ChatViewController (PrivateMethods)

- (void) scrollToBottom:(BOOL)animated;

- (UITableViewCell*) bubbleCell;
- (UITableViewCell*) uploadCell;
- (UITableViewCell*) normalCell;
- (void) bloop;
- (void) reconnect;

- (void) selected:(NSIndexPath*)indexPath;

@end



@implementation ChatViewController

@synthesize roomID;
@synthesize chatBox;
@synthesize chatView;
@synthesize stream;
@synthesize messageData;

const int LANDSCAPE_AVAILABLE_HEIGHT = 268;
const int LANDSCAPE_KEYBOARD_HEIGHT = 162;

const int PORTRAIT_AVAILABLE_HEIGHT = 416;
const int PORTRAIT_KEYBOARD_HEIGHT = 216;

const int CHAT_BOX_HEIGHT = 36;

- (void) dealloc {
	self.roomID = nil;
	self.chatBox = nil;
	self.chatView = nil;
	self.stream = nil;
	self.messageData = nil;
	[super dealloc];
}

- (id) init {
	if(self = [super init]) {
		self.title = @"Chats";
	}
	
	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	//set notification for when keyboard shows/hides
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillHide:) 
												 name:UIKeyboardWillHideNotification 
											   object:nil];
	
	//turn off scrolling and set the font details.
	self.chatBox.scrollEnabled = NO;
	self.chatBox.font = [UIFont fontWithName:@"Helvetica" size:14]; 
	UIImage* image = [[UIImage imageNamed:@"border.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
	self.chatView.image = image;
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearch:)];
	
	[self.room fetch]; // fetch the room to find all the users
	[self.room join:self action:@selector(onJoin:)]; // join the room before anything can be done
}

- (IBAction) onSearch:(id)sender {
	SearchViewController* searchViewController = [SearchViewController new];
	searchViewController.roomID = self.roomID;
	searchViewController.credentialID = self.credentialID;
	[self.navigationController pushViewController:searchViewController animated:YES];
	[searchViewController release];
}


- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = self.room.name;
	[self scrollToBottom:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if([self.navigationController.viewControllers count] <= 2) {
		[self.room leave];	
	}
}

- (void) onJoin:(REST*)rest {
	if([rest.response statusCode] == 200) {	
		self.stream = [CFStream new];
		self.stream.delegate = self;
		[self.stream start:self.room];
		
		[self.room fetchMessagesOperation];
		[self.room fetchUploads];
	} else {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Problem" message:@"Unable to join the room." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

/**
 A lot needs to happen here.  Make sure we have the complete xml message.  Also check for joined room message so we can start streaming.
 */
- (void) onReadEvent:(NSData *)data {
	NSString* readData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
	
	// no access to the room yet, try again.
	NSRange noAccessRange = [readData rangeOfString:@"Access Denied User not in the room"];
	if(noAccessRange.length > 0) {
		[self reconnect];
		return;
	}
	
	// trim line feeds and white space.  Only interested in character content
	NSString* trimData = [readData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([trimData length] > 0) {
		
		// start appending read data
		if(!self.messageData) {
			self.messageData = [NSMutableData data];
		}		
		[self.messageData appendData:data];
		
		// if I get more than one message back this doesn't work...
		NSRange endMessageRange = [trimData rangeOfString:@"</message>" options:NSBackwardsSearch];
		
		// is it the end of the message?
		if((endMessageRange.length + endMessageRange.location) == [trimData length]) {
			
			if ([trimData rangeOfString:@"<type>TextMessage</type>"].length > 0) {
				// only bloop if the message is complete
				[self bloop];	
			}
			
			// trim to the first <message> element
			NSString* messageString = [[NSString alloc] initWithData:self.messageData encoding:NSUTF8StringEncoding];
			
			// problem...need to strip headers down to <message>
			NSRange beginMessageRange = [messageString rangeOfString:@"<message>"];
			NSString* messageXml = [messageString substringFromIndex:beginMessageRange.location];
	
			CFMessageParser* parser = [[CFMessageParser alloc] initWithCredentialID:self.credential.objectID];
			NSString* messages = [NSString stringWithFormat:@"<messages>%@</messages>", messageXml];
			[parser deserialize:messages];
			[parser release];
			
			[messageString release];
			self.messageData = nil;
		}
	}
	
	[readData release];
}

- (void) onEndEvent {
	ALog(@"End event, attempting reconnect");
	[self reconnect];
}

- (void) onErrorEvent {
	ALog(@"Error event, attempting reconnect");
	[self reconnect];
}

- (void) reconnect {
	self.stream = nil;
	self.stream = [CFStream new];
	self.stream.delegate = self;
	[self.stream start:self.room];
}

-(void) keyboardWillShow:(NSNotification *)note{
	if(![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(keyboardWillShow:) withObject:note waitUntilDone:NO];
	}
	
    // get keyboard size and loction
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &keyboardBounds];
	
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height; // 216
	
	// get a rect for the table/main frame
	CGRect tableFrame = self.tableView.frame;
	tableFrame.size.height -= kbSizeH;
	
	CGRect chatViewFrame = self.chatView.frame;
	chatViewFrame.origin.y -= kbSizeH;
	
	// get a rect for the form frame
	CGRect chatBoxFrame = self.chatBox.frame;
	chatBoxFrame.origin.y -= kbSizeH;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	
	// set views with new info
	self.tableView.frame = tableFrame;
	self.chatBox.frame = chatBoxFrame;
	self.chatView.frame = chatViewFrame;
	
	// commit animations
	[UIView commitAnimations];
	
	[self scrollToBottom:NO];
}

- (void) resizeChatBox {
	if(![self.chatBox isFirstResponder])
		return;
	
	// get the size of the text block so we can work our magic
	CGSize textSize = [self.chatBox.text 
					   sizeWithFont:self.chatBox.font 
					   constrainedToSize:CGSizeMake(self.view.frame.size.width - 20,UINT_MAX) 
					   lineBreakMode:UILineBreakModeWordWrap];
	NSInteger textSizeHeight = textSize.height;
	int availableHeight = PORTRAIT_AVAILABLE_HEIGHT;
	int keyboardHeight = PORTRAIT_KEYBOARD_HEIGHT;
	int lineHeight = 18;
	int maxTextHeight = 90;
	
	if(self.interfaceOrientation != UIDeviceOrientationPortrait) {
		availableHeight = LANDSCAPE_AVAILABLE_HEIGHT;	
		keyboardHeight = LANDSCAPE_KEYBOARD_HEIGHT;
		lineHeight = 18;
		maxTextHeight = 90;
	}
	
	if (self.chatBox.hasText)
	{
		if (textSizeHeight <= maxTextHeight)
		{					
			[self.chatBox scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];	
			
			// chatbox
			CGRect chatBoxFrame = self.chatBox.frame;			
			chatBoxFrame.origin.y = availableHeight - keyboardHeight - textSizeHeight - lineHeight;
			self.chatBox.frame = chatBoxFrame;
			
			// 
			CGRect chatViewFrame = self.chatView.frame;
			chatViewFrame.size.height = textSizeHeight + lineHeight;
			chatViewFrame.origin.y = availableHeight - keyboardHeight - textSizeHeight - lineHeight;
			self.chatView.frame = chatViewFrame;
			
			// table view
			CGRect tableFrame = self.tableView.frame;
			tableFrame.size.height = availableHeight - keyboardHeight - textSizeHeight - lineHeight;
			self.tableView.frame = tableFrame;
		}
		
		if (textSizeHeight > maxTextHeight)
		{
			self.chatBox.scrollEnabled = YES;
		}
	} else {
		CGRect tableFrame = self.tableView.frame;
		tableFrame.size.height = availableHeight - keyboardHeight - CHAT_BOX_HEIGHT;
		tableFrame.origin.y = 0; // bug in landscape
		self.tableView.frame = tableFrame;
		
		CGRect chatViewFrame = self.chatView.frame;
		chatViewFrame.origin.y = availableHeight - keyboardHeight - CHAT_BOX_HEIGHT;
		chatViewFrame.size.height = CHAT_BOX_HEIGHT;
		self.chatView.frame = chatViewFrame;
		
		// get a rect for the form frame
		CGRect chatBoxFrame = self.chatBox.frame;
		chatBoxFrame.origin.y = availableHeight - keyboardHeight - CHAT_BOX_HEIGHT;
		self.chatBox.frame = chatBoxFrame;			
	}
}

-(void) keyboardWillHide:(NSNotification *)note{
	if(![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(keyboardWillHide:) withObject:note waitUntilDone:NO];
	}
	
    // get keyboard size and loction
	
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &keyboardBounds];
	
	int height = PORTRAIT_AVAILABLE_HEIGHT;
	if(self.interfaceOrientation != UIDeviceOrientationPortrait)
		height = LANDSCAPE_AVAILABLE_HEIGHT;
	
	// get a rect for the form frame
	CGRect chatBoxFrame = self.chatBox.frame;
	chatBoxFrame.origin.y = height - CHAT_BOX_HEIGHT;

	// get a rect for the form frame
	CGRect chatViewFrame = self.chatView.frame;
	chatViewFrame.size.height = CHAT_BOX_HEIGHT;
	chatViewFrame.origin.y = height - CHAT_BOX_HEIGHT;
	
	// get a rect for the table/main frame
	CGRect tableFrame = self.tableView.frame;
	tableFrame.size.height = height - CHAT_BOX_HEIGHT;
	tableFrame.origin.y = 0; // bug in landscape
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	
	// set views with new info
	self.tableView.frame = tableFrame;
	self.chatBox.frame = chatBoxFrame;
	self.chatView.frame = chatViewFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if(text != nil && [text isEqualToString:@"\n"]) {
		CampfireAppDelegate* appDelegate = (CampfireAppDelegate*)[UIApplication sharedApplication].delegate;
		if(![appDelegate networkAvailable]) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:@"The message was not sent because no network connection was found" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return NO;
		}
		
		CFCoreData* coreData = [CFCoreData new];
		CFMessage* message = [coreData entity:@"CFMessage"];
		message.body = self.chatBox.text;
		message.room = [coreData entityByID:self.room.objectID];
		message.user = [coreData entityByID:self.credential.me.objectID];
		message.credential = [coreData entityByID:self.credential.objectID];
		message.type = @"TextMessage";
		message.createdAt = [NSDate date];
		[message create];
		[coreData deleteObject:message];	
		[coreData commit];
		[coreData release];
		
		self.chatBox.text = nil;
		self.chatBox.scrollEnabled = NO;
		
		return NO;
	} 
	
	[self resizeChatBox];
	return YES;
}

- (CFRoom*) room {
	return [self.coreData entityByID:self.roomID];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
	if(textView.text == nil)
		return;
	
	[self resizeChatBox];
}

- (void) scrollToBottom:(BOOL)animated {
    @try {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];              
    } @catch (NSException* e) {
        
    } 
}


#pragma mark UITableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.room.topic;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Configure the cell.
	CFMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
	UITableViewCell* cell;
	if ([message.type isEqualToString:@"TextMessage"]) {
		cell = [self bubbleCell];
	} else if([message.type isEqualToString:@"UploadMessage"]) {
		cell = [self uploadCell];
	} else {
		cell = [self normalCell];
	}
	
	if([message.user.name isEqualToString:@"Unknown"]) {
		[message.user fetch]; // could cause a lot of duplicate fetches
	}
	
	if([message.type isEqualToString:@"TextMessage"]) {
		BubbleCell* bubbleCell = (BubbleCell*)cell;
		[bubbleCell setMessage:message];
		
		if([message.user.name isEqualToString:@"Unknown"]) {
			[message.user fetch];
		}
	} else if([message.type isEqualToString:@"TimestampMessage"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd MMM, hh:mm a"];
		cell.textLabel.text = [dateFormatter stringFromDate:message.createdAt];
		[dateFormatter release];
	} else if([message.type isEqualToString:@"LockMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ has locked the room", message.user.name];
	} else if([message.type isEqualToString:@"UnlockMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ has unlocked the room", message.user.name];
	} else if([message.type isEqualToString:@"TopicChangeMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ changed the topic to \"%@\"", message.user.name, message.body];
	} else if([message.type isEqualToString:@"EnterMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ has entered the room", message.user.name];
	} else if([message.type isEqualToString:@"KickMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ has left the room", message.user.name];
	} else if([message.type isEqualToString:@"LeaveMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ has left the room", message.user.name];
	} else if([message.type isEqualToString:@"AllowGuestsMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ turned on guest access", message.user.name];
	} else if([message.type isEqualToString:@"DisallowGuestsMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ turned off guest access", message.user.name];
	} else if([message.type isEqualToString:@"IdleMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ is idle", message.user.name];
	} else if([message.type isEqualToString:@"UnidleMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ is no longer idle", message.user.name];
	} else if([message.type isEqualToString:@"SystemMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"System Message: %@", message.body];
	} else if([message.type isEqualToString:@"PasteMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@", message.body];
	} else if([message.type isEqualToString:@"UploadMessage"]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ uploaded %@", message.user.name, message.body];
	} else {
		cell.textLabel.text = message.type;
	}
	
    return cell;
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

- (UITableViewCell*) uploadCell {
    static NSString *CellIdentifier = @"CFUpload";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.textLabel.textColor = [UIColor blueColor];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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

- (void) bloop {
	//Get the filename of the sound file:
	NSString *path = [NSString stringWithFormat:@"%@%@",
					  [[NSBundle mainBundle] resourcePath],
					  @"/bloop.wav"];
	
	//declare a system sound id
	SystemSoundID soundID;
	
	//Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
	
	//Use audio sevices to create the sound
	AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
	
	//Use audio services to play the sound
	AudioServicesPlaySystemSound(soundID);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self.chatBox isFirstResponder]) {
		[self.chatBox resignFirstResponder];
	}	
	
	[self selected:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self selected:indexPath];
}

- (void) selected:(NSIndexPath*)indexPath {
	CFMessage* message = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if([message.type isEqualToString:@"UploadMessage"]) {
		WebViewController* webViewController = [WebViewController new];
		webViewController.messageID = message.objectID;
		webViewController.credentialID = self.credentialID;
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];
	}
}

- (CGFloat)tableView:(UITableView *)uiTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 30.0f;    
    CFMessage* message = (CFMessage*)[self.fetchedResultsController objectAtIndexPath:indexPath];
	if([message.type isEqualToString:@"TextMessage"]) {
		const int MAX_WIDTH = 250;
		UIFont* textFont = [UIFont systemFontOfSize:12];
		UIFont* nameFont = [UIFont boldSystemFontOfSize:12];
		CGSize textSize = [message.body sizeWithFont:textFont constrainedToSize:CGSizeMake(MAX_WIDTH, UINT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		CGSize nameSize = [message.user.name sizeWithFont:nameFont constrainedToSize:CGSizeMake(MAX_WIDTH, UINT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		height = textSize.height + nameSize.height + 20; // dynamic height needed	
	} else if([message.type isEqualToString:@"AdvertisementMessage"]) {
		height = 0.0f;
	} else if([message.type isEqualToString:@"SoundMessage"]) {
		height = 0.0f;
	}
	return height;
}

#pragma mark -
#pragma mark Fetched results controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[super controllerDidChangeContent:controller];
	[self scrollToBottom:YES];
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
	
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageID != nil AND credential=%@ AND room=%@", self.credential, self.room];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self scrollToBottom:YES];
}

@end
