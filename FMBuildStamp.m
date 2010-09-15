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
//  FMBuildStamp.m
//  FoneMonkey
//
//  Created by Stuart Stern on 2/2/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#import "FMBuildStamp.h"
#import "FMBuildStampDefines.h"

@implementation FMBuildStamp
	+ (NSString*) buildStamp {
		return FM_BUILD_STAMP;
	}
+ (NSString*) version {
	// EDIT WITH EACH RELEASE
	return @"4.0.b";
}
@end
