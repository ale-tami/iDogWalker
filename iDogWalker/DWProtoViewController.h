//
//  DWProtoViewController.h
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWOperations.h"


@interface DWProtoViewController : UIViewController <DWOperationsDelegate>

- (void) startBlockeage;
- (void) stopBlockeage;

@end
