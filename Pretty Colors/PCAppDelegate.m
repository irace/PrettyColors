//
//  PCAppDelegate.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCAppDelegate.h"

#import "PCColorPickerViewController.h"

@implementation PCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:
                                          [[PCColorPickerViewController alloc] init]];
    controller.navigationBarHidden = YES;
    controller.toolbarHidden = NO;
    
    self.window.rootViewController = controller;
    
    return YES;
}

@end
