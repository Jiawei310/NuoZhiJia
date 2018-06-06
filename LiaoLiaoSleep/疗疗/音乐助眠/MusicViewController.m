//
//  MusicViewController.m
//  SleepMusic
//
//  Created by 诺之嘉 on 2017/4/11.
//  Copyright © 2017年 诺之嘉. All rights reserved.
//

#import "MusicViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

#import "FunctionHelper.h"
#import "InterfaceModel.h"
#import "DataBaseOpration.h"
#import "MusicModel.h"
#import "AudioPlayer.h"
#import "DownloadOpration.h"
#import "MusicButton.h"
#import "UIButton+Common.h"

#import <POP.h>
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "MSWeakTimer.h"
#import "JXTAlertManagerHeader.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@interface MusicViewController ()<UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate,NSURLConnectionDelegate,UIGestureRecognizerDelegate,CAAnimationDelegate,DownloadOprationDelegate>
{
    UIView *myView;
    CAShapeLayer *myLayer;
    
    float downProgress;
    UIView *animationViewOne;
    UIView *animationViewTwo;
}

//服务器请求数据
@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, strong) NSMutableString *soapResults;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, assign) BOOL elementFound;
@property (nonatomic, strong) NSString *matchingElement;
@property (nonatomic, strong) NSURLConnection *conn;
//数据加载
@property (nonatomic, strong) MBProgressHUD *progressHud;

//MusicModel数组
@property (nonatomic, copy) NSMutableArray *musicArray;
@property (nonatomic, copy) NSMutableArray *resourceArray;
//下载按钮数组
@property (nonatomic, copy) NSMutableArray *downloadBtnArray;

//视图
@property (nonatomic, strong) UITableView *tableView; //数据显示于tableView上
@property (nonatomic, strong) UIView *headerV; //tableView头视图

//沙盒本地Music目录下所有.mp3文件
@property (nonatomic, copy)   NSMutableArray *filePathArray;

@property (nonatomic, strong)    UIImageView *backGroundImagView; //播放区域背景
@property (nonatomic, assign)        CGPoint point;
@property (nonatomic, strong)    UIImageView *maskImagView;       //播放区域蒙板
@property (nonatomic, strong)    UIImageView *typeView;       //播放区域播放类型图标
@property (nonatomic, strong)        UILabel *nameLabel;          //歌曲名称
@property (nonatomic, strong)       UIButton *timeSelectBtn;      //时间选择按钮
@property (nonatomic, strong)        UILabel *timeLabel;          //时间显示Label
@property (nonatomic, strong)    UIImageView *typeImageView;      //按钮下方imageview
@property (nonatomic, copy)   NSMutableArray *timeBtnArray;       //存储五个时间按钮
@property (nonatomic, strong)       UIButton *startBtn;           //开始暂停按钮
@property (nonatomic, assign)      NSInteger timeType;            //选取的时间type
@property (nonatomic, assign)      NSInteger timeCount;           //选取的时间
@property (nonatomic, assign)      NSInteger typeNumber;          //音乐播发类型标记
@property (nonatomic, assign)      NSInteger typeDownNumber;      //音乐下载类型标记
@property (nonatomic, copy)   NSMutableArray *typeImageViewArray; //音乐按钮下方imageview数组
@property (nonatomic, copy)   NSMutableArray *typeBtnArray;       //音乐类型按钮
@property (nonatomic, assign)           BOOL playing;             //表示音乐是否在播放
@property (nonatomic, strong)    AudioPlayer *audioPlayer;

@property (nonatomic, strong)     NSTimer *musicTimer;
@property (nonatomic, strong) MSWeakTimer *refreshTimer;

@end

@implementation MusicViewController
{
    NSString *netState; //网络状态
    UIView *alertBgView;
    UIButton *backBtn;
    UILabel *alertLabel;//网络音乐加载失败提示
    
    dispatch_queue_t queue;   //用于音乐开始播放计时，多线程下创建的global队列（全局队列）
    dispatch_source_t _timer;  //多线程下，创建的时间资源
}

@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

