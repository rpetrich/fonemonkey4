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
//  FoneMonkey+OCUnit.h
//  FoneMonkey
//
//  Created by Stuart Stern on 1/31/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import "FoneMonkey.h"

@interface FoneMonkey (OCUnit)
	/**
	 Run all SentTests linked into the app.
	 */
	- (void) runAllTests;
	/** 
	 Run the specified SenTestSuite.
	 */
	- (void) runTestSuite:(SenTestSuite*)suite;
@end
