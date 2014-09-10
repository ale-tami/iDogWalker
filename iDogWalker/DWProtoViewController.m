//
//  DWProtoViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWProtoViewController.h"
#import "DWUserOperations.h"
#import "DWDogOperations.h"

@interface DWProtoViewController ()


@end

@implementation DWProtoViewController

UIActivityIndicatorView *spinner = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startBlockeage:)
                                                 name:@"NotifyOperation"
                                               object:nil];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self stopBlockeage];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [self stopBlockeage];
}

- (void) startBlockeage:(NSNotification *) notification
{
//    if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])
//    {
//        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    }
    
//    NSLog(@"Notification caller %@",[[notification object] description]);

    if  (!spinner){
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor blackColor];
    
    [self.view addSubview:spinner];
    
    [spinner startAnimating];
//     NSLog(@"On Block spinner: %@", spinner);
//     NSLog(@"On BLOCK thread: %@", [NSThread currentThread]);
    
}

- (void) stopBlockeage
{
//    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
//    {
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//    }
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    
    [self removeAllSpinners];
    
//    NSLog(@"On Unblock spinner: %@", spinner);
//    NSLog(@"On Unblock thread: %@", [NSThread currentThread]);
}

- (void) removeAllSpinners
{
    for (UIActivityIndicatorView *spiner in [self.view subviews])
    {
        if ([spiner isKindOfClass:[UIActivityIndicatorView class]])
        {
         //    NSLog(@"On remove spinner: %@", spiner);
            [spiner removeFromSuperview];
            
        }
    }

}

#pragma mark -- Operation delegate

- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    [self stopBlockeage];

    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
   // NSLog(@"super operaiont");
}

@end
