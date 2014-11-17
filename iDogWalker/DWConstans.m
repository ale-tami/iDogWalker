//
//  DWConstans.m
//  iDogWalker
//
//  Created by Alejandro Tami on 04/09/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWConstans.h"

@implementation DWConstans

#pragma mark -- Segues

NSString *const toApp = @"toApp";
NSString *const toProfile = @"toProfile";
NSString *const toLogout = @"toLogout";

#pragma mark -- MapViewController 

NSString *const isCheckedInPlist = @"isCheckedIn";
NSString *const userPlist = @"User";
NSString *const checkOutButton = @"Go Invisible";
NSString *const checkInButton = @"Go Visible";
NSString *const annotationText = @"annotation";
NSString *const userPinTitle = @"YOU!";
int const regionCoordinateSpan = 0.03;
float const avatarCornerRadius = 15.0;
float const pinXOffset = -5;
float const pinYOffset = -20;
float const secondsForUpdate = 300.0;

#pragma mark -- SettingsViewController
NSString *const searchRadius = @"searchRadius";
NSString *const refreshTime = @"refreshTime";


#pragma mark -- Image names

NSString *const heartFilled = @"heartFilled";
NSString *const placeholder = @"placeholder";
NSString *const appIconPlaceholder = @"AppIconPlaceholder";
NSString *const pinImage = @"imagefiles-location_map_pin_blue";

@end
