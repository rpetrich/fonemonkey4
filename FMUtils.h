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
//  FMUtils.h
//  FoneMonkey
//
//  Created by Stuart Stern on 11/7/09.
//  Copyright 2009 Gorilla Logic, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMUtils : NSObject {

}

+ (UIWindow*) rootWindow;
+ (UIView*) viewWithMonkeyID:(NSString*)mid havingClass:(NSString*)className;
+ (UIView*) viewWithMonkeyID:(NSString*)mid havingClass:(NSString*)className swapsOK:(BOOL)swapsOK;
+ (NSInteger) ordinalForView:(UIView*)view;
+ (UIView*) findFirstMonkeyView:(UIView*)current;
+ (BOOL)writeApplicationData:(NSData *)data toFile:(NSString *)fileName;
+ (NSData *)applicationDataFromFile:(NSString *)fileName;
+ (NSString*) scriptsLocation;
+ (void) navLeft:(UIView*)view to:(UIView*)to;
+ (void) navRight:(UIView*)view from:(UIView*)from;
+ (void) slideOut:(UIView*) view;
+ (void) slideIn:(UIView*) view;
+ (void) dismissKeyboard;
+ (void) shake;
+ (BOOL) isKeyboard:(UIView*)view;
+ (NSString*) stringByJsEscapingQuotesAndNewlines:(NSString*) unescapedString;
+ (NSString*) stringByOcEscapingQuotesAndNewlines:(NSString*) unescapedString;
@end
