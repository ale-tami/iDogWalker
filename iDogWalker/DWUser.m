//
//  DWUser.m
//  iDogWalker
//
//  Created by Alejandro Tami on 25/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWUser.h"

@implementation DWUser

@dynamic profileImage;

+ (DWUser *)user
{
    return (DWUser *) [PFUser user];
}

+ (void) load
{
    [DWUser registerSubclass];
}

//+ (NSString*) parseClassName
//{
//    return @"DWUser";
//}

@end
