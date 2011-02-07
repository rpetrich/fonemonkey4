/* This file is part of FoneMonkey.

    FoneMonkey is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FoneMonkey is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FoneMonkey.  If not, see <http://www.gnu.org/licenses/>.  */
//
//  FMConsoleController.m
//  FoneMonkey
//
//  Created by Stuart Stern on 11/7/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "FMConsoleController.h"
#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "FMUtils.h"
#import "FMSaveScriptDialog.h"
#import "FMOpenScriptDialog.h"
#import "FMCommandEditViewController.h"
#import "FMGorillaView.h"
#import "FMEventViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FMConsoleController

@synthesize moreView, eventView, controlBar;

FoneMonkey* theMonkey;
FMConsoleController* _sharedInstance;
FMCommandEditViewController* _editor = nil;
NSIndexPath* _indexPath;
NSMutableDictionary* _cmdIcons;
BOOL _more = NO;
UIWindow* _appWindow;

typedef enum {
	PAUSE,
	RECORD,
	PLAY,
	MORE
	
	
} consoleCommands;
typedef enum {
	DELETE,
	INSERT
	
} EditMode;

EditMode _editMode;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
		theMonkey = [[FoneMonkey sharedMonkey] retain];
    }
	
	_sharedInstance = self;
    return self;
}



+ sharedInstance {
	return _sharedInstance;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	moreView.alpha = 0.0;
	[[FMUtils rootWindow] sendSubviewToBack:[self view]];
	
	
	// FoneMonkey sends notifications whenever it times out
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(monkeySuspended:)
												 name:FMNotificationMonkeySuspended object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(scriptOpened:)
												 name:FMNotificationScriptOpened object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playingDone:)
												 name:FMNotificationPlayingDone object:nil];	
	// OCUnit may have already started up some tests
	if ([FoneMonkey sharedMonkey].state != FMStatePlaying) {
		// Show the console
		[theMonkey suspend];
	}
	//eventView.allowsSelection = NO;
}


- (void) dismissKeyboard {
	[FMUtils dismissKeyboard];
}

-(void) refresh {	
	[self  dismissKeyboard];	
	[eventView reloadData];

	
}

- (void) scriptOpened:(NSNotification*)notification {
	[self refresh];
}


- (void) showConsole:(BOOL)more {
	((UIWindow*)(self.view)).windowLevel = UIWindowLevelAlert;
	_appWindow = [FMUtils rootWindow];

	//[((UIWindow*)(self.view)) makeKeyAndVisible];
	[UIView beginAnimations:nil context:nil];	

	
	if (!more) {

		moreView.alpha = 0.0;
	}
	
	else {
		[self showMore];
	}
	//[[FMUtils rootWindow] bringSubviewToFront:[self view]];
	//_appWindow = [FMUtils rootWindow];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:[self view] cache:NO];
	[self view].alpha = 1.0;	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(refresh)];	
	NSInteger firstError = [[FoneMonkey sharedMonkey] firstErrorIndex];
	if (firstError > -1) {
		if (more) {
			[eventView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:firstError inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		}
	}
		
	[UIView commitAnimations];	
}


- (void) playingDone:(NSNotification*)notification {
	
	[self showConsole:YES];
}

- (void) showConsole {
	[self showConsole:NO]; 
}

-(void)showMore
{
	_more = YES;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    // using the ease in/out timing function
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type =  kCATransitionMoveIn;
	transition.subtype  = kCATransitionFromTop;
	
    
    // Tto avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
    // -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	// transitioning = YES;
    transition.delegate = self;
    
    // Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
   [moreView.layer addAnimation:transition forKey:nil];
    
	moreView.alpha = 1.0;
	//[[FMUtils rootWindow] bringSubviewToFront:[self view]];
}

-(void)showLess
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    // using the ease in/out timing function
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type =  kCATransitionReveal;
	transition.subtype  = kCATransitionFromBottom;
	
    
    // Tto avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
    // -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	// transitioning = YES;
    transition.delegate = self;
    
    // Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
    [moreView.layer addAnimation:transition forKey:nil];
    
	moreView.alpha = 0.0;
	//[[FMUtils rootWindow] bringSubviewToFront:[self view]];
}

