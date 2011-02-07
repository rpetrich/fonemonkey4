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
//  UISwitch+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 1/9/11.
//  Copyright 2011 Gorilla Logic, Inc. All rights reserved.
//

#import "UISwitch+FMReady.h"
#import "FoneMonkey.h"
#import "FMUtils.h"
#import "FMCommandEvent.h"

@implementation UISwitch (FMReady) 
- (void) playbackMonkeyEvent:(id)event {
	// toggles
	[self setOn:!self.on animated:NO];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

+ (NSString*) uiAutomationCommand:(FMCommandEvent*)command {
	
	if ([command.command isEqualToString:FMCommandSwitch]) {
		return [NSString stringWithFormat:@"FoneMonkey.toggleSwitch(\"%@\"); // UIASwitch", 
				[FMUtils stringByJsEscapingQuotesAndNewlines:command.monkeyID]];
	}
	
	return [super uiAutomationCommand:command];
	
}
@end
