//
//  DatePickerView.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/25.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "YBDatePickerView.h"
#import "Define.h"

@implementation YBDatePickerView

- (instancetype)initWithFrame:(CGRect)frame andTime:(NSString *)time
{
    if (self == [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
        [self prepareDataWithWidthArr];
        [self createDatePickerWithFrame:frame andTime:time];
    }
    return self;
}

- (void)prepareDataWithWidthArr
{
    self.dataSource2 = [NSMutableArray array];
    self.dataSource3 = [NSMutableArray array];
    for (int i = 0; i < 24; i++)
    {
        [self.dataSource2 addObject:[NSString stringWithFormat:@"%02i",i]];
    }
    for (int i = 0; i < 12; i++)
    {
        [self.dataSource3 addObject:[NSString stringWithFormat:@"%02i",i*5]];
    }
}

- (void)createDatePickerWithFrame:(CGRect)frame andTime:(NSString *)time
{
    _timePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(112.5*Rate_NAV_W, 0, 150*Rate_NAV_W, 157*Rate_NAV_H)];
    _timePickerView.tag = 1;
    //指定数据源和委托
    _timePickerView.delegate = self;
    _timePickerView.dataSource = self;
    _timePickerView.showsSelectionIndicator = YES;
    _timePickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_timePickerView];
    //添加 “：”显示
    UILabel *colonLabel = [[UILabel alloc] initWithFrame:CGRectMake(179*Rate_NAV_W, 57*Rate_NAV_H, 20*Rate_NAV_W, 40*Rate_NAV_H)];
    colonLabel.font = [UIFont systemFontOfSize:28*Rate_NAV_H];
    colonLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1.0];
    colonLabel.text = @":";
    colonLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:colonLabel];
    //设置timePickerView的默认值
    NSString *rowOne = [time substringWithRange:NSMakeRange(0, 2)];
    self.selectedRow2 = [rowOne integerValue];
    NSString *rowTwo = [time substringWithRange:NSMakeRange(3, 2)];
    self.selectedRow3 = [rowTwo integerValue]/5;
    [_timePickerView selectRow:self.selectedRow2 inComponent:0 animated:NO];
    [_timePickerView selectRow:self.selectedRow3 inComponent:1 animated:NO];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(68*Rate_NAV_W, 157*Rate_NAV_H, 240*Rate_NAV_W, 50*Rate_NAV_H)];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"treatment_btn_bg"] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmBtn];
}

- (void)confirmBtnClick:(UIButton *)sender
{
    NSString *timeTwo = [self.dataSource2 objectAtIndex:self.selectedRow2];
    NSString *timeThree = [self.dataSource3 objectAtIndex:self.selectedRow3];
    self.YBDatePick([NSString stringWithFormat:@"%@:%@",timeTwo,timeThree]);
    
    [self removeFromSuperview];
}

- (void)sendTimePickValue:(YBDatePickValue)datePick
{
    self.YBDatePick = datePick;
}

- (void)clearSeparatorWithView:(UIView * )view
{
    if(view.subviews != 0  )
    {
        if(view.bounds.size.height < 5)
        {
            view.backgroundColor = [UIColor clearColor];
        }
        [view.subviews enumerateObjectsUsingBlock:^( UIView *  obj, NSUInteger idx, BOOL *  stop) {
            [self clearSeparatorWithView:obj];
        }];
    }
    
}
#pragma mark UIPickerView DataSource Method 数据源方法
//指定pickerview有几个表盘
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;//第一个展示字母、第二个展示数字
}

//指定每个表盘上有几行数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.dataSource2.count;
    }
    else
    {
        return self.dataSource3.count;
    }
}

#pragma mark UIPickerView Delegate Method 代理方法
//指定每行如何展示数据（此处和tableview类似）
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    UILabel *label = nil;
    if(component == 0)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40*Rate_NAV_W, 36*Rate_NAV_H)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = self.dataSource2[row];
        label.font = [UIFont fontWithName:@"DINPro-Regular" size:28*Rate_NAV_H];
        if (row == self.selectedRow2)
        {
            label.textColor = [UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.00];
        }
        else
        {
            label.textColor = [UIColor colorWithRed:0.75 green:0.77 blue:0.78 alpha:1.00];
        }
    }
    else if(component == 1)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(70.5*Rate_NAV_W, 0, 40*Rate_NAV_W, 36*Rate_NAV_H)];
        label.font = [UIFont fontWithName:@"DINPro-Regular" size:28*Rate_NAV_H];
        label.text = self.dataSource3[row];
        if (row == self.selectedRow3)
        {
            label.textColor = [UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.00];
        }
        else
        {
            label.textColor = [UIColor colorWithRed:0.75 green:0.77 blue:0.78 alpha:1.00];
        }
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    if (_timePickerView.subviews.count > 0)
    {
        ((UIView *)[_timePickerView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
        ((UIView *)[_timePickerView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
    }
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 75*Rate_NAV_W;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 36*Rate_NAV_H;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.selectedRow2 = row;
    }
    else
    {
        self.selectedRow3 = row;
    }
    
    [_timePickerView reloadAllComponents];
}


@end
