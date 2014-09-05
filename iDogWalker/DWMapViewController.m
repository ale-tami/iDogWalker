//
//  DWMapViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWMapViewController.h"
#import <MapKit/MapKit.h>
#import "DWUserOperations.h"
#import "DWCheckIn.h"
#import <objc/runtime.h>
#import "DWProfileViewController.h"
#import "DWDogOperations.h"

#pragma mark -- BEGINNING -- category for MKPointAnnotation
static void * UserPropertyKey = &UserPropertyKey;

@interface MKPointAnnotation (UserProperty)

@property DWUser *user;

@end

@implementation  MKPointAnnotation (UserProperty)


- (NSDictionary *)user {
    return objc_getAssociatedObject(self, UserPropertyKey);
}

- (void)setUser:(DWUser *)user {
    objc_setAssociatedObject(self, UserPropertyKey, user, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
#pragma mark -- END -- category for MKPointAnnotation


@interface DWMapViewController () <MKMapViewDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkInButton;

@property BOOL isCheckedIn;
@property NSUserDefaults *uDefaults;
@property NSString *stringForButton;
@property NSTimer *timer;

@end

@implementation DWMapViewController


#pragma mark -- View management

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [DWUserOperations sharedInstance].delegate = self;
    [DWDogOperations sharedInstance].delegate = self;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    self.uDefaults = [NSUserDefaults standardUserDefaults];
    self.isCheckedIn = [self.uDefaults boolForKey:isCheckedInPlist];
    if (self.isCheckedIn && ([(NSString*)[self.uDefaults objectForKey:userPlist] isEqualToString:[DWUser currentUser].email])) {
        self.checkInButton.title = checkOutButton;
    }

    [self annotatePeople];

    self.navigationItem.hidesBackButton = YES;


}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:secondsForUpdate
                                                  target:self
                                                selector:@selector(executeUpdate)
                                                userInfo:nil repeats:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
   
    [self.navigationController setToolbarHidden:TRUE];
   // self.navigationItem.leftBarButtonItem = NO;
}

#pragma mark -- other convenient methods

- (void) imageForPin: (MKAnnotationView*) pin andUser:(DWUser *) user
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        CGSize size = pin.frame.size;
        
        NSData *dataForImage = user.profileImage.getData;
        
        BOOL needsHeart = [[DWDogOperations sharedInstance] userHasDogsInNeed:user];
        
        UIImageView *imageView = [UIImageView new];
        

        
        
        if (needsHeart) {
         //   pin.image = [UIImage imageNamed:@"heartFilled"];
             imageView.image = [UIImage imageNamed:heartFilled];
        }else {
        //    pin.image = [UIImage imageWithData:dataForImage];
            imageView.image = [UIImage imageWithData:dataForImage];
        }
        
        if (!dataForImage) {
         //   pin.image = [UIImage imageNamed:@"placeholder"];
            imageView.image = [UIImage imageNamed:placeholder];
        }
//        
//        pin.contentMode = UIViewContentModeScaleAspectFit;
//        pin.frame = CGRectMake(pin.frame.origin.x,
//                               pin.frame.origin.y,
//                               size.width,
//                               size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(imageView.frame.origin.x,
                                     imageView.frame.origin.y -3,
                                     size.width,
                                     size.height);
        
       // imageView.layer.borderColor = [[UIColor blueColor] CGColor];
      //  imageView.layer.borderWidth = 0.5;
        imageView.layer.cornerRadius = avatarCornerRadius;
        imageView.layer.masksToBounds = YES;
        [UIView animateWithDuration:1.0 animations:^{
            pin.centerOffset =  CGPointMake(pinXOffset, pinYOffset);
        }];

        [pin addSubview:imageView];
        
    });
}

- (void) annotatePeople
{
 //   if (self.isCheckedIn) {
      //  [self startBlockeage];

        [[DWUserOperations sharedInstance] getNerbyWalkers:self.mapView.userLocation.coordinate];
   // }
}

