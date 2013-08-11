//
//  PCColorPickerViewController.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCColorPickerViewController.h"
#import "PCColorPickerView.h"

@interface PCColorPickerViewController()

@property (nonatomic, strong) PCColorPickerView *colorPicker;

@end

@implementation PCColorPickerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colorPicker = [[PCColorPickerView alloc] init];
    [self.view addSubview:self.colorPicker];
    [self.colorPicker addObserver:self forKeyPath:@"backgroundColor" options:0 context:NULL];
    
//    [self.view addConstraints:@[
//        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
//                                        toItem:self.colorPicker attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
//
//        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
//                                        toItem:self.colorPicker attribute:NSLayoutAttributeHeight multiplier:1 constant:0]
//        ]];
    
    [self setToolbarItems:@[[[UIBarButtonItem alloc] initWithTitle:@"Random" style:UIBarButtonItemStylePlain
                                                            target:self.colorPicker action:@selector(randomizeBackgroundColor)]]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.navigationController.toolbar.tintColor = self.colorPicker.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.colorPicker.frame = self.view.bounds;
}

@end
