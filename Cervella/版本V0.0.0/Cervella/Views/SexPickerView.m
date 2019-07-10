//
//  SexPickerView.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/1/12.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "SexPickerView.h"

#define mBlueColor [UIColor colorWithRed:50.0/255.0 green:162.0/255.0 blue:248.0/255.0 alpha:1.0]
#define mGrayColor [UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1.0]

@interface SexPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *bgView;
/* SexPickerView */
@property (strong, nonatomic) UIPickerView *sexPickerView;
/* 性别数组 */
@property (nonatomic, copy) NSArray *sexArray;
/* 性别选择index */
@property (nonatomic, assign) NSInteger sexIndex;

@end

@implementation SexPickerView

#pragma mark 配置视图

- (instancetype)initWith:(NSString *)sexStr
{
    self = [super init];
    if (self)
    {
        // 初始化设置
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 248*Rate_NAV_H);
        [window addSubview:self.bgView];
        [window addSubview:self];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(315*Rate_NAV_W, 11*Rate_NAV_H, 45*Rate_NAV_W, 16*Rate_NAV_H)];
        confirmBtn.backgroundColor = [UIColor whiteColor];
        [confirmBtn setTitleColor:[UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40*Rate_NAV_H, 375*Rate_NAV_W, 0.5*Rate_NAV_H)];
        lineView.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
        [self addSubview:lineView];
        
        [self preparData:sexStr];
        
        self.sexPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44*Rate_NAV_H, 375*Rate_NAV_W, 200*Rate_NAV_H)];
        self.sexPickerView.delegate = self;
        self.sexPickerView.dataSource = self;
        [self.sexPickerView selectRow:_sexIndex inComponent:0 animated:YES];
        [self addSubview:self.sexPickerView];
        
    }
    return self;
}

- (void)preparData:(NSString *)sexStr
{
    if ([sexStr isEqualToString:@"男"])
    {
        _sexIndex = 0;
        self.sexArray = @[@"男",@"女"];
    }
    else if ([sexStr isEqualToString:@"女"])
    {
        _sexIndex = 1;
        self.sexArray = @[@"男",@"女"];
    }
    else
    {
        _sexIndex = 0;
        self.sexArray = @[@"性别",@"男",@"女"];
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
    NSString *sexSelect;
    if (_sexIndex == 0)
    {
        sexSelect = @"男";
    }
    else if (_sexIndex == 1)
    {
        sexSelect = @"女";
    }
    self.gotoSrceenOrderBySexPickBlock(sexSelect);
}

#pragma mark datePickerView的dataSource代理方法
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40*Rate_NAV_H;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.sexArray.count;
}

// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.sexArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _sexIndex = row;
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

@end
