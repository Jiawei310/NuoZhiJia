//
//  ServiceHomeViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "ServiceHomeViewController.h"
#import "Define.h"

#import "EMClient.h"
#import <UMMobClick/MobClick.h>
#import "ServiceChatViewController.h"      //在线客服
#import "InstructionsViewController.h"     //使用说明

@interface ServiceHomeViewController ()<UIAlertViewDelegate,EMChatManagerDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (nonatomic, strong) UIView *firstView;  //视图标题介绍部分
@property (nonatomic, strong) UIView *secondView; //在线客服部分
@property (nonatomic, strong) UIView *thirdView;  //使用说明部分
@property (nonatomic, copy) NSString *unreadCount;//被选中是左边标志

@end

@implementation ServiceHomeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tabBarController.tabBar.hidden = NO;
    
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:Service_ID type:EMConversationTypeChat createIfNotExist:YES];
    _unreadCount = [NSString stringWithFormat:@"%d",[conversation unreadMessagesCount]];
    if ([_unreadCount intValue] > 0)
    {
        self.tabBarController.tabBarItem.badgeValue = _unreadCount;
        self.tabBarItem.badgeColor = [UIColor redColor];
        self.navigationController.tabBarItem.badgeValue = _unreadCount;
    }
    else
    {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    
    [MobClick beginLogPageView:@"客服帮助"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"客服帮助"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"客服帮助";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    
    _patientInfo = [PatientInfo shareInstance];
    
    [self createFirstView];
    [self createSecondView];
    [self createThirdView];
    // Do any additional setup after loading the view.
    
    //注册个人信息修改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePatientInfo:) name:@"patientInfoChange" object:nil];
}

//个人信息修改通知方法
- (void)changePatientInfo:(NSNotification *)notification
{
    _patientInfo = [notification.userInfo objectForKey:@"patientInfo"];
}

/**
 *  创建第一部分视图
 *  包括标题、客服电话、客服服务时间
 */
- (void)createFirstView
{
    UILabel *lable  = [[UILabel alloc] initWithFrame:CGRectMake(40*Rate_W, 20*Rate_H, SCREENWIDTH - 80*Rate_W, 20*Rate_H)];
    lable.text = @"使用疗疗时遇到困难?没关系，让我们来帮您";
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = Service_TitleFont;
    [self.view addSubview:lable];
    
    //视图框架
    _firstView = [[UIView alloc] initWithFrame:CGRectMake(10*Rate_W, 60*Rate_H, SCREENWIDTH - 20*Rate_H, 40*Rate_H)];
    _firstView.layer.cornerRadius = 10;
    _firstView.clipsToBounds = YES;
    _firstView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_firstView];
    
    
    //热线电话
    UILabel *calllable = [[UILabel alloc] init];
    calllable.text = @"您可以直接拨打客服热线:";
    calllable.font = Service_PhoneFont;
    calllable.frame = CGRectMake(22*Rate_W, 9*Rate_H,197*Rate_W, 22*Rate_H);
    [_firstView addSubview:calllable];
    
    //电话号码
    UIButton *phoneBtn = [[UIButton alloc]init];
    [phoneBtn setTitle:@"4006800270" forState:(UIControlStateNormal)];
    phoneBtn.titleLabel.font = Service_PhoneFont;
    [phoneBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    //点击号码呼叫客服
    [phoneBtn addTarget:self action:@selector(CallService:) forControlEvents:(UIControlEventTouchUpInside)];
    phoneBtn.frame = CGRectMake(CGRectGetMaxX(calllable.frame), 9*Rate_H, 115*Rate_W, 22*Rate_H);
    [_firstView addSubview:phoneBtn];
    
    //客服时间
    UILabel * lable2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 145*Rate_H, SCREENWIDTH, 10*Rate_H)];
    lable2.textAlignment = NSTextAlignmentCenter;
    lable2.text = @"客服服务时间：9：00 - 18：00";
    lable2.font = Service_TimeFont;
    [_firstView addSubview:lable2];
    
}

//呼叫客服
- (void)CallService:(UIButton *)sender
{
    NSDate *currentDate = [NSDate date];//获取当前时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    //若时间超过客服上班时间，则出现提示框
    if ([dateString intValue] < 9 || [dateString intValue] >= 18)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"抱歉，客服下班了" message:@"我们的客服工作时间:9：00-18：00" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
    else//若在客服工作时间，则呼叫客服
    {
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"tel:%@",sender.titleLabel.text];
        UIWebView *callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
}

- (void)createSecondView
{
    //第二部分视图框架
    _secondView = [[UIView alloc] initWithFrame:CGRectMake(10*Rate_W, CGRectGetMaxY(_firstView.frame) + 10*Rate_H, SCREENWIDTH - 20*Rate_W, 110*Rate_W)];
    [self.view addSubview:_secondView];
    
    //点击跳转至在线客服界面
    UIButton *btn = [[UIButton alloc] initWithFrame:_secondView.bounds];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_service.png"] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(clickService) forControlEvents:(UIControlEventTouchUpInside)];
    [_secondView addSubview:btn];
}

//跳转至客服界面
- (void)clickService
{
    ServiceChatViewController *serviceVC  = [[ServiceChatViewController alloc] initWithConversationChatter:Service_ID];
    serviceVC.nickName = _patientInfo.PatientName;
    serviceVC.HeaderImage = _patientInfo.PhotoUrl;
    serviceVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:serviceVC animated:YES];
}

//创建第三部分视图
- (void)createThirdView
{
    //第三部分视图框架
    _thirdView = [[UIView alloc]initWithFrame:CGRectMake(10*Rate_W, CGRectGetMaxY(_secondView.frame) + 20*Rate_H, SCREENWIDTH - 20*Rate_W, 110*Rate_W)];
    [self.view addSubview:_thirdView];
    
    //点击跳转至使用帮助界面
    UIButton *btn = [[UIButton alloc]initWithFrame:_thirdView.bounds];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_explain.png"] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(clickHelp) forControlEvents:(UIControlEventTouchUpInside)];
    [_thirdView addSubview:btn];
}

//跳转至使用帮助界面
- (void)clickHelp
{
    InstructionsViewController *VC = [[InstructionsViewController alloc] init];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)messagesDidReceive:(NSArray *)aMessages
{
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:2];
    NSInteger count = [item.badgeValue integerValue];
    item.badgeValue = [NSString stringWithFormat:@"%li",count+1];
    if(count > 99)
    {
        item.badgeValue = @"99+";
    }
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
