//
//  UITabBar+RedDotBadge.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (RedDotBadge)

- (void)showBadgeOnItemIndex:(int)index withInfo:(NSString *)info;
- (void)hideBadgeOnItemIndex:(int)index;

@end
