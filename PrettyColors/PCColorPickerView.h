//
//  PCColorPickerView.h
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

// TODO: HSL/RGB display? (little 'info' thing in the corner?)
// TODO: Auto-layout
// TODO: Label spacing too tight
// TODO: Tumblr integration

@interface PCColorPickerView : UIView

@property (nonatomic, readonly) NSString *hexCodeString;

- (void)randomizeBackgroundColor;

@end
