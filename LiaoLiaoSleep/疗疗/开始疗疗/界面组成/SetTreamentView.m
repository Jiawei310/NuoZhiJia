//
//  SetTreamentView.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/23.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SetTreamentView.h"
#import "SetTreatmentViewController.h"

@implementation SetTreamentView

- (instancetype)initWithFrame:(CGRect)frame andInfoList:(NSArray *)infoList
{
    if (self == [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0.21 green:0.76 blue:0.87 alpha:1.00];
        self.userInteractionEnabled = YES;
        [self customerViewWithFrame:frame andInfoList:infoList];
    }
    
    return self;
}

- (void)customerViewWithFrame:(CGRect)frame andInfoList:(NSArray *)infoList
{
    UIImageView * imageV = [[UIImageView alloc] initWithFrame:CGRectMake(60, 30, 50, 50)];
    imageV.image = [UIImage imageNamed:@"icon_疗程.png"];
    [self addSubview:imageV];
    
    UILabel * lable1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame)+5, 30, frame.size.width-125, 25)];
    lable1.text = @"疗程能帮助您更科学的治疗";
    lable1.adjustsFontSizeToFitWidth = YES;
    lable1.textColor = [UIColor whiteColor];
    [self addSubview:lable1];
    
    UILabel * lable2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame)+5, CGRectGetMaxY(lable1.frame)+10, frame.size.width-125, 20)];
    lable2.text = @"是否开始属于您的疗程?";
    lable2.textColor = [UIColor whiteColor];
    lable2.adjustsFontSizeToFitWidth = YES;
    [self addSubview:lable2];
    
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width-100)/2, CGRectGetMaxY(lable2.frame)+20, 100, 30)];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.cornerRadius = 5;
    [button setTitle:@"开始治疗" forState:(UIControlStateNormal)];
    //跳转至设置疗程
    [button addTarget:self action:@selector(startCure) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:button];
}

- (UIViewController *)viewController:(UIView *)view
{
    UIResponder *responder = view;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    
    return nil;
}

#pragma mark --- 设置疗程
- (void)startCure
{
    _superVC = [self viewController:self];
    //跳转至设置疗程界面
    SetTreatmentViewController *setVC = [[SetTreatmentViewController alloc] init];
    setVC.hidesBottomBarWhenPushed = YES;
    [_superVC.navigationController pushViewController:setVC animated:YES];
}

@end
