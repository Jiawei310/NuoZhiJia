//
//  DatePickerView.m
//  MyDatePickerView
//
//  Created by 诺之家 on 16/7/6.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "DatePickerView.h"

#define mBlueColor [UIColor colorWithRed:50.0/255.0 green:162.0/255.0 blue:248.0/255.0 alpha:1.0]
#define mGrayColor [UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1.0]

@interface DatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *bgView;

/* 用来存储年的数组，datePickerView代理返回 */
@property (nonatomic,strong) NSMutableArray *yearArray;
/* 用来存储月的数组，datePickerView代理返回 */
@property (nonatomic,strong) NSMutableArray *monthArray;
/* 用来存储日的数组，datePickerView代理返回 */
@property (nonatomic,strong) NSMutableArray *dayArray;
/* 当前选择器选择的年月日的index */
@property (nonatomic,assign) NSInteger monthIndex;
@property (nonatomic,assign) NSInteger yearIndex;
@property (nonatomic,assign) NSUInteger dayIndex;
/* 当前年月日的index */
@property (nonatomic,assign) NSInteger year;
@property (nonatomic,assign) NSInteger month;
@property (nonatomic,assign) NSUInteger day;

/* datePickerView */
@property (strong, nonatomic) UIPickerView *datePickerView;
/* 时间格式转换器 */
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation DatePickerView

#pragma mark 配置视图

- (instancetype)initWith:(NSInteger)yearIndex Month:(NSInteger)monthIndex Day:(NSInteger)dayIndex
{
    self = [super init];
    if (self) {
        // 初始化设置
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 244);
        [window addSubview:self.bgView];
        [window addSubview:self];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(275*Rate_NAV_W, 11*Rate_NAV_H, 85*Rate_NAV_W, 16*Rate_NAV_H)];
        confirmBtn.backgroundColor = [UIColor whiteColor];
        [confirmBtn setTitleColor:[UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40*Rate_NAV_H, 375*Rate_NAV_W, 0.5*Rate_NAV_H)];
        lineView.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
        [self addSubview:lineView];
        
        //获取系统当前时间
        NSDate *date=[NSDate date];
        unsigned units  = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
        NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *component = [myCal components:units fromDate:date];
        self.month = [component month];
        self.year = [component year];
        self.day = [component day];
        
        self.monthArray = [NSMutableArray array];
        self.yearArray = [NSMutableArray array];
        self.dayArray = [NSMutableArray array];
        
        [self addYearArrayValues];
        self.yearIndex = yearIndex - 1900;
        
        [self addMonthArrayValues];
        self.monthIndex = monthIndex - 1;
        
        [self addDayArrayValues];
        self.dayIndex = dayIndex -1;
        
        self.datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44*Rate_NAV_H, 375*Rate_NAV_W, 200*Rate_NAV_H)];
        self.datePickerView.tag = 1;
        self.datePickerView.delegate = self;
        self.datePickerView.dataSource = self;
        [self addSubview:_datePickerView];
        
        [self.datePickerView selectRow:self.yearIndex inComponent:0 animated:YES];
        [self.datePickerView selectRow:self.monthIndex inComponent:1 animated:YES];
        [self.datePickerView selectRow:self.dayIndex inComponent:2 animated:YES];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Year:(NSInteger)yearIndex Month:(NSInteger)monthIndex
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 初始化设置
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 248*Rate_NAV_H);
        [window addSubview:self.bgView];
        [window addSubview:self];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(275*Rate_NAV_W, 11*Rate_NAV_H, 85*Rate_NAV_W, 16*Rate_NAV_H)];
        confirmBtn.backgroundColor = [UIColor whiteColor];
        [confirmBtn setTitleColor:[UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40*Rate_NAV_H, 375*Rate_NAV_W, 0.5*Rate_NAV_H)];
        lineView.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
        [self addSubview:lineView];
        
        //获取系统当前时间
        NSDate *date=[NSDate date];
        unsigned units  = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
        NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *component = [myCal components:units fromDate:date];
        self.month = [component month];
        self.year = [component year];
        
        self.monthArray = [NSMutableArray array];
        self.yearArray = [NSMutableArray array];
        
        [self addYearArrayValues];
        if (yearIndex == 0)
        {
            self.yearIndex = self.year - 1900;
        }
        else
        {
            self.yearIndex = yearIndex - 1900;
        }
        
        [self addMonthArrayValues];
        if (monthIndex == 0 || monthIndex > 11)
        {
            self.monthIndex = self.month - 1;
        }
        else
        {
            self.monthIndex = monthIndex - 1;
        }
        
        self.datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44*Rate_NAV_H, 375*Rate_NAV_W, 200*Rate_NAV_H)];
        self.datePickerView.tag = 0;
        self.datePickerView.delegate = self;
        self.datePickerView.dataSource = self;
        [self addSubview:_datePickerView];
        
        [self.datePickerView selectRow:self.yearIndex inComponent:0 animated:YES];
        [self.datePickerView selectRow:self.monthIndex inComponent:1 animated:YES];
    }
    return self;
}

