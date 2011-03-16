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
//  NSObject+FMReady.h
//  FoneMonkey
//
//  Created by Stuart Stern on 10/19/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (FMReady)
- (void) interceptMethod:(SEL)orig withMethod:(SEL)repl ofClass:(Class)class renameOrig:(SEL)newName types:(char*) types;
- (BOOL) fmHasMethod:(SEL) selector;
+ (void) fmSwapImplementation:(SEL)sel;
- (void) interceptMethod:(SEL)orig withClass:(Class)class types:(char*) types;
+ (void) load;
@end
