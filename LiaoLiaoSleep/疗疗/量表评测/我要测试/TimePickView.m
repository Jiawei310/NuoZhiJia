//
//  TimePickView.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/13.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "TimePickView.h"
#import "Define.h"

@interface TimePickView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (assign, nonatomic) TimePickType timePickType;

@property (strong, nonatomic) UIPickerView *minutePickView;
@property (strong, nonatomic) UIPickerView *hourPickView;
@property (strong, nonatomic) UIPickerView *strPickView;

@property (strong, nonatomic) UIPickerView *hourAndMinutePickView;

@property (strong, nonatomic) NSArray *hourArray;
@property (strong, nonatomic) NSArray *minuteArray;

@property (strong, nonatomic) NSArray *strArray;

@end

@implementation TimePickView
{
    NSString *timeStrHour;
    NSString *timeStrMinute;
}

- (instancetype)initWithType:(TimePickType)timeType AndTime:(NSString *)time
{
    self = [super init];
    if (self)
    {
        if (timeType == TimePickTypeMinute)
        {
            [self initializeMinutePickView:time];
            
        }
        else if (timeType == TimePickTypeHour)
        {
            [self initializeHourPickView:time];
        }
        else if (timeType == TimePickTypeHourAndMinute)
        {
            [self initializeHourAndMinutePickView:time];
        }
    }
    
    return self;
}

//minutePickView的初始化
- (void)initializeMinutePickView:(NSString *)time
{
    _timePickType = TimePickTypeMinute;
    
    _minutePickView = [[UIPickerView alloc] initWithFrame:CGRectMake(102.5*Rate_NAV_W, 0, 70*Rate_NAV_W, 281*Rate_NAV_H)];
    _minutePickView.tag = 0;
    [self addSubview:_minutePickView];
    
    _strPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(172.5*Rate_NAV_W, 0, 40*Rate_NAV_W, 281*Rate_NAV_H)];
    _strPickView.tag = 1;
    _strPickView.userInteractionEnabled = NO;
    [self addSubview:_strPickView];
    
    //minutePickView的minuteArray数组初始化数据
    _minuteArray = @[@"10",@"20",@"30",@"40",@"50",@"1"];
    _strArray = @[@"分钟",@"分钟",@"分钟",@"分钟",@"分钟",@"小时"];
    
    _minutePickView.delegate = self;
    _minutePickView.dataSource = self;
    
    _strPickView.delegate = self;
    _strPickView.dataSource = self;
    
    if ([time integerValue] == 1)
    {
        _selectedRow1 = 5;
        [_minutePickView selectRow:5 inComponent:0 animated:YES];
        [_strPickView selectRow:5 inComponent:0 animated:YES];
    }
    else
    {
        _selectedRow1 = [time integerValue]/10 -1;
        [_minutePickView selectRow:[time integerValue]/10 -1 inComponent:0 animated:YES];
        [_strPickView selectRow:[time integerValue]/10 -1 inComponent:0 animated:YES];
    }
}

//hourPickView的初始化
- (void)initializeHourPickView:(NSString *)time
{
    _timePickType = TimePickTypeHour;
    
    _hourPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(102.5*Rate_NAV_W, 0, 70*Rate_NAV_W, 281*Rate_NAV_H)];
    _hourPickView.tag = 0;
    [self addSubview:_hourPickView];
    
    _strPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(172.5*Rate_NAV_W, 0, 40*Rate_NAV_W, 281*Rate_NAV_H)];
    _strPickView.tag = 1;
    _strPickView.userInteractionEnabled = NO;
    [self addSubview:_strPickView];
    
    //hourPickView的hourArray数组初始化数据
    _hourArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24"];
    _strArray = @[@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时",@"小时"];
    
    _hourPickView.delegate = self;
    _hourPickView.dataSource = self;
    
    _strPickView.delegate = self;
    _strPickView.dataSource = self;
    
    _selectedRow1 = [time integerValue] - 1;
    [_hourPickView selectRow:[time integerValue] - 1 inComponent:0 animated:YES];
    [_strPickView selectRow:[time integerValue] - 1 inComponent:0 animated:YES];
}

