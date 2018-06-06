//
//  ProtocolViewController.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/6/19.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "ProtocolViewController.h"
#import "Define.h"

#import "InterfaceModel.h"

#import "EMClient.h"
#import "JXTAlertManagerHeader.h"

#import "SucceedRegisterViewController.h"

@interface ProtocolViewController ()<InterfaceModelDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, strong) PatientInfo *patientInfo;

@end

@implementation ProtocolViewController
{
    BOOL isOverTime;       //用来标志是否注册超时
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
    
    _patientInfo = [PatientInfo shareInstance];
    
    [self createContentView];
}

//返回按钮点击事件
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
    topLabel.text = @"疗疗失眠APP用户注册协议";
    topLabel.textColor = [UIColor whiteColor];
    [topBackgroundView addSubview:topLabel];
    
    /* 内容部分 */
    //内容读取
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"plist"];
    NSDictionary *contentDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *contentStr = [contentDic objectForKey:@"contentRegister"];
    
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
    //添加Loading
    jxt_showLoadingHUDTitleMessage(@"登录", @"Loading...");
    isOverTime = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(overTimeOpration) userInfo:nil repeats:NO];
    //借口请求，后台添加账号
    InterfaceModel *interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
    [interfaceModel sendJsonRegisterInfoToServer:_patientInfo];
}

- (IBAction)disAgreeBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeLogin)
    {
        isOverTime = NO;
        
        _patientInfo = value;
        //隐藏Loading
        jxt_dismissHUD();
        
#pragma mark ------- 注册环信
        [[EMClient sharedClient] registerWithUsername:_patientInfo.PatientID password:Hyphenate_PassWord];
        //跳转到注册成功界面
        SucceedRegisterViewController *succeedRegisterVC = [[SucceedRegisterViewController alloc] init];
        [self.navigationController pushViewController:succeedRegisterVC animated:YES];
    }
}

- (void)overTimeOpration
{
    if (isOverTime)
    {
        //隐藏Loading
        jxt_dismissHUD();
        jxt_showAlertTitle(@"登录超时");
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
