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
//  FMConsoleController.h
//  FoneMonkey
//
//  Created by Stuart Stern on 11/7/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FMConsoleController : UIViewController {
	UIView* moreView;
	UITableView* eventView;
	UISegmentedControl* controlBar;
}

@property (nonatomic, retain) IBOutlet UIView* moreView;
@property (nonatomic, retain) IBOutlet UITableView* eventView;
@property (nonatomic, retain) IBOutlet UISegmentedControl* controlBar;
- (IBAction) doMonkeyAction:(id)sender;
- (IBAction) save:(id)sender;
- (IBAction) open:(id)sender;
- (IBAction) gorilla:(id)sender;
- (IBAction) clear:(id)sender;
- (IBAction) editCommands:(id) sender;
- (IBAction) insertCommands:(id) sender;


- (void) monkeySuspended:(NSNotification*)notification;
-(void) refresh;
- (void) hideConsole;
- (void) showConsole;

+ (FMConsoleController*) sharedInstance;
@end
