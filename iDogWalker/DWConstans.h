//
//  DWConstans.h
//  iDogWalker
//
//  Created by Alejandro Tami on 04/09/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWConstans : NSObject

#pragma mark -- segues

extern NSString *const toApp;
extern NSString *const toProfile;
extern NSString *const toLogout;


#pragma mark -- MapViewController

extern NSString *const isCheckedInPlist;
extern NSString *const userPlist;
extern NSString *const checkOutButton;
extern NSString *const checkInButton;
extern NSString *const annotationText;
extern NSString *const userPinTitle;
extern int const regionCoordinateSpan;
extern float const avatarCornerRadius;
extern float const pinXOffset;
extern float const pinYOffset;
extern float const secondsForUpdate;

#pragma mark -- SettingsViewController

extern NSString *const searchRadius;
extern NSString *const refreshTime;

#pragma mark -- Image names

extern NSString *const heartFilled;
extern NSString *const placeholder;
extern NSString *const pinImage;

@end
