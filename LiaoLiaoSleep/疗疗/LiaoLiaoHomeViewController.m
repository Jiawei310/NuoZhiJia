//
//  LiaoLiaoHomeViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/14.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "LiaoLiaoHomeViewController.h"
#import "sys/utsname.h"
#import "EMClient.h"
#import "Define.h"
#import "FunctionHelper.h"
#import "SDImageCache.h"
#import <UMMobClick/MobClick.h>

#import "TreatmentInfo.h"
#import "DataBaseOpration.h"
#import "InterfaceModel.h"

#import "YBLoopBanner.h"

#import "StartLiaoLiaoViewController.h"
#import "MusicViewController.h"
#import "DoctorHomeViewController.h"
#import "DocProtocolViewController.h"
#import "DataCenterViewController.h"
#import "ScaleTestViewController.h"
#import "MoreFunctionViewController.h"

#define HeaderViewHeight  317*Rate_H
#define FooterViewHeight  SCREENHEIGHT - HeaderViewHeight - 49
#define BtnSpaceUp        42*Rate_H
#define LabelSpaceUp      93*Rate_H

@interface LiaoLiaoHomeViewController ()<EMChatManagerDelegate,InterfaceModelDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (nonatomic, strong)UILabel *noticePoint;//消息提示红点
@property (nonatomic, copy)  NSArray *titleArr;//存储按钮标题
@property (nonatomic, copy)  NSArray *imageArr;//存储图片
@property (nonatomic, copy) NSString *doctorID;//医生ID

@property (nonatomic, copy) NSMutableArray *treatmentArray; //疗程数据数组
@property (nonatomic, assign) BOOL netExist;
@property (nonatomic, strong) YBLoopBanner *loop;

@end

@implementation LiaoLiaoHomeViewController
{
    NSMutableArray *treatmentAndTreatArray;   //所有疗程内的所有治疗数据
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = YES;
    
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick beginLogPageView:@"首页"];//("PageOne"为页面名称，可自定义)
    //注册代理
    [[EMClient sharedClient].chatManager addDelegate:self];
    //医生ID号
    _doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDoctorID"];
    //获取与医生创建的对话
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:_doctorID type:EMConversationTypeChat createIfNotExist:NO];
    //判断医生的未读消息数
    if([conversation unreadMessagesCount] > 0)
    {
        _noticePoint.hidden = NO;
    }
    else
    {
        _noticePoint.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"首页"];//("PageOne"为页面名称，可自定义)

    //移除代理
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //软硬件信息
    NSString *deviceModel = [self deviceVersion];
    NSString *myOsVeriosn = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    NSString *myDevice = [NSString stringWithFormat:@"%@_%@",deviceModel,myOsVeriosn];
    //当前系统时间
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentDate = [df stringFromDate:[NSDate date]];
    //上传版本号等信息
    _patientInfo = [PatientInfo shareInstance];
    InterfaceModel *faceModel = [[InterfaceModel alloc] init];
    [faceModel sendJsonDeviceValueToServer:_patientInfo.PatientID Version:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] Model:myDevice Date:currentDate];
    [MobClick profileSignInWithPUID:_patientInfo.PatientID];
    
    //获取主页轮播图资源
    if ([FunctionHelper isExistenceNetwork])
    {
        //清楚缓存
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
        
        _netExist = YES;
        //请求资源
        InterfaceModel *interfaceM = [[InterfaceModel alloc] init];
        interfaceM.delegate = self;
        [interfaceM sendJsonPictureToServer];
    }
    else
    {
        _netExist = NO;
    }
    //数组初始化
    treatmentAndTreatArray = [NSMutableArray array];
    
    [self prepareData];
    //创建第一部分视图
    [self createHeaderView];
    //创建第二部分视图
    [self createFooterView];
    
    //注册个人信息修改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePatientInfo:) name:@"patientInfoChange" object:nil];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(treatmentChange:) name:@"StartLiaoLiao" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(treatmentChange:) name:@"SetTreatment" object:nil];
}

//个人信息修改通知方法
- (void)changePatientInfo:(NSNotification *)notification
{
    _patientInfo = [notification.userInfo objectForKey:@"patientInfo"];
}

