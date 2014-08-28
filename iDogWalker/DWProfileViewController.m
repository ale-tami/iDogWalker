//
//  DWProfileViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 27/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWProfileViewController.h"
#import "DWUserOperations.h"

@interface DWProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *eMail;
@property (weak, nonatomic) IBOutlet UIButton *befriendChangePassword;
@property (weak, nonatomic) IBOutlet UILabel *friendsAmount;
@property (weak, nonatomic) IBOutlet UILabel *lastCheckIn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;


@end

@implementation DWProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.sentUser) {
        self.sentUser = [DWUser currentUser];
        [self.befriendChangePassword setTitle:@"Change Password" forState:UIControlStateNormal];
        self.title = @"Your Profile";
    } else {
        self.userName.userInteractionEnabled = NO;
        self.eMail.userInteractionEnabled = NO;
        self.navigationItem.rightBarButtonItem = nil;
        self.title = [NSString stringWithFormat:@"%@'s Profile", self.sentUser.username];
    }
    
    self.profileImage.image = [UIImage imageWithData: self.sentUser.profileImage.getData];
    self.userName.text = self.sentUser.username;
    self.eMail.text = self.sentUser.email;
    
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
}

- (void) operationComplete:(NSObject *) objects withError:(NSError*) error;
{
   [super operationComplete:objects withError:error];
    if (!error){
        [self performSegueWithIdentifier:@"unwindedSegue" sender:self];
    }
}


- (IBAction)onDone:(UIBarButtonItem *)sender
{
    [self startBlockeage];
    
    [DWUser currentUser].username = self.userName.text;
    [DWUser currentUser].email = self.eMail.text;
    
    NSData *imageData = UIImagePNGRepresentation(self.profileImage.image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [DWUser currentUser].profileImage = imageFile;

    [DWUserOperations getInstance].delegate = self;
    [[DWUserOperations getInstance] saveCurrentUserModifications];

}


- (IBAction)onTapOnImageView:(UITapGestureRecognizer *)sender
{
    if (self.sentUser == [DWUser currentUser]) {
         [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

#pragma mark -- UIImagePickerController Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.profileImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
