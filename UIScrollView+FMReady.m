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
//  UIScrollView+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/29/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UIScrollView+FMReady.h"
#import <objc/runtime.h>
#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "UIView+FMReady.h"

@implementation UIScrollView (FMReady)

- (BOOL) isFMEnabled {
	return YES;
}

+ (void)load {
    if (self == [UIScrollView class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(setContentOffset:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmSetContentOffset:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}

- (void)fmSetContentOffset:(CGPoint)offset {

	if (!self.dragging || (offset.x == self.contentOffset.x && offset.y == self.contentOffset.y)) {
		[self fmSetContentOffset:offset];
		return;
	}
	
	// offsets are apparently stored as whole-valued floats. We round so that direction determination (up, down, left, right) works
	offset.x = round(offset.x);
	offset.y = round(offset.y);
//	NSLog(@"new:%d,%d prev:%d,%d",offset.x,offset.y,self.contentOffset.x, self.contentOffset.y);	
	// Bouncing screws up delta checking so we're disabling and we'll see if anybody cares
	if (self.bounces) {
		self.bounces = NO;
	}

	
	// Since it's unclear exactly how to do this in a subclass (override a swapped method), we do it here instead (sorry)
	if ([self isKindOfClass:[UITableView class]]) {
		[self fmSetContentOffset:offset];		
		UITableView* table = (UITableView*) self;
		NSArray* cells = [table visibleCells];
		if ([cells count]) {
			NSIndexPath* indexPath = [table indexPathForCell:[cells objectAtIndex:0]];
			[[FoneMonkey sharedMonkey] postCommandFrom:self 
											   command:FMCommandVScroll 
												  args:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", indexPath.row], 
														indexPath.section == 0 ? nil : [NSString stringWithFormat:@"%d", indexPath.section], nil]];		
			return;
		}
	}
	
	
//	if (offset.x == self.contentOffset.x) {
//		if (offset.y >  self.contentOffset.y) {		
//			cmd = FMCommandScrollDown;
//		} else {			
//			cmd = FMCommandScrollUp;
//		}
//		[[FoneMonkey sharedMonkey] postCommandFrom:self 
//										   command:cmd 
//											  args:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", offset.y], nil]];		
//	} else if (offset.y == self.contentOffset.y) {
//		if (offset.x >  self.contentOffset.x) {
//			cmd = FMCommandScrollRight;
//		} else {
//			cmd = FMCommandScrollLeft;
//		}
//		[[FoneMonkey sharedMonkey] postCommandFrom:self 
//										   command:cmd 
//											  args:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", offset.x], nil]];		
//	} else {
		[[FoneMonkey sharedMonkey] postCommandFrom:self 
										   command:FMCommandScroll 
											  args:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", offset.x], [NSString stringWithFormat:@"%1.0f", offset.y], nil]];
//	}
	[self fmSetContentOffset:offset];

}

- (void) playbackMonkeyEvent:(FMCommandEvent*)event {
	CGPoint offset = [self contentOffset];
	if ([event.command isEqual:FMCommandScroll]) {
		if ([event.args count] < 2) {
			event.lastResult = @"Requires 2 arguments, but has %d", [event.args count];
		}
		offset.x = [[[event args] objectAtIndex:0] floatValue];	
		offset.y = [[[event args] objectAtIndex:1] floatValue];
//	} else if ([event.command isEqual:FMCommandScrollDown] || [event.command isEqual:FMCommandScrollUp]) {
//		offset.y = [[[event args] objectAtIndex:0] floatValue];		
//
//	} else if ([event.command isEqual:FMCommandScrollDown] || [event.command isEqual:FMCommandScrollUp]) {
//		offset.x = [[[event args] objectAtIndex:0] floatValue];		
	} else {
		[super playbackMonkeyEvent:event];
		return;
	}
	[self setContentOffset:offset animated:YES];
}


- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch {
	return NO;
}

@end
