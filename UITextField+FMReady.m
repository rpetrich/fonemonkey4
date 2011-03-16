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
//  UITextField+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/17/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "UITextField+FMReady.h"

#import "FoneMonkeyAPI.h"
#import "FoneMonkey.h"
#import "FMUtils.h"
#import <objc/runtime.h>
#import "NSObject+FMReady.h"


#define FMTextFieldStateKey @"FMTextFieldState"

@interface UITextField (FM_INTERCEPTOR) 
// Stop the compiler from whining
- (BOOL) orig_textFieldShouldReturn:(UITextField*)textField;
- (BOOL) orig_textFieldShouldClear:(UITextField*)textField;
- (BOOL) orig_textFieldShouldEndEditing:(UITextField*)textField;
- (void) orig_textFieldDidEndEditing:(UITextField*)textField;
- (BOOL) orig_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end

@interface FMDefaultTextFieldDelegate : NSObject <UITextFieldDelegate>
@end
@implementation FMDefaultTextFieldDelegate
@end


@implementation UITextField (FMReady)

typedef enum {
	FMTextFieldStateNormal,
	FMTextFieldStateEditing,
	FMTextFieldStateReturn
} FMTextFieldState;

+ (void)load {
    if (self == [UITextField class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(fmSetDelegate:));
        method_exchangeImplementations(originalMethod, replacedMethod);	
    }
}
		 
- (void) fmAssureAutomationInit {
	[super fmAssureAutomationInit];
	if (!self.delegate) {
		self.delegate = [[FMDefaultTextFieldDelegate alloc] init];
	}
}

//- (UIControlEvents)monkeyEventsToHandle {
//	return UIControlEventEditingDidEnd | UIControlEventTouchDown;
//}	

- (void) fmSetDelegate:(NSObject <UITextFieldDelegate>*) del {	
	[del interceptMethod:@selector(textFieldShouldReturn:) withClass:[self class] types:"c@:@"];
	[del interceptMethod:@selector(textFieldShouldEndEditing:) withClass:[self class] types:"v@:@"];	
	[del interceptMethod:@selector(textFieldDidEndEditing:) withClass:[self class] types:"v@:@"];	
	[del interceptMethod:@selector(textField:shouldChangeCharactersInRange:replacementString:) withClass:[self class] types:"c@:@@@"];	
	[del interceptMethod:@selector(textFieldShouldClear:) withClass:[self class] types:"c@:@"];
	
	[self fmSetDelegate:del];
	
}

- (NSString*) monkeyID {
	NSString* accLbl = [self accessibilityLabel];
	if (accLbl!=nil && [accLbl length]>0) {
		return accLbl;
	}	
	return self.placeholder ? 
		self.placeholder : 
			[super monkeyID];
}

//- (void) handleMonkeyEventFromSender:(id)sender forEvent:(UIEvent*)event {
//
//	if (event) {
//		
//		if (event.type == UIEventTypeTouches) {
//			[FoneMonkey recordFrom:self command:FMCommandTouch];
//		}
//		
//		return;
//	} 
//	
////	if (!self.editing && self.text != nil) {
////		[FoneMonkeyAPI record:self command:FMCommandInputText args:[NSArray arrayWithObject:[self.text copy]]];
////	} else {
////		[FoneMonkeyAPI continueRecording];
////	}
//	
//}

+ (void) fmSetState:(FMTextFieldState)s {
	[[FoneMonkey sharedMonkey].session setObject:[NSString stringWithFormat:@"%d",s] forKey:FMTextFieldStateKey];
}

+ (FMTextFieldState) fmState {
	FMTextFieldState s = [((NSString*)[[FoneMonkey sharedMonkey].session objectForKey:FMTextFieldStateKey]) intValue];
	return s;
}

- (BOOL)fm_textFieldShouldReturn:(UITextField *)textField {
	if ([FoneMonkey isRecording]) {
		[UITextField fmSetState:FMTextFieldStateReturn];
		FMCommandEvent* lastEvent = [[FoneMonkey sharedMonkey] lastCommand];
		if ([lastEvent.command isEqualToString:FMCommandInputText] && [lastEvent.monkeyID isEqualToString:[textField monkeyID]]) {
			[[FoneMonkey sharedMonkey] popCommand];
		}		
		[ FoneMonkey recordEvent:[[FMCommandEvent alloc]
								  init:FMCommandReturn className:[NSString stringWithUTF8String:class_getName([textField class])]
								  monkeyID:[textField monkeyID]
								  args:[NSArray arrayWithObjects: textField.text, 
										nil]]];		
	}
	if (class_getInstanceMethod([self class], @selector(orig_textFieldShouldReturn:))) {
		return ([self orig_textFieldShouldReturn:textField]);
	} else {
		return YES;
	}
}

