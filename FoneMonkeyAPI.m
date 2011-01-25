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
//  FoneMonkeyAPI.m
//  FoneMonkey
//
//  Created by Stuart Stern on 2/6/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#import "FoneMonkeyAPI.h"
#import "FoneMonkey.h"
#import "FoneMonkey+OCUnit.h"
#import "FMUtils.h"

@implementation FoneMonkeyAPI
+ (void) record:(UIView*)sender command:(NSString*)command args:(NSArray*)args {
	[[FoneMonkey sharedMonkey] postCommandFrom:sender command:command args:args];
}

+ (void) continueRecording {
	[[FoneMonkey sharedMonkey] continueMonitoring];
}

+ (NSString*) playCommands:(NSArray*)commands {
	[[FoneMonkey sharedMonkey] loadCommands:commands];
	return [[FoneMonkey sharedMonkey] playAndWait];
}

+ (NSString*) playFile:(NSString*)file {
	[[FoneMonkey sharedMonkey] open:file];
	return [[FoneMonkey sharedMonkey] playAndWait];
}

+ (UIView*) viewWithMonkeyID:(NSString*)monkeyID havingClass:(NSString*)className{
	Class class = NSClassFromString(className);
	return [FMUtils viewWithMonkeyID:monkeyID startingFromView:[FMUtils rootWindow] havingClass:class];
}

+ (void) runTestSuite:(SenTestSuite*)suite {
	[[FoneMonkey sharedMonkey] runTestSuite:suite];
}

@end