+ (MusicViewController *)shareController
{
    static MusicViewController *musicVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        musicVC = [MusicViewController new];
    });
    
    return musicVC;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
    //设置导航栏全透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //去掉导航栏的横线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //隐藏选项卡
    self.tabBarController.tabBar.hidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [MobClick beginLogPageView:@"音乐助眠"];//("PageOne"为页面名称，可自定义)
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([netState isEqualToString:@"不可用"])
    {
        backBtn.hidden = NO;
        alertLabel.hidden = NO;
        alertBgView.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [MobClick endLogPageView:@"音乐助眠"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
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
    
    _typeNumber = 0;
    
    _timeType = 1200;
    _timeCount = 1200;
    _downloadBtnArray = [NSMutableArray array];
    
    [self prepareMusicData];
    
    //本地有数据则创建页面，否则不创建
    if (_resourceArray.count > 0)
    {
        //创建页面
        [self createPlayArea];
        [self createTableView];
    }
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    if (sender.tag == 11)
    {
        backBtn.hidden = YES;
        alertLabel.hidden = YES;
        alertBgView.hidden = YES;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareMusicData
{
    //获取本地数据
    [self getMusicDataFromLocal];
    //刷新界面数据
    _progressHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _progressHud.labelText = @"正在加载";
    [_progressHud show:YES];
    //添加超时设置
    if (_refreshTimer != nil)
    {
        _refreshTimer = nil;
        _refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:8.0
                                                             target:self
                                                           selector:@selector(getMusicDataDefaild)
                                                           userInfo:nil
                                                            repeats:NO
                                                      dispatchQueue:dispatch_get_main_queue()];
    }
    else
    {
        _refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:8.0
                                                             target:self
                                                           selector:@selector(getMusicDataDefaild)
                                                           userInfo:nil
                                                            repeats:NO
                                                      dispatchQueue:dispatch_get_main_queue()];
    }
    [self getMusicData];
}

/*
 * 获取本地音乐
 */
- (void)getMusicDataFromLocal
{
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    _musicArray = [dbOpration getMusicDataFromDataBase];
    _resourceArray = [NSMutableArray array];
    for (int i = 0; i < _musicArray.count; i++)
    {
        MusicModel *tmpModel = [[_musicArray objectAtIndex:i] copy];
        [_resourceArray addObject:tmpModel];
    }
    [dbOpration closeDataBase];
}

//数据刷新失败
- (void)getMusicDataDefaild
{
    _progressHud.labelText = @"加载失败";
    [_progressHud hide:YES afterDelay:0.5];
    
    //设置网络不可用状态
    netState = @"不可用";
    
    alertBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 44)];
    alertBgView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xDF/255.0 blue:0xDF/255.0 alpha:1];
    alertBgView.userInteractionEnabled = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:alertBgView];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.tag = 11;
    backBtn.frame = CGRectMake(10, 10, 23, 23);
    [backBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    [alertBgView addSubview:backBtn];
    
    alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, SCREENWIDTH - 60, 22)];
    alertLabel.textColor = [UIColor lightGrayColor];
    alertLabel.text = @"当前网络不可用，请检查你的网络设置";
    alertLabel.textAlignment = NSTextAlignmentCenter;
    [alertBgView addSubview:alertLabel];
    
    UIButton *tryAgainBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    tryAgainBtn.frame = CGRectMake(SCREENWIDTH/4, 22, SCREENWIDTH/2, 22);
    [tryAgainBtn setTitle:@"重新加载" forState:UIControlStateNormal];
    [tryAgainBtn addTarget:self action:@selector(reloadMusicDate:) forControlEvents:UIControlEventTouchUpInside];
    [alertBgView addSubview:tryAgainBtn];
}

- (void)reloadMusicDate:(UIButton *)sender
{
    [backBtn removeFromSuperview];
    [alertLabel removeFromSuperview];
    [alertBgView removeFromSuperview];
    
    [self prepareMusicData];
}

/*
 * 获取音乐资源的接口
 */
- (void)getMusicData
{
    //获取本地数据
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Music/"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:DocumentsPath];
    _filePathArray = [NSMutableArray array];
    for (NSString *fileName in enumerator)
    {
        [_filePathArray addObject:fileName];
    }
    
    //获取网络数据
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetAllMusicResourceResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_GetAllMusicResource xmlns=\"MeetingOnline\" />"
                         "</soap12:Body>"
                         "</soap12:Envelope>",nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    
    //设置网络连接的url
    NSString *urlStr = [NSString stringWithFormat:@"%@",ADDRESS];
    NSURL *url = [NSURL URLWithString:urlStr];
    //设置request
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSString *msgLength=[NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [request setHTTPMethod:@"POST"];//默认是GET
    // 将SOAP消息加到请求中
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    // 创建连接
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        webData = [NSMutableData data];
    }
}

/*
 * 创建界面播放区域
 */
