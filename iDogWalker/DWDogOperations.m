//
//  DWDogOperations.m
//  iDogWalker
//
//  Created by Alejandro Tami on 28/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWDogOperations.h"
#import "DWDog.h"

@implementation DWDogOperations

static DWDogOperations *operations = nil;

+ (instancetype) sharedInstance
{

    if (operations) {
        return operations;
    } else {
        
        return operations = [DWDogOperations new];
    }
}

- (void) saveDog:(NSString*)name age: (NSNumber*)age race:(NSString*) race profileImage:(UIImage*) image;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    DWDog *doggie = [DWDog new];
    doggie.name = name;
    doggie.age = age;
    doggie.race = race;
    doggie.user = [DWUser currentUser];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    doggie.imageFile = imageFile;
    
    if (name.length == 0) {
        NSError *error = [NSError errorWithDomain:@"Name cannot be empty" code:1 userInfo:nil];
        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
    } else {
    
        [doggie saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
        }];
    }
}

- (void) getDogs:(DWUser*) owner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    PFQuery *query = [PFQuery queryWithClassName:[DWDog parseClassName]];
    [query whereKey:@"user" equalTo:owner];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self.delegate operationCompleteFromOperation:self withObjects:objects withError: error];
    
    }];
    
}

- (void) saveDoggieModifications: (DWDog *)doggie
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    [doggie saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
        
    }];
}


/* This method does not use delegate */

- (BOOL) userHasDogsInNeed: (DWUser*) owner
{
    PFQuery *query = [PFQuery queryWithClassName:[DWDog parseClassName]];
    [query whereKey:@"user" equalTo:owner];
    
    NSArray* array = [query findObjects];
    
    for (DWDog *doggie in array) {
        if (doggie.isNeedingPartner) {
            return true;
        }
    }
    
    return false;

}


@end
