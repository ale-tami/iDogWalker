//
//  DWDogOperations.h
//  iDogWalker
//
//  Created by Alejandro Tami on 28/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWOperations.h"

@interface DWDogOperations : DWOperations

+ (instancetype) sharedInstance;

- (void) saveDog:(NSString*)name age: (NSNumber*)age race:(NSString*) race profileImage:(UIImage*) image;
- (void) getDogs:(DWUser*) owner;

@end
