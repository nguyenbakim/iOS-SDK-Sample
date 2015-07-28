//
//  UIActionSheet+Extensions.m
//  ooVooSample
//
//  Created by ooVoo on 6/15/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "UIActionSheet+Extensions.h"

@implementation UIActionSheet (Extensions)

- (void)setButton:(NSInteger)buttonIndex Enabled:(BOOL)enabled
{
    for (UIView* view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            if (buttonIndex == 0) {
                if ([view respondsToSelector:@selector(setEnabled:)])
                {
                    UIButton* button = (UIButton*)view;
                    button.enabled = enabled;
                }
            }
            buttonIndex--;
        }
    }
}

@end
