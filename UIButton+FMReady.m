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
//  UIButton+FMReady.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/17/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import "FoneMonkey.h"
#import "FMCommandEvent.h"
#import "UIButton+FMReady.h"
#import "UIView+FMReady.h"

#import <UIKit/UIEvent.h>


@implementation UIButton (FMReady)

- (NSString*) monkeyID {
	return self.currentTitle ? self.currentTitle : 
		[super monkeyID];
}

- (BOOL) shouldRecordMonkeyTouch:(UITouch *)touch {
	if ([self.superview isKindOfClass:[UITextField class]]) {
		// It's a clear button?
		return NO;
	}
	return [super shouldRecordMonkeyTouch:touch];
}


@end