//添加新的疗程到数组中
- (void)treatmentChange:(NSNotification *)notification
{
    if (_treatmentArray == nil)
    {
        _treatmentArray = [NSMutableArray array];
    }
    [_treatmentArray addObject:notification.userInfo[@"TreatmentInfo"]];
}

/**
 * 开始到结束的时间差的天数
 */
- (NSInteger)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    NSInteger day = value / (24 * 3600);
    return day;
}

//创建第一部分视图
- (void)createHeaderView
{
    _loop = [[YBLoopBanner alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, HeaderViewHeight) scrollDuration:3.f];
    [self.view addSubview:_loop];
    if (!_netExist)
    {
        _loop.imageURLStrings = @[@"home_bg.png"];
    }
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeHomePicture)
    {
        NSArray *arrTmp = value;
        NSMutableArray *urlArr = [NSMutableArray array];
        for (int i = 0; i < arrTmp.count; i++)
        {
            NSDictionary *dic = [arrTmp objectAtIndex:i];
            NSString *urlStr = [NSString stringWithFormat:@"http://211.161.200.73:8098/HolidayImg/%@",[dic objectForKey:@"Url"]];
            [urlArr addObject:urlStr];
        }
        if (urlArr.count == 0)
        {
            //请求资源
            InterfaceModel *interfaceM = [[InterfaceModel alloc] init];
            interfaceM.delegate = self;
            [interfaceM sendJsonPictureTwoToServer];
        }
        else
        {
            _loop.imageURLStrings = [NSArray arrayWithArray:urlArr];
        }
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeHomePictureTwo)
    {
        NSArray *arrTmp = value;
        NSMutableArray *urlArr = [NSMutableArray array];
        for (int i = 0; i < arrTmp.count; i++)
        {
            NSDictionary *dic = [arrTmp objectAtIndex:i];
            NSString *urlStr = [NSString stringWithFormat:@"http://211.161.200.73:8098/HolidayImg/%@",[dic objectForKey:@"Url"]];
            [urlArr addObject:urlStr];
        }
        if (urlArr.count == 0)
        {
            _loop.imageURLStrings = @[@"home_bg.png"];
        }
        else
        {
            _loop.imageURLStrings = [NSArray arrayWithArray:urlArr];
        }
    }
}

//数据准备
- (void)prepareData
{
    //读取本地数据(所有疗程信息)
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSArray *allTreatment = [dbOpration getTreatmentDataFromDataBase];
    [dbOpration closeDataBase];
    //将取出的疗程数据进行判断，只需要自己疗程的数据
    if (allTreatment.count > 0)
    {
        _treatmentArray = [NSMutableArray array];
        for (TreatmentInfo *tmp in allTreatment)
        {
            if ([tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [_treatmentArray addObject:tmp];
            }
        }
    }
    
    //按钮选择标题数组
    self.titleArr = @[@"开始疗疗",@"量表评估",@"数据中心",@"音乐助眠",@"问医生",@"更多功能"];
    self.imageArr = @[@"icon_device.png",@"icon_gauge.png",@"数据中心.png",@"icon_music.png",@"icon_doc.png",@"icon_more.png"];
}

- (void)createFooterView
{
    //创建按钮选择区域
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, HeaderViewHeight, SCREENWIDTH, FooterViewHeight)];
    footerView.userInteractionEnabled = YES;
    footerView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    [self.view addSubview:footerView];
    
    //for循环创建选择按钮
    for (int i = 0; i < 6; i++)
    {
        UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(((SCREENWIDTH-2)/3+1)*(i%3), ((FooterViewHeight-1)/2+1)*(i/3), (SCREENWIDTH-2)/3, (FooterViewHeight-1)/2)];
        buttonView.tag = i+1;
        buttonView.backgroundColor = [UIColor whiteColor];
        buttonView.userInteractionEnabled = YES;
        [buttonView addTarget:self action:@selector(clickJump:) forControlEvents:(UIControlEventTouchUpInside)];
        [footerView addSubview:buttonView];
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((125*Rate_W - 36*Rate_H)/2, BtnSpaceUp, 36*Rate_H, 37*Rate_H)];
        //创建标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((125*Rate_W - 58*Rate_H)/2, LabelSpaceUp, 58*Rate_H, 20*Rate_H)];
        label.text = self.titleArr[i];
        label.userInteractionEnabled = YES;
        label.font = [UIFont systemFontOfSize:14*Rate_H];
        label.textAlignment = NSTextAlignmentCenter;
        [buttonView addSubview:label];
        if (i == 4)
        {
            CGSize size = [self.titleArr[i] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:label.font,NSFontAttributeName, nil]];
            _noticePoint = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x+size.width+5, label.frame.origin.y-2, 8, 8)];
            _noticePoint.layer.cornerRadius = 4;
            _noticePoint.clipsToBounds = YES;
            _noticePoint.backgroundColor = [UIColor redColor];
            _noticePoint.hidden = YES;
            [buttonView addSubview:_noticePoint];
        }
        //按钮设置
        imageV.image = [UIImage imageNamed:self.imageArr[i]];
        [buttonView addSubview:imageV];
    }
}

