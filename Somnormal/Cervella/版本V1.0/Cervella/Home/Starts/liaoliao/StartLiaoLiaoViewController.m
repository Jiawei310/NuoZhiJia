//
//  StartLiaoLiaoViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/7.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "StartLiaoLiaoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Define.h"
#import <UMMobClick/MobClick.h>
#import <zlib.h>

#import "SendCommand.h"
#import "DataBaseOpration.h"
#import "InterfaceModel.h"
#import "DataHandle.h"
#import "MSWeakTimer.h"

#import "ModelView.h"
#import "TimeLine.h"
#import "BluetoothStateView.h"
#import "JXTAlertManagerHeader.h"
#import "BindViewController.h"
#import "SetTreatmentViewController.h"
#import "PostWebViewController.h"

@interface StartLiaoLiaoViewController ()<UIScrollViewDelegate,ClickEventDelegate,sendBluetoothValue>//,InterfaceModelDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (nonatomic, strong) BluetoothStateView *bluetoothSV;//设备状态按钮弹出的视图

@property (nonatomic, copy) NSArray *treatmentArray;//疗程数组
@property (nonatomic, copy) NSMutableArray *treatArray;//治疗数据
@property (nonatomic, copy) NSMutableArray *treatmentAndTreatArray;   //所有疗程内的所有治疗数据

@property (nonatomic, strong) UIButton *btnState;//设备状态按钮

//总的视图部分
@property (nonatomic, strong)         UIView *firstView;  //第一部分视图
@property (nonatomic, strong)         UIView *secondView; //第二部分视图
@property (nonatomic, strong)      ModelView *chooseModel;//模式选择视图
@property (nonatomic, strong)   UIScrollView *scrollV;    //滚动View选择条
@property (nonatomic, strong)    UIImageView *imageV;     //展示使用说明的图片框
@property (nonatomic, copy)          NSArray *imageList;  //使用说明的图片
@property (nonatomic, strong) NSMutableArray *postModelList;  //存储滚动View中的Object
@property (nonatomic, strong)    UIImageView *animationV; //治疗时的动画
@property (nonatomic, strong) NSMutableArray *reasonsArr; //存储碎片化失眠原因
@property (nonatomic, assign)      NSInteger isTest;      //是否已做过碎片化（为1表示未做过，为0表示已做过碎片化评估）

//@property(nonatomic, strong) UIVisualEffectView * evaluateView;//碎片化评估界面
@property(nonatomic, strong) UIView * evaluateView;//碎片化评估界面

@property (nonatomic, strong) UIImageView *circleView;//半弧形圆圈
@property (nonatomic, strong)     UILabel *powerLable;//显示强度
@property (nonatomic, assign)   NSInteger percentage; //控制强度的百分比

@property (nonatomic, strong) UIImageView *timeView; //主按钮View（圆形白色按钮）
@property (nonatomic, strong) UIButton *timeBtn;    //显示剩余刺激时间
@property (nonatomic, strong) UIButton *startBtn;   //开始停止按钮
@property (nonatomic, strong) UIButton *subbtn;     //减电流按钮
@property (nonatomic, strong) UIButton *addbtn;     //加电流按钮
@property (nonatomic, assign) int msecCount;   //计数毫秒
@property (nonatomic, assign) int secCount;    //计数秒
@property (nonatomic, assign) int minCount;    //计数分

@property (nonatomic, assign) int percent; //电池百分比

@property (nonatomic, strong)  UIButton *modelBtn; //模式选择按钮
@property (nonatomic, assign) NSInteger styleFirstView;     //开始疗疗界面的视图显示样式（1:第一次启动，显示使用说明 2:开始疗程按钮进入疗程设置 3:显示疗程信息）
@property (nonatomic, assign) NSInteger styleScrollV;       //开始疗疗界面ScrollV中的显示内容样式

@end

@implementation StartLiaoLiaoViewController
{
    DataBaseOpration *dbOpration;           //数据库对象的全局变量
    __strong SendCommand *sendCommand;          //向设备发送命令的对象（封装了发送命令的方法）
    InterfaceModel *interfaceModel;       //向后台服务器请求数据时的借口调用对象（封装了接口调用的方法）
    
    NSString *stateString;//标志是否绑定设备的状态字符串
    
    UIView *view;  //等待动画的门板view
    
    __block int timeout; //用来对刺激过程的计时
    int time;    //存储每个模式下刺激总时间，此变量内存中不变，用于停止后对timeout计时的复位
    int minutes; //记录刺激过程中，剩余刺激总时间的分钟数
    int seconds; //记录刺激过程中，剩余刺激总时间的秒钟数
    dispatch_queue_t queue;   //用于刺激开始计时，多线程下创建的global队列（全局队列）
    dispatch_source_t _timer;  //多线程下，创建的时间资源
    
    NSDate *BegainDate;          //开始刺激时，获取的开始日期
    NSString *BegainTime;        //开始日期在setDateFormat之后，转换成的字符串
    NSString *EndTime;           //结束日期在setDateFormat之后，转换成的字符串
    NSString *CureTime;          //质量多长时间的字符串表示全局变量
    
    NSInteger modelIndex;        //用来记录选择模式的index（0:正常模式；1:刺激模式；2:高强度模式）
    NSInteger electricCurrentNum;//读取本地数据库中电流强度
    
    NSTimer *checkElectric;     //设置阻抗检测的NSTimer对象
    BOOL connectedStateText; //判断设备是否连通
    NSString *order;                   //记录发送命令
    NSString *orderCurrentRegulation;  //记录电流调节发送命令
    NSString *orderSetTimeAndFrequency;//记录设置刺激参数发送命令
    NSString *orderElectricSet;        //记录电流设定发送命令
    NSString *valueAnswer;                   //记录应答数据
    NSMutableArray *stringArray;             //存储应答数据的字符串数组
    NSMutableArray *characteristicArray;     //存储CBCharacteristic对象的特征
    CBCharacteristic *characteristicUUID;      //扫描到蓝牙设备的特征值
    
    int countElectric;                             //记录电量提示弹出次数
    int countElectric_Two;                         //记录电量提示弹出次数
    int countElectric_Three;                       //记录电量大于20%时发送电流调节命令次数
    
    Byte chOUTFinal[8];          //用于存储设备序列号的16进制数的char类型数组
    
    int count;     //用于计数，通过计数结果判断是否创建centralMgr这个对象
    int countAlert;//在5秒钟之后还未连通，刺激时间红黑闪烁
    int countSeconds;//记录自动断开前计时
    
    MSWeakTimer *readElectricQuality;//设置读取电量的NSTimer对象
    BOOL electricQualityAnswer;    //是否收到电量应答数据
    MSWeakTimer *autoDisconnectTimer;//设置自动断开的计时器(每秒执行)
    MSWeakTimer *connectTime;//连接时长
    
    
    Byte chINFinal[8];

}

//StartLiaoLiaoViewController的单例初始化类方法
+ (id)sharedStartLiaoLiaoViewController
{
    static StartLiaoLiaoViewController *startLiaoLiaoVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        startLiaoLiaoVC = [[self alloc] init];
    });
    return startLiaoLiaoVC;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"开始疗疗"];//("PageOne"为页面名称，可自定义)
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"开始疗疗"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //本页标题
    self.navigationItem.title = @"开始疗疗";
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
    //添加右边标题
    _btnState = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [_btnState addTarget:self action:@selector(deviceState) forControlEvents:UIControlEventTouchUpInside];
    [_btnState setBackgroundImage:[UIImage imageNamed:@"img_equipbox_weilian"] forState:(UIControlStateNormal)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:_btnState];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    _patientInfo = [PatientInfo shareInstance];
    
    electricQualityAnswer = NO;
    
    sendCommand = [[SendCommand alloc] init];
    
    //获取网络数据
    interfaceModel = [[InterfaceModel alloc] init];
    
    dbOpration = [[DataBaseOpration alloc] init];
    NSArray *treatInfoArray = [dbOpration getTreatDataFromDataBase];
    NSArray *bluetoothInfoArray = [dbOpration getBluetoothDataFromDataBase];
    _treatArray = [dbOpration getTreatDataFromDataBase];
    [dbOpration closeDataBase];
    
    [self dataHandle];
    
    if (_patientInfo != nil)
    {
        NSMutableArray *treatInfoAtPatientID = [NSMutableArray array];
        for (TreatInfo *tmp in treatInfoArray)
        {
            if ([tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [treatInfoAtPatientID addObject:tmp];
            }
        }
        //判断数据库中是否有治疗数据
        if (treatInfoAtPatientID.count>0)
        {
            _treatInfo = [treatInfoAtPatientID objectAtIndex:treatInfoAtPatientID.count-1];
        }
    }
    
    stringArray=[NSMutableArray array];
    
    if (_treatInfo == nil)
    {
        modelIndex = 0;
        time = 1200;
        timeout = 1200;
        self.percentage = 1;
    }
    else
    {
        time = [_treatInfo.Time intValue]; //倒计时时间
        if ([_treatInfo.Frequency isEqualToString:@"1"])
        {
            modelIndex = 0;
        }
        else if ([_treatInfo.Frequency isEqualToString:@"2"])
        {
            modelIndex = 1;
        }
        else if ([_treatInfo.Frequency isEqualToString:@"3"])
        {
            modelIndex = 2;
        }
        timeout = 1200;
        self.percentage=[_treatInfo.Strength integerValue];
    }
    
    //数据库当中有蓝牙信息说明已绑定，进入开始疗疗直接去连接；如果数据库当中没有则说明未绑定设备
    if (bluetoothInfoArray.count > 0)
    {
        stateString = @"未连接";
        self.bluetoothInfo = [bluetoothInfoArray objectAtIndex:0];
    }
    else
    {
        stateString = @"未绑定";
    }
    
    [self prepareData:[self isLiaoLiaoFirstOpen]];
    [self createFirstViewWithType:_styleFirstView];
    [self createSecondView];
    [self createScrollViewWithStyle:_styleScrollV];
    [self sleepCollecte];
    
    //获取通知中心单例对象(设置疗程完成所需的通知)
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView:) name:@"StartLiaoLiao" object:nil];
    //注册切换用户通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUser) name:@"ChangeUser" object:nil];
    // Do any additional setup after loading the view.
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//切换用户，释放蓝牙绑定信息
- (void)changeUser
{
    if ((_timer != nil) && (timeout != time))
    {
        [self sendStopOrder];
    }
    if (_discoveredPeripheral.state == CBPeripheralStateConnected)
    {
        [_centralMgr cancelPeripheralConnection:_discoveredPeripheral];
    }
    
    if (autoDisconnectTimer != nil)
    {
        [autoDisconnectTimer invalidate];
        countSeconds = 0;
        autoDisconnectTimer = nil;
    }
    
    //按钮恢复点击连接状态（状态为未连接）
    stateString = @"未连接";
    [_btnState setBackgroundImage:[UIImage imageNamed:@"img_equipbox_weilian"] forState:(UIControlStateNormal)];
    [self removeViewFromFatherView:_timeView];
    [self addTimeViewContentView];
}

