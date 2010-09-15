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
#import <objc/runtime.h>
#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "UIView+FMReady.h"


@implementation UITextView (FMReady)

- (void) handleMonkeyTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {	
	// [FoneMonkey suspend];
	//[super handleMonkeyTouchEvent:touches withEvent:event];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(keyBoardDismissed:)
//												 name:UIKeyboardWillHideNotification object:nil];
	[[FoneMonkey sharedMonkey] postCommandFrom:self command:FMCommandTouch args:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyBoardDismissed:)
												 name:UITextViewTextDidEndEditingNotification object:nil];	
}

- (void) keyBoardDismissed:(NSNotification*) notification {
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//												 name:UIKeyboardWillHideNotification object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self
												name:UITextViewTextDidEndEditingNotification object:nil];	
	[[FoneMonkey sharedMonkey] postCommandFrom:self command:FMCommandInputText args:[NSArray arrayWithObject:self.text]];
}

- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch {	
	return (touch.phase == UITouchPhaseBegan);
}

- (void) playbackMonkeyEvent:(FMCommandEvent*)event {
	[self performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:nil];	
	if (event.args) {
		self.text = [[event args] objectAtIndex:0];
	}

}

@end
