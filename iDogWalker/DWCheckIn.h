//
//  DWCheckIn.h
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//


#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface DWCheckIn : PFObject <PFSubclassing>

@property PFGeoPoint *location;
@property DWUser *user;


+ (NSString*) parseClassName;
+ (void) load;

@end