//电池电量百分比的set方法重写
- (void)setPercent:(int)percent
{
    _percent = percent;
    if (_bluetoothSV != nil)
    {
        _bluetoothSV.percent = percent;
    }
}

//设置疗程之后修改界面的firstView的view加载
- (void)changeView:(NSNotification *)notification
{
    _treatmentDic = notification.userInfo[@"TreatmentInfo"];
    [self removeViewFromFatherView:self.firstView];
    [self addTimeLine:_treatmentDic];
}

- (void)removeViewFromFatherView:(UIView *)subView
{
    NSArray *arr = subView.subviews;
    for(int i = 0; i < [arr count]; i++)
    {
        [[arr objectAtIndex:i] removeFromSuperview];
    }
}

//对请求的网络数据进行处理（疗程信息、治疗数据、评估数据、碎片化数据）
- (void)dataHandle
{
    if (_treatmentDic != nil)
    {
        _treatmentAndTreatArray = [NSMutableArray array];
        
        NSString *startDateStr = _treatmentDic.StartDate;
        NSString *endDateStr = _treatmentDic.EndDate;
        
        if (_treatArray.count > 0)
        {
            NSMutableArray *tmpArray = [NSMutableArray array];
            //将治疗数据按日期分配到对应疗程中
            for (int j = 0; j < _treatArray.count; j++)
            {
                TreatInfo *tmpInfoDic = [_treatArray objectAtIndex:j];
                //日期格式数据库当中各不相同，进行的日期数据处理
                NSString *tmpStr = tmpInfoDic.BeginTime;
                NSString *str_1 = [tmpStr substringWithRange:NSMakeRange(0, 4)];
                NSString *str_2 = [tmpStr substringWithRange:NSMakeRange(5, 2)];
                NSString *str_3 = [tmpStr substringWithRange:NSMakeRange(8, 2)];
                NSString *cureDateStr = [NSString stringWithFormat:@"%@-%@-%@",str_1,str_2,str_3];
                
                NSInteger tmp_one = [self dateTimeDifferenceWithStartTime:startDateStr endTime:cureDateStr];
                NSInteger tmp_two = [self dateTimeDifferenceWithStartTime:cureDateStr endTime:endDateStr];
                if (tmp_one >= 0 && tmp_two >= 0)
                {
                    [tmpArray addObject:tmpInfoDic];
                }
            }
            [_treatmentAndTreatArray addObject:tmpArray];
        }
    }
}

//判断开始疗疗是否是第一次使用
- (BOOL)isLiaoLiaoFirstOpen
{
    //判断是否是第一次启动App
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LiaoLiaoFirstStart"])
    {
        //第一次启动App,给予使用向导
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LiaoLiaoFirstStart"];
        NSLog(@"第一次启动");
        _styleFirstView = 1;
        _styleScrollV = 0;
        
        return YES;
    }
    else
    {
        //不是第一次启动App
        NSLog(@"不是第一次启动");
        //判断是否设置疗程（首先读取本地有没有疗程数据，没有则网络请求：1.有数据则表示有疗程，2.无数据则表示无疗程需要设置疗程）
        [self judgeCourseOfTreatment];
        _styleScrollV = 1;
        
        return NO;
    }
}

//加载所需的数据（包括参数的设置，以及数组数据的添加）
- (void)prepareData:(BOOL)isLiaoLiaoFirstStart
{
    if (isLiaoLiaoFirstStart)
    {
        _isTest = 1;
        self.imageList = @[@"shuoming_image1",@"shuoming_image2",@"shuoming_image3"];
        self.postModelList = [NSMutableArray arrayWithObjects:@"放置毛毡垫圈，将导电液滴在毛毡垫圈上，直至完全湿润。",@"将耳夹电极线插入主机接口。",@"将耳夹电极夹在耳垂上，调节舒适度与治疗模式，开始治疗。", nil];
    }
    else
    {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateNow = [dateFormatter stringFromDate:[NSDate date]];
        NSString *sleepDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"sleepCollection"];
        
        if (sleepDate == nil )
        {
            _isTest = 1;
            [self preparePostData];
        }
        else
        {
            if (![sleepDate isEqualToString:dateNow])
            {
                _isTest = 1;
                [self preparePostData];
            }
            else
            {
                _isTest = 0;
                [self preparePostData];
            }
        }
    }
}

- (void)preparePostData
{
    NSDictionary *dicOne = [NSDictionary dictionaryWithObjectsAndKeys:@"什么是焦虑症？", @"title", @"时代发展太快，生活中又会遇到形形色色的问题和困难，这些都会让我们感到害怕、担心、恐惧、烦躁。简单来说，你就是焦虑了", @"content", @"http://url.cn/44jDkmn", @"url", nil];
    NSDictionary *dicTwo = [NSDictionary dictionaryWithObjectsAndKeys:@"母乳喂养 爱在起点——哺乳期失眠怎么办", @"title", @"5月20日作为全国母乳喂养宣传日，由1990年5月10日卫生部决定的。希望新妈妈们母乳喂养，为爱赢在起点", @"content", @"http://mp.weixin.qq.com/s?__biz=MzAwODc2NTczMw==&mid=2654135204&idx=1&sn=dcb1d08504ca98e73fdc43b5174e48ba&mpshare=1&scene=23&srcid=0208GOpWzlHv4VPJHo1Qe4lZ#rd", @"url", nil];
    NSDictionary *dicThree = [NSDictionary dictionaryWithObjectsAndKeys:@"睡眠障碍", @"title", @"睡眠量不正常以及睡眠中出现异常行为的表现，也是睡眠和觉醒正常节律性交替紊乱的表现。可由多种因素引起，常与躯体疾病有关，包括睡眠失调和异态睡眠。睡眠与人的健康息息相关。", @"content", @"http://mp.weixin.qq.com/s?__biz=MzAwODc2NTczMw==&mid=405763865&idx=1&sn=b47e43dac41f8ec3680ed7e65b4d4a56&mpshare=1&scene=23&srcid=0208d4DHXsmA2zcUm6uVnyzL#rd", @"url", nil];
    _postModelList = [NSMutableArray arrayWithObjects:dicOne, dicTwo, dicThree, nil];
}

/**
 *  疗疗主界面第一部分视图容器
 *  创建第一个部分视图，Type为不同情形的显示，
 *  1--》显示尚未开始第一次使用的界面
 *  2--》尚未开始非第一次使用的界面，未设置疗程
 *  3--》尚未开始非第一次使用的界面，已设置疗程
 *  4--》正在进行中的界面
 */
- (void)createFirstViewWithType:(NSInteger)index
{
    //设置第一部分视图框架大小
    self.firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 194*Rate_NAV_H)];
    self.firstView.backgroundColor = [UIColor colorWithRed:0.21 green:0.76 blue:0.87 alpha:1.00];
    self.firstView.userInteractionEnabled = YES;
    [self.view addSubview:self.firstView];
    if (index == 1)
    {
        //显示尚未开始第一次使用的界面无疗程
        self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(123*Rate_NAV_W, 21*Rate_NAV_H, 129*Rate_NAV_W, 118*Rate_NAV_H)];
        _imageV.image = [UIImage imageNamed:_imageList[0]];
        [self.firstView addSubview:_imageV];
    }
    else if (index == 2)
    {
        //显示尚未开始非第一次使用的界面无疗程
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(59*Rate_NAV_W, 27*Rate_NAV_H, 41*Rate_NAV_H, 37*Rate_NAV_H)];
        imageV.image = [UIImage imageNamed:@"icon_疗程.png"];
        [self.firstView addSubview:imageV];
        
        UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame) + 13*Rate_NAV_W, 21*Rate_NAV_H, 198*Rate_NAV_W, 24*Rate_NAV_H)];
        lable1.text = @"疗程能帮助您更科学的治疗";
        lable1.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        lable1.adjustsFontSizeToFitWidth = YES;
        lable1.textColor = [UIColor whiteColor];
        [self.firstView addSubview:lable1];
        
        UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame) + 13*Rate_W, CGRectGetMaxY(lable1.frame), 198*Rate_NAV_W, 24*Rate_NAV_H)];
        lable2.text = @"是否开始属于您的疗程?";
        lable2.textColor = [UIColor whiteColor];
        lable2.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        lable2.adjustsFontSizeToFitWidth = YES;
        [self.firstView addSubview:lable2];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - 100*Rate_NAV_H)/2, CGRectGetMaxY(lable2.frame) + 20*Rate_NAV_H, 100*Rate_NAV_H, 30*Rate_NAV_H)];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        [button setTitle:@"开始疗程" forState:(UIControlStateNormal)];
        //跳转至设置疗程
        [button addTarget:self action:@selector(setTreament) forControlEvents:(UIControlEventTouchUpInside)];
        [self.firstView addSubview:button];
    }
    else if (index == 3)
    {
        //时间轴
        [self addTimeLine:_treatmentDic];
    }
    else
    {
        //正在进行时
        _animationV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30*Rate_NAV_H, 375*Rate_NAV_W, 95*Rate_NAV_H)];
        NSMutableArray  *arrayM=[NSMutableArray array];
        for (int i = 1; i < 6; i++)
        {
            [arrayM addObject:[UIImage imageNamed:[NSString stringWithFormat:@"wave_%d.png",i+1]]];
        }
        //设置动画数组
        [_animationV setAnimationImages:arrayM];
        //设置动画播放次数
        [_animationV setAnimationRepeatCount:0];
        //设置动画播放时间
        [_animationV setAnimationDuration:20*0.075];
        //开始动画
        [_animationV startAnimating];
        [self.firstView addSubview:_animationV];
    }
}

