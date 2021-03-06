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

- (void) twitterLogin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!error) {
            
            NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", [PFTwitterUtils twitter].screenName ];
            
            
            NSURL *verify = [NSURL URLWithString:requestString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
            [[PFTwitterUtils twitter] signRequest:request];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
            
            
            if ( error == nil){
                NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[result objectForKey:@"profile_image_url_https"] ]];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    
                    PFFile *file = [PFFile fileWithData:data];
                    [DWUser currentUser].profileImage = file;
                    
                    [DWUser currentUser].username = [PFTwitterUtils twitter].screenName;
                    
                    
                    [[DWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
                        
                    }];
                    
                }];

                
            }
        
        }
        
    }];
}



- (void) facebookLogin
{
    [PFFacebookUtils initializeFacebook];
    
    NSArray *permissionsArray = @[ @"user_about_me", @"status_update", @"publish_actions"];

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
            } else {
                 [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
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

- (void) checkInCurrentUser:(CLLocationCoordinate2D) coordinates withVisibility: (BOOL) visible
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
        
        [DWUser currentUser].visibile = visible;
        checkIn.user = [DWUser currentUser];
        
        [checkIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
//            [FBSession openActiveSessionWithAllowLoginUI:NO];
//            
//            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
//        //    [params setObject:@"Testing" forKey:@"name"];
//            [params setObject:@"Blah" forKey:@"message"];
//            [params setObject:@"iDogWalker" forKey:@"application"];
//           // [params setObject:@"IMAGE_URL" forKey:@"picture"];
//           // [params setObject:@"Blah" forKey:@"description"];
//            
//            FBRequest *request= [[FBRequest alloc] initWithSession:FBSession.activeSession
//                                                         graphPath:@"me/feed"
//                                                        parameters:params
//                                                        HTTPMethod:@"POST"];
//            
//            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
//                
//            }];
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

    float searchRad = [[[NSUserDefaults standardUserDefaults] objectForKey:searchRadius] floatValue];
   
    PFQuery *query = [PFQuery queryWithClassName:[DWCheckIn parseClassName]];
    [query setLimit:100];
    [query includeKey:@"user"];
    [query whereKey:@"user" notEqualTo:[DWUser currentUser]];
    [query whereKey:@"location" nearGeoPoint:
    [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                           longitude:coordinate.longitude]
                    withinKilometers: searchRad ];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"Objects %lu",(unsigned long)objects.count);
        NSLog(@"Latitude %lu",(unsigned long)coordinate.latitude);
        NSLog(@"Longitude %lu",(unsigned long)coordinate.longitude);

        
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

- (void) postToFacebookWall: (NSString *) name
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];

    [FBSession openActiveSessionWithAllowLoginUI:NO];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    
    NSString *checkedIn = [NSString stringWithFormat:@"I've just checked in at %@", name ];

    [params setObject:checkedIn forKey:@"message"];
    [params setObject:@"iDogWalker" forKey:@"application"];

  
    
    FBRequest *request= [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                 graphPath:@"me/feed"
                                                parameters:params
                                                HTTPMethod:@"POST"];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (error)
        {
            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                
                 [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                 {
                     [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];

                 }];
            }];
        } else {
            [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
        }

    }];
    
  
}

-(void) postToTwitterWall: (NSString *) name
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyOperation" object:self];
    
    NSString *bodyString = [NSString stringWithFormat:@"status= %@", name];
    
    bodyString = [bodyString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"POST";
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [[PFTwitterUtils twitter] signRequest:request];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            [self.delegate operationCompleteFromOperation:self withObjects:nil withError: error];
            
        }];
    });
    
    
}

@end