- (void) monkeySuspended:(NSNotification*) notification {
	if ([FoneMonkey sharedMonkey].state != FMStatePlaying) {
		[self showConsole];
	}
}




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


// Event table datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [theMonkey commandCount];
}

- (UIImage*) getImage:(NSString*)cmd {
	NSString* imgname = [NSString stringWithFormat:@"FM%@",cmd];
	NSString *path = [[NSBundle mainBundle] pathForResource:imgname ofType:@"png"];
	if (!path) {
		// Try it without the leading "FM"
		path = [[NSBundle mainBundle] pathForResource:cmd ofType:@"png"];
	}
	return path ? [UIImage imageWithContentsOfFile:path] : nil;
}

- (UIImage*) iconForCommand:(NSString*) cmd {
	UIImage* image = (UIImage*)[_cmdIcons objectForKey:cmd];
	if (image == nil) {
		image = [self getImage:cmd];
		[_cmdIcons setObject:image forKey:cmd];			
	}
	return image;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"FMCell";
	
    FMEventViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
        cell = [[[FMEventViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
				 
									   reuseIdentifier:CellIdentifier] autorelease];
		
    }
	

    FMCommandEvent* command = [theMonkey commandAt:indexPath.row];
	NSString* className;
	if (command.className) {
		if ([command.className hasPrefix:@"UI"]) {
			className = [command.className substringFromIndex:2];
		} else {
			className = command.className;
		}
	} else {
		className = @"";
	}
	
	NSString* monkeyID = (command.monkeyID) ? command.monkeyID : @"";
	
	NSMutableString* args = [[NSMutableString alloc] init];
	for (NSString* arg in command.args) {
		[args appendFormat:@"%@ ",arg];
	}	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", className, monkeyID];
	cell.textLabel.font = [cell.textLabel.font fontWithSize:[UIFont smallSystemFontSize]+2];
    cell.detailTextLabel.text = args;
	cell.detailTextLabel.textColor = [UIColor blackColor];
 	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.imageView.image = [self iconForCommand:command.command];
	if (command.lastResult) {
		cell.textLabel.textColor = [UIColor redColor];
		cell.detailTextLabel.text = command.lastResult;
		cell.detailTextLabel.textColor = [UIColor redColor];
	} else {
		cell.textLabel.textColor = [UIColor blackColor];
		cell.detailTextLabel.textColor = [UIColor blackColor];		
	}
	cell.commandNumber = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[FoneMonkey sharedMonkey] deleteCommand:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]  withRowAnimation:UITableViewRowAnimationFade];
	} else {
		indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
		[[FoneMonkey sharedMonkey] insertCommand:indexPath.row];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.75];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:[self view] cache:NO];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]  withRowAnimation:UITableViewRowAnimationFade];	
		
		[UIView setAnimationDelegate:self];
		_indexPath = [indexPath retain];
		//[UIView setAnimationDidStopSelector:@selector(editNewCommand)];
		[UIView commitAnimations];

		
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[[FoneMonkey sharedMonkey] moveCommand:fromIndexPath.row to:toIndexPath.row];
}

- (BOOL) showsReorderControl {
	return YES;

}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (!_editor) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		{
			_editor = [[[FMCommandEditViewController alloc] initWithNibName:@"FMCommandEditViewController_iPhone" bundle:nil] retain];
		}
		else
		{
			_editor = [[[FMCommandEditViewController alloc] initWithNibName:@"FMCommandEditViewController_iPad" bundle:nil] retain];
		}
		[self.view addSubview:_editor.view];
	}
	_editor.commandNumber = indexPath.row;
	[FMUtils navRight:_editor.view from:self.view];
}

- (void) editNewCommand {
		[self tableView:nil accessoryButtonTappedForRowWithIndexPath:_indexPath];	
		[_indexPath release];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return _editMode == INSERT ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}


-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	// transitioning = NO;
}



-(void) hideConsoleAndThen:(SEL)action{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[self view] cache:NO];
	[self view].alpha = 0.0;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:action];
	[UIView commitAnimations];
	((UIWindow*)(self.view)).windowLevel = UIWindowLevelStatusBar;
	[[[UIApplication sharedApplication] keyWindow] makeKeyAndVisible];
}