- (void)addTimeLine:(TreatmentInfo *)treatmentDic
{
    NSMutableArray *timeArray = [NSMutableArray array];
    NSArray *treatDataAndTreatmentArray;
    NSInteger timeCount = 0;
    if (_treatmentAndTreatArray.count > 0)
    {
        treatDataAndTreatmentArray = [_treatmentAndTreatArray objectAtIndex:_treatmentAndTreatArray.count-1];
        //处理数据（判断疗程内每天的使用情况）
        for (int i = 0; i < 28; i++)
        {
            NSString *startDateStr = treatmentDic.StartDate;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *startDate = [dateFormatter dateFromString:startDateStr];
            NSDate *treatDate = [startDate dateByAddingTimeInterval:i*24*3600];
            NSString *treatDateStr = [dateFormatter stringFromDate:treatDate];
            NSDictionary *timeDic;
            for (TreatInfo *tmpDic in treatDataAndTreatmentArray)
            {
                //日期格式数据库当中各不相同，进行的日期数据处理
                NSString *tmpStr = tmpDic.BeginTime;
                NSString *str_1 = [tmpStr substringWithRange:NSMakeRange(0, 4)];
                NSString *str_2 = [tmpStr substringWithRange:NSMakeRange(5, 2)];
                NSString *str_3 = [tmpStr substringWithRange:NSMakeRange(8, 2)];
                NSString *cureDateStr = [NSString stringWithFormat:@"%@-%@-%@",str_1,str_2,str_3];
                if ([cureDateStr isEqualToString:treatDateStr])
                {
                    timeDic = [NSDictionary dictionaryWithObjectsAndKeys:@"1",treatDateStr, nil];
                    
//                    timeout++;
                }
            }
            if (timeDic == nil)
            {
                timeDic = [NSDictionary dictionaryWithObjectsAndKeys:@"0",treatDateStr, nil];
                [timeArray addObject:timeDic];
            }
            else
            {
                [timeArray addObject:timeDic];
            }
        }
    }
    else
    {
        //处理数据（判断疗程内每天的使用情况）
        for (int i = 0; i < 28; i++)
        {
            NSString *startDateStr = treatmentDic.StartDate;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *startDate = [dateFormatter dateFromString:startDateStr];
            NSDate *treatDate = [startDate dateByAddingTimeInterval:i*24*3600];
            NSString *treatDateStr = [dateFormatter stringFromDate:treatDate];
            
            NSDictionary *timeDic = [NSDictionary dictionaryWithObjectsAndKeys:@"0",treatDateStr, nil];
            [timeArray addObject:timeDic];
        }
    }
    
    //判断疗程完成情况
    if (timeCount >= 9)
    {
        NSString *strOne = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@13",_treatmentDic.StartDate]];
        if (strOne == nil)
        {
            //更新服务器积分
            InterfaceModel *mod = [[InterfaceModel alloc] init];
            [mod uploadPointToServer:_patientInfo.PatientID pointType:@"2"];
            //此处利用NSUserDefaults进行标记
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            NSString *currentDateStr = [df stringFromDate:[NSDate date]];
            
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            [userDefault setObject:currentDateStr forKey:[NSString stringWithFormat:@"%@13",_treatmentDic.StartDate]];
        }
    }
    else if (timeCount >= 19)
    {
        NSString *strOne = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@23",_treatmentDic.StartDate]];
        if (strOne == nil)
        {
            //更新服务器积分
            InterfaceModel *mod = [[InterfaceModel alloc] init];
            [mod uploadPointToServer:_patientInfo.PatientID pointType:@"3"];
            //此处利用NSUserDefaults进行标记
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            NSString *currentDateStr = [df stringFromDate:[NSDate date]];
            
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            [userDefault setObject:currentDateStr forKey:[NSString stringWithFormat:@"%@23",_treatmentDic.StartDate]];
        }
    }
    else if (timeCount == 28)
    {
        NSString *strOne = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@33",_treatmentDic.StartDate]];
        if (strOne == nil)
        {
            //更新服务器积分
            InterfaceModel *mod = [[InterfaceModel alloc] init];
            [mod uploadPointToServer:_patientInfo.PatientID pointType:@"4"];
            //此处利用NSUserDefaults进行标记
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            NSString *currentDateStr = [df stringFromDate:[NSDate date]];
            
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            [userDefault setObject:currentDateStr forKey:[NSString stringWithFormat:@"%@33",_treatmentDic.StartDate]];
        }
    }
    
    //时间轴
    TimeLine *timeLineV = [[TimeLine alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 180*Rate_NAV_H) andData:timeArray];
    [self.firstView addSubview:timeLineV];
}

/*
 * 判断当前日期是否在疗程内
 * 1.如果在疗程内则显示该疗程的治疗清楚
 * 2.如果不在疗程内显示设置疗程的按钮
 */
- (void)judgeCourseOfTreatment
{
    if (_isInCourse)
    {
        _styleFirstView = 3;
    }
    else
    {
        _styleFirstView = 2;
    }
}

//开始疗疗界面当中中间的滑动View（首次进入显示使用说明，以后显示Tips以及眠友圈的精选帖子）
- (void)createScrollViewWithStyle:(NSInteger)style
{
    self.scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 147*Rate_NAV_H, 375*Rate_NAV_W, 90*Rate_NAV_H)];
    
    self.scrollV.delegate = self;
    self.scrollV.scrollEnabled = YES;
    self.scrollV.pagingEnabled = YES;
    self.scrollV.showsHorizontalScrollIndicator = NO;
    self.scrollV.showsVerticalScrollIndicator = NO;
    if (style == 1)
    {
        self.scrollV.contentSize = CGSizeMake(SCREENWIDTH*(_postModelList.count + _isTest), 90*Rate_NAV_H);
        for (int i = 0; i <_postModelList.count; i++)
        {
            UIButton *bottomView = [[UIButton alloc] initWithFrame:CGRectMake(15*Rate_NAV_W + (SCREENWIDTH)*i, 0, 345*Rate_NAV_W, 90*Rate_NAV_H)];
            bottomView.userInteractionEnabled = YES;
            bottomView.layer.cornerRadius = 5*Rate_NAV_H;
            bottomView.clipsToBounds = YES;
            bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            bottomView.layer.borderWidth = 0.2*Rate_NAV_H;
            bottomView.backgroundColor = [UIColor whiteColor];
            [bottomView addTarget:self action:@selector(postDetail:) forControlEvents:(UIControlEventTouchUpInside)];
            [self.scrollV addSubview:bottomView];
            
            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(10*Rate_NAV_W, 10*Rate_NAV_H, 325*Rate_NAV_W, 20*Rate_NAV_H)];
            bottomView.tag = i+1;
            NSDictionary *tmp = _postModelList[i];
            lable.text = [tmp objectForKey:@"title"];
            lable.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
            lable.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
            lable.adjustsFontSizeToFitWidth = YES;
            [bottomView addSubview:lable];
            
            UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, CGRectGetMaxY(lable.frame) + 5*Rate_NAV_H, bottomView.frame.size.width - 20*Rate_NAV_W, 45*Rate_NAV_H)];
            content.numberOfLines = 0;
            content.text = [tmp objectForKey:@"content"];
            content.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
            content.adjustsFontSizeToFitWidth = YES;
            [bottomView addSubview:content];
        }
        
        [self.view addSubview:self.scrollV];
        
        //强制跳出碎片化搜集
        if (_isTest == 1)//强制弹出
        {
//            [self sleepCollecte];
        }
    }
    else
    {
        self.scrollV.contentSize = CGSizeMake(SCREENWIDTH*self.postModelList.count, 90*Rate_NAV_H);
        self.scrollV.delegate = self;
        for (int i = 0; i < self.imageList.count; i++)
        {
            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(15*Ratio + (SCREENWIDTH)*i, 0, SCREENWIDTH-30, 90)];
            bottomView.layer.cornerRadius = 5;
            bottomView.clipsToBounds = YES;
            bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            bottomView.layer.borderWidth = 0.5;
            bottomView.backgroundColor = [UIColor whiteColor];
            [self.scrollV addSubview:bottomView];
            
            UIImageView *littleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
            littleImage.image = [UIImage imageNamed:@"使用说明 icon.png"];
            [bottomView addSubview:littleImage];
            
            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(littleImage.frame)+8, 10, bottomView.frame.size.width-38, 20)];
            lable.font = [UIFont systemFontOfSize:14];
            lable.text = @"使用说明:";
            lable.textColor = [UIColor colorWithRed:0x39/255.0 green:0x8A/255.0 blue:0xFF/255.0 alpha:1];
            lable.adjustsFontSizeToFitWidth = YES;
            [bottomView addSubview:lable];
            
            UILabel *index = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lable.frame)+10, 30, 30)];
            index.layer.cornerRadius = 15;
            index.layer.borderColor = [UIColor lightGrayColor].CGColor;
            index.layer.borderWidth = 0.5;
            index.text = [NSString stringWithFormat:@"%i",i+1];
            index.adjustsFontSizeToFitWidth = YES;
            index.textAlignment = NSTextAlignmentCenter;
            [bottomView addSubview:index];
            
            UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(index.frame)+8, CGRectGetMaxY(lable.frame), bottomView.frame.size.width-10-(CGRectGetMaxX(index.frame)+8), 45)];
            content.numberOfLines = 0;
            content.font = [UIFont systemFontOfSize:16];
            content.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
            content.text = _postModelList[i];
            content.adjustsFontSizeToFitWidth = YES;
            [bottomView addSubview:content];
        }
        
        [self.view addSubview:self.scrollV];
    }
}

