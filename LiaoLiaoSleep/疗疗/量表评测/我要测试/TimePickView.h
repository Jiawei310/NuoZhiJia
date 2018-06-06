//
//  TimePickView.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/13.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, TimePickType) {
    TimePickTypeMinute				   = 1,       //十分钟选择器
    TimePickTypeHour                   = 2,       //小时选择器
    TimePickTypeHourAndMinute          = 3,       //时分时间选择器
};

typedef void (^TimePickValue)(NSString *timeValue);

@interface TimePickView : UIView

@property (nonatomic, copy) TimePickValue timePick;

@property (nonatomic, assign)NSInteger selectedRow1;
@property (nonatomic, assign)NSInteger selectedRow2;

- (instancetype)initWithType:(TimePickType)timeType AndTime:(NSString *)time;

- (void)sendTimePickValue:(TimePickValue)timePick;

@end
