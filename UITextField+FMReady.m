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
//  UITextField+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/17/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UITextField+FMReady.h"

#import "FoneMonkeyAPI.h"
#import "FoneMonkey.h"
#import <objc/runtime.h>

@implementation UITextField (FMReady)

- (UIControlEvents)monkeyEventsToHandle {
	return UIControlEventEditingDidEnd | UIControlEventTouchDown;
}	


- (NSString*) monkeyID {
	return self.placeholder ? 
		self.placeholder : 
			[super monkeyID];
}

- (void) handleMonkeyEventFromSender:(id)sender forEvent:(UIEvent*)event {

	if (event) {
		
		if (event.type == UIEventTypeTouches) {
			[FoneMonkey recordFrom:self command:FMCommandTouch];
		}
		
		return;
	} 
	
	if (!self.editing && self.text != nil) {
		[FoneMonkeyAPI record:self command:FMCommandInputText args:[NSArray arrayWithObject:[self.text copy]]];
	} else {
		[FoneMonkeyAPI continueRecording];
	}
	
}

- (void) playbackMonkeyEvent:(FMCommandEvent*)recevent {
	if ([recevent.command isEqualToString:FMCommandInputText]) {
		[self becomeFirstResponder];
		self.text = [recevent.args objectAtIndex:0];
		[self resignFirstResponder];
		[self sendActionsForControlEvents:UIControlEventEditingDidEndOnExit];		
	} else if ([recevent.command isEqualToString:FMCommandTouch]) {
		[self becomeFirstResponder];
	} else {
		[super playbackMonkeyEvent:recevent];
	}
}

@end