- (void)createPlayArea
{
    if (_backGroundImagView == nil)
    {
        //播放区域背景（背景按播放音乐类型进行切换）
        _backGroundImagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 375*Rate_W, 304*Rate_H)];
        [self.view addSubview:_backGroundImagView];
    }
    if (_maskImagView == nil)
    {
        //播放区域蒙板
        _maskImagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 375*Rate_W, 279*Rate_H)];
        [self.view addSubview:_maskImagView];
        //播放区域蒙板上添加点击手势（手势负责音乐的播放与暂停）
        _maskImagView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapControlPlay:)];
        tapGesture.numberOfTouchesRequired = 1; //手指数
        tapGesture.numberOfTapsRequired = 1; //tap次数
        tapGesture.delegate= self;
        [_maskImagView addGestureRecognizer:tapGesture];
    }
    if (_typeView == nil)
    {
        //添加播放音乐类型的图标
        _typeView = [[UIImageView alloc] initWithFrame:CGRectMake(135*Rate_W, 20 + 20*Rate_H, 105*Rate_W, 105*Rate_H)];
        _typeView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_typeView];
    }
    if (_nameLabel == nil)
    {
        //音乐名称Label
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(125*Rate_W, 140*Rate_H, 125*Rate_W, 20*Rate_H)];
        _nameLabel.font = [UIFont systemFontOfSize:20*Rate_H];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_nameLabel];
    }
    if (_timeSelectBtn == nil)
    {
        //添加播放时长选择按钮
        _timeSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeSelectBtn.frame = CGRectMake((SCREENWIDTH - 18*Rate_H)/2, 180*Rate_H, 18*Rate_H, 30*Rate_H);
        [_timeSelectBtn setImage:[UIImage imageNamed:@"zhizhengbaisexia"] forState:UIControlStateNormal];
        [_timeSelectBtn addTarget:self action:@selector(timeSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeSelectBtn];
    }
    
    if (_timeLabel == nil)
    {
        //添加时间显示Label
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(125*Rate_W, 230*Rate_H, 125*Rate_W, 20*Rate_H)];
        if (_timeType == INT_MAX)
        {
            _timeLabel.text = @"∞";
        }
        else
        {
            _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",_timeType/60,_timeType%60];
        }
        _timeLabel.font = [UIFont systemFontOfSize:14*Rate_H];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_timeLabel];
    }
    if (_resourceArray.count > 0)
    {
        MusicModel *defaultModel = [_resourceArray objectAtIndex:_typeNumber];
        [_backGroundImagView sd_setImageWithURL:[NSURL URLWithString:defaultModel.playBgBottom] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [_backGroundImagView setImage:image];
        }];
        [_maskImagView sd_setImageWithURL:[NSURL URLWithString:defaultModel.playBgTop] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [_maskImagView setImage:image];
        }];
        [_typeView sd_setImageWithURL:[NSURL URLWithString:defaultModel.btnBgUrl_White] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [_typeView setImage:image];
        }];
        _nameLabel.text = defaultModel.musicName;
    }
    
    //创建开始暂停按钮
    if (_startBtn == nil)
    {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.frame = CGRectMake((SCREENWIDTH - 30*Rate_H)/2, 260*Rate_H, 30*Rate_H, 30*Rate_H);
        [_startBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(stratBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_startBtn];
    }
}

- (void)stratBtnClick:(UIButton *)sender
{
    if (_playing)
    {
        MusicButton *tmpBtn = [_typeBtnArray objectAtIndex:_typeNumber];
        [self musicPause:tmpBtn];
    }
    else
    {
        MusicButton *tmpBtn = [_typeBtnArray objectAtIndex:_typeNumber];
        [self musicPlay:tmpBtn ButtonClick:NO];
    }
}

#pragma -- UIGestureRecognizerDelegate 的代理方法实现
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma -- tapGesture点击手势的方法实现
- (void)tapControlPlay:(UITapGestureRecognizer *)gesture
{
    _point = [gesture locationInView:_maskImagView];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doMusicTapSomething:) object:gesture];
    [self performSelector:@selector(doMusicTapSomething:) withObject:gesture afterDelay:0.5f];
}

- (void)doMusicTapSomething:(UITapGestureRecognizer *)gesture
{
    myLayer = [[CAShapeLayer alloc] init];
    myLayer.frame = CGRectMake(_point.x, _point.y, 1, 1);
    myLayer.path = [self drawPathWithArcCenter:myLayer];
    myLayer.fillColor = [UIColor clearColor].CGColor;
    myLayer.strokeColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0].CGColor;
    myLayer.lineWidth = 0.05;
    [_maskImagView.layer addSublayer:myLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithDouble:1];
    animation.toValue = [NSNumber numberWithDouble:15];
    animation.duration= 0.5;
    animation.autoreverses= NO;
    animation.removedOnCompletion = YES;
    animation.delegate = self;
    [myLayer addAnimation:animation forKey:@"scale"];
    
    if (_playing)
    {
        MusicButton *tmpBtn = [_typeBtnArray objectAtIndex:_typeNumber];
        [self musicPause:tmpBtn];
    }
    else
    {
        MusicButton *tmpBtn = [_typeBtnArray objectAtIndex:_typeNumber];
        [self musicPlay:tmpBtn ButtonClick:NO];
    }
}

