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




@interface DWMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DWMapViewController


- (void) annotatePeople
{
    [self startBlockeage];

    [[DWUserOperations sharedInstance] getNerbyWalkers:self.mapView.userLocation.coordinate];
}


- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    [super operationCompleteFromOperation:operation withObjects:objects withError:error];
    if ([objects isKindOfClass:[NSArray class]] && !error) {
        
        for (DWCheckIn *checkIn in ((NSArray*)objects))
        {
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = CLLocationCoordinate2DMake(checkIn.location.latitude, checkIn.location.longitude);
            annotation.title = checkIn.user.username;
            annotation.user = checkIn.user;
            [self.mapView addAnnotation:annotation];
            
        }

    }
    
    NSLog(@"Operation");
}

#pragma mark -- View management

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DWUserOperations sharedInstance].delegate = self;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationItem.hidesBackButton = NO;
}



#pragma mark -- IBActions
- (IBAction)onCheckIn:(UIBarButtonItem *)sender
{
    
    [[DWUserOperations sharedInstance] checkInCurrentUser:self.mapView.userLocation.coordinate];
    [self annotatePeople];
}

- (IBAction)onRefresh:(UIBarButtonItem *)sender
{
    [self annotatePeople];
}

- (IBAction)onProfileTap:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"toProfile" sender:nil];
}



#pragma mark -- MapView Delegates

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotation"];
    pin.canShowCallout = YES;
   
    
    CGSize size = pin.frame.size;
    
    if (annotation == mapView.userLocation) {
        MKCoordinateSpan coordinateSpan;
        coordinateSpan.latitudeDelta = 0.03;
        coordinateSpan.longitudeDelta = 0.03;
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = coordinateSpan;
        
        [self.mapView setRegion:region animated:YES];
        
        ((MKPointAnnotation*)pin.annotation).title = @"YOU!";
        pin.image = [UIImage imageWithData:[DWUser currentUser].profileImage.getData];
    } else {
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
        pin.image = [UIImage imageWithData: ((MKPointAnnotation *)annotation).user.profileImage.getData];
        if (!pin.image) {
            pin.image = [UIImage imageNamed:@"placeholder"];
        }
        
    }
    
    pin.contentMode = UIViewContentModeScaleAspectFit;
    pin.frame = CGRectMake(pin.frame.origin.x,
                           pin.frame.origin.y,
                           size.width,
                           size.width);

    
    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"toProfile" sender:view];
        
}

-(void) mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self annotatePeople];
    NSLog(@"Map");
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender) {
        DWUser *user = ((MKPointAnnotation*)((MKAnnotationView*)sender).annotation).user;
        ((DWProfileViewController *)segue.destinationViewController).sentUser = user;
    } else {
        ((DWProfileViewController *)segue.destinationViewController).sentUser = nil;
    }
    
}

- (IBAction)unwindSegue:(UIStoryboardSegue*)sender
{
    
}

@end
