//
//  UIButton+NoRepeat.h
//  Somnormal
//
//  Created by Justin on 2017/8/1.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (NoRepeat)

/**
 *  为按钮添加点击间隔 eventTimeInterval秒
 */
@property (nonatomic, assign) NSTimeInterval eventTimeInterval;

@end
