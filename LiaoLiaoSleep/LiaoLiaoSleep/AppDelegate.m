//
//  AppDelegate.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/14.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>

#import "Define.h"
#import "DataBaseOpration.h"
#import "InterfaceModel.h"
#import "DataHandle.h"
#import "FunctionHelper.h"

#import "EMSDK.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UMMobClick/MobClick.h>

#import "LoginViewController.h"
#import "PersonalCenterViewController.h"
#import "LiaoLiaoHomeViewController.h"
#import "SquareViewController.h"
#import "ServiceHomeViewController.h"
#import "StartLiaoLiaoViewController.h"

//注意，关于 iOS10 系统版本的判断，可以用下面这个宏来判断。不能再用截取字符的方法。
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define USHARE_APPKEY @"597595ccbbea8319d3000ad9"
#define WECHAT_APPSECRET @"ffeec20dbe255d59367f58658c305193"

@interface AppDelegate ()<WXApiDelegate,EMChatManagerDelegate,UNUserNotificationCenterDelegate,  InterfaceModelDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIView *launchView;
@property (nonatomic, strong) UIScrollView *launchScrollView;
@property (nonatomic, strong) UIImageView * oldLaunchView;

@property (nonatomic, strong) UITabBarController *tabB;

@end

@implementation AppDelegate
{
    BluetoothInfo *bluetoothInfo;
    
    InterfaceModel *interfaceModel;
    NSInteger badgeCount;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /* 打开日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    [UMSocialGlobal shareInstance].isClearCacheWhenGetUserInfo = NO;
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_APPKEY];
    [self configUSharePlatforms];
    [self confitUShareSettings];
    
    /* 友盟统计 */
    UMConfigInstance.appKey = USHARE_APPKEY;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setTreatmentTime" object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TreatmentTimeUp:) name:@"setTreatmentTime" object:nil];
    
    //iOS 10 的通知注册方式
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0"))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            
        }];
    }
    //iOS 8 的通知注册方式
    else
    {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //iOS 10 使用以下方法注册，才能得到授权
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    }
    
    /*
     *判断晚上22:00的推送是否存在
     */
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    if (localNotifications.count > 1)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    BOOL containSleep = NO;
    for (UILocalNotification *notification in localNotifications)
    {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo)
        {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo.allKeys[0];
            
            if ([info isEqualToString:@"Sleep"])
            {
                NSDate *alertDate = notification.fireDate;
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                NSString *alertStr = [formatter stringFromDate:alertDate];
                if (![alertStr isEqualToString:@"22:00"])
                {
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                }
                else
                {
                    containSleep = YES;
                }
            }
        }
    }
    if (!containSleep)
    {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //监听回调事件
        center.delegate = self;
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            [FunctionHelper registerLocalNotification:@"22:00"
                                            alertBody:@"健康生活从睡眠开始，疗疗提醒您十点要睡觉了！"
                                             userDict:@{@"Sleep":@"key"}];
        }];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //AppKey:注册的AppKey，详细见下面注释。
    //apnsCertName:推送证书名（不需要加后缀），详细见下面注释。
    EMOptions *options = [EMOptions optionsWithAppkey:@"1146170117178025#nuozhijialiaoliaosleep"];
    options.apnsCertName = @"LiaoLiaoSleepCertify";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
#pragma mark - registerNotifications
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //从NSUserDefaults中获取存储的用户信息
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userName=[userDefault objectForKey:@"PatientID"];
    if (userName.length == 0 || userName == nil)
    {
        LoginViewController *rootView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootView];
        self.window.rootViewController = navController;
    }
    else
    {
        //1.从数据库读取数据传到主界面（读取NSUserDefaults中的该PatientID用户信息表信息、治疗数据、评估数据以及蓝牙外设，读完数据之后关闭数据库）
        DataBaseOpration *dataBaseOpration = [[DataBaseOpration alloc] init];
        NSArray* patientInfoArray = [dataBaseOpration getPatientDataFromDataBase];
        [dataBaseOpration closeDataBase];
        
        PatientInfo *patientInfo = [PatientInfo shareInstance];
        for (PatientInfo *tmp in patientInfoArray)
        {
            if ([tmp.PatientID isEqualToString:userName])
            {
                patientInfo = tmp;
            }
        }
        
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
        
        self.window.rootViewController = rootView;
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    }
    
    [self musicBackground];
    
    //微信支付
    [WXApi registerApp:@"wxda493bb4790a315f"];
    
    //先判断app是否第一次安装或更新之后
    NSString *flagStr = [userDefault objectForKey:@"AppFirstOpen"];
    if (flagStr == nil || flagStr.length == 0)
    {
        //添加app打开动画（第一次安装或更新app时添加）
        [self initAd];
    }
    
    //getsoftversion
    [self getSoftVersion];
    
    return YES;
}

- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}

- (void)configUSharePlatforms
{
    /*
     设置微信的appKey和appSecret
     [微信平台从U-Share 4/5升级说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_1
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxda493bb4790a315f" appSecret:WECHAT_APPSECRET redirectURL:nil];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     100424468.no permission of union id
     [QQ/QZone平台集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_3
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1104974574"/*设置QQ平台的appID*/  appSecret:nil redirectURL:nil];
    
    /*
     设置新浪的appKey和appSecret
     [新浪微博集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_2
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"1456908210"  appSecret:@"c309357f2a0d48959d19687f123f6b6c" redirectURL:@"http://www.sina.com"];
}

- (void)musicBackground
{
    //开启后台处理多媒体事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession * session=[AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    //后台播放
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:nil];
}

/*
 兼容使用LaunchImage启动图
 这边去获取启动图（为了防止广告图还在加载中，启动图已经加载结束了）
 */
- (void) initAd
{
    //从NSUserDefaults当中标记app不是第一次安装或更新
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"YES" forKey:@"AppFirstOpen"];
    
    CGSize viewSize = self.window.bounds.size;
    NSString*viewOrientation = @"Portrait";//横屏请设置成 @"Landscape"
    NSString*launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for(NSDictionary* dict in imagesDict)
    {
        CGSize imageSize =CGSizeFromString(dict[@"UILaunchImageSize"]);
        if(CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    self.oldLaunchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
    self.oldLaunchView.frame = self.window.bounds;
    self.oldLaunchView.contentMode = UIViewContentModeScaleAspectFill;
    [self.window addSubview:self.oldLaunchView];
    
    [self loadLaunchAd];
}

/*
 加载自定义广告
 */
-(void)loadLaunchAd
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    if (storyboard == nil)
    {
        return;
    }
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    if (viewController == nil)
    {
        return;
    }
    
    self.launchView = viewController.view;
    self.launchView.userInteractionEnabled = YES;
    [self.window addSubview:self.launchView];
    
    self.launchScrollView = [[UIScrollView alloc] initWithFrame:self.window.frame];
    [_launchScrollView setContentOffset:CGPointMake(0, 0)];//将起始点定义到第二张图
    [_launchScrollView setContentSize:CGSizeMake(self.window.frame.size.width * 5, self.window.frame.size.height)];
    _launchScrollView.backgroundColor = [UIColor blackColor];
    _launchScrollView.showsHorizontalScrollIndicator = NO;
    _launchScrollView.pagingEnabled = YES;
    [self.launchView addSubview:self.launchScrollView];
    
    UIImageView *imageViewOne = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [imageViewOne setImage:[UIImage imageNamed:@"WechatIMG1"]];
    [self.launchScrollView addSubview:imageViewOne];
    
    UIImageView *imageViewTwo = [[UIImageView alloc] initWithFrame:CGRectMake(self.window.frame.size.width, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [imageViewTwo setImage:[UIImage imageNamed:@"WechatIMG2"]];
    [self.launchScrollView addSubview:imageViewTwo];
    
    UIImageView *imageViewThree = [[UIImageView alloc] initWithFrame:CGRectMake(self.window.frame.size.width*2, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [imageViewThree setImage:[UIImage imageNamed:@"WechatIMG3"]];
    [self.launchScrollView addSubview:imageViewThree];
    
    UIImageView *imageViewFour = [[UIImageView alloc] initWithFrame:CGRectMake(self.window.frame.size.width*3, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [imageViewFour setImage:[UIImage imageNamed:@"WechatIMG4"]];
    [self.launchScrollView addSubview:imageViewFour];
    
    UIImageView *imageViewFive = [[UIImageView alloc] initWithFrame:CGRectMake(self.window.frame.size.width*4, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [imageViewFive setImage:[UIImage imageNamed:@"WechatIMG5"]];
    [self.launchScrollView addSubview:imageViewFive];
    
    UIButton *experienceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    experienceBtn.frame = CGRectMake(self.window.frame.size.width*4 + 100*Ratio, self.window.frame.size.height - 130*Ratio, 175*Ratio, 50*Ratio);
    experienceBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [experienceBtn setTitle:@"立即体验" forState:UIControlStateNormal];
    [experienceBtn addTarget:self action:@selector(handle) forControlEvents:UIControlEventTouchUpInside];
    [self.launchScrollView addSubview:experienceBtn];
    
    [self.oldLaunchView removeFromSuperview];
    
    [self.window bringSubviewToFront:self.launchView];
}

-(void)handle
{
    [self transitionWithType:@"rippleEffect" WithSubtype:kCATransitionFromLeft ForView:self.window];
}

#pragma CATransition动画实现
- (void)transitionWithType:(NSString *)type WithSubtype:(NSString *)subtype ForView:(UIView *)view
{
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    //设置运动时间
    animation.duration = 1.0f;
    //设置运动type
    animation.type = type;
    if (subtype != nil)
    {
        //设置子类
        animation.subtype = subtype;
    }
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"animation"];
    
    //动画实现
    [UIView animateWithDuration:1.0f animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [self.launchScrollView removeFromSuperview];
        [self.launchView removeFromSuperview];
    }];
}

#pragma mark - UNUserNotificationCenterDelegate
//在展示通知前进行处理，即有机会在展示通知前再修改通知内容。
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    //1. 处理通知
    //2. 处理完成后条用 completionHandler ，用于指示在前台显示通知的形式
    completionHandler(UNNotificationPresentationOptionAlert);
}

//app未运行情况下，不走此方法。运行或者后台情况下走
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

-(void)TreatmentTimeUp:(NSNotification *)text
{
    [FunctionHelper cancelLocalNotificationWithKey:@"key"];
    NSDictionary * dic = text.userInfo;
    NSString * wakeTime = [dic objectForKey:@"wakeTime"];
    NSString * cureTime1 = [dic objectForKey:@"cureTime1"];
    NSString * cureTime2 = [dic objectForKey:@"cureTime2"];
    NSString * sleepTime = [dic objectForKey:@"sleepTime"];
    NSLog(@"wake == %@",text.userInfo);
    
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //监听回调事件
    center.delegate = self;
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        [FunctionHelper registerLocalNotification:wakeTime
                                        alertBody:@"身体已经准备好一切了，迎接美好的一天吧！"
                                         userDict:@{@"nocure":@"key"}];
        [FunctionHelper registerLocalNotification:cureTime1
                                        alertBody:@"嗨，上午好，疗疗提醒您该治疗啦！"
                                         userDict:@{@"cure":@"key"}];
        [FunctionHelper registerLocalNotification:cureTime2
                                        alertBody:@"嗨，下午好，疗疗提醒您该治疗啦！"
                                         userDict:@{@"cure":@"key"}];
        [FunctionHelper registerLocalNotification:sleepTime
                                        alertBody:@"为了保证充足的睡眠和身体各系统的休息，是时候该睡觉了!"
                                         userDict:@{@"nocure":@"key"}];
    }];
}

- (void)uploadTreatDataAndEvaluateData
{
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSMutableArray *treatInfoArray = [dbOpration getTreatDataFromDataBase];
    NSMutableArray *evaluateInfoArray = [dbOpration getEvaluateDataFromDataBase];
    [dbOpration closeDataBase];
    
    interfaceModel = [[InterfaceModel alloc] init];
    //---------------------GCD----------------------支持多核，高效率的多线程技术
    //创建多线程
    dispatch_queue_t queue = dispatch_queue_create("sendValueToService", NULL);
    //创建一个子线程
    dispatch_async(queue, ^{
        // 子线程code... ..
        if (treatInfoArray.count > 0)
        {
            for (int i = 0; i < treatInfoArray.count; i++)
            {
                [interfaceModel insertTreatInfoToServer:[treatInfoArray objectAtIndex:i] DeviceCode:bluetoothInfo.deviceCode];
//                [interfaceModel insertTreatInfoToServer:[treatInfoArray objectAtIndex:i]];
            }
        }
    });
    //创建一个子线程
    dispatch_async(queue, ^{
        // 子线程code... ..
        if (evaluateInfoArray.count > 0)
        {
            for (int i = 0; i < evaluateInfoArray.count; i++)
            {
                [interfaceModel insertEvaluateInfoToServer:[evaluateInfoArray objectAtIndex:i]];
            }
        }
    });
}

-(void)messagesDidReceive:(NSArray *)aMessages
{
    NSString * doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDoctorID"];
    NSString * questionID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentQuestionID"];
    for (EMMessage * message in aMessages)
    {
        if ([[message.conversationId lowercaseString] isEqualToString:[doctorID lowercaseString]])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isRecieve"];
            [FunctionHelper registerLocalNotificationWithalertBody:@"您有一条新消息" andalertTitle:@"来自问医生"];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            //  后台执行：
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [FunctionHelper uploadHistoryChatMessageWithMessage:message withQuestionID:questionID];
            });
        }
        else if([[message.conversationId lowercaseString] isEqualToString:[Service_ID lowercaseString]])
        {
            
            [FunctionHelper registerLocalNotificationWithalertBody:@"您有一条新消息" andalertTitle:@"来自客服"];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
    }
    // 获取当前应用程序的UIApplication对象
    UIApplication *app = [UIApplication sharedApplication];
    // 设置应用程序右上角的"通知图标"Badge
    app.applicationIconBadgeNumber += 1;
}

//#define __IPHONE_10_0    100000
#if __IPHONE_OS_VERSION_MAX_ALLOWED > 100000
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响。
    BOOL result = [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
    if (!result)
    {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"safepay"])
        {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSString *strMsg;
                //【callback处理支付结果】
                if ([resultDic[@"resultStatus"] isEqualToString:@"9000"])
                {
                    strMsg = @"恭喜您，支付成功!";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"success",@"resultDec":strMsg}];
                }
                else if([resultDic[@"resultStatus"] isEqualToString:@"6001"])
                {
                    strMsg = @"已取消支付!";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"cancel",@"resultDec":strMsg}];
                }
                else
                {
                    strMsg = @"支付失败!";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"failure",@"resultDec":strMsg}];
                }
            }];
            
            // 授权跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic)
             {
                 NSLog(@"result = %@",resultDic);
                 // 解析 auth code
                 NSString *result = resultDic[@"result"];
                 NSString *authCode = nil;
                 if (result.length>0)
                 {
                     NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                     for (NSString *subResult in resultArr)
                     {
                         if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="])
                         {
                             authCode = [subResult substringFromIndex:10];
                             break;
                         }
                     }
                 }
                 NSLog(@"授权结果 authCode = %@", authCode?:@"");
             }];
        }
        else
        {
            /*! @brief 处理微信通过URL启动App时传递的数据
             *
             * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
             * @param url 微信启动第三方应用时传递过来的URL
             * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
             * @return 成功返回YES，失败返回NO。
             */
            return [WXApi handleOpenURL:url delegate:self];
        }
    }
    
    return result;
}

