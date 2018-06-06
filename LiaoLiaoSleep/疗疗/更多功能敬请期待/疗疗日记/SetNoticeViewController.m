//
//  SetNoticeViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/20.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SetNoticeViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>
#import "SetTreatmentViewController.h"

@interface SetNoticeViewController ()

@end

@implementation SetNoticeViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    
    [MobClick beginLogPageView:@"疗程"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"疗程"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加返回按钮
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    backLogin.frame = CGRectMake(12, 30, 23, 23);
    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    
    [self createNoticeView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createNoticeView
{
    UIButton *btnOne = [[UIButton alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 10*Rate_NAV_H, 355*Rate_NAV_W, 40*Rate_NAV_H)];
    btnOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    btnOne.layer.cornerRadius = 4;
    [btnOne setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnOne.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [btnOne setTitle:@"设置疗程才能激活日记功能哦！" forState:UIControlStateNormal];
    btnOne.userInteractionEnabled = NO;
    [self.view addSubview:btnOne];
    
    UILabel *setLable = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 65*Rate_NAV_H, 120*Rate_NAV_W, 25*Rate_NAV_H)];
    setLable.text = @"设置一个疗程";
    setLable.textColor = [UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1.0];
    setLable.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [self.view addSubview:setLable];

    UILabel *setInfoLable  =[[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 100*Rate_NAV_H, 331*Rate_NAV_W, 70*Rate_NAV_H)];
    setInfoLable.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    NSString *cLabelString = @"标准疗程为4周,每天使用两次，建议上午下午各一次，时间间隔3小以上，因个体差异，疗疗失眠一般不超过3个疗程。";
    setInfoLable.numberOfLines = 0;
    setInfoLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:cLabelString];
    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:8];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [cLabelString length])];
    [setInfoLable setAttributedText:attributedString1];
    [setInfoLable sizeToFit];
    [self.view addSubview:setInfoLable];
    
    UILabel *setReasonLable = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 191*Rate_NAV_H, 181*Rate_NAV_W, 25*Rate_NAV_H)];
    setReasonLable.text = @"为什么要设置疗程？";
    setReasonLable.textColor = [UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1.0];
    setReasonLable.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [self.view addSubview:setReasonLable];
    
    UILabel *setReasonInfoLable  =[[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 226*Rate_NAV_H, 331*Rate_NAV_W, 70*Rate_NAV_H)];
    setReasonInfoLable.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    NSString *cLabelString2 = @"标准疗程为4周,每天使用两次，建议上午下午各一次，时间间隔3小以上，因个体差异，疗疗失眠一般不超过3个疗程。";
    setReasonInfoLable.numberOfLines = 0;
    setReasonInfoLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:cLabelString2];
    NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle2 setLineSpacing:8];
    [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [cLabelString2 length])];
    [setReasonInfoLable setAttributedText:attributedString2];
    [self.view addSubview:setReasonInfoLable];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - 205)/2, 538*Rate_NAV_H, 205, 43)];
    [btn setTitle:@"新设一个疗程" forState:(UIControlStateNormal)];
    [btn setBackgroundImage:[UIImage imageNamed:@"treatment_btn_bg"] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(Click) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
}

- (void)Click
{
    SetTreatmentViewController * setVC = [[SetTreatmentViewController alloc] init];
    setVC.VCType = @"设置疗程";
    [self.navigationController pushViewController:setVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
