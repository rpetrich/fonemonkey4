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
//  FMUtils.m
//  FoneMonkey
//
//  Created by Stuart Stern on 11/7/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import <objc/runtime.h>

#import "FMUtils.h"
#import "UIView+FMReady.h"
#import <QuartzCore/QuartzCore.h>
#import "TouchSynthesis.h"
#import <objc/runtime.h>
#import "FMConsoleController.h"
#import "UIMotionEventProxy.h"
#import "FMWindow.h"

@implementation FMUtils
+ (UIWindow*) rootWindow {
	UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
	return  keyWindow != nil ?  keyWindow : [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}


+ (UIView*) viewWithMonkeyID:(NSString*)mid startingFromView:(UIView*)current havingClass:(Class)class{

	// NSLog(@"Checking %@ == %@", current.monkeyID, mid);
	
	if (!current) {
		current =  [FMUtils rootWindow];
	}
	
	if (mid == nil || [mid length] == 0 || [[current monkeyID] isEqualToString:mid]) {
//NSLog(@"Found %@", current.monkeyID);
		if (class == nil) { 
			return current;
		}
		
		if ((class != nil) && (current != nil)) {
			NSString *name = NSStringFromClass (class);
// NSLog(@"Class: %@", class);
// NSLog(@"Current: %@", [current class]);
		}
		
		if ((class != nil) && ([current isKindOfClass:class])) {
			return current;
		}
	}
	
	if (!current.subviews) {
		return nil;
	}
	
	for (UIView* view in current.subviews) {
		UIView* result;
		if (result = [self viewWithMonkeyID:mid startingFromView:view havingClass:class]) {
			return result;
		}
		
	}	
	
	
	
	return nil;
}


+ (UIView*) viewWithMonkeyID:(NSString*)mid havingClass:(NSString*)className{
	Class class = objc_getClass([className UTF8String]);
	for (UIView* view in [[UIApplication sharedApplication] windows]) {
		if ([view isKindOfClass:[FMWindow class]]) {
			continue;
		}
		UIView* result = [self viewWithMonkeyID:mid startingFromView:view havingClass:class];
		if (result != nil) {
			return result;
		}
	}
	return nil;
}

static NSInteger foundSoFar;
+ (NSInteger) ordinalForView:(UIView*)view startingFromView:(UIView*)current {
	//NSLog(@"Checking %@ == %@", current.monkeyID, mid);
	if (!current) {
		current =  [FMUtils rootWindow];
	}
	
	if ([current isMemberOfClass:[view class]]) {
		if (current == view) { 
			return foundSoFar;
		}
		
		foundSoFar++;
		
	}
	
	if (!current.subviews) {
		return -1;
	}
	
	for (UIView* kid in current.subviews) {
		NSInteger result;
		if ((result = [self ordinalForView:view startingFromView:kid]) > -1) {
			return result;
		}
		
	}	
	
	
	
	return -1;
}

// Not Re-entrant!
+ (NSInteger) ordinalForView:(UIView*)view {
	foundSoFar = 0;
	return [self ordinalForView:view startingFromView:nil];
}

+ (UIView*) findFirstMonkeyView:(UIView*)current {
	if (current == nil) {
		return nil;
	}
	
	if ([current isFMEnabled]) { 
		return current;
	}
	
	return [FMUtils findFirstMonkeyView:[current superview]];
}

+ (BOOL)writeApplicationData:(NSData *)data toFile:(NSString *)fileName {
    NSString *documentsDirectory = [FMUtils scriptsLocation];
    if (!documentsDirectory) {
        NSLog(@"Documents directory not found!");
        return NO;
    }
	NSLog(@"Writing %@/%@", documentsDirectory, fileName);	
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    return ([data writeToFile:appFile atomically:YES]);
}

+ (NSData *)applicationDataFromFile:(NSString *)fileName {
    NSString *documentsDirectory = [FMUtils scriptsLocation];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *myData = [[[NSData alloc] initWithContentsOfFile:appFile] autorelease];
    return myData;
}

+ (void) slideIn:(UIView*)view {
	CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type =  kCATransitionPush;
	transition.subtype  = kCATransitionFromBottom;
   // transition.delegate = self;
    [view.layer addAnimation:transition forKey:nil];
	view.alpha = 1.0;
	[[FMUtils rootWindow] bringSubviewToFront:view];
}

+ (void) slideOut:(UIView*) view {
	CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type =  kCATransitionPush;
	transition.subtype  = kCATransitionFromTop;
    //transition.delegate = self;
    [view.layer addAnimation:transition forKey:nil];
	view.alpha = 0;
	[[FMUtils rootWindow] bringSubviewToFront:view];
}

+ (void) navRight:(UIView*)view from:(UIView*)from {
	CATransition *transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	transition.type =  kCATransitionPush;
	transition.subtype  = kCATransitionFromRight;
	// transition.delegate = self;
    [view.layer addAnimation:transition forKey:nil];
	view.alpha = 1.0;
//	[from.layer addAnimation:transition  forKey:nil];
//	from.alpha = 0.0;
	[[FMUtils rootWindow] bringSubviewToFront:view];
}


+ (void) navLeft:(UIView*)view to:(UIView*)to {
	CATransition *transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	transition.type =  kCATransitionPush;
	transition.subtype  = kCATransitionFromLeft;
	// transition.delegate = self;
    [view.layer addAnimation:transition forKey:nil];
	view.alpha = 0.0;
//	[to.layer addAnimation:transition  forKey:nil];
//	to.alpha = 1.0;	
//	[[FMUtils rootWindow] bringSubviewToFront:view];
}

+ (void) dismissKeyboard {	
	UIWindow *keyWindow = (UIWindow*)[FMConsoleController sharedInstance].view;
	UIView   *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
	[firstResponder resignFirstResponder];
}

+ (NSString*) scriptsLocation {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (void) shake {
	// Although such legal wrangling is not necessary in the simulator, it is necessary to prevent dynamic linker errors on the actual iPhone
	UIMotionEventProxy* m = [[NSClassFromString(@"UIMotionEvent") alloc] _init];
	
	m->_subtype = UIEventSubtypeMotionShake;
	m->_shakeState = 1;
	[[UIApplication sharedApplication] sendEvent:m]; // Works in simulator but not on device
	//[[[UIApplication sharedApplication] keyWindow] motionBegan:UIEventSubtypeMotionShake withEvent:m];
	//[[UIApplication sharedApplication] keyWindow] motionEnded:UIEventSubtypeMotionShake withEvent:m];	
}

+(BOOL) isKeyboard:(UIView*)view {
	// It should go without saying that this is a hack
	Class cls = view.window ? [view.window class] : [view class];
	return [[NSString stringWithUTF8String:class_getName(cls)] isEqualToString:@"UITextEffectsWindow"];
}
@end