#pragma mark -- 跳转至帖子详情
- (void)postDetail:(UIButton *)btn
{
    if (btn.tag == 1)
    {
        PostWebViewController *postWebVC = [[PostWebViewController alloc] init];
        NSDictionary *tmpDic = _postModelList[0];
        postWebVC.postURL = [tmpDic objectForKey:@"url"];
        [self.navigationController pushViewController:postWebVC animated:YES];
    }
    else if (btn.tag == 2)
    {
        PostWebViewController *postWebVC = [[PostWebViewController alloc] init];
        NSDictionary *tmpDic = _postModelList[1];
        postWebVC.postURL = [tmpDic objectForKey:@"url"];
        [self.navigationController pushViewController:postWebVC animated:YES];
    }
    else if (btn.tag == 3)
    {
        PostWebViewController *postWebVC = [[PostWebViewController alloc] init];
        NSDictionary *tmpDic = _postModelList[2];
        postWebVC.postURL = [tmpDic objectForKey:@"url"];
        [self.navigationController pushViewController:postWebVC animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x == 0)
    {
        self.imageV.frame = CGRectMake(123*Ratio_NAV_W, 21*Ratio_NAV_H, 129*Ratio_NAV_W, 118*Ratio_NAV_H);
        self.imageV.image = [UIImage imageNamed:@"shuoming_image1"];
    }
    else if (scrollView.contentOffset.x == SCREENWIDTH)
    {
        self.imageV.frame = CGRectMake(145*Ratio_NAV_W, 29*Ratio_NAV_H, 84*Ratio_NAV_W, 97*Ratio_NAV_H);
        self.imageV.image = [UIImage imageNamed:@"shuoming_image2"];
    }
    else if (scrollView.contentOffset.x == SCREENWIDTH*2)
    {
        self.imageV.frame = CGRectMake(125*Ratio_NAV_W, 8*Ratio_NAV_H, 126*Ratio_NAV_W, 194*Ratio_NAV_H);
        self.imageV.image = [UIImage imageNamed:@"shuoming_image3"];
    }
}

/**
 *  疗疗主界面下半部分视图容器
 */
- (void)createSecondView
{
    self.secondView = [[UIView alloc]initWithFrame:CGRectMake(0, 194*Rate_NAV_H, 375*Rate_NAV_W, SCREENHEIGHT - 194*Rate_NAV_H)];
    self.secondView.userInteractionEnabled = YES;
    [self.view addSubview:self.secondView];
    
    //模式选择按钮
    _modelBtn = [[UIButton alloc]initWithFrame:CGRectMake(270*Rate_NAV_W, 60*Rate_NAV_H, 90*Rate_NAV_W, 20*Rate_NAV_H)];
    _modelBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    if (modelIndex == 0)
    {
        [_modelBtn setTitle:@"正常模式" forState:(UIControlStateNormal)];
    }
    else if (modelIndex == 1)
    {
        [_modelBtn setTitle:@"刺激模式" forState:(UIControlStateNormal)];
    }
    else if (modelIndex == 2)
    {
        [_modelBtn setTitle:@"高强度模式" forState:(UIControlStateNormal)];
    }
    
    [_modelBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    [_modelBtn addTarget:self action:@selector(modelChoose:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.secondView addSubview:_modelBtn];
    
    //强度表盘
    self.circleView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 244*Rate_NAV_H)/2, CGRectGetMaxY(_modelBtn.frame) + 20*Rate_NAV_H, 244*Rate_NAV_H, 200*Rate_NAV_H)];
    self.circleView.image = [UIImage imageNamed:[NSString stringWithFormat:@"strength%li.png",(long)self.percentage]];
    self.circleView.userInteractionEnabled = YES;
    [self.secondView addSubview:self.circleView];
    
    //时间视图
    _timeView = [[UIImageView alloc] initWithFrame:CGRectMake(22*Rate_NAV_H, 22*Rate_NAV_H, 200*Rate_NAV_H, 200*Rate_NAV_H)];
    _timeView.image = [UIImage imageNamed:@"主按钮.png"];
    _timeView.userInteractionEnabled = YES;
    [self.circleView addSubview:_timeView];
    
    //强度显示
    _powerLable = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.circleView.frame) + 20*Rate_NAV_H, 375*Rate_NAV_W, 40*Rate_NAV_H)];
    _powerLable.text = [NSString stringWithFormat:@"强度%li",(long)self.percentage];
    _powerLable.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    _powerLable.textAlignment = NSTextAlignmentCenter;
    _powerLable.font = [UIFont boldSystemFontOfSize:15*Rate_NAV_H];
    [self.secondView addSubview:_powerLable];
    
    //减电流按钮
    _subbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _subbtn.frame  = CGRectMake(CGRectGetMinX(self.circleView.frame) + 15*Rate_NAV_H,  CGRectGetMaxY(self.circleView.frame) + 20*Rate_NAV_H, 30*Rate_NAV_H, 30*Rate_NAV_H);
    _subbtn.layer.cornerRadius = 15*Ratio;
    _subbtn.tag = 101;
    [_subbtn setImage:[UIImage imageNamed:@"减.png"] forState:(UIControlStateNormal)];
    [_subbtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondView addSubview:_subbtn];
    
    //加电流按钮
    _addbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addbtn.frame = CGRectMake(CGRectGetMaxX(self.circleView.frame) - 45*Rate_NAV_H, CGRectGetMaxY(self.circleView.frame) + 20*Rate_NAV_H, 30*Rate_NAV_H, 30*Rate_NAV_H);
    _addbtn.layer.cornerRadius = 15*Rate_NAV_H;
    _addbtn.clipsToBounds = YES;
    _addbtn.tag = 102;
    [_addbtn setImage:[UIImage imageNamed:@"加.png"] forState:(UIControlStateNormal)];
    [_addbtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondView addSubview:_addbtn];
    
    [self addTimeViewContentView];
}

- (void)addTimeViewContentView
{
    
    UIButton *stateBtn = [[UIButton alloc] initWithFrame:CGRectMake(41*Rate_NAV_H, 70*Rate_NAV_H, 118*Rate_NAV_H, 30*Rate_NAV_H)];
    stateBtn.titleLabel.font = [UIFont systemFontOfSize:22*Rate_NAV_H];
    [stateBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
    [stateBtn setTitle:[NSString stringWithFormat:@"设备%@", stateString] forState:UIControlStateNormal];
    [stateBtn addTarget:self action:@selector(clickConnectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_timeView addSubview:stateBtn];
    
    UIButton *clickConnectBtn = [[UIButton alloc] initWithFrame:CGRectMake(62*Rate_NAV_H, 110*Ratio_NAV_H, 76*Rate_NAV_H, 17*Ratio_NAV_H)];
    clickConnectBtn.titleLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    clickConnectBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [clickConnectBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
    [clickConnectBtn setTitle:@"点击即可连接" forState:UIControlStateNormal];
    [clickConnectBtn addTarget:self action:@selector(clickConnectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_timeView addSubview:clickConnectBtn];
    
    [self setViewUserInteractionEnabled:NO];
}

//设置未连接时按钮不可点击，以及连接之后恢复点击
- (void)setViewUserInteractionEnabled:(BOOL)isUserInteraction
{
    if (isUserInteraction)
    {
        [_modelBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
        _modelBtn.userInteractionEnabled = YES;
        _circleView.image = [UIImage imageNamed:[NSString stringWithFormat:@"strength%li.png",(long)self.percentage]];
        [_subbtn setImage:[UIImage imageNamed:@"减"] forState:UIControlStateNormal];
        _subbtn.userInteractionEnabled = YES;
        [_addbtn setImage:[UIImage imageNamed:@"加"] forState:UIControlStateNormal];
        _addbtn.userInteractionEnabled = YES;
        _powerLable.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    }
    else
    {
        [_modelBtn setTitleColor:[UIColor colorWithRed:0xD4/255.0 green:0xD7/255.0 blue:0xDA/255.0 alpha:1] forState:UIControlStateNormal];
        _modelBtn.userInteractionEnabled = NO;
        _circleView.image = [UIImage imageNamed:@"strength0"];
        [_subbtn setImage:[UIImage imageNamed:@"减_no"] forState:UIControlStateNormal];
        _subbtn.userInteractionEnabled = NO;
        [_addbtn setImage:[UIImage imageNamed:@"加_no"] forState:UIControlStateNormal];
        _addbtn.userInteractionEnabled = NO;
        _powerLable.textColor = [UIColor colorWithRed:0xD4/255.0 green:0xD7/255.0 blue:0xDA/255.0 alpha:1];
    }
}

- (void)clickConnectBtnClick:(UIButton *)sender
{
    if ([stateString isEqualToString:@"未绑定"])
    {
        BindViewController *bindVC = [[BindViewController alloc] init];
        bindVC.bindFlag = sender.titleLabel.text;
        NSLog(@"%@",sender.titleLabel.text);
        bindVC.blueDelegate = self;
        [self.navigationController pushViewController:bindVC animated:YES];

    }
    else if ([stateString isEqualToString:@"未连接"])
    {
        //1.创建CBCentralManager
        self.centralMgr=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
        stateString = @"连接中";
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        if (_bluetoothSV == nil)
        {
            _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:nil andPercent:_percent];
            _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
            _bluetoothSV.clickDelegate = self;
            [view addSubview:_bluetoothSV];
        }
        else
        {
            [_bluetoothSV removeFromSuperview];
            _bluetoothSV = nil;
            _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:nil andPercent:_percent];
            _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
            _bluetoothSV.clickDelegate = self;
            [view addSubview:_bluetoothSV];
        }
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestureRemove:)];
        [view addGestureRecognizer:tapGesture];
        
        //开始计时20秒（超过20秒则判断为连接超时）
        if (connectTime != nil)
        {
            connectTime = nil;
            connectTime = [MSWeakTimer scheduledTimerWithTimeInterval:20.0
                                                               target:self
                                                             selector:@selector(changeDeviceState)
                                                             userInfo:nil
                                                              repeats:NO
                                                        dispatchQueue:dispatch_get_main_queue()];
        }
        else
        {
            connectTime = [MSWeakTimer scheduledTimerWithTimeInterval:20.0
                                                               target:self
                                                             selector:@selector(changeDeviceState)
                                                             userInfo:nil
                                                              repeats:NO
                                                        dispatchQueue:dispatch_get_main_queue()];
        }
    }
}

- (void)changeDeviceState
{
    if (![stateString isEqualToString:@"已连接"])
    {
        stateString = @"未找到";
        if (connectTime != nil)
        {
            [connectTime invalidate];
            connectTime = nil;
        }
        //取消一分钟自动断开定时
        [autoDisconnectTimer invalidate];
        countSeconds = 0;
        autoDisconnectTimer = nil;
        //让蓝牙停止连接设备
        [_centralMgr stopScan];
        if (_discoveredPeripheral)
        {
            [_centralMgr cancelPeripheralConnection:_discoveredPeripheral];
        }
        
        if (_bluetoothSV != nil)
        {
            [_bluetoothSV removeFromSuperview];
            _bluetoothSV = nil;
            _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:nil andPercent:_percent];
            _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
            _bluetoothSV.clickDelegate = self;
            [view addSubview:_bluetoothSV];
        }
        else
        {
            _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:nil andPercent:_percent];
            _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
            _bluetoothSV.clickDelegate = self;
            [view addSubview:_bluetoothSV];
        }
        
        //设置3秒后连接成功的提示View自动消失
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeViewFromSuperView) userInfo:nil repeats:NO];
    }
}

