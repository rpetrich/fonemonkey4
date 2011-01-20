
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
//  FoneMonkeyAPI.h
//  FoneMonkey
//
//  Created by Stuart Stern on 2/6/10.
//  Copyright (c) 2010 Gorilla Logic, Inc. All rights reserved.
//

//
//  FMWaitForCommand.m
//  FoneMonkey
//
//  Created by Stuart Stern on 3/13/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#import "FMWaitForCommand.h"
#import "FMCommandEvent.h"
#import "FMVerifyCommand.h"
#include <unistd.h>

@implementation FMWaitForCommand
+ (NSString*) execute:(FMCommandEvent*) ev {
	NSInteger interval = 500000;
	FMCommandEvent* verifyEvent = ev;
	if ([ev.args count] > 0) {
		NSString* arg0 = [ev.args objectAtIndex:0];
		if ([arg0 rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location==0) { // starts with a digit
			NSInteger msecs = [((NSString*)[ev.args objectAtIndex:0]) intValue];
			interval = msecs*100;
			NSMutableArray* newArgs = [NSMutableArray arrayWithArray:ev.args];
			[newArgs removeObjectAtIndex:0];
			verifyEvent = [ev copyWithZone:nil];
			verifyEvent.args = newArgs;
		}
	}
	int i;
	for (i = 0; i < 10; i++) {
		if (i) {
			usleep(interval);
		}
		if (![FMVerifyCommand execute:verifyEvent]) {
			return nil;
		}
	}
	return ev.lastResult;

}

@end
