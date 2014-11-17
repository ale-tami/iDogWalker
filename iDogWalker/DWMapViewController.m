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
#import "DWPinAnnotationView.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define secondsToRefresh 60

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

@interface DWMapViewController () <MKMapViewDelegate, UINavigationBarDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkInButton;

//@property BOOL isCheckedIn;
@property (strong, nonatomic) NSUserDefaults *uDefaults;
@property (strong, nonatomic) NSString *stringForButton;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation DWMapViewController

#pragma mark -- View management

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager setActivityType:CLActivityTypeFitness];
    
    self.locationManager.delegate = self;
    self.mapView.delegate = self;
    [DWUserOperations sharedInstance].delegate = self;
    [DWDogOperations sharedInstance].delegate = self;
    
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];
    
    if ([DWUser currentUser].visibile) {
        self.checkInButton.title = checkOutButton;
    }
    
    self.mapView.showsUserLocation = NO;
    self.mapView.showsUserLocation = YES;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[[[NSUserDefaults standardUserDefaults] objectForKey:refreshTime] floatValue] * secondsToRefresh
                                                  target:self
                                                selector:@selector(executeUpdate)
                                                userInfo:nil repeats:YES];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
   
    [self.navigationController setToolbarHidden:TRUE];
    
    [self.timer invalidate];

}

#pragma mark -- other convenient methods

- (void) imageForPin: (DWPinAnnotationView*) pin andUser:(DWUser *) user
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
   
        BOOL needsHeart = [[DWDogOperations sharedInstance] userHasDogsInNeed:user];
        
        if (needsHeart) {
             pin.imageView.image = [UIImage imageNamed:heartFilled];
        } else {
                pin.imageView.file = user.profileImage;
                [pin.imageView loadInBackground];
        }
    
        pin.animatesDrop = YES;
        
    });
}

- (void) annotatePeople
{
    [[DWUserOperations sharedInstance] getNerbyWalkers:self.locationManager.location.coordinate];
}

- (void) executeUpdate
{
    [[DWUserOperations sharedInstance] checkInCurrentUser:self.locationManager.location.coordinate withVisibility:[DWUser currentUser].visibile];
    
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

- (void) reverseGeocodingAndPostToTwitter
{
    
    CLGeocoder *geocoder = [CLGeocoder new];
    
    [geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error){
        
        [[DWUserOperations sharedInstance] postToTwitterWall:((CLPlacemark*)[placemarks firstObject]).name ];
        
    }];
}

#pragma mark -- IBActions
- (IBAction)onCheckIn:(UIBarButtonItem *)sender
{
    if (![DWUser currentUser].visibile)
    {
        [[DWUserOperations sharedInstance] checkInCurrentUser:self.mapView.userLocation.coordinate withVisibility:YES];
        
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            [self reverseGeocodingAndPostToFacebook];
            
        } else if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            [self reverseGeocodingAndPostToTwitter];
        }
        
        
        sender.title = checkOutButton;

    } else {
        [[DWUserOperations sharedInstance] checkOutCurrentUser];
        sender.title = checkInButton;

    }
    
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


#pragma mark -- LocationManager Delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    //[self executeUpdate]; Test this on an actual device
}

#pragma mark -- MapView Delegates

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    DWPinAnnotationView *pin = [[DWPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationText];
    
    if (annotation == mapView.userLocation) {
        
        ((MKPointAnnotation*)pin.annotation).title = userPinTitle;
        
        [self imageForPin:pin andUser:[DWUser currentUser]];
        
    } else {
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

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(DWPinAnnotationView*)sender
{
    if (sender && ![segue.identifier isEqualToString:toLogout]) {
        DWUser *user = ((MKPointAnnotation*)sender.annotation).user;
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
