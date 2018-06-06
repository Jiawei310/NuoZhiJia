//
//  SucceedRegisterViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/2.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SucceedRegisterViewController.h"
#import "AppDelegate.h"
#import "Define.h"

#import "LiaoLiaoHomeViewController.h"
#import "SquareViewController.h"
#import "ServiceHomeViewController.h"
#import "PersonalCenterViewController.h"
#import "GaugeViewController.h"

@interface SucceedRegisterViewController ()

@end

@implementation SucceedRegisterViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"注册成功";
    [self.navigationItem setHidesBackButton:YES];
    
    UIButton *succeedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    succeedBtn.frame = CGRectMake(SCREENWIDTH - 42, 30, 32, 19);
    [succeedBtn setTitle:@"完成" forState:UIControlStateNormal];
    [succeedBtn addTarget:self action:@selector(succeedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *succeedButtonItem = [[UIBarButtonItem alloc] initWithCustomView:succeedBtn];
    self.navigationItem.rightBarButtonItem = succeedButtonItem;
    
}

//测试健康状况按钮点击事件
- (IBAction)testHealthConditionClick:(UIButton *)sender
{
    //跳转到量表评估界面
    GaugeViewController *gaugeVC = [[GaugeViewController alloc] init];
    gaugeVC.typeFlag = @"SucceedRegister";
    [self.navigationController pushViewController:gaugeVC animated:YES];
}

//直接开始疗疗按钮点击事件
- (IBAction)startDirectlyClick:(UIButton *)sender
{
    [self changeRootView];
}

//导航栏右侧完成按钮点击事件
- (void)succeedBtnClick:(UIButton *)sender
{
    [self changeRootView];
}

- (void)changeRootView
{
    //变更app的根视图控制器
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *app2 =  (AppDelegate*)app.delegate;
    
    LiaoLiaoHomeViewController *liaoLiaoHomeVC = [[LiaoLiaoHomeViewController alloc] init ];
    SquareViewController *squareVC = [[SquareViewController alloc] init];
    ServiceHomeViewController *serviceHomeVC = [[ServiceHomeViewController alloc] init];
    PersonalCenterViewController *personalCenterVC = [[PersonalCenterViewController alloc] init];
    
    //2.设置ViewController为根视图控制器，并将数据库当中取得的信息传递到各个控制器当中
    UITabBarController *rootView = [[UITabBarController alloc] init];
    
    UINavigationController *nc_liaoLiaoHome = [[UINavigationController alloc] initWithRootViewController:liaoLiaoHomeVC];
    nc_liaoLiaoHome.title = @"首页";
    nc_liaoLiaoHome.tabBarItem.image = [UIImage imageNamed:@"label_home"];
    nc_liaoLiaoHome.tabBarItem.selectedImage = [[UIImage imageNamed:@"label_home_in"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [rootView addChildViewController:nc_liaoLiaoHome];
    [nc_liaoLiaoHome.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"]forBarMetrics:UIBarMetricsDefault];
    
    UINavigationController *nc_sleepCircle = [[UINavigationController alloc] initWithRootViewController:squareVC];
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
    
    //设置tabbar 风格
    rootView.tabBar.barStyle = UIBarStyleDefault;
    //点击颜色
    rootView.tabBar.tintColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1.0];
    //背景色
    rootView.tabBar.barTintColor = [UIColor whiteColor];
    //字体大小
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:TableBar_Font} forState:UIControlStateNormal];
    
    app2.window.rootViewController = rootView;
    app2.window.backgroundColor = [UIColor whiteColor];
    [app2.window makeKeyAndVisible];
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
