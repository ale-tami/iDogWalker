//
//  DWProfileViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 27/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWProfileViewController.h"
#import "DWUserOperations.h"
#import "DWDogOperations.h"
#import "DWTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "DWDog.h"
#import "DWAddDoggieViewController.h"

@interface DWProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *eMail;
@property (weak, nonatomic) IBOutlet UIButton *befriendChangePassword;
@property (weak, nonatomic) IBOutlet UILabel *friendsAmount;
@property (weak, nonatomic) IBOutlet UILabel *lastCheckIn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property NSArray* dogs;


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
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
        self.title = [NSString stringWithFormat:@"%@'s Profile", self.sentUser.username];
    }
    
    self.userName.text = self.sentUser.username;
    self.eMail.text = self.sentUser.email;
    [self imageForUser];
    
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [DWUserOperations sharedInstance].delegate = self;
    [DWDogOperations sharedInstance].delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   // [self startBlockeage];
    [[DWDogOperations sharedInstance] getDogs:self.sentUser];
    
    self.dogs = [NSArray array];
    
    [self.tableView reloadData];
    
}

- (void) imageForUser
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {

        self.profileImage.image = [UIImage imageWithData: self.sentUser.profileImage.getData];

        if (!self.profileImage.image) {
            self.profileImage.image = [UIImage imageNamed:@"placeholder"];
        }
        
    });
}

- (void) imageForDogCell: (DWTableViewCell *) cell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        cell.image.layer.cornerRadius = 20;
        cell.image.layer.masksToBounds = YES;
   
        NSData *dataForImage = cell.doggie.imageFile.getData;
        cell.image.image = [UIImage imageWithData:dataForImage];
        
        
        if (!dataForImage) {
            cell.image.image = [UIImage imageNamed:@"placeholder"];
        }
    });
}


- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    [super operationCompleteFromOperation:operation withObjects:objects withError:error];
    if (!error){
        if (objects == nil && [operation isKindOfClass:[DWUserOperations class]]) {
            [self performSegueWithIdentifier:@"unwindedSegue" sender:self];
        } else if ([operation isKindOfClass:[DWDogOperations class]]) {
            if (objects != nil ) {
                self.dogs = (NSArray*)objects;
            }
            [self.tableView reloadData];
        }

    }
}

#pragma mark -- IBActions

- (IBAction)onDone:(UIBarButtonItem *)sender
{
  //  [self startBlockeage];
    
    [DWUser currentUser].username = self.userName.text;
    [DWUser currentUser].email = self.eMail.text;
    
    NSData *imageData = UIImagePNGRepresentation(self.profileImage.image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [DWUser currentUser].profileImage = imageFile;
    
   // [self startBlockeage];
    [[DWUserOperations sharedInstance] saveCurrentUserModifications];

}


- (IBAction)onTapOnImageView:(UITapGestureRecognizer *)sender
{
    if (self.sentUser == [DWUser currentUser]) {
         [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

- (IBAction)onLove:(id)sender
{
   
   // [self startBlockeage];
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    DWTableViewCell *cell = (DWTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.doggie.isNeedingPartner = !cell.doggie.isNeedingPartner;
    
    [[DWDogOperations sharedInstance] saveDoggieModifications:cell.doggie];
    
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

#pragma mark -- TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"toAddDog" sender:self];

    }
}

#pragma mark -- TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dogs.count + 1;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Jeeeeesus man, so many numbers thrown everywhere, define a constant
    if (indexPath.row == 0) {
       return 40;
    } else {
       return 94;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cell"];;
    
    if (indexPath.row == 0 && (self.sentUser == [DWUser currentUser])) {
        
        cell.textLabel.text = @"Add a doggie!";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.name.hidden = YES;
        cell.age.hidden = YES;
        cell.race.hidden = YES;
        cell.imageView.image = [UIImage imageNamed:@"plus"];
        cell.image.hidden = YES;
        cell.loveButton.hidden = YES;
       
    } else if (self.dogs.count > 0) {
        
        [cell.loveButton addTarget:self action:@selector(onLove:) forControlEvents:UIControlEventTouchUpInside];
        
        DWDog * dog = [self.dogs objectAtIndex:indexPath.row-1];
        cell.name.text = dog.name;
        cell.race.text = dog.race;
        cell.age.text = [dog.age stringValue];
       
        [self imageForDogCell:cell];
        cell.doggie = dog;
        
        if (self.sentUser == [DWUser currentUser]) {
            cell.loveButton.userInteractionEnabled = YES;
        } else {
            cell.loveButton.userInteractionEnabled = NO;
        }
        
        if (dog.isNeedingPartner) {
            cell.loveButton.imageView.image = [UIImage imageNamed:@"heartFilled"];
        } else {
            cell.loveButton.imageView.image = [UIImage imageNamed:@"heart"];
        }
        
    } else {
        
        cell.textLabel.text = @"No doggies";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.name.hidden = YES;
        cell.age.hidden = YES;
        cell.race.hidden = YES;
        cell.image.hidden = YES;
        cell.loveButton.hidden = YES;
    }

    
    return cell;
}

#pragma mark -- Navigation

- (IBAction)unwindSegue:(UIStoryboardSegue*)sender
{
}

@end