#pragma mark 弹出设备状态View覆盖在界面上（根据stateString这个全局变量的值判断弹出什么样的BluetoothStateView来显示状态）
- (void)deviceState
{
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    if (_bluetoothSV != nil)
    {
        [_bluetoothSV removeFromSuperview];
        _bluetoothSV = nil;
        _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:_BLEinfo.localName andPercent:_percent];
        _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
        _bluetoothSV.clickDelegate = self;
        [view addSubview:_bluetoothSV];
    }
    else
    {
        _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:_BLEinfo.localName andPercent:_percent];
        _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
        _bluetoothSV.clickDelegate = self;
        [view addSubview:_bluetoothSV];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestureRemove:)];
    [view addGestureRecognizer:tapGesture];
}

//点击弹出view之外的地方清楚弹出的view
- (void)handletapPressGestureRemove:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<_bluetoothSV.frame.origin.x || point.x >_bluetoothSV.frame.origin.x+_bluetoothSV.frame.size.width || point.y<_bluetoothSV.frame.origin.y || point.y>_bluetoothSV.frame.origin.y+_bluetoothSV.frame.size.height)
    {
        [_bluetoothSV removeFromSuperview];
        [view removeFromSuperview];
        
        /*此处将_bluetoothSV置空是方便状态切换之后，弹出正确的view
         *如果不布置空弹出的始终都是进入开始疗疗时创建的_bluetoothSV界面
         */
        _bluetoothSV = nil;
    }
}

#pragma mark -- BluetoothStateView中的ClickEventDelegate代理方法
//代理BluetoothStateView做其界面上的按钮点击事件处理
- (void)doClickEvent:(UIButton *)sender andType:(NSString *)btnType
{
    [_bluetoothSV removeFromSuperview];
    [view removeFromSuperview];
    _bluetoothSV = nil;
    
    if ([btnType isEqualToString:@"搜索"])
    {
        BindViewController *bindVC = [[BindViewController alloc] init];
        bindVC.bindFlag = sender.titleLabel.text;
        NSLog(@"%@",sender.titleLabel.text);
        bindVC.blueDelegate = self;
        [self.navigationController pushViewController:bindVC animated:YES];
    }
    else if ([btnType isEqualToString:@"更换设备"])
    {
        //判断设备是否连接
        /*
         *1.已连接：断开蓝牙连接，再跳转到搜索界面，并清除蓝牙信息内存中的数据
         *2.其他：直接跳转到搜索界面，并清除蓝牙信息内存中的数据
         */
        if ([stateString isEqualToString:@"已连接"])
        {
            //每秒一致发送的阻抗检测停止
            if (checkElectric)
            {
                [checkElectric invalidate];
                checkElectric = nil;
            }
            if (readElectricQuality)
            {
                [readElectricQuality invalidate];
                readElectricQuality = nil;
            }
            [self sendStopOrder];
            //停止之后会有一个60s的断开蓝牙计时，避免重复断开，将计时取消
            [autoDisconnectTimer invalidate];
            countSeconds = 0;
            autoDisconnectTimer = nil;
            //断开蓝牙
            [_centralMgr cancelPeripheralConnection:_discoveredPeripheral];
            //按钮恢复点击连接状态（状态为未连接）
            stateString = @"未连接";
            [_btnState setBackgroundImage:[UIImage imageNamed:@"img_equipbox_weilian"] forState:(UIControlStateNormal)];
            [self removeViewFromFatherView:_timeView];
            [self addTimeViewContentView];
        }
        
        //跳转到搜索界面
        BindViewController *bindVC = [[BindViewController alloc] init];
        bindVC.bindFlag = sender.titleLabel.text;
        NSLog(@"%@",sender.titleLabel.text);
        bindVC.blueDelegate = self;
        [self.navigationController pushViewController:bindVC animated:YES];
    }
}
- (void)tryAgainClickEvent:(UIButton *)sender
{
    stateString = @"连接中";
    [_centralMgr scanForPeripheralsWithServices:nil options:nil];
    if (_bluetoothSV != nil)
    {
        [_bluetoothSV removeFromSuperview];
        _bluetoothSV = nil;
        _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:nil andPercent:_percent];
        _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
        _bluetoothSV.clickDelegate = self;
        [view addSubview:_bluetoothSV];
    }
    else
    {
        _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:nil andPercent:_percent];
        _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
        _bluetoothSV.clickDelegate = self;
        [view addSubview:_bluetoothSV];
    }
    if (connectTime != nil)
    {
        connectTime = nil;
        connectTime = [MSWeakTimer scheduledTimerWithTimeInterval:20.0
                                                           target:self
                                                         selector:@selector(changeDeviceState)
                                                         userInfo:nil
                                                          repeats:NO
                                                    dispatchQueue:dispatch_get_main_queue()];
    }
    else
    {
        connectTime = [MSWeakTimer scheduledTimerWithTimeInterval:20.0
                                                           target:self
                                                         selector:@selector(changeDeviceState)
                                                         userInfo:nil
                                                          repeats:NO
                                                    dispatchQueue:dispatch_get_main_queue()];
    }
}

//BindViewController当中的代理方法实现，将BindViewController中的值传递到开始疗疗界面(设备绑定)
- (void)sendBluetoothValueToStartLiaoLiao:(BLEInfo *)bleInfo andBluetooth:(BluetoothInfo *)bluetoothInfo
{
    _BLEinfo = bleInfo;
    _centralMgr = nil;
    
    //绑定连接之后开始疗疗界面的蓝牙操作
    if (_bluetoothInfo==nil)
    {
        _bluetoothInfo=[[BluetoothInfo alloc] init];
        _discoveredPeripheral=_BLEinfo.discoveredPeripheral;
        _bluetoothInfo.deviceName = _BLEinfo.localName;
        _bluetoothInfo.peripheralIdentify=_discoveredPeripheral.identifier.UUIDString;
        
        _bluetoothInfo.deviceCode = nil;
        _bluetoothInfo.deviceElectric = nil;
    }
    else
    {
        _discoveredPeripheral=_BLEinfo.discoveredPeripheral;
        _bluetoothInfo.deviceName = _BLEinfo.localName;
        _bluetoothInfo.peripheralIdentify=_discoveredPeripheral.identifier.UUIDString;
        
        _bluetoothInfo.deviceCode = nil;
        _bluetoothInfo.deviceElectric = nil;
    }
    _bluetoothInfo.saveId=@"1";
    if (_discoveredPeripheral)
    {
        //1.创建CBCentralManager
        self.centralMgr=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
        //更改stateString设备状态字符串，此时修改为“连接中”，等待连接上之后修改为“已连接”
        stateString = @"连接中";
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        if (_bluetoothSV == nil)
        {
            _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:nil andPercent:_percent];
            _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
            _bluetoothSV.clickDelegate = self;
            [view addSubview:_bluetoothSV];
        }
        //阻抗检测
        checkElectric = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(detectionPersecondsForImpedance) userInfo:nil repeats:YES];
        NSRunLoop *runLoop=[NSRunLoop currentRunLoop];
        [runLoop addTimer:checkElectric forMode:NSRunLoopCommonModes];
        [checkElectric fire];
        //读取电量
        readElectricQuality = [MSWeakTimer scheduledTimerWithTimeInterval:1.0
                                                                   target:self
                                                                 selector:@selector(sendElectricQuantity)
                                                                 userInfo:nil
                                                                  repeats:YES
                                                            dispatchQueue:dispatch_get_main_queue()];
        //读取序列号
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(readAndSendDeviceInfo) userInfo:nil repeats:NO];
    }
    
    _arrayServices = [[NSMutableArray alloc] init];
    
    characteristicUUID=[CBCharacteristic new];
    characteristicArray=[[NSMutableArray alloc] init];
    _characteristicNum = 0;
    
    minutes = time/60;
    seconds = time%60;
}

//读取设备序列号借口调用方法
- (void)readAndSendDeviceInfo
{
    [sendCommand sendGetDeviceInfo:_discoveredPeripheral characteristics:characteristicArray];
}

#pragma mark -- 控制计时器的开始与暂停
- (void)timeStart:(UIButton *)btn
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doSomething:) object:btn];
    [self performSelector:@selector(doSomething:) withObject:btn afterDelay:0.5f];
}

- (void)doSomething:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"开始"])
    {
        [sender setTitle:@"停止" forState:(UIControlStateNormal)];
        //发送切换通道状态命令，设置通道参数为电流调节
        orderCurrentRegulation = [sendCommand sendSwitchChannelStateOrder:_discoveredPeripheral characteristics:characteristicArray state:discoveredPeripheralStateCurrentRegulation];

        //发送读取电量命令
        //读取电量
        [self sendElectricQuantity];
        
    }
    else
    {
        [sender setTitle:@"开始" forState:(UIControlStateNormal)];
        [self sendStopOrder];
    }
}

#pragma mark -- 通过增加、减少控制电流强弱
- (void)changeValue:(UIButton *)sender
{
    if (sender.tag == 102)
    {
        if (self.percentage < 12)
        {
            self.percentage = self.percentage+1;
            _powerLable.text = [NSString stringWithFormat:@"强度%li",(long)self.percentage];
            self.circleView.image = [UIImage imageNamed:[NSString stringWithFormat:@"strength%li.png",(long)self.percentage]];
            dispatch_async(dispatch_get_main_queue(), ^{
                //硬件数值改动
                [sendCommand sendElectricSetOrder:_discoveredPeripheral characteristics:characteristicArray currentnumOfElectric:self.percentage];
            });
        }
    }
    else
    {
        if (self.percentage > 1)
        {
            self.percentage = self.percentage-1;
            _powerLable.text = [NSString stringWithFormat:@"强度%li",(long)self.percentage];
            self.circleView.image = [UIImage imageNamed:[NSString stringWithFormat:@"strength%li.png",(long)self.percentage]];
            dispatch_async(dispatch_get_main_queue(), ^{
                //硬件数值改动
                [sendCommand sendElectricSetOrder:_discoveredPeripheral characteristics:characteristicArray currentnumOfElectric:self.percentage];
            });
        }
    }
}

