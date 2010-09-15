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
//  NSObject+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/19/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+FMReady.h"

#import "UIControl+FMready.h"


@implementation NSObject (FMReady)
+ (void)load {
    if (self == [NSObject class]) {	
		Method originalMethod = class_getInstanceMethod(self, @selector(init));
		Method replacedMethod = class_getInstanceMethod(self, @selector(fmInit));		
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}

- (id)fmInit {
	// Calls original (that we swapped in load method)
	if (self = [self fmInit]) {	
		if ([self isKindOfClass:[UIControl class]]) {
			[(UIControl*)self subscribeToMonkeyEvents];
		}
	}
	
	return self;
}
@end
