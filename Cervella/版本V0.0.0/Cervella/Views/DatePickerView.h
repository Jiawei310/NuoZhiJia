//
//  DatePickerView.h
//  MyDatePickerView
//
//  Created by 诺之家 on 16/7/6.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerView : UIView

/** 显示 */
- (void)show;
/** 隐藏 */
- (void)hide;

/** 初始化方法 */
- (instancetype)initWith:(NSInteger)yearIndex
                   Month:(NSInteger)monthIndex
                     Day:(NSInteger)dayIndex;
- (instancetype)initWithFrame:(CGRect)frame
                         Year:(NSInteger)yearIndex
                        Month:(NSInteger)monthIndex;
/** 返回用户选择的开始时间和结束时间 */
@property (nonatomic, copy) void(^gotoSrceenOrderBlock)(NSString *);

@end
