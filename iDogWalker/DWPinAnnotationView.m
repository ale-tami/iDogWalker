//
//  DWPinAnnotationView.m
//  iDogWalker
//
//  Created by Alejandro Tami on 14/11/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWPinAnnotationView.h"

#define imagePositionOffset 5

@implementation DWPinAnnotationView

@synthesize centerOffset = _centerOffset;

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        self.rightCalloutAccessoryView = ([annotation isKindOfClass:[MKUserLocation class]]) ? nil : [UIButton buttonWithType:UIButtonTypeInfoLight];
        self.canShowCallout = YES;
        self.centerOffset =  CGPointMake(pinXOffset, pinYOffset);
        self.image = [UIImage imageNamed:pinImage];
        
        self.imageView = [PFImageView new];
        self.imageView.image = [UIImage imageNamed:appIconPlaceholder];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x + imagePositionOffset,
                                          self.imageView.frame.origin.y + imagePositionOffset,
                                          self.frame.size.width - imagePositionOffset * 2,
                                          self.frame.size.height - imagePositionOffset * 2);
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2;
        self.imageView.layer.masksToBounds = YES;
        
        [self addSubview:self.imageView];
        
    }
    return self;
}


//For some reason, we need this setter to make the centerOffset work
- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
}

@end
