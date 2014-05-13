//
//  PCOLAppDelegate.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCOLAppDelegate.h"

#import "PCOLColorPickerViewController.h"

@implementation PCOLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = ({
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:
                                              [[PCOLColorPickerViewController alloc] init]];
        controller.navigationBarHidden = YES;
        controller.toolbarHidden = NO;
        controller;
    });
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
