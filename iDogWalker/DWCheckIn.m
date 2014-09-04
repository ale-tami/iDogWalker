//
//  DWCheckIn.m
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWCheckIn.h"

@implementation DWCheckIn

@dynamic location;
@dynamic user;


+ (void) load
{
    [DWCheckIn registerSubclass];
}

+ (NSString*) parseClassName
{
    return @"DWCheckIn";
}

@end
