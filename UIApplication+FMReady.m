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
//  UIApplication+FMReady.m
//  UICatalog
//
//  Created by Stuart Stern on 10/21/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UIApplication+FMReady.h"
#import <objc/runtime.h>
#import "UIView+FMReady.h"
#import "FoneMonkey.h"



@implementation UIApplication (FMReady)

+ (void)load {
	if (self == [UIApplication class]) {
		NSLog(@"Loading FoneMonkey...");
		
        Method originalMethod = class_getInstanceMethod(self, @selector(sendEvent:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmSendEvent:));
        method_exchangeImplementations(originalMethod, replacedMethod);
		[[NSNotificationCenter defaultCenter] addObserver:self	
												 selector:@selector(initTheMonkey:)
													 name:UIApplicationDidFinishLaunchingNotification object:nil];
	
	}
}

+ (void) initTheMonkey:(NSNotification*)notification {

	[[FoneMonkey sharedMonkey] open];

	
}



- (void)fmSendEvent:(UIEvent *)event {
	[[FoneMonkey sharedMonkey] handleEvent:event];
	
	// Call the original
	[self fmSendEvent:event];

	
}


@end
