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
//  UIControl+FoneMonkey.h
//  FoneMonkey
//
//  Created by Stuart Stern on 10/13/09.
//  Copyright 2009 Gorilla Logic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>

/**
 FoneMonkey UIControl event handling extensions. Override to modify UIControl recording of UIControlEvents.
 */
@interface UIControl (FoneMonkey)

/**
 The events to be recorded for this UIControl class. Defaults to none.
 */
- (UIControlEvents)monkeyEventsToHandle;

/**
 Prepare a UIControlEvent event for recording.
 */
- (void) handleMonkeyEventFromSender:(id)sender forEvent:(UIEvent*)event;

/**
 Register for events to be recorded
 */
- (void) subscribeToMonkeyEvents;

@end