//hourAndMinutePickView的初始化
- (void)initializeHourAndMinutePickView:(NSString *)time
{
    _timePickType = TimePickTypeHourAndMinute;
    _hourAndMinutePickView = [[UIPickerView alloc] initWithFrame:CGRectMake(30*Rate_NAV_W, 0, 215*Rate_NAV_W, 281*Rate_NAV_H)];
    _hourAndMinutePickView.tag = 0;
    [self addSubview:_hourAndMinutePickView];
    [self clearSeparatorWithView:_hourAndMinutePickView];
    
    //添加“ ：”
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(127.5*Rate_NAV_W, 95*Rate_NAV_H, 20*Rate_NAV_W, 82*Rate_NAV_H)];
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.font = [UIFont systemFontOfSize:64];
    myLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    myLabel.text = @":";
    [self addSubview:myLabel];
    
    //hourPickView的minuteArray数组和hourArray数组初始化数据
    _hourArray = @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"];
    _minuteArray = @[@"00", @"10", @"20", @"30", @"40", @"50"];
    
    _hourAndMinutePickView.delegate = self;
    _hourAndMinutePickView.dataSource = self;
    
    timeStrHour = [time substringWithRange:NSMakeRange(0, 2)];
    timeStrMinute = [time substringWithRange:NSMakeRange(3, 2)];
    _selectedRow1 = [timeStrHour integerValue];
    [_hourAndMinutePickView selectRow:_selectedRow1 inComponent:0 animated:YES];
    _selectedRow2 = ([timeStrMinute integerValue]/10)%6;
    [_hourAndMinutePickView selectRow:_selectedRow2 inComponent:1 animated:YES];
    [_hourAndMinutePickView reloadAllComponents];
}