#pragma mark --- 模式选择
- (void)modelChoose:(UIButton *)sender
{
    /**
     *  设置条件，刺激过程当中模式按钮不可点击，并提示“请先停止刺激”
     *  未连接时提示“请先连接疗疗失眠”
     */
    if (timeout == 1200)
    {
        if ([stateString isEqualToString:@"已连接"])
        {
            //跳转模式选择
            //模式选择视图
            [self.navigationController setNavigationBarHidden:YES];
            _chooseModel = [[ModelView alloc] initWithFrame:self.view.bounds ModelTitle:sender.titleLabel.text];
            [self.view addSubview:_chooseModel];
            
            __block id safeChooseModel = _chooseModel;
            __block id safeModelBtn = _modelBtn;
            __weak typeof(self) weakSelf = self;
            _chooseModel.modelBlock = ^(NSString *modelValue){
                if ([modelValue isEqualToString:@"正常模式"])
                {
                    modelIndex = 0;
                    [safeModelBtn setTitle:@"正常模式" forState:(UIControlStateNormal)];
                }
                else if ([modelValue isEqualToString:@"刺激模式"])
                {
                    modelIndex = 1;
                    [safeModelBtn setTitle:@"刺激模式" forState:(UIControlStateNormal)];
                }
                else if ([modelValue isEqualToString:@"高强度模式"])
                {
                    modelIndex = 2;
                    [safeModelBtn setTitle:@"高强度模式" forState:(UIControlStateNormal)];
                }
                
                [safeChooseModel removeFromSuperview];
                [weakSelf.navigationController setNavigationBarHidden:NO];
            };
        }
        else
        {
            //提示“请先连接疗疗失眠”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"请先连接疗疗失眠");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
    }
    else
    {
        //提示“请先停止刺激”
        jxt_showTextHUDTitleMessage(@"温馨提示", @"请先停止治疗");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
}

#pragma mark -- 模式选择确定，接受通知改变数值
- (void)modelChange:(NSNotification *)text
{
    [_chooseModel removeFromSuperview];
    [_modelBtn setTitle:text.userInfo[@"modelValue"] forState:(UIControlStateNormal)];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark --- 跳转至设置疗程界面
- (void)setTreament
{
    //跳转至设置疗程界面
    SetTreatmentViewController *setVC = [[SetTreatmentViewController alloc] init];
    setVC.VCType = @"开始疗疗";
    [self.navigationController pushViewController:setVC animated:YES];
}

#pragma mark --- 碎片化收集
- (void)sleepCollecte
{
    //初始化存储没睡好原因的数组
    _reasonsArr = [NSMutableArray array];
    //跳转至碎片化评估
    //毛玻璃效果,隐盖底层视图
    [self.navigationController setNavigationBarHidden:YES];
    _evaluateView = [[UIView alloc] init];
    _evaluateView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);

    UIVisualEffectView *effectView =[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    effectView.userInteractionEnabled = YES;
    [_evaluateView addSubview:effectView];
    [self.view addSubview:_evaluateView];
    
    //碎片化评估框
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 76*Rate_H, 335*Rate_W, 516*Rate_H)];
    bottomView.image = [UIImage imageNamed:@"bg_question.png"];
    bottomView.userInteractionEnabled = YES;

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"什么原因导致你昨晚没睡好？"];
    UIFont *font = [UIFont systemFontOfSize:14*Rate_H];
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0,7)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25*Rate_H] range:NSMakeRange(7,2)];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] range:NSMakeRange(7, 2)];
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(9, 4)];

    //问题标题
    UILabel *questionLable = [[UILabel alloc] initWithFrame:CGRectMake(59*Rate_W, 20*Rate_H, 218*Rate_W, 36*Rate_H)];
    questionLable.attributedText = attrString;
    [questionLable sizeToFit];
    [bottomView addSubview:questionLable];

    //标签
    NSArray *temp = @[@"入睡困难",@"易醒或早醒",@"夜间去厕所",@"呼吸不畅",@"咳嗽或鼾声大",@"感觉冷",@"感觉热",@"做恶梦",@"疼痛不适",@"其他事情"];
    //循环创建标签按钮
    for (int i = 0; i < temp.count; i++)
    {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((39 + 134*(i%2))*Rate_W, 78*Rate_H + 78*(i/2)*Rate_H, 125*Rate_W, 48*Rate_H)];
        btn.layer.cornerRadius = 5*Rate_H;
        btn.clipsToBounds = YES;
        [btn setTitle:temp[i] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor colorWithRed:0.21 green:0.76 blue:0.86 alpha:1.0] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_unselected.png"] forState:(UIControlStateNormal)];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_selected.png"] forState:(UIControlStateSelected)];
        btn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_H];
        btn.tag = 200 + i + 1;
        btn.selected = NO;
        [btn addTarget:self action:@selector(collection:) forControlEvents:(UIControlEventTouchUpInside)];
        [bottomView addSubview:btn];
    }

    //选择确定按钮
    UIButton *sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 468*Rate_H, 335*Rate_W, 48*Rate_H)];
    [sureBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [sureBtn setBackgroundImage:[UIImage imageNamed:@"btn_ok_1.png"] forState:(UIControlStateNormal)];
    [sureBtn addTarget:self action:@selector(sureCollection) forControlEvents:(UIControlEventTouchUpInside)];
    [bottomView addSubview:sureBtn];
    
    [_evaluateView addSubview:bottomView];
}
#pragma mark -- 选择失眠原因
- (void)collection:(UIButton *)sender
{
    if (sender.selected == NO)
    {
        sender.selected = YES;
        [self.reasonsArr addObject:sender.titleLabel.text];
    }
    else
    {
        sender.selected = NO;
        [self.reasonsArr removeObject:sender.titleLabel.text];
    }
}
#pragma mark -- 确定所有失眠原因选项
- (void)sureCollection
{
    //将遮盖层去除
    [self.evaluateView removeFromSuperview];
    //还原导航栏
    [self.navigationController setNavigationBarHidden:NO];
    //去除碎片化评估
    _isTest = 0;
    [_scrollV removeFromSuperview];
    [self createScrollViewWithStyle:1];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [[NSUserDefaults standardUserDefaults] setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"sleepCollection"];
    
    /**** 上传碎片化搜集数据 ****/
    FragmentInfo *fragmentInfo = [FragmentInfo new];
    fragmentInfo.PatientID = self.patientInfo.PatientID;
    fragmentInfo.CollectDate = [dateFormatter stringFromDate:[NSDate date]];
    //将fragmentInfo中的数据进行初始化
    fragmentInfo.SleepDifficult = @"0";
    fragmentInfo.EasyWakeUp = @"0";
    fragmentInfo.NightUp = @"0";
    fragmentInfo.BreathDifficult = @"0";
    fragmentInfo.Snore = @"0";
    fragmentInfo.Cold = @"0";
    fragmentInfo.Hot = @"0";
    fragmentInfo.BadDream = @"0";
    fragmentInfo.Pain = @"0";
    fragmentInfo.Other = @"0";
    if (_reasonsArr.count > 0)
    {
        for (NSString *tmp in _reasonsArr)
        {
            if ([tmp isEqualToString:@"入睡困难"])
            {
                fragmentInfo.SleepDifficult = @"1";
            }
            else if ([tmp isEqualToString:@"易醒或早醒"])
            {
                fragmentInfo.EasyWakeUp = @"1";
            }
            else if ([tmp isEqualToString:@"夜间去厕所"])
            {
                fragmentInfo.NightUp = @"1";
            }
            else if ([tmp isEqualToString:@"呼吸不畅"])
            {
                fragmentInfo.BreathDifficult = @"1";
            }
            else if ([tmp isEqualToString:@"咳嗽或鼾声大"])
            {
                fragmentInfo.Snore = @"1";
            }
            else if ([tmp isEqualToString:@"感觉冷"])
            {
                fragmentInfo.Cold = @"1";
            }
            else if ([tmp isEqualToString:@"感觉热"])
            {
                fragmentInfo.Hot = @"1";
            }
            else if ([tmp isEqualToString:@"做恶梦"])
            {
                fragmentInfo.BadDream = @"1";
            }
            else if ([tmp isEqualToString:@"疼痛不适"])
            {
                fragmentInfo.Pain = @"1";
            }
            else if ([tmp isEqualToString:@"其他事情"])
            {
                fragmentInfo.Other = @"1";
            }
        }
    }
    
    //将数据存储在本地，进行缓存
    dbOpration=[[DataBaseOpration alloc] init];
    [dbOpration insertFragmentInfo:fragmentInfo];
    [dbOpration closeDataBase];
    //发送到服务器
    [interfaceModel insertFragmentInfoToServer:fragmentInfo];
}

#pragma mark -- 阻抗检测
- (void)detectionPersecondsForImpedance
{
    [sendCommand sendImpedanceDetectionOrder:_discoveredPeripheral characteristics:characteristicArray];
}

