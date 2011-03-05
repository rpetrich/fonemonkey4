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
//  FMBuildStamp.h
//  FoneMonkey
//
//  Created by Stuart Stern on 2/2/10.
//  Copyright 2010 Gorilla Logic, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STARTUP_MESSAGE @"\n\n \
								   .\"`\". \n \
							  .-./ _=_ \\.-. \n \
							 {  (,(oYo),) }}       ___________________________ \n \
							 {{ |   \"   |} }-.   /                             \\ \n \
							 { { \\(-^-)/  }}  *.|   Need help? Go gorilla!     | \n \
							 { { }._:_.{  }}      \\____________________________/ \n \
							 {{  } -:- { } } \n \
							 {_{ }`===`{  _} \n \
							((((\\)     (/)))) \n \
#########################################################################################################################\n \
#                                                                                                                       #\n \
# FoneMonkey %@%@ (%@), Copyright (c) 2011, Gorilla Logic, Inc., All Rights Reserved                     #\n \
#                                                                                                                       #\n \
# Gorilla Logic can help you create complex applications for iOS, Android, Adobe Flex and Java platforms.               #\n \
# To learn more about our development, training, and testing services, visit us at www.gorillalogic.com.                #\n \
#                                                                                                                       #\n \
#########################################################################################################################\n\n" \
, [FMBuildStamp version], [FMBuildStamp minorVersion], [FMBuildStamp buildStamp]

@interface FMBuildStamp : NSObject

+ (NSString*) buildStamp;
+ (NSString*) version;
+ (NSString*) minorVersion;
@end
