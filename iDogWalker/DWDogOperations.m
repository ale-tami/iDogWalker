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
    DWDog *doggie = [DWDog new];
    doggie.name = name;
    doggie.age = age;
    doggie.race = race;
    doggie.user = [DWUser currentUser];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    doggie.imageFile = imageFile;
    
    [doggie saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
    }];
}

- (void) getDogs:(DWUser*) owner
{
    
    PFQuery *query = [PFQuery queryWithClassName:[DWDog parseClassName]];
    [query whereKey:@"user" equalTo:owner];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self.delegate operationCompleteFromOperation:self withObjects:objects withError: error];
    
    }];
    
}

@end
