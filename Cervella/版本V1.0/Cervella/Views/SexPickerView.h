//
//  SexPickerView.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/1/12.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SexPickerView : UIView

/** 显示 */
- (void)show;
/** 隐藏 */
- (void)hide;

/** 初始化方法 */
- (instancetype)initWith:(NSString *)sexStr;
/** 返回用户选择的开始时间和结束时间 */
@property (nonatomic, copy) void(^gotoSrceenOrderBySexPickBlock)(NSString *);

@end
