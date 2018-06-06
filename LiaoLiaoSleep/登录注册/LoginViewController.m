//
//  LoginViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/18.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Define.h"

#import "InterfaceModel.h"
#import "DataBaseOpration.h"

#import "EMClient.h"
#import "JXTAlertManagerHeader.h"

#import "RegisterViewController.h"
#import "SucceedRegisterViewController.h"
#import "FindPasswordViewController.h"
#import "LiaoLiaoHomeViewController.h"
#import "SquareViewController.h"
#import "ServiceHomeViewController.h"
#import "PersonalCenterViewController.h"


@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource,InterfaceModelDelegate>

@property (strong, nonatomic) IBOutlet UITableView *loginTableview;
@property (strong, nonatomic) IBOutlet    UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet    UIButton *forgetPasswordBtn;
@property (strong, nonatomic) IBOutlet    UIButton *registerBtn;

@end

@implementation LoginViewController
{
    UITextField *userName;       //用户名输入框
    UITextField *passWord;       //密码输入框
       UIButton *changeVisible;  //是否显示输入的密码按钮
           BOOL isVisible;       //标识密码输入框中输入的密码是否可见（默认为不可见）
    
           BOOL isOverTime;      //判断登录是否超时
    
    DataBaseOpration *dbOpration;
      InterfaceModel *interfaceModel;
         PatientInfo *patientInfo;
    
    NSArray *treatInfoArray;
    NSArray *evaluateInfoArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_navigation"]forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"疗疗失眠登录";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    /*
     *简单点说就是automaticallyAdjustsScrollViewInsets根据按所在界面的status bar，navigationbar，与tabbar的高度
     *自动调整scrollview的inset,设置为no，不让viewController调整，我们自己修改布局即可
     */
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置导航栏背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:46/255.0 green:195/255.0 blue:222/255.0 alpha:1];
    
    interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
    
    _loginTableview.scrollEnabled = NO;
    _loginTableview.delegate = self;
    _loginTableview.dataSource = self;
    
    //设置键盘收起手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doHideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [_loginTableview.backgroundView addGestureRecognizer:tap];
    [self.view  addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    //设置登录按钮背景图片
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"signin_btn_bg1"] forState:UIControlStateNormal];
}

- (void)doHideKeyBoard
{
    [userName resignFirstResponder];
    [passWord resignFirstResponder];
}

