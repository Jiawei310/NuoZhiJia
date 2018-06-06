//
//  ScaleTestViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/24.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "ScaleTestViewController.h"
#import "GaugeViewController.h"

#import <UMMobClick/MobClick.h>

#import "Define.h"

@interface ScaleTestViewController ()

@end

@implementation ScaleTestViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"] forBarMetrics:(UIBarMetricsDefault)];
    //隐藏选项卡
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"量表评估"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"量表评估"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"量表评估";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
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
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 10*Rate_NAV_H, 355*Rate_NAV_W, 417*Rate_NAV_H)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UILabel *introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 10*Rate_NAV_H, 40*Rate_NAV_W, 25*Rate_NAV_H)];
    introduceLabel.textAlignment = NSTextAlignmentLeft;
    introduceLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    introduceLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    introduceLabel.text = @"简介";
    [bgView addSubview:introduceLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 43*Rate_NAV_H, 325*Rate_NAV_W, 100*Rate_NAV_H)];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    contentLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    contentLabel.numberOfLines = 0;
    
    NSString *strText = [NSString stringWithFormat:@"“我要测试”按钮点击可进入量表测试列表界面，用户可选择需要进行测试的量表，来测试自己的睡眠状况以及影响睡眠治疗的原因。\n\n“测试报告”按钮点击可进入四种量表测试结果的大体趋势图，详细趋势图需在界面中选择哪种量表，同时详情界面还可查看每次评估的详细数据，便于用户了解自身睡眠状况。"];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 3; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距
    NSDictionary *dic = @{NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:strText attributes:dic];
    contentLabel.attributedText = attributeStr;
    
    CGSize adviseContentLabelSize = [contentLabel sizeThatFits:CGSizeMake(345*Rate_NAV_W, MAXFLOAT)];
    contentLabel.frame = CGRectMake(15*Rate_NAV_W, 50*Rate_NAV_H, 345*Rate_NAV_W, adviseContentLabelSize.height);
    
    [bgView addSubview:contentLabel];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 500*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [testBtn setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
    testBtn.layer.cornerRadius = 25*Rate_NAV_H;
    [testBtn setTitle:@"我要测试" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    testBtn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [testBtn addTarget:self action:@selector(testBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)testBtnClick:(UIButton *)sender
{
    //跳转到量表测试界面
    GaugeViewController *gaugeVC = [[GaugeViewController alloc] init];
    gaugeVC.typeFlag = @"ScaleTest";
    [self.navigationController pushViewController:gaugeVC animated:YES];
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
