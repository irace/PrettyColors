//
//  PCColorPickerView.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCColorPickerView.h"
#import "FBKVOController.h"

static void * PCColorPickerViewKVOContext = &PCColorPickerViewKVOContext;

static CGFloat const PCColorPickerViewContentSizeScale = 3;
static CGFloat const PCColorPickerViewMinimumZoomScale = 0;
static CGFloat const PCColorPickerViewMaximumZoomScale = 4;

static CGFloat const PCColorPickerViewHexLabelAlpha = 0.4;
static CGFloat const PCColorPickerViewHexLabelFontSize = 60;
static NSString * const PCColorPickerViewHexLabelFontName = @"Helvetica Neue";

@interface PCColorPickerView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

/// Superview for `zoomView` and `hexLabel`, which should stay in place despite being UIScrollView subviews
@property (nonatomic, strong) UIView *stationaryView;

@property (nonatomic, strong) UIScrollView *zoomView;

/// Exists solely because UIScrollViewDelegate `viewForZoomingInScrollView:` requires a subview be returned
@property (nonatomic, strong) UIView *viewForZoomingInScrollView;

@property (nonatomic, strong) UILabel *hexLabel;
@property (nonatomic, strong) UIButton *infoButton;

@property (nonatomic) CGFloat maxScrollViewXOffset;
@property (nonatomic) CGFloat maxScrollViewYOffset;
@property (nonatomic) CGFloat zoomScaleRange;

@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;
@property (nonatomic) CGFloat brightness;

@property (nonatomic) FBKVOController *KVOController;

@end

@implementation PCColorPickerView

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.scrollView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] init];
            scrollView.delegate = self;
            scrollView.directionalLockEnabled = YES;
            scrollView.scrollsToTop = NO;
            scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
            scrollView;
        });
        [self addSubview:self.scrollView];
        
        self.stationaryView = [[UIView alloc] init];
        [self.scrollView addSubview:self.stationaryView];
        
        self.zoomView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] init];
            scrollView.delegate = self;
            scrollView.minimumZoomScale = PCColorPickerViewMinimumZoomScale;
            scrollView.maximumZoomScale = PCColorPickerViewMaximumZoomScale;
            [scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
            scrollView;
        });
        [self.stationaryView addSubview:self.zoomView];
        
        self.zoomScaleRange = self.zoomView.maximumZoomScale - self.zoomView.minimumZoomScale;
        
        self.viewForZoomingInScrollView = [[UIView alloc] init];
        [self.zoomView addSubview:self.viewForZoomingInScrollView];
        
        self.hexLabel = ({
            UILabel *label = [[UILabel alloc] init];;
            label.font = [UIFont fontWithName:PCColorPickerViewHexLabelFontName size:PCColorPickerViewHexLabelFontSize];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        [self.stationaryView addSubview:self.hexLabel];
        
        self.infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [self addSubview:self.infoButton];
        
        [self randomizeBackgroundColor];

        _KVOController = [FBKVOController controllerWithObserver:self];
        
        void (^updateBackgroundColorWhenKeypathChanges)(SEL selector) = ^(SEL selector) {
            [_KVOController observe:self keyPath:NSStringFromSelector(selector) options:0 block:^(id observer, id object, NSDictionary *change) {
                [self updateBackgroundColor];
            }];
        };
        
        updateBackgroundColorWhenKeypathChanges(@selector(hue));
        updateBackgroundColorWhenKeypathChanges(@selector(saturation));
        updateBackgroundColorWhenKeypathChanges(@selector(brightness));
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.scrollView.frame = self.bounds;
    self.stationaryView.frame = self.bounds;
    
    self.zoomView.frame = self.bounds;
    self.viewForZoomingInScrollView.frame = self.bounds;
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGSize scrollViewContentSize = CGSizeApplyAffineTransform(scrollViewSize,
                                                              CGAffineTransformMakeScale(PCColorPickerViewContentSizeScale,
                                                                                         PCColorPickerViewContentSizeScale));
    
    self.scrollView.contentSize = scrollViewContentSize;
    
    self.maxScrollViewXOffset = scrollViewContentSize.width - scrollViewSize.width;
    self.maxScrollViewYOffset = scrollViewContentSize.height - scrollViewSize.height;
    
    [self.hexLabel sizeToFit];
    self.hexLabel.frame = ({
        CGRect frame = self.hexLabel.frame;
        frame.origin.x = 0;
        frame.origin.y = (CGRectGetHeight(self.stationaryView.frame) - CGRectGetHeight(frame))/2;
        frame.size.width = CGRectGetWidth(self.stationaryView.frame);
        frame;
    });
}

#pragma mark - PCColorPickerView

- (void)randomizeBackgroundColor {
    CGFloat (^randomFloat)() = ^ {
        // http://stackoverflow.com/questions/5172421/generate-a-random-float-between-0-and-1
        return ((CGFloat)arc4random()/0x100000000);
    };
    
    self.hue = randomFloat();
    self.saturation = randomFloat();
    self.brightness = randomFloat();
    
    self.scrollView.contentOffset = CGPointMake(self.hue * self.maxScrollViewXOffset,
                                                self.saturation * self.maxScrollViewYOffset);;
    
    self.scrollView.zoomScale = self.brightness * self.zoomScaleRange;
    
    [self updateBackgroundColor];
}

- (NSString *)hexCodeString {
    return [self.hexLabel.text substringFromIndex:1];
}

#pragma mark - Private

- (void)updateBackgroundColor {
    UIColor *color = [[UIColor alloc] initWithHue:self.hue saturation:self.saturation
                                       brightness:self.brightness alpha:1];
    
    self.backgroundColor = color;
    
    self.hexLabel.text = [@"#" stringByAppendingString:[hexCodeForColor(color) uppercaseString]];
    
    self.hexLabel.textColor = [UIColor colorWithHue:0
                                         saturation:0
                                         brightness:1 - round(self.brightness)
                                              alpha:PCColorPickerViewHexLabelAlpha];
}

NSString *hexCodeForColor(UIColor *color) {
    // http://stackoverflow.com/questions/10880396/how-to-get-hexcode-based-on-the-rgb-values-in-iphoneios
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    [color getRed:&red green:&green blue:&blue alpha:nil];
    
    NSString *(^floatToHexString)(CGFloat) = ^(CGFloat floatValue) {
        return [NSString stringWithFormat:@"%02x", (NSInteger)(255 * floatValue)];
    };
    
    return [@[floatToHexString(red), floatToHexString(green), floatToHexString(blue)] componentsJoinedByString:@""];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (self.maxScrollViewYOffset > 0 && self.maxScrollViewXOffset > 0) {
            CGFloat xOffset = scrollView.contentOffset.x;
            CGFloat yOffset = scrollView.contentOffset.y;
            
            // Re-calculate hue and saturation
            
            self.hue = xOffset/self.maxScrollViewXOffset;
            self.saturation = yOffset/self.maxScrollViewYOffset;
            
            // Ensure stationary view frame does not change
            
            CGRect stationaryViewFrame = self.stationaryView.frame;
            stationaryViewFrame.origin = CGPointMake(xOffset, yOffset);
            self.stationaryView.frame = stationaryViewFrame;
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView == self.zoomView) {
        self.brightness = scrollView.zoomScale/self.zoomScaleRange;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.zoomView) {
        return self.viewForZoomingInScrollView;
    }
    
    return nil;
}

@end
