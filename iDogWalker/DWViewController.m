//
//  DWViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 22/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWViewController.h"

@interface DWViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation DWViewController

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    
    if ([PFUser currentUser] && [[PFUser currentUser] isAuthenticated]) {
        [self performSegueWithIdentifier:@"toApp" sender:self];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)onLogin:(UIButton *)sender
{
    PFUser * user = [PFUser logInWithUsername:self.emailField.text password:self.passwordField.text];
    if (!user) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nope"
                                                        message:@"Wrong user/password"
                                                       delegate:self
                                              cancelButtonTitle:@"Bummer... ok"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        [self performSegueWithIdentifier:@"toApp" sender:self];
    }
}

- (IBAction)onRegister:(UIButton *)sender
{
   // [self performSegueWithIdentifier:@"toRegister" sender:self];
}

@end