- (void)musicPlay:(MusicButton *)button ButtonClick:(BOOL)bk
{
    if (bk)
    {
        _audioPlayer = [AudioPlayer sharePlayer];
        if (button.downLoad)
        {
            _playing = YES;
            button.selected = YES;
            for (MusicButton *tmp in _typeBtnArray)
            {
                if (tmp.tag != button.tag)
                {
                    tmp.selected = NO;
                }
            }
            _typeNumber = button.tag - 10;
            for (int i = 0; i < _resourceArray.count; i++)
            {
                MusicModel *tmpModel = [_resourceArray objectAtIndex:i];
                if (i != _typeNumber)
                {
                    UIImageView *tmp = [_typeImageViewArray objectAtIndex:i];
                    [tmp sd_setImageWithURL:[NSURL URLWithString:tmpModel.btnBgUrl_Gray] placeholderImage:[UIImage new] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [tmp setImage:image];
                    }];
                }
                else
                {
                    UIImageView *tmp = [_typeImageViewArray objectAtIndex:_typeNumber];
                    [tmp sd_setImageWithURL:[NSURL URLWithString:tmpModel.btnBgUrl_Colour] placeholderImage:[UIImage new] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [tmp setImage:image];
                    }];
                }
            }
            MusicModel *musicModel = [_resourceArray objectAtIndex:_typeNumber];
            [self setPlayAreaValueWithMusicModel:musicModel];
            [_audioPlayer setPrepareMusicUrl:musicModel.musicUrl];
            [_startBtn setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
            
            //音乐播发或继续播放
            if (!_musicTimer)
            {
                [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                NSDictionary *btnDic = @{@"button":button};
                _musicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(calculagraph:)
                                                             userInfo:btnDic
                                                              repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_musicTimer forMode:NSRunLoopCommonModes];
            }
            else
            {
                [_musicTimer setFireDate:[NSDate date]];
            }
        }
        else
        {
            //判断网络情况
            if ([FunctionHelper isExistenceNetwork])
            {
                button.userInteractionEnabled = NO;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    _typeDownNumber = button.tag - 10;
                    [_downloadBtnArray addObject:button];
                    MusicModel *musicModel = [_resourceArray objectAtIndex:_typeDownNumber];
                    DownloadOpration *dOpration = [[DownloadOpration alloc] initWithUrl:musicModel.musicUrl typeNum:_typeDownNumber];
                    dOpration.delegate = self;
                });
            }
            else
            {
                //提示网络不通
                jxt_showTextHUDTitleMessage(@"温馨提示", @"请检查网络连接是否正常");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
            }
        }
    }
    else
    {
        _audioPlayer = [AudioPlayer sharePlayer];
        if (button.downLoad)
        {
            _playing = YES;
            button.selected = YES;
            for (MusicButton *tmp in _typeBtnArray)
            {
                if (tmp.tag != button.tag)
                {
                    tmp.selected = NO;
                }
            }
            _typeNumber = button.tag - 10;
            for (int i = 0; i < _resourceArray.count; i++)
            {
                MusicModel *tmpModel = [_resourceArray objectAtIndex:i];
                if (i != _typeNumber)
                {
                    UIImageView *tmp = [_typeImageViewArray objectAtIndex:i];
                    [tmp sd_setImageWithURL:[NSURL URLWithString:tmpModel.btnBgUrl_Gray] placeholderImage:[UIImage new] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [tmp setImage:image];
                    }];
                }
                else
                {
                    UIImageView *tmp = [_typeImageViewArray objectAtIndex:_typeNumber];
                    [tmp sd_setImageWithURL:[NSURL URLWithString:tmpModel.btnBgUrl_Colour] placeholderImage:[UIImage new] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [tmp setImage:image];
                    }];
                }
                
            }
            MusicModel *musicModel = [_resourceArray objectAtIndex:_typeNumber];
            [self setPlayAreaValueWithMusicModel:musicModel];
            [_audioPlayer setPrepareMusicUrl:musicModel.musicUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_startBtn setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
            });
            
            //音乐播发或继续播放
            if (!_musicTimer)
            {
                [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                NSDictionary *btnDic = @{@"button":button};
                _musicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(calculagraph:)
                                                             userInfo:btnDic
                                                              repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_musicTimer forMode:NSRunLoopCommonModes];
            }
            else
            {
                [_musicTimer setFireDate:[NSDate date]];
            }
        }
    }
}

- (void)calculagraph:(NSTimer *)timer
{
    MusicButton *tmpBtn = [timer.userInfo objectForKey:@"button"];
    if (_timeType != INT_MAX)
    {
        if (_timeType <= 0)
        {
            //更新服务器积分
            InterfaceModel *mod = [[InterfaceModel alloc] init];
            [mod uploadPointToServer:[PatientInfo shareInstance].PatientID pointType:@"8"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self musicPause:tmpBtn];
                _timeType = _timeCount;
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",_timeType/60,_timeType%60];
        });
        _timeType--;
    }
}

