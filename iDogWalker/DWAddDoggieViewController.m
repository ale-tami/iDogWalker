//
//  DWAddDoggieViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 29/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWAddDoggieViewController.h"
#import "DWDogOperations.h"

@interface DWAddDoggieViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *race;
@property (weak, nonatomic) IBOutlet UITextField *age;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation DWAddDoggieViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DWDogOperations sharedInstance].delegate = self;
    
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}


- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    [super operationCompleteFromOperation:operation withObjects:objects withError:error];
    if (!error){
        [self performSegueWithIdentifier:@"unwindedSegueFromDogAdd" sender:self];
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

#pragma mark -- IBActions
- (IBAction)onDone:(UIButton *)sender
{
    [self startBlockeage];
    [[DWDogOperations sharedInstance] saveDog:self.name.text
                                          age:[NSNumber numberWithInteger:[self.age.text integerValue] ]
                                         race:self.race.text
                                 profileImage:self.profileImage.image];
}

- (IBAction)onCancel:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"unwindedSegueFromDogAdd" sender:self];
}

- (IBAction)onAddPhoto:(UIButton *)sender
{
    [self presentViewController:self.imagePicker animated:YES completion:nil];
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
