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
//  FMCommandEvent.h
//  FoneMonkey
//
//  Created by Stuart Stern on 10/14/09.
//  Copyright 2009 Gorilla Logic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSArray.h>

/**
 The FoneMonkey command object used for recording and playback.
 */
@interface FMCommandEvent : NSObject {

	UIView* source;
	NSString* command;
	NSString* className;
	NSString* monkeyID;	
	NSArray* args;
	NSMutableDictionary* dict;
	NSString* lastResult;
}
/**
 Create a new FMCommandEvent
*/
+ (FMCommandEvent*) command:(NSString*)cmd className:(NSString*)name monkeyID:(NSString*)id args:(NSArray*)array;
- (id) init:(NSString*)cmd className:(NSString*)className monkeyID:(NSString*)monkeyID args:(NSArray*)args;
- (id) initWithDict:(NSMutableDictionary*)dict;
- (id) execute;
/**
 The component corresponding to the supplied className and monkeyID.
 */
@property (readonly) UIView* source;
@property (nonatomic, retain) NSString* command;
@property (nonatomic, retain) NSString* className;
@property (nonatomic, retain) NSString* monkeyID;
@property (nonatomic, retain) NSString* lastResult;
@property (nonatomic, retain) NSArray* args;
@property (nonatomic, retain) NSMutableDictionary* dict;
@end