//登录按钮点击事件
- (IBAction)loginBtnClick:(UIButton *)sender
{
    //判断是否有网络
    if(userName.text.length == 0)
    {
        jxt_showTextHUDTitleMessage(@"温馨提示", @"账号不能为空，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if(passWord.text.length == 0)
    {
        jxt_showTextHUDTitleMessage(@"温馨提示", @"密码不能为空，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else
    {
        jxt_showLoadingHUDTitleMessage(@"登录", @"Loading...");
        isOverTime = YES;
        //调用登录接口
        [interfaceModel sendJsonLoginInfoToServer:userName.text password:passWord.text isLogin:YES];
        [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(overTimeOpration) userInfo:nil repeats:NO];
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

//忘记密码按钮点击事件
- (IBAction)forgetPasswordBtnClick:(UIButton *)sender
{
    if (userName.text.length == 0)
    {
        jxt_showTextHUDTitleMessage(@"温馨提示", @"账号不能为空，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else
    {
        //判断不为空时，并验证输入的账号是否存在
        [interfaceModel sendJsonLoginInfoToServer:userName.text password:@"" isLogin:NO];
        //设置“忘记密码”按钮不可点击，避免多次点击多次响应
        _forgetPasswordBtn.userInteractionEnabled=NO;
    }
}

//跳转到注册界面
- (IBAction)registerBtnClick:(UIButton *)sender
{
    RegisterViewController *registerController = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0)
    {
        cell=[[UITableViewCell alloc] init];
        
        UIImageView *userImage = [[UIImageView alloc] init];
        userImage.frame = CGRectMake(15, 14.5, 15, 22);
        userImage.image = [UIImage imageNamed:@"icon_phone"];
        
        userName = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, 2*(SCREENWIDTH - 50)/3, 51)];
        userName.placeholder = @"请输入手机号";
        userName.keyboardType = UIKeyboardTypeASCIICapable;
        
        [cell.contentView addSubview:userImage];
        [cell.contentView addSubview:userName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        return cell;
    }
    else
    {
        cell = [[UITableViewCell alloc] init];
        
        UIImageView *pwdImage = [[UIImageView alloc] init];
        pwdImage.frame = CGRectMake(15, 17, 15, 17);
        pwdImage.image = [UIImage imageNamed:@"icon_password"];
        
        passWord = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, 2*(SCREENWIDTH - 50)/3, 51)];
        passWord.secureTextEntry = YES;
        passWord.placeholder = @"请输入密码";
        
        changeVisible = [UIButton buttonWithType:UIButtonTypeCustom];
        changeVisible.frame = CGRectMake(SCREENWIDTH - 36, 20, 21, 12);
        [changeVisible setImage:[UIImage imageNamed:@"icon_eye"] forState:UIControlStateNormal];
        [changeVisible addTarget:self action:@selector(setPasswordIsVisible:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:pwdImage];
        [cell.contentView addSubview:passWord];
        [cell.contentView addSubview:changeVisible];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
}

//密码可见不可见按钮点击事件
- (void)setPasswordIsVisible:(UIButton *)sender
{
    if (isVisible)
    {
        [changeVisible setImage:[UIImage imageNamed:@"icon_eye"] forState:UIControlStateNormal];
        passWord.secureTextEntry=YES;
        isVisible = NO;
    }
    else
    {
        [changeVisible setImage:[UIImage imageNamed:@"icon_eye_in"] forState:UIControlStateNormal];
        passWord.secureTextEntry=NO;
        isVisible = YES;
    }
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeLogin)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            isOverTime = NO;
            dbOpration=[[DataBaseOpration alloc] init];
            treatInfoArray=[dbOpration getTreatDataFromDataBase];
            evaluateInfoArray=[dbOpration getEvaluateDataFromDataBase];
            [dbOpration closeDataBase];
            
            //循环将治疗数据以及评估数据上传至服务器
            if (treatInfoArray.count != 0)
            {
                TreatInfo *treatInfo = [[TreatInfo alloc] init];
                for (int i = 1; i <= treatInfoArray.count; i++)
                {
                    treatInfo = [treatInfoArray objectAtIndex:i-1];
                    //循环调用插入治疗数据接口
//                    [interfaceModel sendJsonCureDataToServer:treatInfo];
                }
            }
            //循环将治疗数据以及评估数据上传至服务器
            if (evaluateInfoArray.count != 0)
            {
                EvaluateInfo *evaluateInfo = [[EvaluateInfo alloc] init];
                for (int i = 1; i <= evaluateInfoArray.count; i++)
                {
                    evaluateInfo = [evaluateInfoArray objectAtIndex:i-1];
                    //循环调用插入治疗数据接口
//                    [interfacePro sendJsonEvaluateDataToServer:evaluateInfo];
                }
            }
        });
        //隐藏Loading
        jxt_dismissHUD();
        
        patientInfo = value;
        //记住密码（这里记住的不是三方注册账号的账号和密码，不是使用账户密码登陆方式的账号和密码）
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:patientInfo.PatientID forKey:@"PatientID"];
        [userDefault setObject:patientInfo.PatientPwd forKey:@"PatientPwd"];
        
#pragma mark ------- 环信注册
        EMError *errorRegister = [[EMClient sharedClient] registerWithUsername:patientInfo.PatientID password:Hyphenate_PassWord];
        if (errorRegister == nil) {
            NSLog(@"注册成功");
        }
#pragma mark ------- 环信自动登录
        EMError *errorLogin = [[EMClient sharedClient] loginWithUsername:patientInfo.PatientID password:Hyphenate_PassWord];
        if (!errorLogin)
        {
            [[EMClient sharedClient].options setIsAutoLogin:YES];
        }
        
        [self changRootView];
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeLoginPasswordError)
    {
        isOverTime = NO;
        //隐藏Loading
        jxt_dismissHUD();
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeFindPassword)
    {
        FindPasswordViewController *findPasswordController = [[FindPasswordViewController alloc] initWithNibName:@"FindPasswordViewController" bundle:nil];
        findPasswordController.PatientID = userName.text;
        [self.navigationController pushViewController:findPasswordController animated:YES];
        //将之前“忘记密码”按钮设置成用户可点击
        _forgetPasswordBtn.userInteractionEnabled = YES;
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeAccountNotExist)
    {
        _forgetPasswordBtn.userInteractionEnabled = YES;
    }
}

//切换app的根视图控制器
- (void)changRootView
{
    //变更app的根视图控制器
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *app2 =  (AppDelegate*)app.delegate;
    
    LiaoLiaoHomeViewController *liaoLiaoHomeVC = [[LiaoLiaoHomeViewController alloc] init];
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
