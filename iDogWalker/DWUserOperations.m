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


- (void) saveUser:(NSString*)userName eMail: (NSString*)email password:(NSString*) password profileImage:(UIImage*) image
{
    DWUser *user = [DWUser user];
    user.username = userName;
    user.password = password;
    user.email = email;

    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    user.profileImage = imageFile;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate operationComplete:nil withError: error];
    }];
}

- (void) checkInCurrentUser:(CLLocationCoordinate2D) coordinates
{
    
    PFQuery *query = [PFQuery queryWithClassName:[DWCheckIn parseClassName]];
    
    [query whereKey:@"user" equalTo:[DWUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        DWCheckIn *checkIn = [objects firstObject];
        checkIn.location = [PFGeoPoint geoPointWithLatitude:coordinates.latitude longitude:coordinates.longitude];
        checkIn.user = [DWUser currentUser];
        
        [checkIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.delegate operationComplete:nil withError: error];
            
        }];
    }];
}

- (void) getNerbyWalkers:(CLLocationCoordinate2D) coordinate
{
    
    PFQuery *query = [PFQuery queryWithClassName:[DWCheckIn parseClassName]];
    [query setLimit:100];
    [query includeKey:@"user"];
    [query whereKey:@"user" notEqualTo:[DWUser currentUser]];
    [query whereKey:@"location" nearGeoPoint:
        [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                               longitude:coordinate.longitude]
                        withinKilometers:1.0f];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self.delegate operationComplete:objects withError: error];
    }];
    
}

- (void) saveCurrentUserModifications
{
    [[DWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate operationComplete:nil withError:error];
    }];
}

@end
