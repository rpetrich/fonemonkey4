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
//  UISlider.m
//  UICatalog
//
//  Created by Stuart Stern on 10/28/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UISlider+FMReady.h"
#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "UIView+FMReady.h"

@implementation UISlider (FMReady)

- (BOOL) isFMEnabled {
	return YES;
}

/**
 The events to be recorded for the class of control. Defaults to none.
 */
- (UIControlEvents)monkeyEventsToHandle {
		return UIControlEventValueChanged;
}


- (void) handleMonkeyEventFromSender:(id)sender forEvent:(UIEvent*)event {
	
	if (event) {
		
		if (event.type == UIEventTypeTouches) {
			UITouch* touch = [[event allTouches] anyObject];
			// Inexplicably, UISwitches sometimes get touch events without any touches in them
			if (touch == nil || touch.phase == UITouchPhaseEnded) {
				if ([self accessibilityLabel] == nil) {
					[self setAccessibilityLabel:[sender accessibilityLabel]];
				}

				if ([self isMemberOfClass:[UISlider class]]) {
					[FoneMonkey recordFrom:self command:FMCommandSlide args:[NSArray arrayWithObject:[[NSString alloc] initWithFormat:@"%.2f",self.value]]];
				} else {
					// It's a UISwitch (probably)
					[FoneMonkey recordFrom:sender command:FMCommandSwitch];
				}
		
			}
		}
		
		return;
	} 
	
}	

- (void) playbackMonkeyEvent:(FMCommandEvent*)event {
	if ([event.command isEqual:FMCommandSlide]) {
		if ([[event args] count] == 0) {
			event.lastResult = @"Requires 1 argument, but has %d", [event.args count];
			return;
		}
		self.value = [[[event args] objectAtIndex:0] floatValue];
	} else {
		[super playbackMonkeyEvent:event];
	}
}

- (BOOL) shouldRecordMonkeyTouch:(UITouch*)phase {
	return NO;
}


@end
