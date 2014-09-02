//
//  DWUser.h
//  iDogWalker
//
//  Created by Alejandro Tami on 25/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface DWUser : PFUser <PFSubclassing>

@property PFFile *profileImage;
@property NSArray* doggies;

+ (DWUser *)user;
//+ (NSString*) parseClassName;
+ (void) load;

@end
