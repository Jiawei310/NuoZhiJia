//
//  DatePickerView.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/25.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^YBDatePickValue)(NSString *timeValue);

@interface YBDatePickerView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, copy) YBDatePickValue YBDatePick;

@property (nonatomic,strong)UIPickerView * timePickerView;

@property (nonatomic,strong) NSMutableArray *dataSource2;
@property (nonatomic,strong) NSMutableArray *dataSource3;
@property (nonatomic,assign) NSInteger selectedRow1;
@property (nonatomic,assign) NSInteger selectedRow2;
@property (nonatomic,assign) NSInteger selectedRow3;


- (instancetype)initWithFrame:(CGRect)frame andTime:(NSString *)time;

- (void)sendTimePickValue:(YBDatePickValue)datePick;

@end
