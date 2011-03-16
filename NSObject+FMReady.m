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
#import "NSObject+FMReady.h"


@implementation NSObject (FMReady)
+ (void)load {
    if (self == [NSObject class]) {	
		Method originalMethod = class_getInstanceMethod(self, @selector(init));
		Method replacedMethod = class_getInstanceMethod(self, @selector(fmInit));		
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}

/**
 Exchanges implementation of selector with a selector prefixed with "fm"
 */
+ (void) fmSwapImplementation:(SEL)sel {
	NSString* selName = [NSString stringWithFormat:@"fm_%s", sel_getName(sel)];
	SEL newSelector = NSSelectorFromString(selName);
	Method originalMethod = class_getInstanceMethod(self, sel);
	Method replacedMethod = class_getInstanceMethod(self, newSelector);	
	method_exchangeImplementations(originalMethod, replacedMethod);		
}
	
	

- (id)fmInit {
	// Calls original (that we swapped in load method)
	if (self = [self fmInit]) {	

	}
	return self;
}

- (void) interceptMethod:(SEL)orig withClass:(Class)class types:(char*) types {
	Method originalMethod = class_getInstanceMethod([self class], orig);
	IMP origImp = nil;
	if (originalMethod) {
		origImp = method_getImplementation(originalMethod);
	}
	const char* origName = sel_getName(orig);
	Method replaceMethod = class_getInstanceMethod(class, NSSelectorFromString([NSString stringWithFormat:@"fm_%s", origName]));
	IMP replImp = method_getImplementation(replaceMethod);
	
	if (origImp != replImp) {
		if (originalMethod) {
			NSString* newName = [NSString stringWithFormat:@"orig_%s", origName];
			method_setImplementation(originalMethod, replImp);
			class_addMethod([self class], NSSelectorFromString(newName), origImp,types);		
		} else {
			class_addMethod([self class], orig, replImp,types);
		}
		
	}
}

- (void) interceptMethod:(SEL)orig withMethod:(SEL)repl ofClass:(Class)class renameOrig:(SEL)newName types:(char*) types {
	Method originalMethod = class_getInstanceMethod([self class], orig);
	IMP origImp = nil;
	if (originalMethod) {
		origImp = method_getImplementation(originalMethod);
	}
	Method replacedMethod = class_getInstanceMethod(class, repl);
	IMP replImp = method_getImplementation(replacedMethod);
		
	if (origImp != replImp) {
		if (originalMethod) {
			method_setImplementation(originalMethod, replImp);
			class_addMethod([self class], newName, origImp,types);		
		} else {
			class_addMethod([self class], orig, replImp,types);
		}

	}
}

- (BOOL) fmHasMethod:(SEL) selector {
	return class_getInstanceMethod([self class], selector) != nil;
}

@end
