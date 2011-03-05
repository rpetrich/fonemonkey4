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
#import <objc/runtime.h>
#import "UITableView+FMReady.h"
#import "FMCommandEvent.h"
#import "FoneMonkey.h"
#import "UIView+FMReady.h"
#import "NSObject+FMReady.h"

// Note that the recording functionality is actually implemented in UIScrollView (FMReady). This is because we're not sure
// about overriding the setContentOffset method here, since we swizzle it in UIScrollView. The Objective-C doc is unclear
// on the safety of overriding a swizzled method (and it's not clear there's a prescribed order of class loading so 
// further swizzling the swizzled methods here seems dangerous. As a result, we do an explicit type check in 
// UIScrollView to see if we're actually a UITableView, and if we are, we record the (section,row) tuple rather than (x,y)

@implementation UITableView (FMReady)

+ (void)load {
    if (self == [UITableView class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(setDataSource:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmSetDataSource:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}

- (void) fmSetDataSource:(NSObject <UITableViewDataSource>*) del {
	// The existence of this method triggers swipe-to-edit functionality in a UITableView (and who knows what else). 
	// If we add this method and it doesn't already exist, we inadvertently enable swipe-to-edit 
	// So, if this method doesn't already exist, we assume the table is not editable and therefore we don't have to record these delegate calls.
	if ([del fmHasMethod:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
		[del  interceptMethod:@selector(tableView:commitEditingStyle:forRowAtIndexPath:) 
				   withMethod:@selector(fmTableView:commitEditingStyle:forRowAtIndexPath:) 
					  ofClass:[self class] 
				   renameOrig:@selector(origTableView:commitEditingStyle:forRowAtIndexPath:) 
						types:"v@:@i@"];
	}
	
//	Method originalMethod = class_getInstanceMethod([del class], @selector(tableView:commitEditingStyle:forRowAtIndexPath:));
//	if (originalMethod) {
//		IMP origImp = method_getImplementation(originalMethod);
//		Method replacedMethod = class_getInstanceMethod([self class], @selector(fmTableView:commitEditingStyle:forRowAtIndexPath:));
//		IMP replImp = method_getImplementation(replacedMethod);
//		
//		if (origImp != replImp) {
//			method_setImplementation(originalMethod, replImp);
//			class_addMethod([del class], @selector(origTableView:commitEditingStyle:forRowAtIndexPath:), origImp,"v@:@i@");
//		}
//	}
	[self fmSetDataSource:del];
	
	
}

- (void)fmTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[FoneMonkey recordFrom:tableView command:FMCommandDelete args:[NSArray arrayWithObjects: [NSString stringWithFormat: @"%d", indexPath.row], [NSString stringWithFormat:@"%d", indexPath.section], nil]];
	}
	[self origTableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

- (void) playbackMonkeyEvent:(FMCommandEvent*)event {
	if ([event.command isEqualToString:FMCommandVScroll]) {
//		if ([event.args count] > 2) {
//			event.lastResult = @"Requires 0, 1, or 2 arguments, but has %d", [event.args count];
//		}
		NSInteger row = [event.args count] > 0 ? [[event.args objectAtIndex:0] intValue] : 0;
		NSInteger section = [event.args count] > 1 ? [[event.args objectAtIndex:1] intValue] : 0;


		NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];

		[self scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
	} else if ([event.command isEqualToString:FMCommandDelete]) {
//		if ([event.args count] > 2) {
//			event.lastResult = @"Requires 0, 1, or 2 arguments, but has %d", [event.args count];
//		}
		NSInteger row = [event.args count] > 0 ? [[event.args objectAtIndex:0] intValue] : 0;
		NSInteger section = [event.args count] > 1 ? [[event.args objectAtIndex:1] intValue] : 0;
		
		
		NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
		
		[self.dataSource origTableView:self commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:path];
	} else {
		[super playbackMonkeyEvent:event];
		return;
	}
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
