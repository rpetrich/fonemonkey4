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
//  UIPickerView+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 11/09/10
//  Copyright 2010 Gorilla Logic, Inc. All rights reserved.
//

#import "UIPIckerView+FMReady.h"
#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "UIPickerViewDelegateInterceptor.h"
#import <objc/runtime.h>

@implementation UIPickerView (FMReady)


+ (void)load {
    if (self == [UIPickerView class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmSetDelegate:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}

- (void) fmSetDelegate:(id <UIPickerViewDelegate>) del {
	Method originalMethod = class_getInstanceMethod([del class], @selector(pickerView:didSelectRow:inComponent:));
	if (originalMethod) {
		IMP origImp = method_getImplementation(originalMethod);
		Method replacedMethod = class_getInstanceMethod([self class], @selector(fmPickerView:didSelectRow:inComponent:));
		IMP replImp = method_getImplementation(replacedMethod);
		
		if (origImp != replImp) {
			method_setImplementation(originalMethod, replImp);
			class_addMethod([del class], @selector(origPickerView:didSelectRow:inComponent:), origImp,"v@:@ii");
		}
	}
	[self fmSetDelegate:del];

}
- (void)fmPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[ FoneMonkey recordEvent:[[FMCommandEvent alloc]
							  init:FMCommandSelect className:@"UIPickerView" monkeyID:[pickerView monkeyID] args:[NSArray arrayWithObjects: [NSString stringWithFormat: @"%d", row], [NSString stringWithFormat:@"%d", component], nil]]];
	[self origPickerView:pickerView didSelectRow:row inComponent:component];
}	

- (void) playbackMonkeyEvent:(FMCommandEvent*)event {
	if ([event.command isEqual:FMCommandSelect]) {
		if ([event.args count] == 0) {
			event.lastResult = @"Requires 1 or 2 arguments (row #, component #)";
			return;
		}
		NSInteger row = [[event.args objectAtIndex:0] intValue];
		NSInteger component = 0;
		if ([event.args count] == 2) {
			component = [[event.args objectAtIndex:1] intValue];
		}
		
		[self selectRow:row inComponent:component animated:YES];
	}
}


- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch {
	return NO;
}

@end