- (void) executeUpdate
{
    [[DWUserOperations sharedInstance] checkInCurrentUser:self.mapView.userLocation.coordinate];
    
    [self annotatePeople];
    
    NSLog(@"Executed");

}

- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    [super operationCompleteFromOperation:operation withObjects:objects withError:error];
    
    if (objects != nil && [operation isKindOfClass:[DWUserOperations class]]){

        NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy];

        [self.mapView removeAnnotations:annotationsToRemove];
        
        self.mapView.showsUserLocation = NO;
        for (DWCheckIn *checkIn in ((NSArray*)objects))
        {
            if (checkIn.user.visibile) {
            
                MKPointAnnotation *annotation = [MKPointAnnotation new];
                annotation.coordinate = CLLocationCoordinate2DMake(checkIn.location.latitude, checkIn.location.longitude);
                annotation.title = checkIn.user.username;
                annotation.user = checkIn.user;
                [self.mapView addAnnotation:annotation];
            }
        }
        self.mapView.showsUserLocation = YES;

    }
    
  //  NSLog(@"Operation");
}


- (void) reverseGeocodingAndPostToFacebook
{
    
    CLGeocoder *geocoder = [CLGeocoder new];
    
    [geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error){

        [[DWUserOperations sharedInstance] postToFacebookWall:((CLPlacemark*)[placemarks firstObject]).name];
        
    }];
    
}

#pragma mark -- IBActions
- (IBAction)onCheckIn:(UIBarButtonItem *)sender
{
    if (!self.isCheckedIn) {
        [[DWUserOperations sharedInstance] checkInCurrentUser:self.mapView.userLocation.coordinate];
        
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            [self reverseGeocodingAndPostToFacebook];
        }
        
        
        sender.title = checkOutButton;
        self.isCheckedIn = YES;

    } else {
        [[DWUserOperations sharedInstance] checkOutCurrentUser];
        sender.title = checkInButton;
        self.isCheckedIn = NO;
        //[self.mapView removeAnnotations:self.mapView.annotations];

    }
    
    [self.uDefaults setBool:self.isCheckedIn forKey:isCheckedInPlist];
    [self.uDefaults setValue:[DWUser currentUser].email  forKey:userPlist];

    [self.uDefaults synchronize];
    
    [self annotatePeople];
}

- (IBAction)onRefresh:(UIBarButtonItem *)sender
{
    [self executeUpdate];
}

- (IBAction)onProfileTap:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:toProfile sender:nil];
}

- (IBAction)onLogout:(UIBarButtonItem *)sender
{
    [DWUser logOut];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
   
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark -- MapView Delegates

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *pin = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationText];
    pin.image = [UIImage imageNamed:pinImage];
    pin.canShowCallout = YES;
    
    if (annotation == mapView.userLocation) {
        MKCoordinateSpan coordinateSpan;
        coordinateSpan.latitudeDelta = regionCoordinateSpan;
        coordinateSpan.longitudeDelta = regionCoordinateSpan;
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = coordinateSpan;
        
        [self.mapView setRegion:region animated:YES];
        
        ((MKPointAnnotation*)pin.annotation).title = userPinTitle;
        
        [self imageForPin:pin andUser:[DWUser currentUser]];
        
    } else {
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [self imageForPin:pin andUser:((MKPointAnnotation *)annotation).user];

    }
   
    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:toProfile sender:view];
        
}


-(void) mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self annotatePeople];
   // NSLog(@"Map");
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender && ![segue.identifier isEqualToString:toLogout]) {
        DWUser *user = ((MKPointAnnotation*)((MKAnnotationView*)sender).annotation).user;
        ((DWProfileViewController *)segue.destinationViewController).sentUser = user;
    } else if ([segue.identifier isEqualToString:toLogout]) {
        
    }else {
        ((DWProfileViewController *)segue.destinationViewController).sentUser = nil;
    }
    
}

- (IBAction)unwindSegue:(UIStoryboardSegue*)sender
{
    
}

@end
