//
//  DWAppDelegate.m
//  iDogWalker
//
//  Created by Alejandro Tami on 22/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWAppDelegate.h"
#import "DWUser.h"
#import "DWConstans.h"

@implementation DWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"AdjsaKpwMwHa7HQXWmGD99WeByDQWrxkcoNhqitg" clientKey:@"QUvkZk32EPnrll3mFBghAsb1Y3DRy2AeDsW7Z9af"];
    
   
    if (![[NSUserDefaults standardUserDefaults]  objectForKey:searchRadius])
    {
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:searchRadius];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if (![[NSUserDefaults standardUserDefaults]  objectForKey:refreshTime])
    {
        [[NSUserDefaults standardUserDefaults] setFloat:5.0 forKey:refreshTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSettings setDefaultAppID: @"690986340977897"];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
