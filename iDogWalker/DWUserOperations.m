//
//  DWUserOperations.m
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWUserOperations.h"
#import "DWCheckIn.h"
#import <FacebookSDK/FacebookSDK.h>

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

- (void) facebookLogin
{
    [PFFacebookUtils initializeFacebook];
    
    NSArray *permissionsArray = @[ @"user_about_me", @"status_update"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result is a dictionary with the user's Facebook data
                NSDictionary *userData = (NSDictionary *)result;
                
                NSString *facebookID = userData[@"id"];
                NSString *name = userData[@"name"];
                
                NSURL *pictureURL = [NSURL URLWithString:
                                     [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                
                
                NSURLRequest *request = [NSURLRequest requestWithURL:pictureURL];
                
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    PFFile *imageFile = [PFFile fileWithName:@"profile.png" data:data];
                    [DWUser currentUser].profileImage = imageFile;
                    [DWUser currentUser].username = name;
                    
                    [[DWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
                    }];
                    
                    
                }];
            }
        }];
       
       
    }];
}

- (void) loginUser: (NSString *) user andPassword:(NSString *) pass
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];
    
    [DWUser logInWithUsernameInBackground:user password:pass block:^(PFUser *user, NSError *error) {
        if(error.code == 101 ){
            error = [NSError errorWithDomain:@"Wrong User Name / Password" code:101 userInfo:nil];
        }
        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];

    }];
}

- (void) saveUser:(NSString*)userName eMail: (NSString*)email password:(NSString*) password profileImage:(UIImage*) image
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    DWUser *user = (DWUser*)[DWUser user];
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
    
    PFQuery *query = [PFQuery queryWithClassName:[DWCheckIn parseClassName]];
    
    [query whereKey:@"user" equalTo:[DWUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    DWCheckIn *checkIn = [objects firstObject];
        
    if (!checkIn)
        checkIn = [DWCheckIn object];
        
    //DWCheckIn *checkIn = [DWCheckIn object];
        checkIn.location = [PFGeoPoint geoPointWithLatitude:coordinates.latitude longitude:coordinates.longitude];
        
        [DWUser currentUser].visibile = YES;
        checkIn.user = [DWUser currentUser];
        
        [checkIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
            
        }];
        
    }];
}

- (void) checkOutCurrentUser
{
    
    [DWUser currentUser].visibile = NO;
    
    [self saveCurrentUserModifications];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];
//
//    PFQuery *query = [PFQuery queryWithClassName:[DWCheckIn parseClassName]];
//    
//    [query whereKey:@"user" equalTo:[DWUser currentUser]];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        
//        DWCheckIn *checkIn = [objects firstObject];
//        
//        [checkIn deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
//            
//        }];
//    }];
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
