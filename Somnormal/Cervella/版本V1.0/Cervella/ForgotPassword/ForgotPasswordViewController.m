//
//  ForgotPasswordViewController.m
//  Cervella
//
//  Created by Justin on 2017/6/27.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "ResetViewController.h"

#import "TypeDefine.h"

#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@interface ForgotPasswordViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SKPSMTPMessageDelegate>

@property (strong, nonatomic) IBOutlet UITableView *FPTableView;
@property (strong, nonatomic) IBOutlet UIButton *sendCodeBtn;

@property (strong, nonatomic) IBOutlet UILabel *alertLabel;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation ForgotPasswordViewController
{
    NSString *randCode;
    
    NSTimer *m_timer; //设置验证按钮计时器
    int secondsCountDown;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Get Back Password";
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
    
    _FPTableView.scrollEnabled =NO; //设置tableview不能滚动
    _FPTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _FPTableView.delegate = self;
    _FPTableView.dataSource = self;
    
    _alertLabel.hidden = YES;
    _codeTextField.hidden = YES;
    _confirmBtn.hidden = YES;
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma loginTableView -- delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma loginTableView -- dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF4/255.0 blue:0xF4/255.0 alpha:1.0];
    if (indexPath.row == 0)
    {
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREENWIDTH - 20, 30)];
        tmpLabel.textAlignment = NSTextAlignmentCenter;
        tmpLabel.text = @"Your identifying code will be sent to your email:";
        tmpLabel.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:tmpLabel];
    }
    else
    {
        UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREENWIDTH - 20, 30)];
        emailLabel.textAlignment = NSTextAlignmentCenter;
        emailLabel.text = _patientInfo.Email;
        [cell.contentView addSubview:emailLabel];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (IBAction)sendCodeBtnClick:(UIButton *)sender
{
    //发送邮件
    [self sendCodeOpration];
    //按钮倒计时开始
    //做90秒倒计时
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calcuRemainTime) userInfo:nil repeats:YES];
    secondsCountDown = 90;
    [sender setBackgroundColor:[UIColor colorWithRed:0xAA/255.0 green:0xAA/255.0 blue:0xAA/255.0 alpha:1.0]];
    sender.userInteractionEnabled = NO;
    //显示隐藏的控件
    _alertLabel.hidden = NO;
    _codeTextField.hidden = NO;
    _confirmBtn.hidden = NO;
}

- (void)calcuRemainTime
{
    secondsCountDown--;
    NSString *strTime = [NSString stringWithFormat:@"%.2ds", secondsCountDown];
    [_sendCodeBtn setTitle:strTime forState:UIControlStateNormal];
    if (secondsCountDown <= 0)
    {
        [m_timer invalidate];
        [_sendCodeBtn setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7E/255.0 blue:0xD6/255.0 alpha:1.0]];
        [_sendCodeBtn setTitle:@"Obtain again" forState:UIControlStateNormal];
        _sendCodeBtn.userInteractionEnabled=YES;
    }
}

#pragma --生成四位随机数
- (NSString *)createRandomNumber
{
    int num = (arc4random() % 10000);
    randCode = [NSString stringWithFormat:@"%.4d", num];
    
    return randCode;
}

#pragma -- 邮件后台发送操作
- (void)sendCodeOpration
{
//    E-mail login:    https://www.google.com/gmail/
//    User Name:     support@cervella.us
//Password:        CervellaRocks!
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.requiresAuth = YES;
    testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
    testMsg.delegate = self;
//    testMsg.relayHost = @"smtp.qiye.163.com";
//    testMsg.login = @"sleepstyle@nuozhijia.com.cn";
//    testMsg.pass = @"Sleep4U2016";
    testMsg.relayHost = @"https://www.google.com/gmail/";
    testMsg.login = @"support@cervella.us";
    testMsg.pass = @"CervellaRocks!";
    
    testMsg.fromEmail = testMsg.login;
    testMsg.toEmail = _patientInfo.Email;
    
    
    testMsg.subject = [NSString stringWithCString:"The email of identifying code for Cervella" encoding:NSUTF8StringEncoding];
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                               [NSString stringWithFormat:@"Thanks for using, the identfying code is:%@",[self createRandomNumber]],kSKPSMTPPartMessageKey,
                               @"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    testMsg.parts = [NSArray arrayWithObjects:plainPart, nil];
    
    [testMsg send];
}

#pragma --SKPSMTPMessageDelegate
- (void)messageSent:(SKPSMTPMessage *)message
{
    NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    NSLog(@"delegate - error(%ld): %@", (long)[error code], [error localizedDescription]);
}

- (IBAction)confirmBtnClick:(UIButton *)sender
{
    if ([randCode isEqualToString:_codeTextField.text])
    {
        //跳转到密码重置界面
        ResetViewController *resetVC = [[ResetViewController alloc] init];
        resetVC.patientInfo = _patientInfo;
        [self.navigationController pushViewController:resetVC animated:YES];
    }
    else
    {
        jxt_showTextHUDTitleMessage(@"", @"Verification code input error.Please check and re-enter");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
}

#pragma mark - UITextFieldDelegate实现
/*点击编辑区域外的view收起键盘*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_codeTextField resignFirstResponder];
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
