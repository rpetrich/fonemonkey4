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
//  UITextView+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 11/1/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UITextView+FMReady.h"
#import "FMUtils.h"
#import <objc/runtime.h>
#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "UIView+FMReady.h"
#import "NSObject+FMReady.h"

@interface UITextView (FM_INTERCEPTOR)  
// Stop the compiler from whining
- (BOOL)orig_textViewShouldEndEditing:(UITextView *)textView;
- (BOOL) orig_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string;
- (void) orig_setDelegate:(NSObject <UITextViewDelegate>*) del;
@end

@interface FMDefaultTextViewDelegate : NSObject <UITextViewDelegate>
@end
@implementation FMDefaultTextViewDelegate
@end

@implementation UITextView (FMReady)

+ (void)load {
   // if (self == [UITextView class]) {
		
        //[self fmSwapImplementation:@selector(setDelegate:)];
		[UIScrollView interceptMethod:@selector(setDelegate:) withClass:[UITextView class] types:"v@:@"];
   // }
}
- (void) fmInitAutomation {
	[super fmInitAutomation];
	self.delegate = [[FMDefaultTextViewDelegate alloc] init];
}
- (void) fm_setDelegate:(NSObject <UITextViewDelegate>*) del {	
	if ([self class] == [UITextView class]) {
		//	[del interceptMethod:@selector(textViewDidChangeSelection:) withClass:[self class] types:"v@:@"];
		[del interceptMethod:@selector(textViewShouldEndEditing:) withClass:[self class] types:"c@:@"];	
		[del interceptMethod:@selector(textViewShouldBeginEditing:) withClass:[self class] types:"c@:@"];			
		//	[del interceptMethod:@selector(textViewDidEndEditing:) withClass:[self class] types:"v@:@"];	
		[del interceptMethod:@selector(textView:shouldChangeTextInRange:replacementText:) withClass:[self class] types:"c@:@@@"];	
		//	[del interceptMethod:@selector(textViewDidChange:) withClass:[self class] types:"v@:@"];
	}
	[self orig_setDelegate:del];

	
}


- (BOOL)fm_textViewShouldEndEditing:(UITextView *)textView {
	if ([FoneMonkey isRecording]) {
		FMCommandEvent* lastEvent = [[FoneMonkey sharedMonkey] lastCommand];
		if (![lastEvent.command isEqualToString:FMCommandInputText]) {
			[[FoneMonkey sharedMonkey] recordFrom:textView command:FMCommandInputText 
										  args:[NSArray arrayWithObjects: textView.text, nil]
										  post:NO];
			NSInteger index = [[FoneMonkey sharedMonkey].commands count] - 1;
			FMCommandEvent* prevCommand = [[FoneMonkey sharedMonkey] commandAt:index - 2];
										   
			if ([prevCommand.command isEqualToString:FMCommandInputText] && [prevCommand.monkeyID isEqualToString:textView.monkeyID]) {
				[[FoneMonkey sharedMonkey] deleteCommand:index -2 ];
				index--;
			}
			[[FoneMonkey sharedMonkey] moveCommand:index to:index - 1];
		} else {
			if ([lastEvent.command isEqualToString:FMCommandInputText] && [lastEvent.monkeyID isEqualToString:[textView monkeyID]]) {
				[[FoneMonkey sharedMonkey] popCommand];
			}
			[ [FoneMonkey sharedMonkey] recordFrom:textView command:FMCommandInputText 
											  args:[NSArray arrayWithObjects: textView.text, nil]
											  post:NO];
		}
	}
	if (class_getInstanceMethod([self class], @selector(orig_textViewShouldEndEditing:))) {
		return ([self orig_textViewShouldEndEditing:textView]);
	} else {
		return YES;
	}
}

- (BOOL) fm_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
	if ([FoneMonkey isRecording]) {
		FMCommandEvent* lastEvent = [[FoneMonkey sharedMonkey] lastCommand];
		if ([lastEvent.command isEqualToString:FMCommandInputText] && [lastEvent.monkeyID isEqualToString:[textView monkeyID]]) {
			[[FoneMonkey sharedMonkey] popCommand];
		}
		NSString* newVal = [textView.text stringByReplacingCharactersInRange:range withString:string];
		[ [FoneMonkey sharedMonkey] recordFrom:textView command:FMCommandInputText 
										  args:[NSArray arrayWithObjects: newVal, nil]
										  post:NO];
	}
	if (class_getInstanceMethod([self class], @selector(orig_textView:shouldChangeTextInRange:replacementText:))) {
		return [self orig_textView:textView shouldChangeTextInRange:range replacementText:string];
	} else {
		return YES;
	}
	
}
//- (void) handleMonkeyTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {	
//	// [FoneMonkey suspend];
//	//[super handleMonkeyTouchEvent:touches withEvent:event];
////	[[NSNotificationCenter defaultCenter] addObserver:self
////											 selector:@selector(keyBoardDismissed:)
////												 name:UIKeyboardWillHideNotification object:nil];
//	[[FoneMonkey sharedMonkey] postCommandFrom:self command:FMCommandTouch args:nil];	
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(keyBoardDismissed:)
//												 name:UITextViewTextDidEndEditingNotification object:nil];	
//}

//- (void) keyBoardDismissed:(NSNotification*) notification {
////	[[NSNotificationCenter defaultCenter] removeObserver:self
////												 name:UIKeyboardWillHideNotification object:nil];	
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//												name:UITextViewTextDidEndEditingNotification object:nil];	
//	[[FoneMonkey sharedMonkey] postCommandFrom:self command:FMCommandInputText args:[NSArray arrayWithObject:self.text]];
//}
//
//- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch {	
//	return (touch.phase == UITouchPhaseBegan);
//}

- (void) playbackMonkeyEvent:(FMCommandEvent*)event {
	if ([event.command isEqualToString:FMCommandInputText]) {
		NSString* newText = [event.args count] < 1 ? @"" : [event.args objectAtIndex:0];
		NSRange range;
		range.location = 0;
		range.length = [self.text length];
		//BOOL noInput = range.length == 0 && [newText length] == 0;
		if ([self.delegate textView:self shouldChangeTextInRange:range replacementText:newText]) {
			self.text = newText;
		}
		return;
	}
	
	if ([event.command isEqualToString:FMCommandTouch]) {
		[self becomeFirstResponder];
		return;
	}
	
	[super playbackMonkeyEvent:event];
	//	[self performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:nil];	
	//	if (event.args) {
	//		self.text = [[event args] objectAtIndex:0];
	//	}
	
	
}

+ (NSString*) uiAutomationCommand:(FMCommandEvent*)command {
	NSMutableString* string = [[NSMutableString alloc] init];
	if ([command.command isEqualToString:FMCommandInputText]) {
		NSString* textValue = [command.args count] < 1 ? @"" : [command.args objectAtIndex:0];
		[string appendFormat:@"FoneMonkey.elementNamed(\"%@\").setValue(\"%@\"); // UIATextView", 
		 [FMUtils stringByJsEscapingQuotesAndNewlines:command.monkeyID], 
		 [FMUtils stringByJsEscapingQuotesAndNewlines:textValue]];
	} else {
		[string appendString:[super uiAutomationCommand:command]];
	}
	return string;
}

- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch {
	return (touch.phase == UITouchPhaseEnded);
}


@end