#pragma -- DownloadOprationDelegate的代理方法实现
- (void)musicDownloadProgress:(float)progress typeNum:(NSInteger)num
{
    //添加下载动画
    if (progress >= 1.0)
    {
        MusicButton *tmpBtn = [_typeBtnArray objectAtIndex:num];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.2 animations:^{
                
                tmpBtn.animationBgView.frame = CGRectMake(tmpBtn.frame.size.width/2, 29.5*Rate_H, 0, 0);
                tmpBtn.animationViewOne.frame = CGRectMake(tmpBtn.frame.size.width/2, 29.5*Rate_H, 0, 0);
                
            } completion:^(BOOL finished) {
                
                [tmpBtn.animationBgView removeFromSuperview];
                [tmpBtn.animationViewOne removeFromSuperview];
                [tmpBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
                tmpBtn.downLoad = YES;
                tmpBtn.userInteractionEnabled = YES;
                
                //将下载完毕的按钮从downloadBtnArray中remove掉
                for (int i = 0; i < _downloadBtnArray.count; i++)
                {
                    MusicButton *tmp = [_downloadBtnArray objectAtIndex:i];
                    if (tmp.tag == tmpBtn.tag)
                    {
//                        [_downloadBtnArray removeObjectAtIndex:i];
                        [_downloadBtnArray removeObject:tmp];
                    }
                }
            }];
            
        });
    }
    else
    {
        NSLog(@"%ld__%f",(long)num,progress);
        MusicButton *tmpBtn = [_typeBtnArray objectAtIndex:num];
        tmpBtn.progress = progress;
    }
}

- (void)musicPause:(MusicButton *)button
{
    if (button.downLoad)
    {
        _playing = NO;
        [[AudioPlayer sharePlayer] pause];
        //音乐暂停
        [_musicTimer setFireDate:[NSDate distantFuture]];
        button.selected = NO;
        [_startBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    }
}

#pragma -- CAAnimationDelegate代理方法实现
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [myLayer removeFromSuperlayer];
    NSLog(@"Stop");
}

//利用贝塞尔曲线来画圆
- (CGPathRef)drawPathWithArcCenter:(CAShapeLayer *)caLayer
{
    CGFloat position_y = caLayer.frame.size.height/2;
    CGFloat position_x = caLayer.frame.size.width/2; // Assuming that width == height
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y) radius:position_y startAngle:(-M_PI/2) endAngle:(3*M_PI/2)clockwise:YES].CGPath;
}

//播放时间选择按钮点击时间
- (void)timeSelectClick:(UIButton *)sender
{
    if (sender.selected == NO)
    {
        NSArray *timeBtnBgArray = [NSArray arrayWithObjects:@"10min_baise", @"20min_baise", @"40min_baise", @"60min_baise", @"wuqiong_baise", nil];
        _timeBtnArray = [NSMutableArray array];
        //添加五种时间选择方式按钮动画
        for (int i = 0; i < 5; i++)
        {
            UIButton *timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            timeBtn.tag = 100 + i;
            [timeBtn setTintColor:[UIColor whiteColor]];
            timeBtn.frame = CGRectMake((SCREENWIDTH - 18*Rate_H)/2, 180*Rate_H, 18*Rate_H, 30*Rate_H);
            [timeBtn setImage:[UIImage imageNamed:[timeBtnBgArray objectAtIndex:i]] forState:UIControlStateNormal];
            [timeBtn addTarget:self action:@selector(timeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:timeBtn];
            [_timeBtnArray addObject:timeBtn];
            
            POPSpringAnimation *butttonAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            butttonAnim.beginTime = CACurrentMediaTime();
            if (i == 4)
            {
                butttonAnim.toValue = [NSValue valueWithCGPoint:CGPointMake((76.5 + i*55)*Rate_W, 228.5*Rate_H)];
            }
            else
            {
                butttonAnim.toValue = [NSValue valueWithCGPoint:CGPointMake((76.5 + i*55)*Rate_W, 233.5*Rate_H)];
            }
            
            butttonAnim.springSpeed = 20;
            butttonAnim.springBounciness = 8;
            [timeBtn pop_addAnimation:butttonAnim forKey:@"timeBtn"];
        }
        //隐藏时间显示
        _timeLabel.hidden = YES;
        //变换按钮的选中状态
        sender.selected = YES;
    }
    else
    {
        //防止动画执行期间无限制的点击造成的错误
        sender.userInteractionEnabled = NO;
        //移除时间显示按钮
        [UIView animateWithDuration:0.2 animations:^{
            for (UIButton *tmp in _timeBtnArray)
            {
                tmp.frame = CGRectMake(178.5*Rate_W, 180*Rate_H, 18*Rate_W, 30*Rate_H);
            }
        } completion:^(BOOL finished) {
            for (UIButton *tmp in _timeBtnArray)
            {
                [tmp removeFromSuperview];
            }
            sender.userInteractionEnabled = YES;
            _timeLabel.hidden = NO;
        }];
        //变换按钮的选中状态
        sender.selected = NO;
    }
}

//时间按钮点击事件
- (void)timeBtnClick:(UIButton *)sender
{
    if (sender.tag - 100 == 0)
    {
        _timeType = 600;
        _timeCount = 600;
    }
    else if (sender.tag - 100 == 1)
    {
        _timeType = 1200;
        _timeCount = 1200;
    }
    else if (sender.tag - 100 == 2)
    {
        _timeType = 2400;
        _timeCount = 2400;
    }
    else if (sender.tag - 100 == 3)
    {
        _timeType = 3600;
        _timeCount = 3600;
    }
    else if (sender.tag - 100 == 4)
    {
        _timeType = INT_MAX;
        _timeCount = INT_MAX;
    }
    //防止动画执行期间无限制的点击造成的错误
    _timeSelectBtn.userInteractionEnabled = NO;
    //移除时间显示按钮
    [UIView animateWithDuration:0.2 animations:^{
        for (UIButton *tmp in _timeBtnArray)
        {
            tmp.frame = CGRectMake(175*Rate_W, 180*Rate_H, 18*Rate_W, 30*Rate_H);
        }
    } completion:^(BOOL finished) {
        for (UIButton *tmp in _timeBtnArray)
        {
            [tmp removeFromSuperview];
        }
        _timeSelectBtn.userInteractionEnabled = YES;
        _timeLabel.hidden = NO;
        if (_timeType == INT_MAX)
        {
            _timeLabel.text = @"∞";
        }
        else
        {
            NSInteger min = _timeType/60;
            NSInteger sec = _timeType%60;
            _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)min,(long)sec];
        }
    }];
    //变换按钮的选中状态
    _timeSelectBtn.selected = NO;
}