#endif

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"safepay"])
        {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSString *strMsg;
                //【callback处理支付结果】
                if ([resultDic[@"resultStatus"] isEqualToString:@"9000"])
                {
                    strMsg = @"恭喜您，支付成功!";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"success",@"resultDec":strMsg}];
                    
                }
                else if([resultDic[@"resultStatus"] isEqualToString:@"6001"])
                {
                    strMsg = @"已取消支付!";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"cancel",@"resultDec":strMsg}];
                    
                }
                else
                {
                    strMsg = @"支付失败!";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"failure",@"resultDec":strMsg}];
                }
            }];
            
            // 授权跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic)
             {
                 NSLog(@"result = %@",resultDic);
                 // 解析 auth code
                 NSString *result = resultDic[@"result"];
                 NSString *authCode = nil;
                 if (result.length > 0)
                 {
                     NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                     for (NSString *subResult in resultArr)
                     {
                         if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="])
                         {
                             authCode = [subResult substringFromIndex:10];
                             break;
                         }
                     }
                 }
                 NSLog(@"授权结果 authCode = %@", authCode?:@"");
             }];
        }
        
        if ([sourceApplication isEqualToString:@"com.tencent.xin"])
        {
            //微信支付回调
            return [WXApi handleOpenURL:url delegate:self];
        }
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    if ([url.host isEqualToString:@"safepay"])
//    {
//        // 支付跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSString *strMsg;
//            //【callback处理支付结果】
//            if ([resultDic[@"resultStatus"] isEqualToString:@"9000"])
//            {
//                strMsg = @"恭喜您，支付成功!";
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"success",@"resultDec":strMsg}];
//                
//            }
//            else if([resultDic[@"resultStatus"] isEqualToString:@"6001"])
//            {
//                strMsg = @"已取消支付!";
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"cancel",@"resultDec":strMsg}];
//                
//            }
//            else
//            {
//                strMsg = @"支付失败!";
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"failure",@"resultDec":strMsg}];
//            }
//        }];
//        
//        // 授权跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic)
//         {
//             NSLog(@"result = %@",resultDic);
//             // 解析 auth code
//             NSString *result = resultDic[@"result"];
//             NSString *authCode = nil;
//             if (result.length > 0)
//             {
//                 NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                 for (NSString *subResult in resultArr)
//                 {
//                     if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="])
//                     {
//                         authCode = [subResult substringFromIndex:10];
//                         break;
//                     }
//                 }
//             }
//             NSLog(@"授权结果 authCode = %@", authCode?:@"");
//         }];
//    }
//    
//    if ([sourceApplication isEqualToString:@"com.tencent.xin"])
//    {
//        //微信支付回调
//        return [WXApi handleOpenURL:url delegate:self];
//    }
//    
//    return YES;
//}
//
//// NOTE: 9.0以后使用新API接口
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
//{
//    if ([url.host isEqualToString:@"safepay"])
//    {
//        // 支付跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSString *strMsg;
//            //【callback处理支付结果】
//            if ([resultDic[@"resultStatus"] isEqualToString:@"9000"])
//            {
//                strMsg = @"恭喜您，支付成功!";
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"success",@"resultDec":strMsg}];
//            }
//            else if([resultDic[@"resultStatus"] isEqualToString:@"6001"])
//            {
//                strMsg = @"已取消支付!";
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"cancel",@"resultDec":strMsg}];
//            }
//            else
//            {
//                strMsg = @"支付失败!";
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"failure",@"resultDec":strMsg}];
//            }
//        }];
//        
//        // 授权跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic)
//         {
//             NSLog(@"result = %@",resultDic);
//             // 解析 auth code
//             NSString *result = resultDic[@"result"];
//             NSString *authCode = nil;
//             if (result.length>0)
//             {
//                 NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                 for (NSString *subResult in resultArr)
//                 {
//                     if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="])
//                     {
//                         authCode = [subResult substringFromIndex:10];
//                         break;
//                     }
//                 }
//             }
//             NSLog(@"授权结果 authCode = %@", authCode?:@"");
//         }];
//    }
//    else
//    {
//        /*! @brief 处理微信通过URL启动App时传递的数据
//         *
//         * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
//         * @param url 微信启动第三方应用时传递过来的URL
//         * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
//         * @return 成功返回YES，失败返回NO。
//         */
//        return [WXApi handleOpenURL:url delegate:self];
//    }
//    
//    return YES;
//}

