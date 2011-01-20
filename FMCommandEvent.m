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
//  FMCommandEvent.m
//  FoneMonkey
//
//  Created by Stuart Stern on 10/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FMCommandEvent.h"
#import "FMUtils.h"

@implementation FMCommandEvent

//@synthesize source, command, className, monkeyID, args, dict;
@synthesize dict;

- (id) init {
	if (self = [super init]) {
		dict = [[NSMutableDictionary alloc] initWithCapacity:4];
		[self setCommand:@"Verify"];
		[self setMonkeyID:@""];
		[self setClassName:@""];
		[self setArgs:[NSMutableArray arrayWithCapacity:1]];
	}
	
	return self;
}


- (id) init:(NSString*)cmd className:(NSString*)name monkeyID:(NSString*)id args:(NSArray*)array {
	self = [self init];
	self.command = cmd;
	self.className = name;
	self.monkeyID = id;
	self.args = array;
	return self;
}

+ (FMCommandEvent*) command:(NSString*)cmd className:(NSString*)name monkeyID:(NSString*)id args:(NSArray*)array {
	return [[[FMCommandEvent alloc] init:cmd className:name monkeyID:id args:array] autorelease];
}

// protocl NSCopying
- (id) copyWithZone:(NSZone*)zone {
	return [FMCommandEvent command:self.command className:self.className monkeyID:self.monkeyID args:self.args];
}

- (id) initWithDict:(NSMutableDictionary*)dictionary {
	if (self = [super init]) {
		self.dict = dictionary;
	}

	return self;
}

- (UIView*) source {
	UIView* v = [FMUtils viewWithMonkeyID:self.monkeyID havingClass:self.className];
	if (v) {
		return v;
	}
	// Search again considering classes that can be swapped with the supplied class (ie, UIToolbarTextButton and UINavigationButton)
	return [FMUtils viewWithMonkeyID:self.monkeyID startingFromView:nil havingClass:NSClassFromString([self className]) swapsOK:YES];
}

- (void) set:(NSString*)key value:(NSObject*)value {
	if (value == nil) {
		[dict removeObjectForKey:key];
		return;
	}
	[dict setObject:value forKey:key];
}

- (NSString*) command {
	return [dict objectForKey:@"command"];
}

- (void) setCommand:(NSString*)value {
	[self set:@"command" value:value];
}

- (NSString*) monkeyID {
	return [dict objectForKey:@"monkeyID"];

}
- (void) setMonkeyID:(NSString*)value {
	[self set:@"monkeyID" value:value];
}


- (NSString*) className {
	return [dict objectForKey:@"className"];
}

- (void) setClassName:(NSString*)value {
	[self set:@"className" value:value];
}


- (NSArray*) args {
	return [dict objectForKey:@"args"];
}
	
- (void) setArgs:(NSArray*)value {
	[self set:@"args" value:value];
}

- (NSString*) lastResult {
	return [dict objectForKey:@"lastResult"];
}

- (void) setLastResult:(NSString*)value {
	[self set:@"lastResult" value:value];
}

- (id) execute {
	return nil;
}



- (void) dealloc {
//	[source release];
//	[command release];
//	[monkeyID release];
//	[className release];
//	[args release];
	[dict release];
	[super dealloc];
}

@end