/*
 * 创建按钮显示的tableview
 */
- (void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20 + 304*Rate_H, SCREENWIDTH, 343*Rate_H) style:UITableViewStylePlain];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //下拉刷新
    _tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshView)];
    _tableView.tableHeaderView = [UIView new];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
}

#pragma mark --- 下拉刷新
- (void)refreshView
{
    //添加超时设置
    if (_refreshTimer != nil)
    {
        _refreshTimer = nil;
        _refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3.0
                                                             target:self
                                                           selector:@selector(refreshDefaild)
                                                           userInfo:nil
                                                            repeats:NO
                                                      dispatchQueue:dispatch_get_main_queue()];
    }
    else
    {
        _refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3.0
                                                             target:self
                                                           selector:@selector(refreshDefaild)
                                                           userInfo:nil
                                                            repeats:NO
                                                      dispatchQueue:dispatch_get_main_queue()];
    }
    [self getMusicData];
}

- (void)refreshDefaild
{
    [_tableView.mj_header endRefreshing];
}

#pragma mark -- tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ceil(_resourceArray.count/4.0) * 80*Rate_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndetifier = @"MusicCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
    _typeImageViewArray = [NSMutableArray array];
    if (_typeBtnArray == nil)
    {
        _typeBtnArray = [NSMutableArray array];
    }
    for (int i = 0; i < _resourceArray.count; i++)
    {
        MusicModel *musicModel = [_resourceArray objectAtIndex:i];
        _typeImageView = [[UIImageView alloc] init];
        _typeImageView.frame = CGRectMake((24 + (i%4)*94)*Rate_W, (12 + (i/4)*79)*Rate_H, 45*Rate_W, 35*Rate_H);
        
        BOOL containFile = NO;
        for (NSString *fileName in _filePathArray)
        {
            if ([musicModel.musicUrl containsString:fileName])
            {
                containFile = YES;
                if (i == _typeNumber)
                {
                    [_typeImageView sd_setImageWithURL:[NSURL URLWithString:musicModel.btnBgUrl_Colour] placeholderImage:[UIImage new] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        [_typeImageView setImage:image];
                    }];
                }
                else
                {
                    [_typeImageView sd_setImageWithURL:[NSURL URLWithString:musicModel.btnBgUrl_Gray] placeholderImage:[UIImage new] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        [_typeImageView setImage:image];
                    }];
                }
            }
        }
        if (containFile == NO)
        {
            [_typeImageView sd_setImageWithURL:[NSURL URLWithString:musicModel.btnBgUrl_Gray] placeholderImage:[UIImage new] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                [_typeImageView setImage:image];
            }];
        }
        //自适应图片宽高比例
        _typeImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_typeImageViewArray addObject:_typeImageView];
        [cell.contentView addSubview:_typeImageView];
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake((15 + (i%4)*94)*Rate_W, (59 + (i/4)*79)*Rate_H, 63*Rate_W, 15*Rate_H)];
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.font = [UIFont systemFontOfSize:14*Rate_H];
        typeLabel.textColor = [UIColor colorWithRed:0x98/255 green:0x98/255 blue:0x98/255 alpha:1.0];
        typeLabel.text = musicModel.musicName;
        [cell.contentView addSubview:typeLabel];
        
        BOOL containBtn = NO;
        for (MusicButton *tmp in _downloadBtnArray)
        {
            if (tmp.tag == 10 + i)
            {
                containBtn = YES;
                [cell.contentView addSubview:tmp];
                [_typeBtnArray replaceObjectAtIndex:i withObject:tmp];
            }
        }
        if (!containBtn)
        {
            //添加音乐类型按钮
            MusicButton *typeBtn = [MusicButton buttonWithType:UIButtonTypeCustom];
            typeBtn.tag = 10 + i;
            typeBtn.frame = CGRectMake((i%4)*94*Rate_W, (i/4)*79*Rate_H, 93*Rate_W, 79*Rate_H);
            [typeBtn addTarget:self action:@selector(selectMusic:) forControlEvents:UIControlEventTouchUpInside];
            typeBtn.downLoad = containFile;
            if (typeBtn.downLoad == NO)
            {
                [typeBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
            }
            if (i < _typeBtnArray.count)
            {
                [_typeBtnArray replaceObjectAtIndex:i withObject:typeBtn];
            }
            else
            {
                [_typeBtnArray addObject:typeBtn];
            }
            
            [cell.contentView addSubview:typeBtn];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//音乐类型按钮点击事件
- (void)selectMusic:(MusicButton *)sender
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doMusicSomething:) object:sender];
    [self performSelector:@selector(doMusicSomething:) withObject:sender afterDelay:0.5f];
}

