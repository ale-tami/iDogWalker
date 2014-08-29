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
    
}

- (void) startBlockeage
{
//    if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])
//    {
//        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    }
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    NSLog(@"Blocking");
    
}

- (void) stopBlockeage
{
//    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
//    {
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//    }
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    NSLog(@"Unblocking");
}

#pragma mark -- Operation delegate

- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    [self stopBlockeage];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                                        message:error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    NSLog(@"super operaiont");
}

@end
