//
//  UIImage+CommonOption.h
//  SleepExpert
//
//  Created by 诺之家 on 16/6/29.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CommonOption)

/**
 *  获取圆角图片
 *
 *  @param image       <#image description#>
 *  @param borderWidth <#borderWidth description#>
 *  @param color       <#color description#>
 *
 *  @return <#return value description#>
 */

+ (UIImage *)imageWithClipImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color;

/**
 *  指定区域图片的截图
 *
 *  @param sourceImage 原始图片
 *  @param clipRect    截取范围
 *
 *  @return 截图图片
 */
+ (UIImage *)imageWithSourceImage:(UIImage *)sourceImage
                         clipRect:(CGRect)clipRect;

/**
 *  截取指定位置的图片
 *
 *  @param bounds <#bounds description#>
 *
 *  @return <#return value description#>
 */
- (UIImage *)croppedImage:(CGRect)bounds;

@end
