//
//  SettingViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/23.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SettingViewController.h"
#import "EMClient.h"
#import "AppDelegate.h"
#import "Define.h"
#import "DataBaseOpration.h"

#import <UMMobClick/MobClick.h>

#import "GoodsInfoViewController.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *markTableView;
@property (strong, nonatomic) UITableView *settingTableView;
@property (strong, nonatomic) UIButton *exitLoginBtn;

@end

@implementation SettingViewController
{
    UIAlertView *alert; //用于显示提示信息的全局变量
}

- (void)viewWillAppear:(BOOL)animated
{
    //让下方tabbar隐藏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"设置"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"设置"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"设置";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.exitLoginBtn.layer.cornerRadius = 5;
    
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
    
    [self createSettingTableView];
    
    _exitLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 523*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [_exitLoginBtn setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
    _exitLoginBtn.layer.cornerRadius = 25*Rate_NAV_H;
    _exitLoginBtn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_exitLoginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_exitLoginBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [_exitLoginBtn addTarget:self action:@selector(exitLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_exitLoginBtn];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createSettingTableView
{
    _markTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10*Rate_NAV_H, 375*Rate_NAV_W, 50*Rate_NAV_H)];
    _markTableView.tag = 0;
    if ([_markTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _markTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_markTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    _markTableView.delegate = self;
    _markTableView.dataSource = self;
    [self.view addSubview:_markTableView];
    
    _settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 67*Rate_NAV_H, 375*Rate_NAV_W, 100*Rate_NAV_H)];
    _settingTableView.tag = 1;
    if ([_settingTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _settingTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_settingTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    _settingTableView.delegate = self;
    _settingTableView.dataSource = self;
    [self.view addSubview:_settingTableView];
}

#pragma tableview的delegate、dataSource代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0)
    {
        return 1;
    }
    else if (tableView.tag == 1)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Rate_NAV_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (tableView.tag == 0)
    {
        cell.textLabel.text = @"为疗疗失眠打分";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (tableView.tag == 1)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"清除缓存";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row ==1)
        {
            cell.textLabel.text = @"关于";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 0)
    {
        //为疗疗打分，跳转到App Store
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1060524805&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
    }
    else
    {
        if (indexPath.row == 0)
        {
            //清除缓存
            //提示“清除成功”
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"清除成功" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
        else if (indexPath.row == 1)
        {
            //关于
            GoodsInfoViewController *infoVC  = [[GoodsInfoViewController alloc] init];
            [self.navigationController pushViewController:infoVC animated:YES];
        }
    }
    
}

- (IBAction)exitLoginBtnClick:(UIButton *)sender
{
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"是否切换用户？" message:nil delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    
    alertView.tag=0;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==0)
    {
        if (buttonIndex==0)
        {
            [MobClick profileSignOff];
            //退出环信
            [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
                if (!aError)
                {
                    NSLog(@"退出成功");
                }
            }];
            
            //切换账号
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
            //清除缓存（例：绑定刺激仪后，切换用户，不断开外设以及清楚缓存，刺激仪将一致处于连接状态）
            NSNotification *notification=[NSNotification notificationWithName:@"ChangeUser" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //删除本地数据库蓝牙绑定信息
            DataBaseOpration *dbOpration=[[DataBaseOpration alloc] init];
            [dbOpration deletePeripheralInfo];
            
            //调用AppDelegate的代理方法，切换根视图
            UIApplication *app=[UIApplication sharedApplication];
            AppDelegate *appDelegate=(AppDelegate *)app.delegate;
            [appDelegate application:app didFinishLaunchingWithOptions:nil];
        }
    }
}

//alertview自动消失
- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
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
