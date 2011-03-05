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
//  UITableViewCell+FMReady.m
//  UICatalog
//
//  Created by Stuart Stern on 10/21/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UITableViewCell+FMReady.h"
#import <objc/runtime.h>
#import "TouchSynthesis.h"
#import "UIView+FMReady.h"
#import "FMUtils.h"
#import "Fonemonkey.h"
#import "FMCommandEvent.h"
@implementation UITableViewCell (FMReady)


- (BOOL) isFMEnabled {
	return YES;
}

//
//- (void) playbackMonkeyEvent:(id)event {
//	[UIEvent performTouchInView:self];
//}
- (void) handleMonkeyTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
	
	UITouch* touch = [touches anyObject];
	if (touch) {
		NSString* cname = [FMUtils className:touch.view];
		if (cname) {
			if ([cname isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
				// [FoneMonkey recordFrom:self command:FMCommandDelete]; //No-op for now
				return;
			}
			
			if ([cname isEqualToString:@"UITableViewCellEditControl"]) {
				//[FoneMonkey recordFrom:self command:FMCommandEdit]; No-op for now
				return;
			}
		}
	}
	[super handleMonkeyTouchEvent:touches withEvent:event];
					  
					  
}

- (NSString*) monkeyID {
	NSString* label =  [[self textLabel] text];
	if (label) {
		return  label;
	}
	
	label =  [[self detailTextLabel] text];
	if (label) {
		return label;
	}
	
	label =[self text];
	if (label) {
		return label;
	}
	
	for (UIView* view in [[self contentView] subviews]) {
		NSObject* obj;
		 
		if ([view respondsToSelector:@selector(text)]) {
			return [view performSelector:@selector(text)];
		}
	}
	
	return [super monkeyID];
}
//
//- (void) playbackMonkeyEvent:(id)event {
//	FMCommandEvent* command = event;
//	
//	if ([command.command  isEqualToString:FMCommandDelete]) {
//		UITableView* table = [self superview];
// 		[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:[table indexPathForCell:self]] withRowAnimation:YES];
//	}
//}
@end