#pragma mark -- 开始／停止方法实现
//设置切换通道工作状态命令（正常工作通道状态）
- (void)sendStartWork
{
    if (timeout == time)
    {
        //发送切换通道状态命令，设置通道参数为正常工作
        order = [sendCommand sendSwitchChannelStateOrder:_discoveredPeripheral characteristics:characteristicArray state:discoveredPeripheralStateWork];
        orderCurrentRegulation = nil;
        orderSetTimeAndFrequency = nil;
        
        [autoDisconnectTimer invalidate];
        countSeconds = 0;
        autoDisconnectTimer = nil;
        
        BegainDate=[NSDate date];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        BegainTime=[dateFormatter stringFromDate:[NSDate date]];
        
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            
            if (connectedStateText)
            {
                countAlert = 0;
                NSLog(@"%d",timeout);
                [_timeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                
                if(timeout <= 0)
                {
                    connectedStateText = NO;
                    //倒计时结束，关闭
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self sendStopOrder];
                    });
                    
                }
                else if (timeout%60 == 0)
                {
                    //更新治疗积分
                    if (timeout == 600)
                    {
                        //更新服务器积分
                        InterfaceModel *mod = [[InterfaceModel alloc] init];
                        [mod uploadPointToServer:_patientInfo.PatientID pointType:@"1"];
                    }
                    if (timeout == time-60)
                    {
                        //存储治疗数据到数据库
                        //初始化数据库
                        dbOpration = [[DataBaseOpration alloc] init];
                        if (_patientInfo.PatientID != nil)
                        {
                            TreatInfo *treatInfoTmp = [[TreatInfo alloc] init];
                            treatInfoTmp.PatientID = _patientInfo.PatientID;
                            treatInfoTmp.Date = [BegainTime substringWithRange:NSMakeRange(0, 10)];
                            treatInfoTmp.Strength = [NSString stringWithFormat:@"%ld",(long)self.percentage];
                            if (modelIndex == 0)
                            {
                                treatInfoTmp.Frequency=@"0.5";
                            }
                            else if (modelIndex==1)
                            {
                                treatInfoTmp.Frequency=@"1.5";
                            }
                            else if (modelIndex==2)
                            {
                                treatInfoTmp.Frequency=@"100";
                            }
                            treatInfoTmp.Time=@"1200";
                            treatInfoTmp.BeginTime=BegainTime;
                            treatInfoTmp.EndTime=BegainTime;
                            treatInfoTmp.CureTime=@"1";
                            
                            //插入CureTime为1的数据进入数据库
                            [dbOpration insertTreatInfo:treatInfoTmp];
                            [dbOpration closeDataBase];
                        }
                        minutes = timeout/60;
                        seconds = timeout%60;
                        //设置界面的按钮显示 根据自己需求设置
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //设置时间倒计时
                            _timeBtn.titleLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
                            [_timeBtn setTitle:[NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds] forState:UIControlStateNormal];
                        });
                        timeout--;
                    }
                    else
                    {
                        if (_patientInfo.PatientID!=nil)
                        {
                            //更新治疗数据到数据库
                            //初始化数据库
                            dbOpration=[[DataBaseOpration alloc] init];
                            TreatInfo *treatInfoTmp=[[TreatInfo alloc] init];
                            treatInfoTmp.PatientID=_patientInfo.PatientID;
                            treatInfoTmp.Date=[BegainTime substringWithRange:NSMakeRange(0, 10)];
                            treatInfoTmp.Strength=[NSString stringWithFormat:@"%ld",(long)self.percentage];;
                            if (modelIndex==0)
                            {
                                treatInfoTmp.Frequency=@"0.5";
                            }
                            else if (modelIndex==1)
                            {
                                treatInfoTmp.Frequency=@"1.5";
                            }
                            else if (modelIndex==2)
                            {
                                treatInfoTmp.Frequency=@"100";
                            }
                            treatInfoTmp.Time=@"1200";
                            treatInfoTmp.BeginTime=BegainTime;
                            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                            EndTime=[dateFormatter stringFromDate:[NSDate date]];
                            treatInfoTmp.EndTime=EndTime;
                            treatInfoTmp.CureTime=[NSString stringWithFormat:@"%d",(time-timeout)/60];
                            //更新数据
                            if (![treatInfoTmp.CureTime isEqualToString:@"0"])
                            {
                                [dbOpration updateTreatInfo:treatInfoTmp];
                                [dbOpration closeDataBase];
                            }
                        }
                        minutes = timeout/60;
                        seconds = timeout%60;
                        //设置界面的时分label的显示 根据自己需求设置
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //设置时间倒计时
                            _timeBtn.titleLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
                            [_timeBtn setTitle:[NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds] forState:UIControlStateNormal];
                        });
                        timeout--;
                    }
                }
                else
                {
                    minutes = timeout/60;
                    seconds = timeout%60;
                    //设置界面的时分label的显示 根据自己需求设置
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //设置时间倒计时
                        _timeBtn.titleLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
                        [_timeBtn setTitle:[NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds] forState:UIControlStateNormal];
                    });
                    timeout--;
                }
            }
            else
            {
                //蓝牙断开连接，红黑交替闪烁
                if ([_startBtn.titleLabel.text isEqualToString:@"停止"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (countAlert%2 == 0 && countAlert >= 5)
                        {
                            [_timeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                        }
                        else if (countAlert%2 == 1)
                        {
                            [_timeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                            _timeBtn.titleLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
                            [_timeBtn setTitle:[NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds] forState:UIControlStateNormal];
                        }
                        countAlert++;
                    });
                }
            }
        });
        dispatch_resume(_timer);
    }
}

//设置切换通道工作状态命令（停止通道状态）
- (void)sendStopOrder
{
    //发送切换通道状态命令，设置通道参数为停止
    order = [sendCommand sendSwitchChannelStateOrder:_discoveredPeripheral characteristics:characteristicArray state:discoveredPeripheralStateStop];
    //将命令发送流程纪录发送过的命令清空
    orderCurrentRegulation = nil;
    orderSetTimeAndFrequency = nil;
    orderElectricSet = nil;
    
    //存储治疗数据到数据库
    if (_patientInfo!=nil && time-timeout>=60)
    {
        dbOpration=[[DataBaseOpration alloc] init];
        TreatInfo *treatInfoTmp=[[TreatInfo alloc] init];
        treatInfoTmp.PatientID=_patientInfo.PatientID;
        treatInfoTmp.Date=[BegainTime substringWithRange:NSMakeRange(0, 10)];
        treatInfoTmp.Strength=[NSString stringWithFormat:@"%ld",(long)self.percentage];
        if (modelIndex==0)
        {
            treatInfoTmp.Frequency=@"0.5";
        }
        else if (modelIndex==1)
        {
            treatInfoTmp.Frequency=@"1.5";
        }
        else if (modelIndex==2)
        {
            treatInfoTmp.Frequency=@"100";
        }
        treatInfoTmp.Time=@"1200";
        treatInfoTmp.BeginTime=BegainTime;
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        EndTime=[dateFormatter stringFromDate:[NSDate date]];
        treatInfoTmp.EndTime=EndTime;
        treatInfoTmp.CureTime=[NSString stringWithFormat:@"%d",(time-timeout)/60];
        //更新数据
        [dbOpration updateTreatInfo:treatInfoTmp];
        [dbOpration closeDataBase];
        [interfaceModel insertTreatInfoToServer:treatInfoTmp DeviceCode:self.bluetoothInfo.deviceCode];
    }
    
    //倒计时结束，关闭
    if (_timer != nil)
    {
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_source_cancel(_timer);
        });
    }
    
    timeout = time;
    minutes = timeout/60;
    seconds = timeout%60;
    //设置界面的时分label的显示 根据自己需求设置
    dispatch_async(dispatch_get_main_queue(), ^{
        //设置时间倒计时
        _timeBtn.titleLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
        [_timeBtn setTitle:[NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds] forState:UIControlStateNormal];
        //将"停止"按钮状态修改成"开始"按钮
        [_startBtn setTitle:@"开始" forState:(UIControlStateNormal)];
    });
    //设置一分钟之后如果不进行操作直接断开蓝牙外设
    autoDisconnectTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(cancelBlutooth:)
                                                             userInfo:nil
                                                              repeats:YES
                                                        dispatchQueue:dispatch_get_main_queue()];
}

#pragma mark -- 释放蓝牙连接
- (void)cancelBlutooth:(NSTimer *)timer
{
    countSeconds++;
    NSLog(@"%d",countSeconds);
    if (countSeconds >= 60)
    {
        //每秒一致发送的阻抗检测停止
        if (checkElectric)
        {
            [checkElectric invalidate];
            checkElectric = nil;
        }
        if (readElectricQuality)
        {
            [readElectricQuality invalidate];
            readElectricQuality = nil;
        }
        
        [self.centralMgr cancelPeripheralConnection:_discoveredPeripheral];
        [autoDisconnectTimer invalidate];
        autoDisconnectTimer = nil;
        countSeconds = 0;
        
        //按钮恢复点击连接状态（状态为未连接）
        stateString = @"未连接";
        [_btnState setBackgroundImage:[UIImage imageNamed:@"img_equipbox_weilian"] forState:(UIControlStateNormal)];
        [self removeViewFromFatherView:_timeView];
        [self addTimeViewContentView];
    }
}

- (void)cancelBlutoothOpration
{
    
}

#pragma mark -- CBCentralManager的代理方法实现
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            connectedStateText = NO;
            count++;
            if (count == 1)
            {
                self.centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            }
            //还需要对刺激开始按钮复位
            
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
            
            count=0;
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //如果发现绑定的外设直接连接
    if ([peripheral.identifier.UUIDString isEqualToString:_bluetoothInfo.peripheralIdentify])
    {
        _discoveredPeripheral=peripheral;
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
        [_centralMgr stopScan];
        //阻抗检测
        checkElectric = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(detectionPersecondsForImpedance) userInfo:nil repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:checkElectric forMode:NSRunLoopCommonModes];
        [checkElectric fire];
        //读取电量
        readElectricQuality = [MSWeakTimer scheduledTimerWithTimeInterval:1.0
                                                                   target:self
                                                                 selector:@selector(sendElectricQuantity)
                                                                 userInfo:nil
                                                                  repeats:YES
                                                            dispatchQueue:dispatch_get_main_queue()];
        
        _arrayServices = [[NSMutableArray alloc] init];
        
        characteristicUUID=[CBCharacteristic new];
        characteristicArray=[[NSMutableArray alloc] init];
        _characteristicNum = 0;
        
        if (_timer!=nil)
        {
            timeout=time;
            dispatch_source_set_event_handler(_timer, ^{
                dispatch_source_cancel(_timer);
            });
        }
        minutes = time/60;
        seconds = time%60;
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
    NSLog(@"设备已被连接");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //更改stateString设备状态字符串，此时修改为“已连接”
    stateString = @"已连接";
    [_btnState setBackgroundImage:[UIImage imageNamed:@"img_equipbox_yilian"] forState:(UIControlStateNormal)];
    if (connectTime != nil)
    {
        [connectTime invalidate];
        connectTime = nil;
    }
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestureRemove:)];
        [view addGestureRecognizer:tapGesture];
    }
    
    if (_bluetoothSV != nil)
    {
        [_bluetoothSV removeFromSuperview];
        _bluetoothSV = nil;
        _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:peripheral.name andPercent:_percent];
        _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
        _bluetoothSV.clickDelegate = self;
        [view addSubview:_bluetoothSV];
    }
    else
    {
        _bluetoothSV = [[BluetoothStateView alloc] initWithState:stateString andDevice:_bluetoothInfo.deviceName andSerialNumber:peripheral.name andPercent:_percent];
        _bluetoothSV.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
        _bluetoothSV.clickDelegate = self;
        [view addSubview:_bluetoothSV];
    }
    //设置3秒后连接成功的提示View自动消失
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeViewFromSuperView) userInfo:nil repeats:NO];
    
    [self setViewUserInteractionEnabled:YES];
    [self createStimulateBtnView];
    
    [self.arrayServices removeAllObjects];
    [_discoveredPeripheral setDelegate:self];
    [_discoveredPeripheral discoverServices:nil];
}

