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
//  FMSaveScriptDialog.h
//  FoneMonkey
//
//  Created by Stuart Stern on 11/15/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FMSaveScriptDialog : UIViewController {
	UITableView* table;
}
- (IBAction) save:(id)sender;
- (IBAction) cancel:(id)sender;
@property (nonatomic, retain) IBOutlet UITableView* table;
@end
