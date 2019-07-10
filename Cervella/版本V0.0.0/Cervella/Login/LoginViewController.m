//
//  LoginViewController.m
//  Cervella
//
//  Created by Justin on 2017/6/27.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginViewController.h"
#import "ForgotPasswordViewController.h"
#import "HomeViewController.h"

@interface LoginViewController ()<UITableViewDelegate, UITableViewDataSource, InterfaceModelDelegate>

@property (strong, nonatomic) IBOutlet UITableView *loginTableView;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *registerBtn;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordBtn;

@property (strong ,nonatomic) UITextField *acountTextField;
@property (strong ,nonatomic) UITextField *passwordTextField;

@end

@implementation LoginViewController
{
    BOOL isOverTime;      //判断登录是否超时
    
    DataBaseOpration *dbOpration;
    InterfaceModel *interfaceModel;
    PatientInfo *patientInfo;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation"]forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Cervella";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
    
    _loginTableView.scrollEnabled =NO; //设置tableview不能滚动
    _loginTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _loginTableView.delegate = self;
    _loginTableView.dataSource = self;
    
    //设置键盘收起手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doHideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [_loginTableView.backgroundView addGestureRecognizer:tap];
    [_loginBtn addGestureRecognizer:tap];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}

- (void)doHideKeyBoard
{
    [_acountTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeLogin)
    {
        isOverTime = NO;
        //隐藏Loading
        jxt_dismissHUD();
        
        patientInfo = value;
        //记住密码（这里记住的不是三方注册账号的账号和密码，不是使用账户密码登陆方式的账号和密码）
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:patientInfo.PatientID forKey:@"PatientID"];
        [userDefault setObject:patientInfo.PatientPwd forKey:@"PatientPwd"];
        
        [self changeRoot];
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeLoginPasswordError)
    {
        isOverTime = NO;
        //隐藏Loading
        jxt_dismissHUD();
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeFindPassword)
    {
        //先判断邮箱是否存在
        [interfaceModel sendJsonPatientIDToServer:_acountTextField.text andPwd:nil];
        
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeGetPatientInfo)
    {
        patientInfo = value;
        if (patientInfo.Email.length > 0)
        {
            //获取storyboard:通过bundle根据storyboard的名字来获取我们的storyboard,
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            //由storyboard根据myView的storyBoardID来获取我们要切换的视图
            
            ForgotPasswordViewController *fpVC = [story instantiateViewControllerWithIdentifier:@"ForgotPassword"];
            fpVC.patientInfo = patientInfo;
            [self.navigationController pushViewController:fpVC animated:YES];
        }
        else
        {
            [JXTAlertView showToastViewWithTitle:@"Kindly Reminder" message:@"Your email is empty" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                NSLog(@"关闭");
            }];
        }
        //将之前“忘记密码”按钮设置成用户可点击
        _forgotPasswordBtn.userInteractionEnabled = YES;
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeAccountNotExist)
    {
        _forgotPasswordBtn.userInteractionEnabled = YES;
    }
}

//切换app的根视图控制器
- (void)changeRoot
{
    //变更app的根视图控制器
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *app2 =  (AppDelegate*)app.delegate;
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.patientInfo = patientInfo;
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    app2.window.rootViewController = rootVC;
    app2.window.backgroundColor = [UIColor whiteColor];
    [app2.window makeKeyAndVisible];
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
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 20, 20)];
        [headImageView setImage:[UIImage imageNamed:@"login_head"]];
        [cell.contentView addSubview:headImageView];
        
        _acountTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 5, 240, 40)];
        _acountTextField.font = [UIFont systemFontOfSize:18];
        _acountTextField.placeholder = @"Acount";
        [cell.contentView addSubview:_acountTextField];
    }
    else
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 20, 20)];
        [headImageView setImage:[UIImage imageNamed:@"login_password"]];
        [cell.contentView addSubview:headImageView];
        
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 5, 240, 40)];
        _passwordTextField.font = [UIFont systemFontOfSize:18];
        _passwordTextField.placeholder = @"Password";
        _passwordTextField.secureTextEntry = YES;
        [cell.contentView addSubview:_passwordTextField];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (IBAction)loginAction:(UIButton *)sender
{
    [self performSelector:@selector(doLogin) withObject:nil afterDelay:0.55];
}

- (void)doLogin
{
    //判断账号密码，之后再加入NSUserDefault当中，便于之后直接进入
    if(_acountTextField.text.length == 0)
    {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Account number must be entered");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if(_passwordTextField.text.length == 0)
    {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Password must be entered");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else
    {
        jxt_showLoadingHUDTitleMessage(@"Sign in", @"Loading...");
        isOverTime = YES;
        //调用登录接口
        [interfaceModel sendJsonLoginInfoToServer:_acountTextField.text password:_passwordTextField.text isLogin:YES];
        [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(overTimeOpration) userInfo:nil repeats:NO];
    }
}

- (void)overTimeOpration
{
    if (isOverTime)
    {
        //隐藏Loading
        jxt_dismissHUD();
        jxt_showAlertTitle(@"Login timeout");
    }
}

- (IBAction)forgotPasswordAction:(UIButton *)sender
{
    [self performSelector:@selector(doForgotPassword) withObject:nil afterDelay:0.55];
}

- (void)doForgotPassword
{
    //判断输入的账号在后台有没有，有的话再判断有没有绑定邮箱
    if (_acountTextField.text.length == 0)
    {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Account number must be entered");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else
    {
        //判断不为空时，并验证输入的账号是否存在
        [interfaceModel sendJsonLoginInfoToServer:_acountTextField.text password:@"" isLogin:NO];
        //设置“忘记密码”按钮不可点击，避免多次点击多次响应
        _forgotPasswordBtn.userInteractionEnabled = NO;
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
