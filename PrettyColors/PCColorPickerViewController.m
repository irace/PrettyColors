//
//  PCColorPickerViewController.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCColorPickerView.h"
#import "PCColorPickerViewController.h"
#import "FBKVOController.h"

static CGFloat const MaxToolbarTintColorBrightness = 0.6;

@interface PCColorPickerViewController()

@property (nonatomic) UIView *colorPicker;
@property (nonatomic) FBKVOController *KVOController;

@end

@implementation PCColorPickerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor redColor];
    
    self.colorPicker = [[UIView alloc] init];
    self.colorPicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.colorPicker.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.colorPicker];

    self.toolbarItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"Random" style:UIBarButtonItemStylePlain target:self.colorPicker
                                        action:@selector(randomizeBackgroundColor)],
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

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeWidth
                                 multiplier:1
                                   constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:1
                                   constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeTop
                                 multiplier:1
                                   constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.colorPicker
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeLeading
                                 multiplier:1
                                   constant:0]];
}

#pragma mark - Actions

- (void)share {
//    [self presentViewController:[[UIActivityViewController alloc] initWithActivityItems:@[self.colorPicker.hexCodeString] applicationActivities:nil]
//                       animated:YES completion:nil];
}

#pragma mark - Private

- (void)backgroundColorUpdated {
    // Update toolbar tint color, enforcing a minimum brightness to ensure visibility
    
    self.navigationController.toolbar.tintColor = ({
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        
        [self.colorPicker.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
        
        UIColor *tintColor = [UIColor colorWithHue:hue
                                        saturation:saturation
                                        brightness:MIN(brightness, MaxToolbarTintColorBrightness)
                                             alpha:1];
        tintColor;
    });
}

@end
