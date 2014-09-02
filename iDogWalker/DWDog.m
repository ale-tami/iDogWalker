//
//  DWDog.m
//  iDogWalker
//
//  Created by Alejandro Tami on 28/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWDog.h"

@implementation DWDog

@dynamic user;
@dynamic imageFile;
@dynamic name;
@dynamic age;
@dynamic race;
@dynamic isNeedingPartner;

+ (void) load
{
    [DWDog registerSubclass];
}

+ (NSString*) parseClassName
{
    return @"DWDog";
}

@end
