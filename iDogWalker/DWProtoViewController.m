//
//  DWProtoViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWProtoViewController.h"

@interface DWProtoViewController ()


@end

@implementation DWProtoViewController

UIActivityIndicatorView *spinner = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) startBlockeage
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
}

- (void) stopBlockeage
{
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

#pragma mark -- Operation delegate

- (void) operationComplete:(NSObject *) objects withError:(NSError*) error;
{
    [spinner removeFromSuperview];
    [self stopBlockeage];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                                        message:error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
