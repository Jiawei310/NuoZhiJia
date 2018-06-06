//
//  UIViewController+BackButton.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/3.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonProtocol <NSObject>

@optional
- (BOOL)navigationShouldPopOnBackButton;

@end

@interface UIViewController (BackButton)<BackButtonProtocol>

@end
