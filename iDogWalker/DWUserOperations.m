//
//  DWUserOperations.m
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWUserOperations.h"
#import "DWCheckIn.h"

@implementation DWUserOperations

static DWUserOperations *operations = nil;

+ (instancetype) sharedInstance
{
    
    if (operations) {
        return operations;
    } else {
        
        return operations = [DWUserOperations new];
    }
}



- (void) saveUser:(NSString*)userName eMail: (NSString*)email password:(NSString*) password profileImage:(UIImage*) image
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    DWUser *user = [DWUser user];
    user.username = userName;
    user.password = password;
    user.email = email;

    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    user.profileImage = imageFile;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
    }];
}

- (void) checkInCurrentUser:(CLLocationCoordinate2D) coordinates
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    DWCheckIn *checkIn = [DWCheckIn object];
    checkIn.location = [PFGeoPoint geoPointWithLatitude:coordinates.latitude longitude:coordinates.longitude];
    checkIn.user = [DWUser currentUser];
    
    [checkIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
        
    }];

}

- (void) checkOutCurrentUser
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    PFQuery *query = [PFQuery queryWithClassName:[DWCheckIn parseClassName]];
    
    [query whereKey:@"user" equalTo:[DWUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        DWCheckIn *checkIn = [objects firstObject];
        
        [checkIn deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
            
        }];
    }];
}


- (void) getNerbyWalkers:(CLLocationCoordinate2D) coordinate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    PFQuery *query = [PFQuery queryWithClassName:[DWCheckIn parseClassName]];
    [query setLimit:100];
    [query includeKey:@"user"];
    [query whereKey:@"user" notEqualTo:[DWUser currentUser]];
    [query whereKey:@"location" nearGeoPoint:
        [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                               longitude:coordinate.longitude]
                        withinKilometers:1.0f];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self.delegate operationCompleteFromOperation:self withObjects:objects withError: error];
    }];
    
}

- (void) saveCurrentUserModifications
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    [[DWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
    }];
}

@end