- (void)createStimulateBtnView
{
    [self removeViewFromFatherView:_timeView];
    
    _timeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _timeBtn.frame = CGRectMake(0, _timeView.frame.size.height/4, _timeView.frame.size.width, _timeView.frame.size.height/4);
    [_timeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _timeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:35];
    _timeBtn.titleLabel.text = @"20:00";
    [_timeBtn setTitle:@"20:00" forState:UIControlStateNormal];

    [_timeView addSubview:_timeBtn];
    
    
    //开始/暂停计时按钮
    _startBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, _timeView.frame.size.height/2, _timeView.frame.size.width, _timeView.frame.size.height/3)];
    [_startBtn setTitle:@"开始" forState:(UIControlStateNormal)];
    _startBtn.titleLabel.font = [UIFont systemFontOfSize:30*Ratio];
    [_startBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(timeStart:) forControlEvents:(UIControlEventTouchUpInside)];
    [_timeView addSubview:_startBtn];
}

//设置3秒后连接成功的提示View自动消失的NSTimer的方法
- (void)removeViewFromSuperView
{
    if (_bluetoothSV != nil)
    {
        [_bluetoothSV removeFromSuperview];
        [view removeFromSuperview];
    }
    else
    {
        if (view != nil)
        {
            [view removeFromSuperview];
        }
    }
}

//蓝牙断开连接时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"蓝牙外设断开连接");
    if (checkElectric)
    {
        [checkElectric invalidate];
        checkElectric = nil;
    }
    [_centralMgr cancelPeripheralConnection:_discoveredPeripheral];
    //倒计时结束，关闭
    if (_timer != nil)
    {
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_source_cancel(_timer);
        });
        timeout=time;
    }
    //按钮恢复点击连接状态（状态为未连接）
    stateString = @"未连接";
    [_btnState setBackgroundImage:[UIImage imageNamed:@"img_equipbox_weilian"] forState:(UIControlStateNormal)];
    [self removeViewFromFatherView:_timeView];
    [self addTimeViewContentView];
}

//获取服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServices : %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *s in peripheral.services)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{peripheral.name:s.UUID.description}];
        [self.arrayServices addObject:dic];
        [s.peripheral discoverCharacteristics:nil forService:s];
    }
}

//获取特性
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *c in service.characteristics)
    {
        self.characteristicNum++;
        [peripheral readValueForCharacteristic:c];
        [characteristicArray addObject:c];
        [peripheral setNotifyValue:YES forCharacteristic:c];
    }
    
    //发送切换通道状态命令，设置通道参数为电流调节
    orderCurrentRegulation = [sendCommand sendSwitchChannelStateOrder:_discoveredPeripheral characteristics:characteristicArray state:discoveredPeripheralStateCurrentRegulation];
   
    [self doSomething:_startBtn];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData* data = characteristic.value;
    valueAnswer =[self hexadecimalString:data];
    NSLog(@"valueAnswer: %@",valueAnswer)
    if ([valueAnswer containsString:@"55bb010b84"])
    {
        [stringArray removeAllObjects];
        
        for (int i=1; i<=valueAnswer.length/2; i++)
        {
            NSString *str=[valueAnswer substringWithRange:NSMakeRange(2*(i-1), 2)];
            [stringArray addObject:str];
        }
        if ([[stringArray objectAtIndex:8] isEqualToString:@"00"])
        {
            connectedStateText=NO;
        }
        else if([[stringArray objectAtIndex:8] isEqualToString:@"01"])
        {
            connectedStateText=YES;
        }
    }
    else if ([valueAnswer containsString:@"55bb010a"])
    {
        electricQualityAnswer = YES;
        NSLog(@"%@",valueAnswer);
        //电量提示
        NSString *numberStr_One = [valueAnswer substringWithRange:NSMakeRange(14, 1)];
        NSString *numberStr_Two = [valueAnswer substringWithRange:NSMakeRange(15, 1)];
        unichar numberStr = [valueAnswer characterAtIndex:15];
        if (numberStr >= 'a' && numberStr <= 'f')
        {
            numberStr_Two = [NSString stringWithFormat:@"%d",numberStr-87];
        }
        self.percent = [numberStr_One intValue]*16+[numberStr_Two intValue];
        
        if (_percent > 5 && _percent <= 20)
        {
            if (countElectric < 1)
            {
                jxt_showTextHUDTitleMessage(@"温馨提示", @"电池电量小于20%，请及时给设备充电");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
                
                countElectric++;
            }
        }
        else if(_percent <= 5)
        {
            if (countElectric_Two < 1)
            {
                jxt_showTextHUDTitleMessage(@"温馨提示", @"电池电量小于5%，设备无法正常工作，请先充电");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
                
                countElectric_Two++;
            }
        }
    }
    else if ([valueAnswer containsString:@"55bb011387"] && [[valueAnswer substringWithRange:NSMakeRange(34, 2)] isEqualToString:@"00"])
    {
        Byte myChar[8];
        for (int i=0; i<8; i++)
        {
            NSString *tmp = [valueAnswer substringWithRange:NSMakeRange(18+2*i, 2)];
            unsigned int anInt;
            NSScanner * scanner = [[NSScanner alloc] initWithString:tmp];
            [scanner scanHexInt:&anInt];
            myChar[i] = anInt;
        }
        [self Deciphering:myChar];
        
        //发送序列号接口
        NSMutableArray *deviceIDArray = [NSMutableArray array];
        NSString *hexStr = @"";
        for(int i = 0; i < 6; i++)
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",chOUTFinal[i]&0xff];///16进制数
            if([newHexStr length] == 1)
            {
                hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
            }
            else
            {
                hexStr = [NSString stringWithFormat:@"%@",newHexStr];
            }
            [deviceIDArray addObject:hexStr];
        }
        
        _bluetoothInfo.deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@%@",[deviceIDArray objectAtIndex:0],[deviceIDArray objectAtIndex:1],[deviceIDArray objectAtIndex:2],[deviceIDArray objectAtIndex:3],[deviceIDArray objectAtIndex:4],[deviceIDArray objectAtIndex:5]];
        //将电量跟新到本地数据库
        dbOpration = [[DataBaseOpration alloc] init];
        [dbOpration updatePeripheralInfo:_bluetoothInfo];
        [dbOpration closeDataBase];
        
        //将读取到的序列号解密之后传到服务器当中
//        [interfaceModel insertTreatInfoToServer:treatInfoTmp Version:self.bluetoothInfo.deviceCode];
        
    }
    if ([orderCurrentRegulation containsString:@"55AA030781028C"])
    {
        //发送设置刺激参数命令，设置治疗时间和刺激频率
        orderSetTimeAndFrequency = [sendCommand sendSetTimeAndFrequencyOrder:_discoveredPeripheral characteristics:characteristicArray indexFrequency:modelIndex];
    }
    if ([orderSetTimeAndFrequency containsString:@"55AA030882"])
    {
        //发送电流设定命令，设置电流强度
        orderElectricSet = [sendCommand sendElectricSetOrder:_discoveredPeripheral characteristics:characteristicArray currentnumOfElectric:self.percentage];
    }
    if ([orderElectricSet containsString:@"55AA030785"] && [orderCurrentRegulation containsString:@"55AA030781028C"] && [orderSetTimeAndFrequency containsString:@"55AA030882"])
    {
        //发送开始命令，即疗疗正常工作命令
        [self sendStartWork];
    }
    
}

//获取特性值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.characteristicNum--;
    for (NSMutableDictionary *dic in self.arrayServices)
    {
        NSString *service = [dic valueForKey:peripheral.name];
        if ([service isEqual:characteristic.service.UUID.description])
        {
            [dic setValue:characteristic.value forKey:characteristic.UUID.description];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    NSData* data = characteristic.value;
    NSString *valueStr = [self hexadecimalString:data];
    if ([valueStr isEqualToString:@"55bb01079300ab"])
    {
        NSLog(@"接上外接电源蓝牙模块复位功能：%@",valueStr);
    }
    
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }
}

-(void)Deciphering:(Byte *)chData
{
    Byte chKey[] = { 0x01, 0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05, 0x01,
        0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05 };
    Byte chOUT[16];
    Byte chC[16];
    
    for (int i = 0; i < 8; i++) {
        chC[2 * i] = (Byte) (chData[i] >> 4);
        chC[2 * i + 1] = (Byte) (chData[i] & 0x0f);
    }
    
    for (int k = 0; k < 16; k++) {
        for (int j = 0; j < 16; j++) {
            if ((((j * chKey[k]) - chC[k]) % 16) == 0) {
                chOUT[k] = (Byte) j;
                j = 15;
            }
        }
    }
    
    for (int g = 0; g < 8; g++)
    {
        chOUTFinal[g] = (Byte) (((chOUT[2 * g] << 4) & 0xf0) + (chOUT[2 * g + 1] & 0x0f));
    }
}

//发送读取电量命令
-(void)sendElectricQuantity
{
    if (electricQualityAnswer == NO)
    {
        order = [sendCommand sendElectricQuantity:_discoveredPeripheral characteristics:characteristicArray];
    }
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data
{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

/**
 * 开始到结束的时间差的天数
 */
- (NSInteger)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *startD = [date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    NSInteger day = value / (24 * 3600);
    return day;
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