- (void)addYearArrayValues
{
    for (int i = 1900; i <= self.year; i++)
    {
        NSString *yearStr=[NSString stringWithFormat:@"%d",i];
        [self.yearArray addObject:yearStr];
    }
}

- (void)addMonthArrayValues
{
    if (self.yearIndex == self.year-1900)
    {
        for (int i = 1; i <= self.month; i++)
        {
            NSString *monthStr=[NSString stringWithFormat:@"%d",i];
            [self.monthArray addObject:monthStr];
        }
    }
    else
    {
        for (int i = 1; i <= 12; i++)
        {
            NSString *monthStr=[NSString stringWithFormat:@"%d",i];
            [self.monthArray addObject:monthStr];
        }
    }
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _bgView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_bgView addGestureRecognizer:tap];
    }
    return _bgView;
}

- (void)confirmBtnClick:(UIButton *)sender
{
    if (self.datePickerView.tag == 0)
    {
        if (self.monthIndex > self.monthArray.count-1)
        {
            self.monthIndex = self.monthArray.count-1;
        }
        
        NSString *birthMonth = [NSString stringWithFormat:@"%02ld",(long)[[self.monthArray objectAtIndex:self.monthIndex] integerValue]];
        NSString *birthday=[NSString stringWithFormat:@"%@-%@",[self.yearArray objectAtIndex:self.yearIndex],birthMonth];
        self.gotoSrceenOrderBlock(birthday);
    }
    else
    {
        NSString *birthMonth = [NSString stringWithFormat:@"%02ld",(long)[[self.monthArray objectAtIndex:self.monthIndex] integerValue]];
        NSString *birthDay = [NSString stringWithFormat:@"%02ld",(long)[[self.dayArray objectAtIndex:self.dayIndex] integerValue]];
        NSString *birthday=[NSString stringWithFormat:@"%@-%@-%@",[self.yearArray objectAtIndex:self.yearIndex],birthMonth,birthDay];
        self.gotoSrceenOrderBlock(birthday);
    }
}

#pragma mark UIPickerView Delegate Method 代理方法
//指定每行如何展示数据（此处和tableview类似）
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = [UIColor colorWithRed:0x6A/255.0 green:0x6C/255.0 blue:0x6C/255.0 alpha:1.0];
        }
    }
    
    UILabel *label = nil;
    if (pickerView.tag == 0)
    {
        if(component == 0)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(400*Rate_NAV_W, 0, 60*Rate_NAV_W, 36*Rate_NAV_H)];
            label.textAlignment = NSTextAlignmentRight;
            label.text = self.yearArray[row];
            label.font = [UIFont systemFontOfSize:22];
            if (row == self.yearIndex)
            {
                label.textColor = [UIColor colorWithRed:0x6A/255.0 green:0x6C/255.0 blue:0x6C/255.0 alpha:1.0];
            }
            else
            {
                label.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1.0];
            }
        }
        else if(component == 1)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 0, 35*Rate_NAV_W, 36*Rate_NAV_H)];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:22];
            label.text = self.monthArray[row];
            if (row == self.monthIndex)
            {
                label.textColor = [UIColor colorWithRed:0x6A/255.0 green:0x6C/255.0 blue:0x6C/255.0 alpha:1.0];
            }
            else
            {
                label.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1.0];
            }
        }
    }
    else
    {
        if(component == 0)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(400*Rate_NAV_W, 0, 60*Rate_NAV_W, 36*Rate_NAV_H)];
            label.textAlignment = NSTextAlignmentRight;
            label.text = self.yearArray[row];
            label.font = [UIFont systemFontOfSize:22];
            if (row == self.yearIndex)
            {
                label.textColor = [UIColor colorWithRed:0x6A/255.0 green:0x6C/255.0 blue:0x6C/255.0 alpha:1.0];
            }
            else
            {
                label.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1.0];
            }
        }
        else if(component == 1)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 0, 35*Rate_NAV_W, 36*Rate_NAV_H)];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:22];
            label.text = self.monthArray[row];
            if (row == self.monthIndex)
            {
                label.textColor = [UIColor colorWithRed:0x6A/255.0 green:0x6C/255.0 blue:0x6C/255.0 alpha:1.0];
            }
            else
            {
                label.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1.0];
            }
        }
        else if(component == 2)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 0, 35*Rate_NAV_W, 36*Rate_NAV_H)];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:22];
            label.text = self.dayArray[row];
            if (row == self.dayIndex)
            {
                label.textColor = [UIColor colorWithRed:0x6A/255.0 green:0x6C/255.0 blue:0x6C/255.0 alpha:1.0];
            }
            else
            {
                label.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1.0];
            }
        }
    }
    
    return label;
}

