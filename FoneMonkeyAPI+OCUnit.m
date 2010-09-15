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
//  FoneMonkeyAPI+OCUnit.h
//  FoneMonkey
//
//  Created by Stuart Stern on 4/4/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#include "FoneMonkeyAPI+OCUnit.h"
#include "FoneMonkey+OCUnit.h"

@implementation FoneMonkeyAPI (OCUnit)
/** 
 Run the specified SenTestSuite.
 */
+ (void) runTestSuite:(SenTestSuite*)suite {
	[[FoneMonkey sharedMonkey] runTestSuite:suite];
}
@end
