//
//  DWPrivacyPolictyViewController.m
//  iDogWalker
//
//  Created by Alejandro Tami on 15/11/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWPrivacyPolictyViewController.h"

@interface DWPrivacyPolictyViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DWPrivacyPolictyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString * loadUrl = @"http://www.privacychoice.org/policy/mobile?policy=3aadc404b453efb0b066b93f89cc840d";
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:loadUrl]];
    
    // Load the request in the UIWebView
    [self.webView loadRequest:requestObj];
}

- (IBAction)onClose:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:self completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
