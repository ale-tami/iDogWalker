//
//  DWUserOperations.h
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWOperations.h"
#import "DWUser.h"
	

@interface DWUserOperations : DWOperations

+ (instancetype) sharedInstance;

- (void) facebookLogin;
- (void) loginUser: (NSString *) user andPassword:(NSString *) pass;
- (void) saveUser:(NSString*)userName eMail: (NSString*)email password:(NSString*) password profileImage:(UIImage*) image;
- (void) checkInCurrentUser:(CLLocationCoordinate2D) coordinates;
- (void) checkOutCurrentUser;
- (void) getNerbyWalkers:(CLLocationCoordinate2D) coordinate;
- (void) saveCurrentUserModifications;
- (void) postToFacebookWall: (NSString *) name;

@end
