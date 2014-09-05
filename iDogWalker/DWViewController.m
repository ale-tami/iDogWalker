//
//  DWViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 22/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWViewController.h"
#import "DWMapViewController.h"
#import "DWUserOperations.h"

@interface DWViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation DWViewController

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    self.modalInPopover = YES;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    if ([PFUser currentUser] /*&& [[PFUser currentUser] isAuthenticated]*/) {
//        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
//        {
            [self performSegueWithIdentifier:toApp sender:self];
      //  }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBarHidden = NO;
}
- (IBAction)onFbLogin:(UIButton *)sender
{
    [DWUserOperations sharedInstance].delegate = self;
    
    [[DWUserOperations sharedInstance] facebookLogin];
}

- (IBAction)onLogin:(UIButton *)sender
{
    [DWUserOperations sharedInstance].delegate = self;

    [[DWUserOperations sharedInstance] loginUser:self.emailField.text andPassword:self.passwordField.text];
    
//    DWUser * user = [DWUser logInWithUsername:self.emailField.text password:self.passwordField.text];
//    if (!user) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nope"
//                                                        message:@"Wrong user/password"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Bummer... ok"
//                                              otherButtonTitles:nil];
//        [alert show];
//        
//    } else {
//        [self performSegueWithIdentifier:@"toApp" sender:self];
//    }
}

- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    [super operationCompleteFromOperation:operation withObjects:objects withError:error];
    
    if (!error) {
        [self performSegueWithIdentifier:toApp sender:self];
    }
}

- (IBAction)onRegister:(UIButton *)sender
{
}
@end
