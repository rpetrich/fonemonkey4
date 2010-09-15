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
//  UIResponder+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/19/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UIView+FMReady.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "FMCommandEvent.h"
#import "FoneMonkey.h"
#import "UIControl+FMready.h"
#import "TouchSynthesis.h"
#import "FMUtils.h"
#import "UITabBarButtonProxy.h"
#import "UIToolbarTextButtonProxy.h"
#import "UIPushButtonProxy.h"
#import "UISegmentedControlProxy.h"


@implementation UIView (FoneMonkey) 	
+ (void)load {
	if (self == [UIView class]) {

        Method originalMethod = class_getInstanceMethod(self, @selector(initWithFrame:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmInitWithFrame:));
        method_exchangeImplementations(originalMethod, replacedMethod);	
	}
}

	
- (id)fmInitWithFrame:(CGRect)aRect {
	// This is actually for UIControl, but UIControl inherits this method
	// Calls original initWithFrame (that we swapped in load method)
	if ((self = [self fmInitWithFrame:aRect])) {	
		if ([self isKindOfClass:[UIControl class]]) {
			[(UIControl*)self performSelector:@selector(subscribeToMonkeyEvents)];
		}
	}
	
	return self;	
	
}

- (void) handleMonkeyTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
	// Test for special UI classes that require special handling of record
	// UISegmentedControl
	if ([self isKindOfClass:objc_getClass("UISegmentedControl")]) {
		UISegmentedControlProxy *tmp = (UISegmentedControlProxy *)self;
		int index = tmp.selectedSegmentIndex;
		if (index < 0) {
			return;
		}	
		NSString* title = [tmp titleForSegmentAtIndex:index];
		
		if (title == nil) {
			title = [NSString stringWithFormat:@"%d", index];
		}
		[FoneMonkey recordFrom:self command:FMCommandTouch args:[NSArray arrayWithObject:title]];
	} else {
		// DEFAULT
		// By default we simply record that they touched the view
		UITouch* touch = [touches anyObject];
		if (touch.phase == UITouchPhaseMoved) {
			CGPoint loc = [touch locationInView:self];
			FMCommandEvent* command = [[FoneMonkey sharedMonkey] lastCommandPosted];
			if ([command.command isEqualToString:FMCommandMove] && [command.monkeyID isEqualToString:[self monkeyID]]) {
				[[FoneMonkey sharedMonkey] deleteCommand:[[FoneMonkey sharedMonkey] commandCount] - 1];
				NSMutableArray* args = [NSMutableArray arrayWithArray:command.args];
				[args addObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", loc.x], 
										   [NSString stringWithFormat:@"%1.0f", loc.y],
										   nil]];
				[FoneMonkey recordFrom:self command:FMCommandMove args:args];
				return;
			} else {
				[FoneMonkey recordFrom:self command:FMCommandMove args:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", loc.x], 
																		[NSString stringWithFormat:@"%1.0f", loc.y],
																		nil]];
				return;
			}
		}
		CGPoint loc = [touch locationInView:self];	
		NSMutableArray* args = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", loc.x], 
								[NSString stringWithFormat:@"%1.0f", loc.y],
								nil];
		if (touch.tapCount >1) {
			[args addObject:[NSString stringWithFormat:@"%1.0d", touch.tapCount]];
		}
		[FoneMonkey recordFrom:self command:FMCommandTouch args:args];
	} //End Default record operations
}

- (void) handleMonkeyMotionEvent:(UIEvent*)event {
	[FoneMonkey recordFrom:nil command:FMCommandShake];
}

- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch {
	// By default, we only record TouchEnded	
	return (touch.phase == UITouchPhaseEnded);
}