- (void) pause {
	[theMonkey pause];
}


- (void) record {
	[theMonkey record];
}

- (void) play {
	NSIndexPath* path = [eventView indexPathForSelectedRow];
	if (path) {
		[theMonkey playFrom:[path row]];
	} else {
		[theMonkey play];
	}
}

- (void) hideConsole {
	[self doMonkeyAction:controlBar];	
}

- (IBAction) doMonkeyAction:(id)sender {
	UISegmentedControl* seg = ((UISegmentedControl*)sender);	
	NSInteger index = seg.selectedSegmentIndex;
	
	switch (index) {
		case MORE:
			_more = !_more;
			if (_more) {
				[self showMore];
			} else {
				[self showLess];
			}
			seg.selectedSegmentIndex = UISegmentedControlNoSegment;
			return;				
		case RECORD:
			_more = NO;
			[self hideConsoleAndThen:@selector(record)];
			break;
		case PLAY:
			seg.selectedSegmentIndex = UISegmentedControlNoSegment;
			[self hideConsoleAndThen:@selector(play)];
			break;
		case PAUSE:
			_more = NO;
			[self hideConsoleAndThen:@selector(pause)];
			break;
			
	}
	
}


- (IBAction) timeoutDidChange:(id)sender {
	[FoneMonkey sharedMonkey].runTimeout = [(UISlider*)sender value];
}


- (IBAction) open:(id)sender {
	FMSaveScriptDialog* dialog;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		dialog =[[FMOpenScriptDialog alloc] initWithNibName:@"FMOpenScriptDialog_iPhone" bundle:nil];
	}
	else
	{
		dialog =[[FMOpenScriptDialog alloc] initWithNibName:@"FMOpenScriptDialog_iPad" bundle:nil];
	}
	[self.view addSubview:dialog.view];
}


- (IBAction) gorilla:(id)sender {
	FMSaveScriptDialog* dialog;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		dialog =[[FMGorillaView alloc] initWithNibName:@"FMGorillaView_iPhone" bundle:nil];
	}
	else
	{
		dialog =[[FMGorillaView alloc] initWithNibName:@"FMGorillaView_iPad" bundle:nil];
	}
	[self.view addSubview:dialog.view];
}

- (IBAction) save:(id)sender {
	FMSaveScriptDialog* dialog;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		dialog =[[FMSaveScriptDialog alloc] initWithNibName:@"FMSaveScriptDialog_iPhone" bundle:nil];
	}
	else
	{
		dialog =[[FMSaveScriptDialog alloc] initWithNibName:@"FMSaveScriptDialog_iPad" bundle:nil];
	}
	[self.view addSubview:dialog.view];
}

- (IBAction) clear:(id)sender {
	[[FoneMonkey sharedMonkey] clear];
	[self refresh];
}

- (IBAction) editCommands:(id) sender {
	_editMode = DELETE;
	NSLog(@"Edit!");
	UIBarButtonItem* item = ((UIBarButtonItem*)sender);
	BOOL editing = !(eventView.editing);
	if (editing) {
		item.style = UIBarButtonItemStyleBordered;
	} else {
		item.style = UIBarButtonItemStylePlain;
	}
	
	[eventView setEditing:editing animated:true];
}

- (IBAction) insertCommands:(id) sender {
	_editMode = INSERT;
	UIBarButtonItem* item = ((UIBarButtonItem*)sender);
	BOOL editing = !(eventView.editing);
	if (editing) {
		item.style = UIBarButtonItemStyleBordered;
	} else {
		item.style = UIBarButtonItemStylePlain;
		item.title = @"Done";
	}
	
	[eventView setEditing:editing animated:true];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//[self refresh];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	if (controlBar.selectedSegmentIndex == UISegmentedControlNoSegment) {
		controlBar.selectedSegmentIndex = PAUSE;
	} else {
		[[FMConsoleController sharedInstance] hideConsole];
	}
}
- (void)dealloc {
	[moreView release];
	[eventView release];
	[controlBar release];
	[_editor release];
	[_cmdIcons release];
    [super dealloc];
}


@end
