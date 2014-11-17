//
//  DWPinAnnotationView.h
//  iDogWalker
//
//  Created by Alejandro Tami on 14/11/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DWPinAnnotationView : MKPinAnnotationView

@property (strong, nonatomic) PFImageView *imageView;

@end