- (void) playbackMonkeyEvent:(id)event {
	// By default we generate a touch in the center of the view
	FMCommandEvent* ev = event;
	if (([self isKindOfClass:objc_getClass("UISegmentedControl")]) && ([[ev command] isEqualToString:FMCommandTouch])) {
		UISegmentedControlProxy *tmp = (UISegmentedControlProxy *)self;
		if ([[ev args] count] == 0) {
			ev.lastResult = @"Requires 1 argument, but has %d", [ev.args count];
			return;
		}	
		int index;
		int i;
		NSString* title =(NSString*) [ev.args objectAtIndex:0];
		for (i = 0; i < [tmp numberOfSegments]; i++) {
			
			NSString* t = [tmp titleForSegmentAtIndex:i];
			if (t == nil)  {
				index = [title intValue];
				// Need to use undocumented property that contains array of "segments" (subviews that are the buttons)			
				[UIEvent performTouchInView:(UIView*) [tmp->_segments objectAtIndex:index]]; 
				return;
			}
			if ([t isEqualToString:title]) {
				// Need to use undocumented property that contains array of "segments" (subviews that are the buttons)
				[UIEvent performTouchInView:(UIView*) [tmp->_segments objectAtIndex:i]]; 
				return;
			}
			
		}
		NSLog(@"Unable to find %@ in UISegmentedControl", title);
	} else {
		// DEFAULT
		if ([ev.command isEqualToString:FMCommandVerify]) {
			if ([ev.args count] == 2) {
				NSString* prop = [ev.args objectAtIndex:0];
				NSString* expected = [ev.args objectAtIndex:1];
				NSString* value = [self valueForKeyPath:prop];
				if ([expected isEqualToString:value]) {
					ev.lastResult = nil;
				} else {
					ev.lastResult = [NSString stringWithFormat: @"Expected \"%@\", but found \"%@\"", expected, value];
				}
			} else if ([ev.args count] != 0) {
				ev.lastResult = [NSString stringWithFormat:@"Requires 0 or 2 arguments, but has %d", [ev.args count]];
			}
			return;
		}
		
		if ([ev.command isEqualToString:FMCommandMove]) {
			int i;
			CGPoint prevPoint;
			for (i = 0; i < ([ev.args count]); i += 2) {
				CGPoint point;
				point.x = [[ev.args objectAtIndex:i] floatValue];
				point.y = [[ev.args objectAtIndex:i+1] floatValue];
				if (i == 0) {
					prevPoint = point;
					//				[UIEvent performTouchDownInView:self at:point];
				} 
				//			else if (i == ([ev.args count]/2 - 2)) {
				//				[UIEvent performTouchUpInView:self at:point];
				//			} else {
				[UIEvent performMoveInView:self from:prevPoint to:point];
				
				//			}			
				prevPoint = point;
			}
			return;
		}
		
		CGPoint point;
		if ([ev.args count] >= 2) { 
			point.x = [[ev.args objectAtIndex:0] floatValue];
			point.y = [[ev.args objectAtIndex:1] floatValue];
			if ([ev.args count] == 3) {
				[UIEvent performTouchInView:self at:point withCount:[[ev.args objectAtIndex:2] intValue]];
			} else {
				[UIEvent performTouchInView:self at:point];
			}
		} else {
			[UIEvent performTouchInView:self];
		}
	} // End DEFAULT
}

- (BOOL) isFMEnabled {
	// Don't record events for containers
	return ![self isMemberOfClass:[UIView class]] && ![FMUtils isKeyboard:self];
}

- (NSString*) monkeyID {
	if ([self isKindOfClass:objc_getClass("UITabBarButton")]) {
		UITabBarButtonProxy* but = (UITabBarButtonProxy *)self;
		NSString* label = [but->_label text];
		if (label != nil) {
			return label;
		}	
	} else if ([self isKindOfClass:objc_getClass("UIToolbarTextButton")]) {
		UIToolbarTextButtonProxy* but = (UIToolbarTextButtonProxy *)self;
		NSString* label = but->_title;
		if ([but->_info isKindOfClass:objc_getClass("UIPushButton")]) {
			label = [(UIPushButtonProxy *)but->_info title];
		}
		if (label != nil) {
			return label;
		}	
	} else if ([self isKindOfClass:objc_getClass("UISegmentedControl")]) {
		UISegmentedControlProxy *but = (UISegmentedControlProxy *)self;
		NSMutableString* label = [[[NSMutableString alloc] init] autorelease];
		int i;
		for (i = 0; i < [but numberOfSegments]; i++) {
			NSString* title = [but titleForSegmentAtIndex:i];
			if (title == nil) {
				goto use_default;
			}
			[label appendString:title];
		}
		return label;
	}

use_default:;
	return [self accessibilityLabel] ? [self accessibilityLabel] :
	self.tag < 0 ? [NSString stringWithFormat:@"%ld",(long)self.tag] :
	[[FoneMonkey sharedMonkey] monkeyIDfor:self];
}

@end
