//
//  PCColorPickerView.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCColorPickerView.h"

#import "PCCopyableLabel.h"

static void * PCColorPickerViewKVOContext = &PCColorPickerViewKVOContext;

static CGFloat const PCColorPickerViewContentSizeScale = 3;
static CGFloat const PCColorPickerViewMinimumZoomScale = 0;
static CGFloat const PCColorPickerViewMaximumZoomScale = 4;

static CGFloat const PCColorPickerViewHexLabelAlpha = 0.25;
static CGFloat const PCColorPickerViewHexLabelFontSize = 60;
static NSString * const PCColorPickerViewHexLabelFontName = @"CourierNewPS-BoldMT";

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

/// Prevent programmatic changes to content offset from triggering UIScrollViewDelegate methods
@property (nonatomic) BOOL recalculateOnContentOffsetChange;

@end

@implementation PCColorPickerView

- (void)randomizeBackgroundColor {
    CGFloat (^randomFloat)() = ^ {
        // http://stackoverflow.com/questions/5172421/generate-a-random-float-between-0-and-1
        return ((CGFloat)arc4random()/0x100000000);
    };
    
    self.hue = randomFloat();
    self.saturation = randomFloat();
    self.brightness = randomFloat();
    
    self.recalculateOnContentOffsetChange = NO;
    
    self.scrollView.contentOffset = CGPointMake(self.hue * self.maxScrollViewXOffset,
                                                self.saturation * self.maxScrollViewYOffset);;
    
    self.scrollView.zoomScale = self.brightness * self.zoomScaleRange;
    
    self.recalculateOnContentOffsetChange = YES;
    
    [self updateBackgroundColor];
}

#pragma mark - NSObject

- (void)dealloc {
    void (^unobserve)(NSString *keyPath) = ^(NSString *keyPath) {
        [self removeObserver:self forKeyPath:keyPath context:PCColorPickerViewKVOContext];
    };
    
    unobserve(@"hue");
    unobserve(@"saturation");
    unobserve(@"brightness");
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.recalculateOnContentOffsetChange = YES;
        
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.delegate = self;
        self.scrollView.bounces = NO;
        self.scrollView.directionalLockEnabled = YES;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:self.scrollView];
        
        self.stationaryView = [[UIView alloc] init];
        [self.scrollView addSubview:self.stationaryView];
        
        self.zoomView = [[UIScrollView alloc] init];
        self.zoomView.delegate = self;
        self.zoomView.minimumZoomScale = PCColorPickerViewMinimumZoomScale;
        self.zoomView.maximumZoomScale = PCColorPickerViewMaximumZoomScale;
        [self.zoomView.panGestureRecognizer requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
        [self.stationaryView addSubview:self.zoomView];
        
        self.zoomScaleRange = self.zoomView.maximumZoomScale - self.zoomView.minimumZoomScale;
        
        self.viewForZoomingInScrollView = [[UIView alloc] init];
        [self.zoomView addSubview:self.viewForZoomingInScrollView];
        
        self.hexLabel = [[PCCopyableLabel alloc] init];
        self.hexLabel.font = [UIFont fontWithName:PCColorPickerViewHexLabelFontName
                                             size:PCColorPickerViewHexLabelFontSize];
        [self.stationaryView addSubview:self.hexLabel];
        
        self.infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [self addSubview:self.infoButton];
        
        [self randomizeBackgroundColor];
        
        void (^observe)(NSString *keyPath) = ^(NSString *keyPath) {
            [self addObserver:self forKeyPath:keyPath options:0 context:PCColorPickerViewKVOContext];
        };
        
        observe(@"hue");
        observe(@"saturation");
        observe(@"brightness");
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
    
#warning - Initial frame is off
    self.hexLabel.center = self.stationaryView.center;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if (context == PCColorPickerViewKVOContext) {
        if (object == self && [@[@"hue", @"saturation", @"brightness"] containsObject:keyPath]) {
            [self updateBackgroundColor];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private

- (void)updateBackgroundColor {
    UIColor *color = [[UIColor alloc] initWithHue:self.hue saturation:self.saturation
                                       brightness:self.brightness alpha:1];
    
    self.backgroundColor = color;
    
    self.hexLabel.text = [@"#" stringByAppendingString:[hexCodeForColor(color) uppercaseString]];
    [self.hexLabel sizeToFit];
    
    self.hexLabel.textColor = [UIColor colorWithHue:0 saturation:0 brightness:1 - round(self.brightness)
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
