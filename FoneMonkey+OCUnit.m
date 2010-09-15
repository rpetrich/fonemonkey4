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
//  FoneMonkey+OCUnit.m
//  FoneMonkey
//
//  Created by Stuart Stern on 1/31/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#import "FoneMonkey+OCUnit.h"

@implementation FoneMonkey (OCUnit)

- (void) runTests:(SenTestSuite*) suite {
	// We're a thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 		
	SenTestRun* run = [suite run];
	if (getenv("FM_ENABLE_AUTOEXIT")) {
		int exitStatus = (([run totalFailureCount] == 0U) ? 0 : 1);
		exit(exitStatus);
	}
	
	[pool release];	
}	

- (void) runTestSuite:(SenTestSuite*)suite {
	[NSThread detachNewThreadSelector:@selector(runTests:) toTarget:self withObject:suite];
	
}

- (void) runAllTests {
	[self runTestSuite:[SenTestSuite defaultTestSuite]];
}


@end
