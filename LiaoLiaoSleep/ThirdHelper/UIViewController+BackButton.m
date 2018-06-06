//
//  UIViewController+BackButton.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/3.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "UIViewController+BackButton.h"

@implementation UIViewController (BackButton)

@end

@implementation UINavigationController (ShouldPopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if([self.viewControllers count] < [navigationBar.items count])
    {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController* vc = [self topViewController];
    if([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)])
    {
        shouldPop = [vc navigationShouldPopOnBackButton];
    }
    
    if(shouldPop)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    else
    {
        // 取消 pop 后，复原返回按钮的状态
        for(UIView *subview in [navigationBar subviews])
        {
            if(0. < subview.alpha && subview.alpha < 1.)
            {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    
    return NO;
}

@end
