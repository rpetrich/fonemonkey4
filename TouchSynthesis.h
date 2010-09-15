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
//  TouchSynthesis.h
//  SelfTesting
//
//  Created by Matt Gallagher on 23/11/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
// Modified extensively for FoneMonkey by Stu Stern, Gorilla Logic, November, 2009
//


#import <UIKit/UIKit.h>

//
// UITouch (Synthesize)
/**
 UITouch extensions for synthesizing touch events.
*/
@interface UITouch (Synthesize)

- (id)initInView:(UIView *)view;
- (void)setPhase:(UITouchPhase)phase;
- (void)setLocationInWindow:(CGPoint)location;


@end


/**
// UIEvent extensions for simulating touch events.
*/
@interface UIEvent (Synthesize)

- (id)initWithTouch:(UITouch *)touch;
+ (void)performTouchLeftInView:(UIView*)view;
+ (void)performTouchRightInView:(UIView*)view;
+ (void)performTouchInView:(UIView*)view;
+ (void)performTouchInView:(UIView*)view at:(CGPoint)point;
+ (void)performTouchInView:(UIView*)view at:(CGPoint)point withCount:(NSInteger)count;
+ (void)performTouchInView:(UIView*)view at:(CGPoint)point forPhase:(UITouchPhase)phase;
+ (void)performTouchDownInView:(UIView*)view at:(CGPoint)point;
+ (void)performTouchUpInView:(UIView*)view at:(CGPoint)point;
+ (void)performMoveInView:(UIView *)view from:(CGPoint)from to:(CGPoint)to;
@end
