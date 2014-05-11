//
//  PCColorPickerViewController.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCColorPickerViewController.h"

#import "PCColorPickerView.h"
#import "PCSavedColorViewController.h"

static CGFloat const PCColorPickerViewControllerMaxTintColorBrightness = 0.6;
static void * PCColorPickerViewControllerKVOContext = &PCColorPickerViewControllerKVOContext;

@interface PCColorPickerViewController()

@property (nonatomic, strong) PCColorPickerView *colorPicker;

@end

@implementation PCColorPickerViewController

#pragma mark - NSObject

- (void)dealloc {
    [self.colorPicker removeObserver:self forKeyPath:@"backgroundColor" context:PCColorPickerViewControllerKVOContext];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colorPicker = [[PCColorPickerView alloc] init];
    [self.view addSubview:self.colorPicker];
    
    [self backgroundColorUpdated];
    
    [self.colorPicker addObserver:self forKeyPath:@"backgroundColor" options:0 context:PCColorPickerViewControllerKVOContext];
    
//    [self.view addConstraints:@[
//        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
//                                        toItem:self.colorPicker attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
//
//        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
//                                        toItem:self.colorPicker attribute:NSLayoutAttributeHeight multiplier:1 constant:0]
//        ]];
    
    UIBarButtonItem *(^barButton)(NSString *, id, SEL) = ^ (NSString *title, id target, SEL action) {
        return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    };

    self.toolbarItems = @[barButton(@"Random", self.colorPicker, @selector(randomizeBackgroundColor)),
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          barButton(@"Save", self, @selector(save))];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
    
    self.colorPicker.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Actions

- (void)save {
    [self.navigationController pushViewController:[[PCSavedColorViewController alloc] init] animated:YES];
}

#pragma mark - Private

- (void)backgroundColorUpdated {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    
    [self.colorPicker.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    
    // Update toolbar tint color
    
    UIColor *tintColor = [UIColor colorWithHue:hue saturation:saturation
                                    brightness:MIN(brightness, PCColorPickerViewControllerMaxTintColorBrightness)
                                         alpha:1];
    
    self.navigationController.toolbar.tintColor = tintColor;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == PCColorPickerViewControllerKVOContext) {
        if (object == self.colorPicker && [keyPath isEqualToString:@"backgroundColor"]) {
            [self backgroundColorUpdated];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