- (void)clickJump:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        StartLiaoLiaoViewController *startVC = [StartLiaoLiaoViewController sharedStartLiaoLiaoViewController];
        if ([self judgeCourseOfTreatment])
        {
            startVC.treatmentDic = [_treatmentArray objectAtIndex:_treatmentArray.count-1];
        }
        startVC.isInCourse = [self judgeCourseOfTreatment];
        [self.navigationController pushViewController:startVC animated:YES];
    }
    else if (sender.tag == 2)
    {
        ScaleTestViewController *scaleVC = [[ScaleTestViewController alloc] init];
        [self.navigationController pushViewController:scaleVC animated:YES];
    }
    else if (sender.tag == 3)
    {
        DataCenterViewController *dataCenterVC = [[DataCenterViewController alloc] init];
        [self.navigationController pushViewController:dataCenterVC animated:YES];
    }
    else if (sender.tag == 4)
    {
        MusicViewController *musicVC = [MusicViewController shareController];
        [self.navigationController pushViewController:musicVC animated:YES];
    }
    else if (sender.tag == 5)
    {
        if ([self isDoctorFirstOpen])
        {
            DocProtocolViewController *docPVC = [[DocProtocolViewController alloc] init];
            [self.navigationController pushViewController:docPVC animated:YES];
        }
        else
        {
            DoctorHomeViewController *doctorVC = [[DoctorHomeViewController alloc] init];
            [self.navigationController pushViewController:doctorVC animated:YES];
        }
    }
    else if (sender.tag == 6)
    {
        MoreFunctionViewController *moreVC = [[MoreFunctionViewController alloc] init];
        [self.navigationController pushViewController:moreVC animated:YES];
    }
}

#pragma mark -- 判断问医生是否是第一次使用
- (BOOL)isDoctorFirstOpen
{
    //判断是否是第一次进入问医生
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DoctorFirstStart"])
    {
        //第一次进入问医生
        NSLog(@"第一次启动");
        
        return YES;
    }
    else
    {
        //不是第一次进入问医生
        NSLog(@"不是第一次启动");
        
        return NO;
    }
}

#pragma mark -- 接收到消息
- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage * message in aMessages)
    {
        if ([message.conversationId isEqualToString:_doctorID])
        {
            _noticePoint.hidden = NO;
        }
    }
}

/*
 * 判断当前日期是否在疗程内
 * 1.如果在疗程内则显示该疗程的治疗清楚
 * 2.如果不在疗程内显示设置疗程的按钮
 */
- (BOOL)judgeCourseOfTreatment
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *nowDate = [NSDate date];
    NSString *nowDateStr = [df stringFromDate:nowDate];
    
    if (_treatmentArray.count > 0)
    {
        TreatmentInfo *treatmentDic = [_treatmentArray objectAtIndex:_treatmentArray.count-1];
        NSString *treatmentEndDateStr = treatmentDic.EndDate;
        NSInteger numOne = [self dateTimeDifferenceWithStartTime:nowDateStr endTime:treatmentEndDateStr];
        
        if (numOne < 0)//表示当前日期不在最近疗程内
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

/* 获取手机型号 */
- (NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    return deviceString;
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