//回调方法
- (void)onResp:(BaseResp*)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    NSString *strTitle;
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        strTitle = @"发送媒体消息结果";
    }
    if([resp isKindOfClass:[PayResp class]])
    {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        switch (resp.errCode)
        {
            case WXSuccess:
            {
                strMsg = @"恭喜您，支付成功!";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"success",@"resultDec":strMsg}];
                break;
            }
            case WXErrCodeUserCancel:
            {
                strMsg = @"已取消支付!";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"cancel",@"resultDec":strMsg}];
                break;
            }
            default:
            {
                strMsg = [NSString stringWithFormat:@"支付失败 !"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayOrWeiXinPay" object:nil userInfo:@{@"state":@"failure",@"resultDec":strMsg}];
                break;
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - getSoftVersion
- (void)getSoftVersion {
    interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
    [interfaceModel getSoftVersion];
}

#pragma mark - InterfaceModelDelegate
- (void)sendValueBackToController:(id)value
                             type:(InterfaceModelBackType)interfaceModelBackType{
    if (interfaceModelBackType == InterfaceModelBackTypeGetSoftVersion) {
        // Version is the same as version of setting;
        if ([value isEqualToString:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"APP版本太低需要更新，请前往APPStore更新最新版本" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 10;
            [alert show];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/liao-liao-shi-mian/id1060524805?mt=8"]];
    }
}



@end
