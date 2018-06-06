//
//  AutoSlider.h
//  Sleep4U
//
//  Created by 诺之家 on 16/5/19.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^valueChangeBlock)(int index);

@interface AutoSlider : UIControl

/**
 *  回调
 */
@property (nonatomic,copy)valueChangeBlock block;

/**
 *  设置滑杆当前滑动到的位置
 */
@property (nonatomic,assign)CGFloat locationIndex;


/**
 *  初始化方法
 *
 *  @param frame
 *  @param titleArray         必传，传入节点数组
 *  @param defaultIndex       必传，范围（0到(array.count-1)）
 *  @param sliderImage        传入画块图片
 *
 *  @return
 */
-(instancetype)initWithFrame:(CGRect)frame
                      titles:(NSArray *)titleArray
                defaultIndex:(CGFloat)defaultIndex
                 sliderImage:(UIImage *)sliderImage;


@end
