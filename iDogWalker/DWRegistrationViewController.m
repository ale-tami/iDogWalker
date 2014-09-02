//
//  DWRegistrationViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 25/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWRegistrationViewController.h"
#import "DWUser.h"
#import "DWUserOperations.h"


@interface DWRegistrationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, DWOperationsDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation DWRegistrationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}


#pragma mark -- IBActions

- (IBAction)onAddProfilePhoto:(UIButton *)sender
{
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (IBAction)onStart:(UIBarButtonItem *)sender
{
    
  //  [self startBlockeage];
    
    DWUserOperations *userOps = [DWUserOperations new];
    [userOps saveUser:self.userNameField.text
                eMail:self.emailField.text
             password:self.passwordField.text
         profileImage:self.profileImageView.image];
    userOps.delegate = self;
}


#pragma mark -- UIImagePickerController Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.profileImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
