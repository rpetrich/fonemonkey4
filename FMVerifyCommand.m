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
//  FMVerifyCommand.m
//  FoneMonkey
//
//  Created by Stuart Stern on 3/13/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#define RETRIES 10
#define RETRY 500

#import "FMVerifyCommand.h"


@implementation FMVerifyCommand

+ (NSString*) execute:(FMCommandEvent*) ev {
		ev.lastResult = nil;
		UIView* source = ev.source;		
		if (source == nil) {
			ev.lastResult = [NSString stringWithFormat:@"Unable to find %@ with monkeyID %@", ev.className, ev.monkeyID];
			return ev.lastResult;
		}	
		if ([ev.args count] == 3) {
			NSString* prop = [ev.args objectAtIndex:1];
			NSString* expected = [ev.args objectAtIndex:2];
			NSString* value = [source valueForKeyPath:prop];
			if ([expected isEqualToString:value]) {
				return nil;
			} else {
				ev.lastResult = [NSString stringWithFormat: @"Expected \"%@\", but found \"%@\"", expected, value];
			}
		} 
		return ev.lastResult;
}
@end