#pragma mark datePickerView的dataSource代理方法
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 0)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 100*Rate_NAV_W;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 0)
    {
        if(component==0)
        {
            return [self.yearArray count];
        }
        else
        {
            return [self.monthArray count];
        }
    }
    else
    {
        if (component == 0)
        {
            return [self.yearArray count];
        }
        else if (component == 1)
        {
            return [self.monthArray count];
        }
        else
        {
            return [self.dayArray count];
        }
    }
}

// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 0)
    {
        if (component == 0)
        {
            return self.yearArray[row];
        }
        else
        {
            return self.monthArray[row];
        }
    }
    else
    {
        if (component == 0)
        {
            return self.yearArray[row];
        }
        else if (component == 1)
        {
            return self.monthArray[row];
        }
        else
        {
            return self.dayArray[row];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 0)
    {
        if (component == 0)
        {
            self.yearIndex = row;
            if (self.yearIndex==self.year-1900)
            {
                [self.monthArray removeAllObjects];
                for (int i=1; i<=self.month; i++)
                {
                    NSString *monthStr=[NSString stringWithFormat:@"%d",i];
                    [self.monthArray addObject:monthStr];
                }
            }
            else
            {
                [self.monthArray removeAllObjects];
                for (int i=1; i<=12; i++)
                {
                    NSString *monthStr=[NSString stringWithFormat:@"%d",i];
                    [self.monthArray addObject:monthStr];
                }
            }
            [self.datePickerView reloadComponent:1];
        }
        else
        {
            self.monthIndex=row;
        }
    }
    else
    {
        if (component == 0)
        {
            self.yearIndex = row;
        }
        else if (component == 1)
        {
            self.monthIndex = row;
        }
        else
        {
            self.dayIndex = row;
        }
    }
    
    [self.datePickerView reloadAllComponents];
}

#pragma mark 功能方法
/** 显示 */
- (void)show
{
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.hidden = NO;
        
        CGRect newFrame = self.frame;
        newFrame.origin.y = SCREENHEIGHT - self.frame.size.height;
        self.frame = newFrame;
    } completion:nil];
}

/** 隐藏 */
- (void)hide
{
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        self.bgView.hidden = YES;
        
        CGRect newFrame = self.frame;
        newFrame.origin.y = SCREENHEIGHT;
        self.frame = newFrame;
    } completion:nil];
}

#pragma mark 私有方法
/** 用颜色生成一张图片 */
- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)addDayArrayValues
{
    if (self.yearIndex == self.year-1900)
    {
        if (self.monthIndex == self.month)
        {
            for (int i=1; i<=self.day; i++)
            {
                NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                [self.dayArray addObject:dayStr];
            }
        }
        else
        {
            [self addDayPart];
        }
    }
    else
    {
        [self addDayPart];
    }
}

- (void)addDayPart
{
    if (self.monthIndex == 0 || self.monthIndex == 2 || self.monthIndex == 4 || self.monthIndex == 6 || self.monthIndex == 7 || self.monthIndex == 9 || self.monthIndex == 11)
    {
        for (int i=1; i<=31; i++)
        {
            NSString *dayStr=[NSString stringWithFormat:@"%d",i];
            [self.dayArray addObject:dayStr];
        }
    }
    else if (self.monthIndex == 3 || self.monthIndex == 5 || self.monthIndex == 8 || self.monthIndex == 10)
    {
        for (int i=1; i<=30; i++)
        {
            NSString *dayStr=[NSString stringWithFormat:@"%d",i];
            [self.dayArray addObject:dayStr];
        }
    }
    else
    {
        if ((self.yearIndex%4 == 0 && self.yearIndex%100 != 0) || (self.yearIndex%100 == 0 && self.yearIndex%400 == 0))
        {
            for (int i=1; i<=29; i++)
            {
                NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                [self.dayArray addObject:dayStr];
            }
        }
        else
        {
            for (int i=1; i<=28; i++)
            {
                NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                [self.dayArray addObject:dayStr];
            }
        }
    }
}

@end
