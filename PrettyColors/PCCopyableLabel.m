//
//  PCCopyableLabel.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/13/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCCopyableLabel.h"

@implementation PCCopyableLabel

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;

        UIGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(showMenu)];
        [self addGestureRecognizer:longPressRecognizer];
    }
    
    return self;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Actions

- (void)showMenu {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([UIMenuController sharedMenuController].isMenuVisible) {
        [menuController setMenuVisible:NO animated:YES];
        
    } else {
        [self becomeFirstResponder];
        
        menuController.menuItems = @[[[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyText)]];
        [menuController setTargetRect:CGRectMake(floorf(CGRectGetWidth(self.bounds)/2), 0, 0, 0) inView:self];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void)copyText {
    [UIPasteboard generalPasteboard].string = self.text;
}

@end
