//
//  PCColorPickerViewController.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCColorPickerViewController.h"
#import "PCColorPickerView.h"

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
    
    [self updateTintColor];
    
    [self.colorPicker addObserver:self forKeyPath:@"backgroundColor" options:0 context:PCColorPickerViewControllerKVOContext];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.colorPicker.frame = self.view.bounds;
}

#pragma mark - Private

- (void)updateTintColor {
    UIColor *tintColor = colorWithMaxBrightness(self.colorPicker.backgroundColor,
                                                PCColorPickerViewControllerMaxTintColorBrightness);
    
    self.navigationController.toolbar.tintColor = tintColor;
}

UIColor *colorWithMaxBrightness(UIColor *color, CGFloat maxBrightness) {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    
    if (brightness > maxBrightness) {
        brightness = maxBrightness;
    }
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == PCColorPickerViewControllerKVOContext) {
        if (object == self.colorPicker && [keyPath isEqualToString:@"backgroundColor"]) {
            [self updateTintColor];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
