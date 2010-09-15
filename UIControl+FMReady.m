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
//  UIControl+FoneMonkey.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIControl+FMReady.h"
#import <UIKit/UIControl.h>
#import <objc/runtime.h>
#import "FoneMonkey.h"


@implementation UIControl (FoneMonkey)

+ (void)load {
    if (self == [UIControl class]) {
		// Hijack UIControl's initialializers so we can add FoneMonkey stuff whenever a UIControl is created

        Method originalMethod = class_getInstanceMethod(self, @selector(initWithCoder:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmInitWithCoder:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}

- (void) subscribeToMonkeyEvents {
	if (self.monkeyEventsToHandle != 0) {
		[self addTarget:self action:@selector(handleMonkeyEventFromSender:forEvent:) forControlEvents:self.monkeyEventsToHandle];
	}
}

- (id)fmInitWithCoder:(NSCoder *)decoder {
	// Calls original initWithCoder (that we swapped in load method)
	if (self = [self fmInitWithCoder:decoder]) {	
		[self subscribeToMonkeyEvents];
	}

	return self;	

}



- (UIControlEvents) monkeyEventsToHandle {
	// Default ignores all events
	return 0;
}
- (void) handleMonkeyEventFromSender:(id)sender forEvent:(UIEvent*)event {
	// Default is a no-op
}

@end
