//
//  GaugeViewController.m
//  Assessment
//
//  Created by 诺之家 on 16/10/20.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "GaugeViewController.h"
#import "AppDelegate.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

#import "LiaoLiaoHomeViewController.h"
#import "SleepCircleViewController.h"
#import "ServiceHomeViewController.h"
#import "PersonalCenterViewController.h"
#import "IntroduceViewController.h"

@interface GaugeViewController ()

@property (strong, nonatomic) UIImageView *pittsburghView;
@property (strong, nonatomic) UIImageView *depressedView;
@property (strong, nonatomic) UIImageView *anxiousView;
@property (strong, nonatomic) UIImageView *bodyView;

@end

@implementation GaugeViewController
{
    NSArray *insomniaArray;
    NSArray *depressedArray;
    NSArray *anxiousArray;
    NSArray *bodyArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"量表测试"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"量表测试"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"量表测试";
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
    
    _pittsburghView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 74, SCREENWIDTH - 20, (SCREENHEIGHT - 114)/4)];
    [_pittsburghView setImage:[UIImage imageNamed:@"gauge_home_psqi"]];
    _pittsburghView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapPittsburghView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedGauge:)];
    [_pittsburghView addGestureRecognizer:tapPittsburghView];
    [self.view addSubview:_pittsburghView];
    [tapPittsburghView view].tag = 0;
    NSLog(@"%ld",[tapPittsburghView view].tag);
    
    _depressedView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 84 + (SCREENHEIGHT - 114)/4, SCREENWIDTH - 20, (SCREENHEIGHT - 114)/4)];
    [_depressedView setImage:[UIImage imageNamed:@"gauge_home_phq9"]];
    _depressedView.userInteractionEnabled = YES;
    [self.view addSubview:_depressedView];
    UITapGestureRecognizer *tapDepressedView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedGauge:)];
    [_depressedView addGestureRecognizer:tapDepressedView];
    [tapDepressedView view].tag = 1;
    NSLog(@"%ld",[tapDepressedView view].tag);
    
    _anxiousView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 94 + (SCREENHEIGHT - 114)/2, SCREENWIDTH - 20, (SCREENHEIGHT - 114)/4)];
    [_anxiousView setImage:[UIImage imageNamed:@"gauge_home_gad7"]];
    _anxiousView.userInteractionEnabled = YES;
    [self.view addSubview:_anxiousView];
    UITapGestureRecognizer *tapAnxiousView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedGauge:)];
    [_anxiousView addGestureRecognizer:tapAnxiousView];
    [tapAnxiousView view].tag = 2;
    NSLog(@"%ld",[tapAnxiousView view].tag);
    
    _bodyView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 104 + (SCREENHEIGHT - 114)*3/4, SCREENWIDTH - 20, (SCREENHEIGHT - 114)/4)];
    [_bodyView setImage:[UIImage imageNamed:@"gauge_home_phq15"]];
    _bodyView.userInteractionEnabled = YES;
    [self.view addSubview:_bodyView];
    UITapGestureRecognizer *tapBodyView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedGauge:)];
    [_bodyView addGestureRecognizer:tapBodyView];
    [tapBodyView view].tag = 3;
    NSLog(@"%ld",[tapBodyView view].tag);
    
    insomniaArray = [NSArray array];
    depressedArray = [NSArray array];
    anxiousArray = [NSArray array];
    bodyArray = [NSArray array];
    //读取plist当中问题数据
    NSString *questionStr = [[NSBundle mainBundle] pathForResource:@"QuestionPlist" ofType:@"plist"];
    NSDictionary *questionDci = [NSDictionary dictionaryWithContentsOfFile:questionStr];
    insomniaArray = [questionDci objectForKey:@"匹兹堡睡眠指数"];
    depressedArray = [questionDci objectForKey:@"抑郁自评"];
    anxiousArray = [questionDci objectForKey:@"焦虑自评"];
    bodyArray = [questionDci objectForKey:@"躯体自评"];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    if ([self.typeFlag isEqualToString:@"SucceedRegister"])
    {
        [self changeRootView];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//更换rootview，并进入首页
- (void)changeRootView
{
    //变更app的根视图控制器
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *app2 =  (AppDelegate*)app.delegate;
    
    LiaoLiaoHomeViewController *liaoLiaoHomeVC = [[LiaoLiaoHomeViewController alloc] init ];
    SleepCircleViewController *sleepCircleVC = [[SleepCircleViewController alloc] init];
    ServiceHomeViewController *serviceHomeVC = [[ServiceHomeViewController alloc] init];
    PersonalCenterViewController *personalCenterVC = [[PersonalCenterViewController alloc] init];
    
    //2.设置ViewController为根视图控制器，并将数据库当中取得的信息传递到各个控制器当中
    UITabBarController *rootView = [[UITabBarController alloc] init];
    
    UINavigationController *nc_liaoLiaoHome = [[UINavigationController alloc] initWithRootViewController:liaoLiaoHomeVC];
    nc_liaoLiaoHome.title = @"疗疗";
    nc_liaoLiaoHome.tabBarItem.image = [UIImage imageNamed:@"label_home"];
    nc_liaoLiaoHome.tabBarItem.selectedImage = [[UIImage imageNamed:@"label_home_in"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [rootView addChildViewController:nc_liaoLiaoHome];
    [nc_liaoLiaoHome.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"]forBarMetrics:UIBarMetricsDefault];
    
    UINavigationController *nc_sleepCircle = [[UINavigationController alloc] initWithRootViewController:sleepCircleVC];
    nc_sleepCircle.title = @"眠友圈";
    nc_sleepCircle.tabBarItem.image = [UIImage imageNamed:@"label_mian"];
    nc_sleepCircle.tabBarItem.selectedImage = [[UIImage imageNamed:@"label_mian_in"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [rootView addChildViewController:nc_sleepCircle];
    [nc_sleepCircle.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"]forBarMetrics:UIBarMetricsDefault];
    
    UINavigationController *nc_serviceHomel = [[UINavigationController alloc] initWithRootViewController:serviceHomeVC];
    nc_serviceHomel.title = @"客服";
    nc_serviceHomel.tabBarItem.image = [UIImage imageNamed:@"label_ke"];
    nc_serviceHomel.tabBarItem.selectedImage = [[UIImage imageNamed:@"label_ke_in"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [rootView addChildViewController:nc_serviceHomel];
    [nc_serviceHomel.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"]forBarMetrics:UIBarMetricsDefault];
    
    UINavigationController *nc_personal = [[UINavigationController alloc] initWithRootViewController:personalCenterVC];
    nc_personal.title = @"我";
    nc_personal.tabBarItem.image = [UIImage imageNamed:@"label_profile"];
    nc_personal.tabBarItem.selectedImage = [[UIImage imageNamed:@"label_profile_in"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [rootView addChildViewController:nc_personal];
    [nc_personal.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"]forBarMetrics:UIBarMetricsDefault];
    
    //    设置tabbar 风格
    rootView.tabBar.barStyle = UIBarStyleDefault;
    //    点击颜色
    rootView.tabBar.tintColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1.0];
    //    背景色
    rootView.tabBar.barTintColor = [UIColor whiteColor];
    //    字体大小
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:TableBar_Font} forState:UIControlStateNormal];
    
    app2.window.rootViewController = rootView;
    app2.window.backgroundColor = [UIColor whiteColor];
    [app2.window makeKeyAndVisible];
}

- (void)selectedGauge:(UITapGestureRecognizer *)gesture
{
    if ([gesture view].tag == 0)
    {
        //跳转到量表测试介绍并开始测试界面（匹兹堡睡眠指数PSQI）
        IntroduceViewController *pittsburghIntroduceVC = [[IntroduceViewController alloc] init];
        pittsburghIntroduceVC.questionArray = insomniaArray;
        pittsburghIntroduceVC.typeFlag = _typeFlag;
        pittsburghIntroduceVC.typeStr = @"匹兹堡睡眠指数";
        
        [self.navigationController pushViewController:pittsburghIntroduceVC animated:YES];
    }
    else if ([gesture view].tag ==1)
    {
        //跳转到量表测试介绍并开始测试界面（抑郁自评GAD－7）
        IntroduceViewController *depressedIntroduceVC = [[IntroduceViewController alloc] init];
        depressedIntroduceVC.questionArray = depressedArray;
        depressedIntroduceVC.typeFlag = _typeFlag;
        depressedIntroduceVC.typeStr = @"抑郁自评";
        
        [self.navigationController pushViewController:depressedIntroduceVC animated:YES];
    }
    else if ([gesture view].tag ==2)
    {
        //跳转到量表测试介绍并开始测试界面（焦虑自评PHQ－9）
        IntroduceViewController *anxiousIntroduceVC = [[IntroduceViewController alloc] init];
        anxiousIntroduceVC.questionArray = anxiousArray;
        anxiousIntroduceVC.typeFlag = _typeFlag;
        anxiousIntroduceVC.typeStr = @"焦虑自评";
        
        [self.navigationController pushViewController:anxiousIntroduceVC animated:YES];
    }
    else if ([gesture view].tag ==3)
    {
        //跳转到量表测试介绍并开始测试界面（躯体自评PHQ－15）
        IntroduceViewController *bodyIntroduceVC = [[IntroduceViewController alloc] init];
        bodyIntroduceVC.questionArray = bodyArray;
        bodyIntroduceVC.typeFlag = _typeFlag;
        bodyIntroduceVC.typeStr = @"躯体自评";
        
        [self.navigationController pushViewController:bodyIntroduceVC animated:YES];
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
