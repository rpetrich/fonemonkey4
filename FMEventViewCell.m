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
//  FMEventViewCell.m
//  FoneMonkey
//
//  Created by Stuart Stern on 1/30/11.
//  Copyright 2011 Gorilla Logic, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FoneMonkey.h"
#import "FMEventViewCell.h"


@implementation FMEventViewCell
@synthesize commandNumber;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([(UITouch*)[touches anyObject] tapCount] > 1 ){
		[[FoneMonkey sharedMonkey] playFrom:commandNumber numberOfCommands:1];
	} 
//	else if (!selected) {
//		selected = YES;
//		self.backgroundColor = [UIColor blueColor];
//		self.textLabel.textColor = [UIColor whiteColor];
//	} else {
//		selected = NO;
//		self.backgroundColor = [UIColor whiteColor];
//		self.textLabel.textColor = [UIColor blackColor];		
//	}
	[super touchesEnded:touches withEvent:event];
}
@end
