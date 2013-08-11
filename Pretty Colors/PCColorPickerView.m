//
//  PCColorPickerView.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCColorPickerView.h"

static void * PCColorPickerViewKVOContext = &PCColorPickerViewKVOContext;

static CGFloat const PCColorPickerViewContentSizeScale = 3;
static CGFloat const PCColorPickerViewMinimumZoomScale = 0;
static CGFloat const PCColorPickerViewMaximumZoomScale = 4;

@interface PCColorPickerView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *zoomView;
@property (nonatomic, strong) UIView *viewForZoomingInScrollView;

@property (nonatomic) CGFloat maxScrollViewXOffset;
@property (nonatomic) CGFloat maxScrollViewYOffset;
@property (nonatomic) CGFloat zoomScaleRange;

@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;
@property (nonatomic) CGFloat brightness;

@end

@implementation PCColorPickerView

- (void)randomizeBackgroundColor {
    CGFloat (^randomFloat)() = ^ {
        return ((CGFloat)arc4random()/0x100000000);
    };
    
    self.hue = randomFloat();
    self.saturation = randomFloat();
    self.brightness = randomFloat();
    
    self.scrollView.delegate = nil;
    
    self.scrollView.contentOffset = CGPointMake(self.hue * self.maxScrollViewXOffset,
                                                self.saturation * self.maxScrollViewYOffset);;
    
    self.scrollView.zoomScale = self.brightness * self.zoomScaleRange;
    
    self.scrollView.delegate = self;
    
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

        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.delegate = self;
        self.scrollView.bounces = NO;
        self.scrollView.directionalLockEnabled = YES;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:self.scrollView];
        
        self.zoomView = [[UIScrollView alloc] init];
        self.zoomView.delegate = self;
        self.zoomView.minimumZoomScale = PCColorPickerViewMinimumZoomScale;
        self.zoomView.maximumZoomScale = PCColorPickerViewMaximumZoomScale;
        [self.zoomView.panGestureRecognizer requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
        [self.scrollView addSubview:self.zoomView];
        
        self.zoomScaleRange = self.zoomView.maximumZoomScale - self.zoomView.minimumZoomScale;
        
        // Exists solely because UIScrollViewDelegate `viewForZoomingInScrollView:` requires a subview be returned
        self.viewForZoomingInScrollView = [[UIView alloc] init];
        [self.zoomView addSubview:self.viewForZoomingInScrollView];
        
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
    
    self.viewForZoomingInScrollView.frame = self.bounds;
    self.zoomView.frame = self.bounds;
    self.scrollView.frame = self.bounds;
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGSize scrollViewContentSize = CGSizeApplyAffineTransform(scrollViewSize,
                                                              CGAffineTransformMakeScale(PCColorPickerViewContentSizeScale,
                                                                                         PCColorPickerViewContentSizeScale));
    
    self.scrollView.contentSize = scrollViewContentSize;
    
    self.maxScrollViewXOffset = scrollViewContentSize.width - scrollViewSize.width;
    self.maxScrollViewYOffset = scrollViewContentSize.height - scrollViewSize.height;
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
    NSLog(@"Hue: %f, saturation: %f, brightness: %f", self.hue, self.saturation, self.brightness);
    
    self.scrollView.backgroundColor = [[UIColor alloc] initWithHue:self.hue saturation:self.saturation
                                                        brightness:self.brightness alpha:1];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView && !CGRectIsEmpty(self.scrollView.frame)) {
        CGFloat xOffset = scrollView.contentOffset.x;
        CGFloat yOffset = scrollView.contentOffset.y;
        
        CGRect zoomViewFrame = self.zoomView.frame;
        zoomViewFrame.origin = CGPointMake(xOffset, yOffset);
        self.zoomView.frame = zoomViewFrame;
        
        self.hue = xOffset/self.maxScrollViewXOffset;
        self.saturation = yOffset/self.maxScrollViewYOffset;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scrollView == self.zoomView) {
        self.brightness = scale/self.zoomScaleRange;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.zoomView) {
        return self.viewForZoomingInScrollView;
    }
    
    return nil;
}

@end
