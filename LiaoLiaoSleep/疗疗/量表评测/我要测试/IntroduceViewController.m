//
//  IntroduceViewController.m
//  Assessment
//
//  Created by 诺之家 on 16/10/20.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "IntroduceViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

#import "GaugeTestViewController.h"

@interface IntroduceViewController ()


@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *introduceImageView;

@property (strong, nonatomic) IBOutlet UILabel *staticLabelOne;
@property (strong, nonatomic) IBOutlet UITextView *introductionTextView;
@property (strong, nonatomic) IBOutlet UILabel *staticLabelTwo;

@property (strong, nonatomic) IBOutlet UILabel *introduceLabel;
@property (strong, nonatomic) IBOutlet UITextView *whyDoTextView;

@end

@implementation IntroduceViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"量表介绍"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"量表介绍"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    
    [self createContentView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createContentView
{
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 10*Rate_NAV_H, 355*Rate_NAV_W, 500*Rate_NAV_H)];
    _containerView.layer.cornerRadius = 4;
    _containerView.layer.borderWidth = 0.5;
    _containerView.layer.borderColor = [UIColor colorWithRed:0xDE/255.0 green:0xE4/255.0 blue:0xE7/255.0 alpha:1].CGColor;
    [self.view addSubview:_containerView];
    
    _introduceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 355*Rate_NAV_W, 136*Rate_NAV_H)];
    [_containerView addSubview:_introduceImageView];
    
    _staticLabelOne = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 149*Rate_NAV_H, 40*Rate_NAV_W, 25*Rate_NAV_H)];
    _staticLabelOne.text = @"简介";
    _staticLabelOne.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    _staticLabelOne.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_containerView addSubview:_staticLabelOne];
    
    _introductionTextView = [[UITextView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 182*Rate_NAV_H, 325*Rate_NAV_H, 100*Rate_NAV_H)];
    _introductionTextView.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    _introductionTextView.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_containerView addSubview:_introductionTextView];
    
    _staticLabelTwo = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 302*Rate_NAV_H, 150
                                                                *Rate_NAV_W, 25*Rate_NAV_H)];
    _staticLabelTwo.text = @"我为什么要做这个";
    _staticLabelTwo.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    _staticLabelTwo.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_containerView addSubview:_staticLabelTwo];
    
    _introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 336*Rate_NAV_H, 325*Rate_NAV_W, 40*Rate_NAV_H)];
    _introduceLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    _introduceLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    _introduceLabel.numberOfLines = 0;
    [_containerView addSubview:_introduceLabel];
    
    _whyDoTextView = [[UITextView alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 393*Rate_NAV_H, 335*Rate_NAV_W, 78*Rate_NAV_H)];
    _whyDoTextView.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    _whyDoTextView.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_containerView addSubview:_whyDoTextView];
    
    
    if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
    {
        self.navigationItem.title = @"匹兹堡睡眠指数 PSQI";
        _introduceImageView.image = [UIImage imageNamed:@"gauge_home_psqi"];
        _introductionTextView.text = @"匹兹堡睡眠质量指数（Pittsburgh sleep quality index,PSQI）是美国匹兹堡大学精神科医生Buysse博士等人于1989年编制的。该量表适用于睡眠障碍患者、精神障碍患者评价睡眠质量，同时也适用于一般人睡眠质量的评估。";
        _introduceLabel.text = @"该量表是睡眠质量与心身健康相关性研究的评定工具，完成该量表，您将：";
        _whyDoTextView.text = @"1. 了解自我的睡眠状况；\n2. 睡眠指数管理，掌握自我睡眠状况的变化；\n3. 和医生交流时提供数据支撑；";
    }
    else if ([_typeStr isEqualToString:@"抑郁自评"])
    {
        self.navigationItem.title = @"抑郁自评 PHQ-9";
        _introduceImageView.image = [UIImage imageNamed:@"gauge_home_phq9"];
        _introductionTextView.text = @"抑郁自评（Patient Health Questionnaire - 9）是基于DSM-IV的诊断标准而修订的关于抑郁的一个筛查表。该量表主要适用于具有抑郁症状的成年人。";
        _introduceLabel.text = @"该量表是评定心身健康的工具，辅助评判你睡眠质量是否受到抑郁影响的依据，完成该量表，您将：";
        _whyDoTextView.text = @"1. 直观地反映自身的主观感受；\n2. 评判自己的睡眠质量是否受抑郁所干扰；\n3. 和医生交流时提供数据支撑；";
    }
    else if ([_typeStr isEqualToString:@"焦虑自评"])
    {
        self.navigationItem.title = @"焦虑自评 GAD-7";
        _introduceImageView.image = [UIImage imageNamed:@"gauge_home_gad7"];
        _introductionTextView.text = @"焦虑自评（Generalised Anxiety Disorder - 7）是一种分析患者主观症状的临床工具，可用于广泛性焦虑的筛查及症状严重度的评估。适用于具有焦虑症状的成年人。";
        _introduceLabel.text = @"该量表是评定心身健康的工具，完成该量表，您将：";
        _whyDoTextView.text = @"1. 评估得知自己症状的严重度；\n2. 评判自己的睡眠质量是否受焦虑所干扰；\n3. 和医生交流时提供数据支撑；";
    }
    else if ([_typeStr isEqualToString:@"躯体自评"])
    {
        self.navigationItem.title = @"躯体自评 PHQ-15";
        _introduceImageView.image = [UIImage imageNamed:@"gauge_home_phq15"];
        _introductionTextView.text = @"躯体（Patient Health Questionnaire - 15）是PHQ的一个组成部分，该量表共有15个项目，包含有较广泛的精神病症状学内容，从感觉、意识、行为、饮食睡眠等，均有涉及，并从不同侧面反映各种职业群体的心理卫生问题。";
        _introduceLabel.text = @"该量表是评定心身健康的工具，完成该量表，您将：";
        _whyDoTextView.text = @"1. 评估得知自己症状的表现；\n2. 评判自己的睡眠质量受其中的哪些症状所干扰；\n3. 和医生交流时提供数据支撑；";
    }
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 532*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [testBtn setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
    testBtn.layer.cornerRadius = 25*Rate_NAV_H;
    testBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [testBtn setTitle:@"开始测试" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(startToTestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (void)startToTestBtnClick:(UIButton *)sender
{
    //根据typeLabel的值进入对应测试量表
    GaugeTestViewController *gaugeTestVC = [[GaugeTestViewController alloc] init];
    gaugeTestVC.typeFlag = _typeFlag;
    gaugeTestVC.typeStr = _typeStr;
    gaugeTestVC.questionArray = self.questionArray;
    
    [self.navigationController pushViewController:gaugeTestVC animated:YES];
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