- (void)doMusicSomething:(MusicButton *)sender
{
    if (sender.selected == NO)
    {
        [self musicPlay:sender ButtonClick:YES];
    }
    else
    {
        [self musicPause:sender];
    }
}

- (void)setPlayAreaValueWithMusicModel:(MusicModel *)musicModel
{
    //修改播放区域
    [_backGroundImagView sd_setImageWithURL:[NSURL URLWithString:musicModel.playBgBottom] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [_backGroundImagView setImage:image];
    }];
    [_maskImagView sd_setImageWithURL:[NSURL URLWithString:musicModel.playBgTop] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [_maskImagView setImage:image];
    }];
    [_typeView sd_setImageWithURL:[NSURL URLWithString:musicModel.btnBgUrl_White] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [_typeView setImage:image];
    }];
    _nameLabel.text = musicModel.musicName;
}

- (NSData *)setImageForImageView:(NSString *)imageURL
{
    NSData *imageData = nil;
    
    BOOL isExit = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:imageURL]];
    if (isExit)
    {
        NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageURL]];
        if (cacheImageKey.length)
        {
            NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
            if (cacheImagePath.length)
            {
                imageData = [NSData dataWithContentsOfFile:cacheImagePath];
            }
        }
    }
    if (!imageData) {
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    }
    
    return imageData;
}

#pragma mark -
#pragma mark URL Connection Data Delegate Methods
//刚开始接受响应时调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response
{
    [webData setLength: 0];
}

//每接收到一部分数据就追加到webData中
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *) data
{
    [webData appendData:data];
}

//出现错误时
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    conn = nil;
    webData = nil;
}

//完成接收数据时调用
- (void)connectionDidFinishLoading:(NSURLConnection *) connection
{
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes]
                                                length:[webData length]
                                              encoding:NSUTF8StringEncoding];
    
    // 打印出得到的XML
    NSLog(@"%@", theXML);
    // 使用NSXMLParser解析出我们想要的结果
    xmlParser = [[NSXMLParser alloc] initWithData: webData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
}


#pragma mark -
#pragma mark XML Parser Delegate Methods
//开始解析一个元素名
-(void)parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:matchingElement])
    {
        if (!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        elementFound = YES;
    }
}

//追加找到的元素值，一个元素值可能要分几次追加
- (void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if (elementFound)
    {
        [soapResults appendString: string];
    }
}

