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
#import "FMUtils.h"
#import <objc/runtime.h>
#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "UIView+FMReady.h"

#pragma mark UIScrollView delegate methods
@interface FMReadyUIScrollViewDelegate : NSObject <UIScrollViewDelegate> {
}
@end

@implementation FMReadyUIScrollViewDelegate
- (void)scrollViewWillBeginDragging_defaultImp:(UIScrollView *)scrollView {}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self scrollViewWillBeginDragging_defaultImp:scrollView];
}
- (void)scrollViewDidEndDragging_defaultImp:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self scrollViewDidEndDragging_defaultImp:scrollView willDecelerate:decelerate];
}
@end
#pragma mark -

@implementation UIScrollView (FMReady)

- (BOOL) isFMEnabled {
	return YES;
}

+ (void)load {
    if (self == [UIScrollView class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(setContentOffset:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmSetContentOffset:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
		
		originalMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        replacedMethod = class_getInstanceMethod(self, @selector(fmSetDelegate:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
		
    }
}

-(void) assureDelegate {
	if (self.delegate==nil) { 
		FMReadyUIScrollViewDelegate* del= [[FMReadyUIScrollViewDelegate alloc]init];
		self.delegate=del;
	}
}

- (void)fmSetContentOffset:(CGPoint)offset {
	[self assureDelegate];
	
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
	
		UIView* currentItem = [self subviewAtContentOffset:offset];
		NSString* elementMonkeyID = nil;
		if (currentItem!=nil) {
			elementMonkeyID = currentItem.accessibilityLabel;
			if (elementMonkeyID==nil || elementMonkeyID.length==0) { 
				elementMonkeyID = currentItem.monkeyID;
			}
		}
		[[FoneMonkey sharedMonkey] postCommandFrom:self 
										   command:FMCommandScroll 
											  args:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", offset.x], 
																			[NSString stringWithFormat:@"%1.0f", offset.y], 
																			elementMonkeyID,
																			nil]];
	
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

+ (NSString*) uiAutomationCommand:(FMCommandEvent*)command {
	NSMutableString* string = [[NSMutableString alloc] init];
	if ([command.command isEqualToString:FMCommandScroll]) {
		NSString* x = [command.args count] < 1 ? @"0" : [command.args objectAtIndex:0];
		NSString* y = [command.args count] < 2 ? @"0" : [command.args objectAtIndex:1];
		NSString* hitTestViewName = [command.args count] < 3 ? @"" : [command.args objectAtIndex:2];
		// handle this with drag...
		/*
		[string appendFormat:@"FoneMonkey.elementNamed(\"%@\").setValue(\"%@\"); // UIAScrollView", 
					[FMUtils stringByJsEscapingQuotesAndNewlines:command.monkeyID], 
					[FMUtils stringByJsEscapingQuotesAndNewlines:x],
					[FMUtils stringByJsEscapingQuotesAndNewlines:y],
					[FMUtils stringByJsEscapingQuotesAndNewlines:hitTestViewName]];
		 */
		[string appendFormat:@" // FoneMonkey.elementNamed(\"%@\").setContentOffset(%d,%d,\"%@\"); // UIAScrollView - sadly this method does not exist", 
				[FMUtils stringByJsEscapingQuotesAndNewlines:command.monkeyID], 
				[FMUtils stringByJsEscapingQuotesAndNewlines:x],
				[FMUtils stringByJsEscapingQuotesAndNewlines:y],
				[FMUtils stringByJsEscapingQuotesAndNewlines:hitTestViewName]];
		
	} else {
		[string appendString:[super uiAutomationCommand:command]];
	}
	return string;
}

- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch {
	return NO;
}
								
- (UIView*) subviewAtContentOffset:(CGPoint) offset {
	return [self subviewAtContentOffset:offset inView:self];
}

- (UIView*) subviewAtContentOffset:(CGPoint)offset inView:(UIView*)view {
	/*
	UIView* rez=nil;
	NSArray* kids=view.subviews;
	NSLog(@"testing content offset at %f, %f", offset.x, offset.y);	
	NSLog(@"found %d kids", kids.count);
	int i=0;
	for (UIView * kid in kids) {
		i++;
		NSLog(@"kid %d is a %@ with frame x=%f y=%f w=%f h=%f", i, NSStringFromClass([kid class]), kid.frame.origin.x, kid.frame.origin.y, kid.frame.size.width, kid.frame.size.height );
		if (!kid.hidden && [kid pointInside:offset withEvent:nil]) {
			rez=kid;
			CGPoint newOffset;
			newOffset.x = offset.x - rez.frame.origin.x;
			newOffset.y = offset.y - rez.frame.origin.y;
			UIView* nestedRez = [self subviewAtContentOffset:newOffset inView:rez];
			if (nestedRez != nil) {
				rez=nestedRez;
			}
		}
    }
	return rez;
	 */
	UIView* rez = [view hitTest:offset withEvent:nil];;
	// NSLog(@"testing content offset at %f, %f", offset.x, offset.y);	
	if (rez!=nil) {
		// NSLog(@"it's a %@ with frame x=%f y=%f w=%f h=%f",NSStringFromClass([rez class]), rez.frame.origin.x, rez.frame.origin.y, rez.frame.size.width, rez.frame.size.height );
	} else {
		// NSLog(@"it's nil");
	}
	return rez;
}

- (id <UIScrollViewDelegate>)fmReadyZapDelegate:(id <UIScrollViewDelegate>)del {
	Class clazz = [del class];
	
	SEL targetSelector = @selector(scrollViewWillBeginDragging:);
	Method replacementMethod = class_getInstanceMethod([self class],@selector(fmScrollViewWillBeginDragging:));
	SEL saveOriginalAs = @selector(fmOrigScrollViewWillBeginDragging:);
	Method defaultMethod = class_getInstanceMethod([FMReadyUIScrollViewDelegate class], @selector(scrollViewWillBeginDragging_defaultImp:));
	[self zapInstanceMethodForClass:clazz 
									targetSelector:targetSelector
									withReplacement:replacementMethod
									saveOriginalAs:saveOriginalAs
									defaultIfNotFound:defaultMethod];

	targetSelector = @selector(scrollViewDidEndDragging:willDecelerate:);
	replacementMethod = class_getInstanceMethod([self class],@selector(fmScrollViewDidEndDragging:willDecelerate:));
	saveOriginalAs = @selector(fmOrigScrollViewDidEndDragging:willDecelerate:);
	defaultMethod = class_getInstanceMethod([FMReadyUIScrollViewDelegate class], @selector(scrollViewDidEndDragging_defaultImp:willDecelerate:));
	[self zapInstanceMethodForClass:clazz 
					 targetSelector:targetSelector
					withReplacement:replacementMethod
					 saveOriginalAs:saveOriginalAs
				  defaultIfNotFound:defaultMethod];
	return del;
}


- (void)zapInstanceMethodForClass:(Class)clazz targetSelector:(SEL)targetSelector withReplacement:(Method)replacedMethod 
				   saveOriginalAs:(SEL)saveAsSelector defaultIfNotFound:(Method)defaultMethod {
	NSLog(@"-- --- -- - ------ -- - checking for zap on object of class %@", NSStringFromClass(clazz));	
	Method saveAsMethod = class_getInstanceMethod(clazz, saveAsSelector);
	if (!saveAsMethod) {
		IMP replImp = method_getImplementation(replacedMethod);		
		Method originalMethod = class_getInstanceMethod(clazz,targetSelector);
		if (originalMethod) {
			NSLog(@"-- --- -- - ------ -- - zapping method in class %@", NSStringFromClass(clazz));	
			const char* typeEncoding = method_getTypeEncoding(originalMethod);
			IMP origImp = method_getImplementation(originalMethod);
			
			if (origImp != replImp) {
				method_setImplementation(originalMethod, replImp);
				
				class_addMethod(clazz, saveAsSelector, origImp, typeEncoding);
			}
		} else {
			NSLog(@"-- --- -- - ------ -- - original method not found in class %@", NSStringFromClass(clazz));	
			if (defaultMethod) {
				NSLog(@"-- --- -- - ------ -- - using default method");	
				IMP defaultImp = method_getImplementation(defaultMethod);
				const char* typeEncoding = method_getTypeEncoding(originalMethod);
				class_addMethod(clazz, targetSelector, replImp, typeEncoding);
				class_addMethod(clazz, saveAsSelector, defaultImp, typeEncoding);
			}
		}
	} else {
		NSLog(@"-- --- -- - ------ -- - had already zapped class %@", NSStringFromClass(clazz));	
	}
}

- (void)fmScrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// NSLog(@" ### AAA ### ### ### ### ### ### ### ### UIScrollView+FMReady::fmScrollViewWillBeginDragging called");
//	[FMUtils setShouldRecordMonkeyTouch:YES forView:scrollView];
	[self fmOrigScrollViewWillBeginDragging:scrollView];
}
- (void)fmScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// NSLog(@" ### BBB ### ### ### ### ### ### ### ### UIScrollView+FMReady::fmScrollViewDidEndDragging called");
//	[FMUtils setShouldRecordMonkeyTouch:NO forView:self];
	[self fmOrigScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void) fmSetDelegate:(id <UIScrollViewDelegate>) del {
	[self fmReadyZapDelegate:del];
	[self fmSetDelegate:del];
}

@end
