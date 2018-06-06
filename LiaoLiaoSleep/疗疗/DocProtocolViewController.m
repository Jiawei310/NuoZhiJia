//
//  DocProtocolViewController.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/6/19.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "DocProtocolViewController.h"
#import "Define.h"

#import "DoctorHomeViewController.h"

@interface DocProtocolViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;

@end

@implementation DocProtocolViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"]forBarMetrics:UIBarMetricsDefault];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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

#pragma mark -- 返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createContentView
{
    /* 协议头部 */
    UIView *topBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 10*Rate_NAV_H, SCREENWIDTH, 60*Rate_NAV_H)];
    topBackgroundView.backgroundColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    [_contentScrollView addSubview:topBackgroundView];
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 10*Rate_NAV_H, 345*Rate_NAV_W, 40*Rate_NAV_H)];
    topLabel.font = [UIFont systemFontOfSize:22*Rate_NAV_H];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = @"问医生在线咨询服务协议";
    topLabel.textColor = [UIColor whiteColor];
    [topBackgroundView addSubview:topLabel];
    
    /* 内容部分 */
    //内容读取
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"plist"];
    NSDictionary *contentDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *contentStr = [contentDic objectForKey:@"contentDoc"];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 80*Rate_NAV_H, 355*Rate_NAV_W, 553*Rate_NAV_H)];
    contentLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    contentLabel.text = contentStr;
    contentLabel.textAlignment = NSTextAlignmentJustified;
    contentLabel.numberOfLines = 0;
    
    NSDictionary *dic = @{NSKernAttributeName:@1.5f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:contentStr attributes:dic];
    contentLabel.attributedText = attributeStr;
    CGSize adviseContentLabelSize = [contentLabel sizeThatFits:CGSizeMake(355*Rate_NAV_W, MAXFLOAT)];
    contentLabel.frame = CGRectMake(10*Rate_NAV_W, 80*Rate_NAV_H, 355*Rate_NAV_W, adviseContentLabelSize.height);
    [_contentScrollView addSubview:contentLabel];
    
    _contentScrollView.contentSize = CGSizeMake(SCREENWIDTH, 80*Rate_NAV_H + adviseContentLabelSize.height);
}

- (IBAction)agreeBtnClick:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DoctorFirstStart"];
    
    DoctorHomeViewController *doctorVC = [[DoctorHomeViewController alloc] init];
    [self.navigationController pushViewController:doctorVC animated:YES];
}

- (IBAction)disAgreeBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
