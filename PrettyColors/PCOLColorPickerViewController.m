//
//  PCOLColorPickerViewController.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "FBKVOController.h"
#import "PCOLColorPickerView.h"
#import "PCOLColorPickerViewController.h"

static CGFloat const MaxToolbarTintColorBrightness = 0.6;

@interface PCOLColorPickerViewController()

@property (nonatomic) PCOLColorPickerView *colorPicker;
@property (nonatomic) FBKVOController *KVOController;

@end

@implementation PCOLColorPickerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.colorPicker = [[PCOLColorPickerView alloc] init];
    self.colorPicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.colorPicker];

    [self.view addConstraints:@[
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1
                                   constant:0],
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1
                                   constant:0],
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeTop
                                 multiplier:1
                                   constant:0],
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1
                                   constant:0]
     ]];
    
//    self.navigationController.toolbar.barTintColor = nil;
//    self.navigationController.toolbar.translucent = NO;
    
    [self.navigationController.toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
//    [self.navigationController.toolbar setBackgroundColor:[UIColor clearColor]];
    
    [self.navigationController.toolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];

    self.toolbarItems = @[
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"904-shuffle"] style:UIBarButtonItemStylePlain target:self.colorPicker action:@selector(randomizeBackgroundColor)],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithCustomView:[UIButton buttonWithType:UIButtonTypeInfoDark]],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)]
    ];
    
    self.KVOController = [FBKVOController controllerWithObserver:self];
    
    [self.KVOController observe:self.colorPicker
                        keyPath:NSStringFromSelector(@selector(backgroundColor))
                        options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self backgroundColorUpdated];
                          }];
}

#pragma mark - Actions

- (void)share {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.colorPicker.hexCodeString]
                                                                             applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Private

- (void)backgroundColorUpdated {
    // Update toolbar tint color, enforcing a minimum brightness to ensure visibility
    
    self.navigationController.toolbar.tintColor = ({
//        CGFloat hue, saturation, brightness;
//        [self.colorPicker.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
//        
//        UIColor *tintColor = [UIColor colorWithHue:hue
//                                        saturation:saturation
//                                        brightness:MIN(brightness, MaxToolbarTintColorBrightness)
//                                             alpha:1];
//        tintColor;
        self.colorPicker.labelColor;
    });
}

@end
