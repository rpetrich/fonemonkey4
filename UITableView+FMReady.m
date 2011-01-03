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
//  UITableView+FMReady.m
//  GLPaint
//
//  Created by Stuart Stern on 11/29/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UITableView+FMReady.h"
#import "FMCommandEvent.h"
#import "FoneMonkey.h"
#import "UIView+FMReady.h"

// Note that the recording functionality is actually implemented in UIScrollView (FMReady). This is because we're not sure
// about overriding the setContentOffset method here, since we swizzle it in UIScrollView. The Objective-C doc is unclear
// on the safety of overriding a swizzled method (and it's not clear there's a prescribed order of class loading so 
// further swizzling the swizzled methods here seems dangerous. As a result, we do an explicit type check in 
// UIScrollView to see if we're actually a UITableView, and if we are, we record the (section,row) tuple rather than (x,y)

@implementation UITableView (FMReady)

- (void) playbackMonkeyEvent:(FMCommandEvent*)event {
	if ([event.command isEqualToString:FMCommandVScroll]) {
		if ([event.args count] > 2) {
			event.lastResult = @"Requires 0, 1, or 2 arguments, but has %d", [event.args count];
		}
		NSInteger row = [event.args count] > 0 ? [[event.args objectAtIndex:0] intValue] : 0;
		NSInteger section = [event.args count] > 1 ? [[event.args objectAtIndex:1] intValue] : 0;


		NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];

		[self scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
	} else {
		[super playbackMonkeyEvent:event];
		return;
	}
}

+ (NSString*) objcCommandEvent:(FMCommandEvent*)command {
	NSMutableString* string = [[NSMutableString alloc] init];
	//	if (command.source && ![command.source accessibilityLabel]) {
	//		[string appendFormat:@"// Accessibility label may need to be set to %@ for %@\n", command.monkeyID, command.className]; 
	//		NSLog(@"Accessibility label may need to be set to %@ for %@\n", command.monkeyID, command.className);
	//	}
	if ([command.command isEqualToString:FMCommandVScroll]) {
		NSString* section = [command.args count] < 2 ? @"0" : [command.args objectAtIndex:1];
		NSString* row = [command.args count] < 1 ? @"0" : [command.args objectAtIndex:0];
		string = [NSString stringWithFormat:@"[FMCommandEvent command:@\"VScroll\" className:@\"%@\" monkeyID:@\"%@\" args:[NSArray arrayWithObjects:%@, %@, nil]", command.className, command.monkeyID, row, section];
	} else {
		string = [super uiAutomationCommand:command];
	}
	return string;
}

+ (NSString*) uiAutomationCommand:(FMCommandEvent*)command {
	NSMutableString* string = [[NSMutableString alloc] init];
//	if (command.source && ![command.source accessibilityLabel]) {
//		[string appendFormat:@"// Accessibility label may need to be set to %@ for %@\n", command.monkeyID, command.className]; 
//		NSLog(@"Accessibility label may need to be set to %@ for %@\n", command.monkeyID, command.className);
//	}
	if ([command.command isEqualToString:FMCommandVScroll]) {
		NSString* section = [command.args count] < 2 ? @"0" : [command.args objectAtIndex:1];
		NSString* row = [command.args count] < 1 ? @"0" : [command.args objectAtIndex:0];
		[string appendFormat:@"FoneMonkey.scrollTo(\"%@\", \"%@\", \"%@\")", command.monkeyID, section, row];
	} else {
		[string appendString:[super uiAutomationCommand:command]];
	}
	return string;
}

@end
