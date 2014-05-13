//
//  PCOLColorPickerView.h
//  Pretty Colors
//
//  Created by Bryan Irace on 8/11/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

@interface PCOLColorPickerView : UIView

@property (nonatomic, strong, readonly) UIButton *infoButton;
@property (nonatomic, copy, readonly) NSString *hexCodeString;

- (void)randomizeBackgroundColor;

@end
