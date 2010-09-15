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
//  UIResponder+FMReady.h
//  FoneMonkey
//
//  Created by Stuart Stern on 10/19/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FMCommandEvent;

/**
 FoneMonkey UIView extensions provide recording and playback of Touch and Motion events. UIView subclasses can override one or more of these methods to cusotmize recording and playback logic for a class.
 */
@interface UIView (FoneMonkey) 
/** Interpret the command and generate the necessary UI events for the component.
*/
- (void) playbackMonkeyEvent:(FMCommandEvent*)event;
/**
 A string value uniquely identifying this instance of the component class
 */
- (NSString*) monkeyID;

/**
Returns YES if the supplied touch should be recorded. By default, returns YES if touch.phase == UITouchPhaseEnded and NO otherwise. Override this method to filter which touch events should be recorded for a class.
 */
- (BOOL) shouldRecordMonkeyTouch:(UITouch*)touch;

/**
Evaluates touch events and records corresponding command. 
 */
- (void) handleMonkeyTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event;
/**
 Evaluates motion (shake) event and records corresponding command.
 */
- (void) handleMonkeyMotionEvent:(UIEvent*)event;

/**
 Returns NO if recording should be disabled for the component. By default, returns YES for UIView subclasses, but NO for UIView class instances (since these are component containers).
 */
- (BOOL) isFMEnabled;

@end