#pragma pickerview的delegate和dataSource代理方法

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = view?(UILabel *)view:[[UILabel alloc] init];
    //去除原本分割线
    if (_timePickType == TimePickTypeMinute)
    {
        if (pickerView.tag == 0)
        {
            pickerLabel.frame = CGRectMake(74*Rate_NAV_W, 0, 66*Rate_NAV_W, 82*Rate_NAV_H);
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            pickerLabel.textAlignment = NSTextAlignmentCenter;
            pickerLabel.font = [UIFont fontWithName:@"DINPro-Regular" size:64*Rate_NAV_H];
            if (_selectedRow1 == row)
            {
                pickerLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
            }
            else
            {
                pickerLabel.textColor = [UIColor colorWithRed:0xBE/255.0 green:0xC5/255.0 blue:0xC7/255.0 alpha:1];
            }
            pickerLabel.backgroundColor = [UIColor clearColor];
            pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
            
            ((UIView *)[_minutePickView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
            ((UIView *)[_minutePickView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
        }
        else
        {
            pickerLabel.frame = CGRectMake(74*Rate_NAV_W, 0, 66*Rate_NAV_W, 82*Rate_NAV_H);
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            pickerLabel.textAlignment = NSTextAlignmentCenter;
            pickerLabel.font = [UIFont fontWithName:@"DINPro-Regular" size:20*Rate_NAV_H];
            if (_selectedRow1 == row)
            {
                pickerLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
            }
            else
            {
                pickerLabel.textColor = [UIColor colorWithRed:0xBE/255.0 green:0xC5/255.0 blue:0xC7/255.0 alpha:1];
            }
            pickerLabel.backgroundColor = [UIColor clearColor];
            pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
            
            ((UIView *)[_strPickView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
            ((UIView *)[_strPickView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
        }
    }
    else if (_timePickType == TimePickTypeHour)
    {
        if (pickerView.tag == 0)
        {
            pickerLabel.frame = CGRectMake(74*Rate_NAV_W, 0, 66*Rate_NAV_W, 82*Rate_NAV_H);
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            pickerLabel.textAlignment = NSTextAlignmentCenter;
            pickerLabel.font = [UIFont fontWithName:@"DINPro-Regular" size:64*Rate_NAV_H];
            if (_selectedRow1 == row)
            {
                pickerLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
            }
            else
            {
                pickerLabel.textColor = [UIColor colorWithRed:0xBE/255.0 green:0xC5/255.0 blue:0xC7/255.0 alpha:1];
            }
            pickerLabel.backgroundColor = [UIColor clearColor];
            
            pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
            
            ((UIView *)[_hourPickView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
            ((UIView *)[_hourPickView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
        }
        else
        {
            pickerLabel.frame = CGRectMake(74*Rate_NAV_W, 0, 66*Rate_NAV_W, 82*Rate_NAV_H);
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            pickerLabel.textAlignment = NSTextAlignmentCenter;
            pickerLabel.font = [UIFont fontWithName:@"DINPro-Regular" size:20*Rate_NAV_H];
            if (_selectedRow1 == row)
            {
                pickerLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
            }
            else
            {
                pickerLabel.textColor = [UIColor colorWithRed:0xBE/255.0 green:0xC5/255.0 blue:0xC7/255.0 alpha:1];
            }
            pickerLabel.backgroundColor = [UIColor clearColor];
            pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
            
            ((UIView *)[_strPickView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
            ((UIView *)[_strPickView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
        }
        
    }
    else if (_timePickType == TimePickTypeHourAndMinute)
    {
        if (component == 0)
        {
            pickerLabel.frame = CGRectMake(0, 0, 66*Rate_NAV_W, 82*Rate_NAV_H);
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            pickerLabel.textAlignment = NSTextAlignmentCenter;
            pickerLabel.font = [UIFont fontWithName:@"DINPro-Regular" size:64*Rate_NAV_H];
            if (_selectedRow1 == row)
            {
                pickerLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
            }
            else
            {
                pickerLabel.textColor = [UIColor colorWithRed:0xBE/255.0 green:0xC5/255.0 blue:0xC7/255.0 alpha:1];
            }
            pickerLabel.backgroundColor = [UIColor clearColor];
            
            pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        }
        else if (component == 1)
        {
            pickerLabel.frame = CGRectMake(160*Rate_NAV_W, 0, 66*Rate_NAV_W, 82*Rate_NAV_H);
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            pickerLabel.textAlignment = NSTextAlignmentCenter;
            pickerLabel.backgroundColor = [UIColor redColor];
            pickerLabel.font = [UIFont fontWithName:@"DINPro-Regular" size:64*Rate_NAV_H];
            if (_selectedRow2 == row)
            {
                pickerLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
            }
            else
            {
                pickerLabel.textColor = [UIColor colorWithRed:0xBE/255.0 green:0xC5/255.0 blue:0xC7/255.0 alpha:1];
            }
            pickerLabel.backgroundColor = [UIColor clearColor];
            
            pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        }
        
        if (_hourAndMinutePickView.subviews.count > 0)
        {
            ((UIView *)[_hourAndMinutePickView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
            ((UIView *)[_hourAndMinutePickView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
        }
    }
    
    return pickerLabel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if (pickerView.tag == 11)
    {
        return 24*Rate_NAV_H;
    }
    else
    {
        return 82*Rate_NAV_H;
    }
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_timePickType == TimePickTypeHourAndMinute)
    {
        if (pickerView.tag == 0)
        {
            return 2;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 1;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_timePickType == TimePickTypeMinute)
    {
        if (pickerView.tag == 0)
        {
            return _minuteArray.count;
        }
        else
        {
            return _strArray.count;
        }
    }
    else if (_timePickType == TimePickTypeHour)
    {
        if (pickerView.tag == 0)
        {
            return _hourArray.count;
        }
        else
        {
            return _strArray.count;
        }
    }
    else if (_timePickType == TimePickTypeHourAndMinute)
    {
        if (component == 0)
        {
            return _hourArray.count;
        }
        else
        {
            return _minuteArray.count;
        }
    }
    else
    {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_timePickType == TimePickTypeMinute)
    {
        if (pickerView.tag == 0)
        {
            return _minuteArray[row];
        }
        else
        {
            return _strArray[row];
        }
    }
    else if (_timePickType == TimePickTypeHour)
    {
        if (pickerView.tag == 0)
        {
            return _hourArray[row];
        }
        else
        {
            return _strArray[row];
        }
    }
    else if (_timePickType == TimePickTypeHourAndMinute)
    {
        if (component == 0)
        {
            return _hourArray[row];
        }
        else
        {
            return _minuteArray[row];
        }
    }
    else
    {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //传递时间选择的值
    if (_timePickType == TimePickTypeMinute)
    {
        if (pickerView.tag == 0)
        {
            NSString *str = [_minuteArray objectAtIndex:row];
            self.timePick(str);
            _selectedRow1 = row;
            [_strPickView selectRow:_selectedRow1 inComponent:0 animated:YES];
        }
        [pickerView reloadAllComponents];
        [_strPickView reloadAllComponents];
    }
    else if (_timePickType == TimePickTypeHour)
    {
        if (pickerView.tag == 0)
        {
            NSString *str = [_hourArray objectAtIndex:row];
            self.timePick(str);
            _selectedRow1 = row;
            [_strPickView selectRow:_selectedRow1 inComponent:0 animated:YES];
        }
        [pickerView reloadAllComponents];
        [_strPickView reloadAllComponents];
    }
    else if (_timePickType == TimePickTypeHourAndMinute)
    {
        if (component == 0)
        {
            timeStrHour = [_hourArray objectAtIndex:row];
            _selectedRow1 = row;
        }
        else
        {
            timeStrMinute = [_minuteArray objectAtIndex:row];
            _selectedRow2 = row;
        }
        NSString *tmp = [timeStrHour stringByAppendingFormat:@":%@",timeStrMinute];
        self.timePick(tmp);
        
        [pickerView reloadAllComponents];
    }
}

- (void)sendTimePickValue:(TimePickValue)timePick
{
    self.timePick = timePick;
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

@end