- (BOOL)fm_textFieldShouldClear:(UITextField *)textField {
	if ([FoneMonkey isRecording]) {
		[UITextField fmSetState:FMTextFieldStateEditing];
		[FoneMonkey recordFrom:textField command:FMCommandClear];
	}
	if (class_getInstanceMethod([self class], @selector(orig_textFieldShouldClear:))) {
		return [self orig_textFieldShouldClear:textField];
	} else {
		return YES;
	}
}

- (BOOL)fm_textFieldShouldEndEditing:(UITextField *)textField {
	if ([FoneMonkey isRecording]) {
//		NSInteger index = [[[FoneMonkey sharedMonkey] commands] count] - 1;
//		if (index < 0 || ![[[FoneMonkey sharedMonkey] commandAt:index].command isEqualToString:FMCommandReturn]) {
//			[ [FoneMonkey sharedMonkey] recordFrom:textField command:FMCommandInputText 
//							   args:[NSArray arrayWithObjects: textField.text, nil]
//							   post:NO];
//			[[FoneMonkey sharedMonkey] moveCommand:index + 1 to:index];
//		}
	}
	if (class_getInstanceMethod([self class], @selector(orig_textFieldShouldEndEditing:))) {
		return ([self orig_textFieldShouldEndEditing:textField]);
	} else {
		return YES;
	}
}

- (void)fm_textFieldDidEndEditing:(UITextField *)textField {
	if ([FoneMonkey isRecording]) {
		[UITextField fmSetState:FMTextFieldStateNormal];
	}
	
	if (class_getInstanceMethod([self class], @selector(orig_textFieldDidEndEditing:))) {
		[self orig_textFieldDidEndEditing:textField];
	}
}

- (BOOL) fm_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([FoneMonkey isRecording]) {
		[UITextField fmSetState:FMTextFieldStateEditing];
		if ([FoneMonkey isRecording]) {
			FMCommandEvent* lastEvent = [[FoneMonkey sharedMonkey] lastCommand];
			if ([lastEvent.command isEqualToString:FMCommandInputText] && [lastEvent.monkeyID isEqualToString:[textField monkeyID]]) {
				[[FoneMonkey sharedMonkey] popCommand];
			}
			NSString* newVal = [textField.text stringByReplacingCharactersInRange:range withString:string];
			[ [FoneMonkey sharedMonkey] recordFrom:textField command:FMCommandInputText 
											  args:[NSArray arrayWithObjects: newVal, nil]
											  post:NO];
		}		
	}
	if (class_getInstanceMethod([self class], @selector(orig_textField:shouldChangeCharactersInRange:replacementString:))) {
		return [self orig_textField:textField shouldChangeCharactersInRange:range replacementString:string];
	} else {
		return YES;
	}

}

- (void) playbackMonkeyEvent:(FMCommandEvent*)recevent {
	[self fmAssureAutomationInit];
	if ([recevent.command isEqualToString:FMCommandReturn] || [recevent.command isEqualToString:FMCommandInputText] ) {
		NSString* newText = [recevent.args count] < 1 ? @"" : [recevent.args objectAtIndex:0];
		NSRange range;
		range.location = 0;
		range.length = [self.text length];
		BOOL noInput = range.length == 0 && [newText length] == 0;
		if (noInput  || [self.delegate textField:self shouldChangeCharactersInRange:range replacementString:newText]) {
			if (!noInput) {
				self.text = newText;
			}
			if ([recevent.command isEqualToString:FMCommandReturn]) {
				if ([self.delegate textFieldShouldReturn:self]) {
				// If text field should return, then autocorrected value would be accepted?
				// Autocorrected text handling goes here?
				}
			} else {
				if ([self.delegate textFieldShouldEndEditing:self]) {
					[self resignFirstResponder];	
				}
			}
		} 
		return;
	}
	
	if ([recevent.command isEqualToString:FMCommandTouch]) {
		[self becomeFirstResponder];
		return;
	}
				 
	if ([recevent.command isEqualToString:FMCommandClear]) {
		if ([self.delegate textFieldShouldClear:self]) {
			self.text = nil;
		}
		return;
	}			 
	
	[super playbackMonkeyEvent:recevent];
	
}

+ (NSString*) uiAutomationCommand:(FMCommandEvent*)command {
	NSMutableString* string = [[NSMutableString alloc] init];
	if ([command.command isEqualToString:FMCommandInputText]) {
		NSString* value = [command.args count] < 1 ? @"" : [command.args objectAtIndex:0];
		[string appendFormat:@"FoneMonkey.elementNamed(\"%@\").setValue(\"%@\"); // UIATextField", 
						[FMUtils stringByJsEscapingQuotesAndNewlines:command.monkeyID], 
						[FMUtils stringByJsEscapingQuotesAndNewlines:value]];
	} else {
		[string appendString:[super uiAutomationCommand:command]];
	}
	return string;
}



@end