// 结束解析这个元素名
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:matchingElement])
    {
        if ([matchingElement isEqualToString:@"APP_GetAllMusicResourceResponse"])
        {
            if (_refreshTimer != nil)
            {
                [_refreshTimer invalidate];
                _refreshTimer = nil;
            }
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            if (_musicArray == nil)
            {
                _musicArray = [NSMutableArray array];
            }
            for (int i = 0; i < resultArray.count; i++)
            {
                NSDictionary *tmpDic = [resultArray objectAtIndex:i];
                BOOL containModel = NO;
                for (int i = 0; i < _musicArray.count; i++)
                {
                    MusicModel *m = [_musicArray objectAtIndex:i];
                    if ([m.musicID isEqualToString:[tmpDic objectForKey:@"Num"]])
                    {
                        containModel = YES;
                        //判断是否最新，是则不做操作，否则更新本地数据
                        if ([self dateOrderWithStartTime:m.updateDate endTime:[tmpDic objectForKey:@"Date"]])
                        {
                            //更新
                            MusicModel *tmpModel = [[MusicModel alloc] init];
                            tmpModel.musicID = [tmpDic objectForKey:@"Num"];
                            tmpModel.state = [tmpDic objectForKey:@"State"];
                            tmpModel.musicName = [tmpDic objectForKey:@"Name"];
                            tmpModel.musicUrl = [tmpDic objectForKey:@"MusicUrl"];
                            tmpModel.btnBgUrl_Gray = [tmpDic objectForKey:@"BtnBgUrlLiangse"];
                            tmpModel.btnBgUrl_Colour = [tmpDic objectForKey:@"BtnBgUrlCaise"];
                            tmpModel.btnBgUrl_White = [tmpDic objectForKey:@"BtnBgUrlBaise"];
                            tmpModel.playBgBottom = [tmpDic objectForKey:@"TopBgUrlFang"];
                            tmpModel.playBgTop = [tmpDic objectForKey:@"TopBgUrlBolang"];
                            tmpModel.updateDate = [tmpDic objectForKey:@"Date"];
                            tmpModel.visible = [tmpDic objectForKey:@"Visible"];
                            //更新本地数据
                            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
                            [dbOpration updateMusicInfo:tmpModel];
                            [dbOpration closeDataBase];
                            //更新_localMusicArray数组
                            [_musicArray replaceObjectAtIndex:i withObject:tmpModel];
                        }
                    }
                }
                if (!containModel)
                {
                    MusicModel *tmpModel = [[MusicModel alloc] init];
                    tmpModel.musicID = [tmpDic objectForKey:@"Num"];
                    tmpModel.state = [tmpDic objectForKey:@"State"];
                    tmpModel.musicName = [tmpDic objectForKey:@"Name"];
                    tmpModel.musicUrl = [tmpDic objectForKey:@"MusicUrl"];
                    tmpModel.btnBgUrl_Gray = [tmpDic objectForKey:@"BtnBgUrlLiangse"];
                    tmpModel.btnBgUrl_Colour = [tmpDic objectForKey:@"BtnBgUrlCaise"];
                    tmpModel.btnBgUrl_White = [tmpDic objectForKey:@"BtnBgUrlBaise"];
                    tmpModel.playBgBottom = [tmpDic objectForKey:@"TopBgUrlFang"];
                    tmpModel.playBgTop = [tmpDic objectForKey:@"TopBgUrlBolang"];
                    tmpModel.updateDate = [tmpDic objectForKey:@"Date"];
                    tmpModel.visible = [tmpDic objectForKey:@"Visible"];
                    //插入本地数据
                    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
                    [dbOpration insertMusicInfo:tmpModel];
                    [dbOpration closeDataBase];
                    //添加到数组
                    [_musicArray addObject:tmpModel];
                }
            }
            //_resourceArray的深复制
            _resourceArray = [NSMutableArray array];
            for (int i = 0; i < _musicArray.count; i++)
            {
                MusicModel *tmpModel = [[_musicArray objectAtIndex:i] copy];
                [_resourceArray addObject:tmpModel];
            }
            [self removeVisibleMusicData];
            
//            [self createPlayArea];
            //创建页面
            [self createPlayArea];
            [self createTableView];
            
            _progressHud.labelText = @"加载完成";
            [_progressHud hide:YES afterDelay:0.5];
            [_tableView reloadData];
            [_tableView.mj_header endRefreshing];
            
            //设置网络状态可用
            netState = @"可用";
        }
        
        elementFound = FALSE;
        // 强制放弃解析
        [xmlParser abortParsing];
    }
}

//解析整个文件结束后
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

//出错时，例如强制结束解析
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

- (void)removeVisibleMusicData
{
    if (_resourceArray.count > 0)
    {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i = 0; i < _resourceArray.count; i++)
        {
            MusicModel *tmpModel = [_resourceArray objectAtIndex:i];
            if ([tmpModel.visible isEqualToString:@"1"])
            {
                [tempArr addObject:tmpModel];
            }
        }
        _resourceArray = tempArr;
    }
}

/**
 * 根据日期字符串判断时间先后
 */

- (BOOL)dateOrderWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *startD = [date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    NSInteger day = value / (24 * 3600);
    if (day > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
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
