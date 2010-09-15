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
//  FoneMonkey.h
//  FoneMonkey
//
//  Created by Stuart Stern on 10/14/09.
//  Copyright 2009 Gorilla Logic, Inc. All rights reserved.
//

#define FMCommandTouch @"Touch"
#define FMCommandTouchLeft @"TouchLeft"
#define FMCommandTouchRight @"TouchRight"
#define FMCommandSwitch @"Switch"
#define FMCommandSlide @"Slide"
#define FMCommandScroll @"Scroll"
#define FMCommandScrollRight @"ScrollRight"
#define FMCommandScrollLeft @"ScrollLeft"
#define FMCommandScrollUp @"ScrollUp"
#define FMCommandScrollDown @"ScrollDown"
#define FMCommandVerify @"Verify"
#define FMCommandInputText @"InputText"
#define FMCommandShake @"Shake"
#define FMCommandMove @"Move"
#define FMCommandVScroll @"VScroll"
#define FMCommandPause @"Pause"
#define FMCommandWaitFor @"WaitFor"

#define FMNotificationMonkeySuspended @"FMNotificationMonkeySuspended"
#define FMNotificationCommandPosted @"FMNotificationCommandPosted"
#define FMNotificationScriptOpened @"FMNotificationScriptOpened"
#define FMNotificationPlayingDone @"FMNotificationPlayingDone"



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FMCommandEvent;
@class SenTestSuite;

//@interface FoneMonkey : UIApplication {

typedef enum  {
	FMStateSuspended,
	FMStatePaused,
	FMStateRecording,
	FMStatePlaying
} FMState;

@interface FoneMonkey : NSObject {	

	NSTimeInterval runTimeout;
	FMState state;
	NSMutableArray* commands;

}	

+ (FoneMonkey*) sharedMonkey;
- (void) play;
- (NSString*) playAndWait;
- (NSString*) runScript:(NSString*)script;
- (void) record;
- (void) continueMonitoring;
- (void) clear;
- (void) pause;	
- (void) suspend;
- (void) handleEvent:(UIEvent*) event;
+ (void) recordFrom:(UIView*)source command:(NSString*)command;
+ (void) recordFrom:(UIView*)source command:(NSString*)command args:(NSArray*)args;
- (void) postCommandFrom:(UIView*)sender command:(NSString*)command args:(NSArray*)args;
- (FMCommandEvent*)commandAt:(NSInteger)index;
- (NSUInteger) commandCount;
- (void) deleteCommand:(NSInteger) index;
- (void) insertCommand:(NSInteger) index;
- (void) save:(NSString*)file;
- (void) delete:(NSString*)file;
- (void) open:(NSString*)file;
- (NSArray*) scripts;
- (NSInteger) firstErrorIndex;
- (void) moveCommand:(NSInteger)from to:(NSInteger)to;
- (FMCommandEvent*) lastCommandPosted;
- (NSString*) monkeyIDfor:(UIView*)view;
- (void) openConsole;
- (void) loadCommands:(NSArray*) cmds;
- (void) receivedRotate: (NSNotification*) notification;

@property (nonatomic, retain) NSMutableArray* commands;
@property NSTimeInterval runTimeout;
@property (readonly) FMState state;

@end

