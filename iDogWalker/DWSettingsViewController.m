//
//  DWSettingsViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 08/09/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWSettingsViewController.h"
#import "DWUserOperations.h"
#import "DWConstans.h"

@interface DWSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISlider *searchRadiousSlider;
@property (weak, nonatomic) IBOutlet UISlider *mapRefreshTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *searchRadiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *refreshTimeLabel;
@property NSUserDefaults *uDefaults;

@end

@implementation DWSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.uDefaults = [NSUserDefaults standardUserDefaults];
    
    self.searchRadiousSlider.value = [[self.uDefaults objectForKey:searchRadius] floatValue];
    self.mapRefreshTimeSlider.value = [[self.uDefaults objectForKey:refreshTime] floatValue];
    self.refreshTimeLabel.text = [NSString stringWithFormat:@"%.00f minutes", [[self.uDefaults objectForKey:refreshTime] floatValue]];
    self.searchRadiusLabel.text = [NSString stringWithFormat:@"%.00f km", [[self.uDefaults objectForKey:searchRadius] floatValue]];

}

- (IBAction)onDone:(id)sender
{
    [self.uDefaults setFloat:self.searchRadiousSlider.value forKey:searchRadius];
    [self.uDefaults setFloat:self.mapRefreshTimeSlider.value forKey:refreshTime];
    [self.uDefaults synchronize];
    [self performSegueWithIdentifier:@"unwindSegue" sender:self];
}

- (IBAction)onCancel:(id)sender
{
}

- (IBAction)onRefreshMapValueChanged:(UISlider *)sender
{
    int discreteValue = roundl([sender value]);
    [sender setValue:(float)discreteValue];
    self.refreshTimeLabel.text = [NSString stringWithFormat:@"%.00f minutes", sender.value];
}

- (IBAction)onSearchRadiusValueChanged:(UISlider *)sender
{
    int discreteValue = roundl([sender value]);
    [sender setValue:(float)discreteValue];
    self.searchRadiusLabel.text = [NSString stringWithFormat:@"%.00f km", sender.value];
}


- (IBAction)onChangePassword:(UIButton *)sender
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change password"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];
    alertView.delegate = self;
    
    [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    [alertView textFieldAtIndex:0].placeholder = @"Password";
    [alertView textFieldAtIndex:0].secureTextEntry = YES;
    
    [alertView textFieldAtIndex:1].placeholder = @"Repeat Password";
    [alertView textFieldAtIndex:1].secureTextEntry = YES;
    
    [alertView show];
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText1 = [[alertView textFieldAtIndex:0] text];
    NSString *inputText2 = [[alertView textFieldAtIndex:1] text];
    
    if( [inputText1 isEqualToString:inputText2])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [DWUser currentUser].password = [alertView textFieldAtIndex:1].text;
        [[DWUserOperations sharedInstance] saveCurrentUserModifications];
    }
}


@end
