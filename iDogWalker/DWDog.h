//
//  DWDog.h
//  iDogWalker
//
//  Created by Alejandro Tami on 28/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface DWDog : PFObject <PFSubclassing>

@property DWUser *user;
@property PFFile *imageFile;
@property NSString *name;
@property NSNumber *age;
@property NSString *race;
@property BOOL isNeedingPartner;

+ (NSString*) parseClassName;
+ (void) load;

@end
