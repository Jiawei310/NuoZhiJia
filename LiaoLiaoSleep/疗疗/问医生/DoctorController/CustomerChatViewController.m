//
//  CustomerChatViewController.m
//  Chat
//
//  Created by 甘伟 on 16/12/26.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "CustomerChatViewController.h"

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

//视图控制器
#import "DoctorDetailsViewController.h"
#import "CommendViewController.h"
#import "ConsultRuleViewController.h"
#import "DoctorHomeViewController.h"
#import "MyQuestionsViewController.h"
#import "GaugeViewController.h"
#import "TestReportViewController.h"
#import "ReportShowViewController.h"

//自定义
#import "UIViewController+BackButton.h"
#import "ChatTextTableViewCell.h"
#import "ChatImageTableViewCell.h"
#import "ChatTimeTableViewCell.h"
#import "ScaleTableViewCell.h"

//三方
#import "UIImageView+EMWebCache.h"
#import "UIViewController+HUD.h"
#import "NSDate+Category.h"
#import "MJRefresh.h"
#import "MessageModel.h"
#import <UMMobClick/MobClick.h>

//环信
#import "EaseMessageReadManager.h"
#import "EaseSDKHelper.h"

//宏定义
#import "Define.h"

@interface CustomerChatViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>{
    UIMenuItem *_copyMenuItem; //复制框
    UILongPressGestureRecognizer *_lpgr;//长按
    dispatch_queue_t _messageQueue;
}

@end

@implementation CustomerChatViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
{
    if ([conversationChatter length] == 0)
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:EMConversationTypeChat createIfNotExist:YES]; //获取会话
        _messageCountOfPage = 50; //会话最大数
        _deleteConversationIfNull = NO;//是否删除会话记录
        _scrollToBottomWhenAppear = YES;//显示最底部
        _messsagesSource = [NSMutableArray array];//聊天记录
        [_conversation markAllMessagesAsRead:nil];//标记已读
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MobClick beginLogPageView:@"等待接诊／正在问答"];
    //注册消息回调
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_conversation markAllMessagesAsRead:nil];//标记已读
    //隐藏tabBar
    self.tabBarController.tabBar.hidden = NO;
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [MobClick endLogPageView:@"等待接诊／正在问答"];
    
}

- (void)viewDidDisappear:(BOOL)animated
{

}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateScaleTest" object:nil];
    //增加监听量表更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scaleTestUpdate:) name:@"updateScaleTest" object:nil];
#pragma mark -- 单击键盘消失
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
#pragma mark -- 长按复制
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    _isWaiting = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChange:) userInfo:nil repeats:YES];
    _messageQueue = dispatch_queue_create("hyphenate.com", NULL);
    //数据处理对象
    _patientInfo = [PatientInfo shareInstance];
    _handle =  [[DataHandle alloc] init];
    [_timer setFireDate:[NSDate distantFuture]];
    //准备数据
    [self prepareData];
}

#pragma mark -- 指定返回界面
- (void)backLoginClick:(UIButton *)click
{
    if (!_isAsking)
    {
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[DoctorHomeViewController class]] || [controller isKindOfClass:[MyQuestionsViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 准备数据
- (void)prepareData
{
    if (_isAsking)
    {
        //获取问题详情
        NSData *detailData = [_handle getDataFromNetWorkWithStringType:DataModelBackTypeGetQuestionDetail andPrimaryKey:_questionID];
        NSArray *arr = [_handle objectFromeResponseString:detailData andType:(DataModelBackTypeGetQuestionDetail)];
        for (NSDictionary *dic in arr)
        {
            _model = [[ConsultQuestionModel alloc] initWithDictionary:dic];
                //获取对方发送的消息
            EMConversation *coversation = [[EMClient sharedClient].chatManager getConversation:_model.doctorID type:(EMConversationTypeChat) createIfNotExist:NO];
            [coversation loadMessagesWithKeyword:nil timestamp:0 count:1 fromUser:_model.doctorID searchDirection:(EMMessageSearchDirectionDown) completion:^(NSArray *aMessages, EMError *aError) {
                if(aMessages.count > 0 )
                {
                    //是否上传了截止时间
                    if ([FunctionHelper isBlankString:_model.answerTime])
                    {
                        //获取医生的回复的第一条消息
                        EMMessage *message = aMessages[0];
                        NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
                        //上传问题的截止时间
                        [self uploadDoctorInfoWithMessage:messageDate];
                    }
                    _isWaiting = NO;
                    [self createViewWhenConsuting];
                }
                else
                {
                    _isWaiting = YES; //正在等待
                    [self createViewWhenWating];
                }
            }];
        }
    }
    else
    {
        //从填写症状界面跳转过来的;
        _model = [[ConsultQuestionModel alloc] init];
        _model.questionID = _questionID; //问题ID
        _model.question = _question;//问题内容
        _model.startTime = _time;//问题的开始时间
        _model.doctorID = _doctorID;//医生ID
        _isWaiting = YES;
        [self createViewWhenWating];
    }
}

#pragma mark -- 获取追问次数
- (void)getAskCount
{
    //获取追问条数
    NSData *data1 = [_handle getDataFromNetWorkWithStringType:(DataModelBackTypeGetQuestionAskCount) andPrimaryKey:_questionID];
    NSString *result = [_handle objectFromeResponseString:data1 andType:(DataModelBackTypeGetQuestionAskCount)];
    if ([result integerValue] == 0)
    {
        _askCount = @"0";
        _totalCount = @"10";
    }
    else if([result integerValue] < 10)
    {
        _askCount = result;
        _totalCount = @"10";
    }
    else
    {
        _askCount = [result componentsSeparatedByString:@"/"][0] ;
        _totalCount = [result componentsSeparatedByString:@"/"][1] ;
    }
}

#pragma mark -- 等待接诊时
- (void)createViewWhenWating
{
    self.navigationItem.title = @"等待接诊";
    //添加导航栏右边按钮，设备状态查看
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [btn addTarget:self action:@selector(deleteQuestion) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"删除" forState:(UIControlStateNormal)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    [self creatHeaderView];
    [self.view addSubview:_headerView];
    [self createFooterView];
}

#pragma mark -- 删除问题
- (void)deleteQuestion
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"撤销提问" message:@"你确定撤销该提问吗？（由于医生未接诊，我们将“问题数”返还与您）" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alter.tag = 111;
    [alter show];
}

#pragma mark -- 正在问答时
- (void)createViewWhenConsuting
{
    [_headerView removeFromSuperview];
    [_footerView removeFromSuperview];
     [_timer setFireDate:[NSDate distantPast]];
    self.navigationItem.title = @"正在问答";
    //添加导航栏右边按钮，设备状态查看
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    [btn addTarget:self action:@selector(stopConsult) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"结束咨询" forState:(UIControlStateNormal)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    [self createTimeViewWithFrame:CGRectMake(0, SCREENHEIGHT-64-50-30, SCREENWIDTH, 30)];
    //获取问题的追问次数
    [self getAskCount];
    //若追问次数已用完，则创建继续追问按钮
    if ([_askCount integerValue] == [_totalCount integerValue])
    {
        [self continueAskButton];
        [self createTableViewWithHight:_continueBtn.frame.size.height];
    }
    else
    {
        [self createChatToolBar];
        [self createTableViewWithHight:_chatToolbar.frame.size.height];
    }
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark -- 问题未关闭时间倒计时
- (void)createTimeViewWithFrame:(CGRect)frame
{
    [_timeView removeFromSuperview];
    _timeView = [[UIView alloc] init];
    _timeView.frame = frame;
    _timeView.layer.borderWidth = 0.5;
    _timeView.layer.borderColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0].CGColor;
    _timeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_timeView];
    
    if(_isClosed)
    {
        _timeLeave = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, SCREENWIDTH, 20)];
        _timeLeave.text = @"问题已关闭";
        _timeLeave.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.00];
        _timeLeave.font = [UIFont systemFontOfSize:16];
        _timeLeave.textAlignment = NSTextAlignmentCenter;
        [_timeView addSubview:_timeLeave];
    }
    else
    {
        _timeLeave = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 166, 20)];
        _timeLeave.text = @"离问题关闭还有";
        _timeLeave.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.00];
        _timeLeave.font = [UIFont systemFontOfSize:16];
        [_timeLeave sizeToFit];
        [_timeView addSubview:_timeLeave];
        
        //距离问题关闭的时间
        _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_timeLeave.frame)+5, 5, 166, 20)];
        _timeLable.text = [self getTimeIntervalWithEndTime:_model.answerTime];
        _timeLable.font = [UIFont systemFontOfSize:16];
        _timeLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.00];
        [_timeLable adjustsFontSizeToFitWidth];
        [_timeView addSubview:_timeLable];
    }
}

#pragma mark -- 创建chatToolBar
- (void)createChatToolBar
{
    [_continueBtn removeFromSuperview];
    _chatToolbar = [[DoctorChatToolBar alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-64-50, self.view.frame.size.width, 50)];
    _chatToolbar.delegate = self;
    [self.view addSubview:_chatToolbar];
}

#pragma mark -- 创建问题标签
- (void)creatHeaderView
{
    //头部视图
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 128*Rate_NAV_H)];
    _headerView.backgroundColor = [UIColor whiteColor];
    
    //提问图标
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 17*Rate_NAV_H, 46*Rate_NAV_W, 24*Rate_NAV_H)];
    imageV.image = [UIImage imageNamed:@"tab_ask.png"];
    [_headerView addSubview:imageV];
    
    //提问时间
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(258*Rate_NAV_W, 17*Rate_NAV_H, 101*Rate_NAV_W, 14*Rate_NAV_H)];
    time.text = _model.startTime;
    time.textColor = [UIColor colorWithRed:0.62 green:0.64 blue:0.64 alpha:1.0];
    time.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    time.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:time];
    
    //提问的问题
    UILabel *question = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 35*Rate_NAV_H, 290*Rate_NAV_W, 52*Rate_NAV_H)];
    question.text = _model.question;
    question.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    question.numberOfLines = 2;
    [_headerView addSubview:question];
    
    //分割线
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 76*Rate_NAV_H, 345*Rate_NAV_W, Rate_NAV_H)];
    line1.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [_headerView addSubview:line1];
    
    //查看量表
    UILabel *scaleLable = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 91*Rate_NAV_H, 169*Rate_NAV_W, 22*Rate_NAV_H)];
    scaleLable.text = @"查看我的量表结果";
    scaleLable.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [_headerView addSubview:scaleLable];
    
    //量表跳转箭头
    UIImageView *scaleArrow = [[UIImageView alloc] initWithFrame:CGRectMake(344*Rate_NAV_W, 94*Rate_NAV_H, 16*Rate_NAV_H, 17*Rate_NAV_H)];
    scaleArrow.image = [UIImage imageNamed:@"icon_arrow_dark.png"];
    [_headerView addSubview:scaleArrow];
    
    //查看量表按钮
    UIButton *scaleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 77*Rate_NAV_H, 375*Rate_NAV_W, 50*Rate_NAV_H)];
    [scaleBtn addTarget:self action:@selector(lookResult) forControlEvents:(UIControlEventTouchUpInside)];
    [_headerView addSubview:scaleBtn];
}

#pragma mark -- 查看量表结果
-(void)lookResult
{
    ReportShowViewController *reportVC =[[ReportShowViewController alloc] init];
    reportVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reportVC animated:YES];
}

#pragma mark -- 创建等待接诊界面
-(void)createFooterView
{
    //等待接诊时的界面
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame)+10*Rate_NAV_H, SCREENWIDTH, SCREENHEIGHT-CGRectGetMaxY(_headerView.frame)-64-10*Rate_NAV_H)];
    [self.view addSubview:_footerView];
    
    UIImageView *imageV1 = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 10*Rate_NAV_H, SCREENWIDTH-30*Rate_NAV_W, 39*Rate_NAV_H)];
    imageV1.image = [UIImage imageNamed:@"describe_bg.png"];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(103*Rate_NAV_W, 9*Rate_NAV_H, 139*Rate_NAV_W, 20*Rate_NAV_H)];
    lable.text = @"正在为您分配医生......";
    lable.textColor = [UIColor colorWithRed:0.07 green:0.64 blue:1.00 alpha:1.00];
    lable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [imageV1 addSubview:lable];
    [_footerView addSubview:imageV1];
    
    UIImageView *imageV2 = [[UIImageView alloc] initWithFrame:CGRectMake(79*Rate_NAV_W, 166*Rate_NAV_H, 218*Rate_NAV_W, 137*Rate_NAV_H)];
    imageV2.image = [UIImage imageNamed:@"img_doc.png"];
    [_footerView addSubview:imageV2];
}

#pragma mark -- 创建医生信息
- (void)createDoctorInfo
{
    //获取医生信息
    NSData *doctorData = [_handle getDataFromNetWorkWithStringType:(DataModelBackTypeGetDoctorInfo) andPrimaryKey:_model.doctorID];
    NSArray *temp = [_handle objectFromeResponseString:doctorData andType:(DataModelBackTypeGetDoctorInfo)];
    DoctorInfoModel *doctor;
    for (NSDictionary *dic in temp)
    {
        doctor = [[DoctorInfoModel alloc] initWithDictionary:dic];
    }
    //延长头部视图
    _headerView.frame = CGRectMake(0, 0, SCREENWIDTH, 397*Rate_NAV_H);
    
    //分割线
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 128*Rate_NAV_H, SCREENWIDTH, 10*Rate_NAV_H)];
    line1.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line1];
    
    //医生头像
    UIImageView *doctorIcon = [[UIImageView alloc] initWithFrame:CGRectMake(153*Rate_NAV_W, 158*Rate_NAV_H, 70*Rate_NAV_H, 70*Rate_NAV_H)];
    [doctorIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,doctor.doctorIcon]] placeholderImage:[UIImage imageNamed:@"headerImage_doctor"]];
    doctorIcon.layer.cornerRadius = 35*Rate_NAV_H;
    doctorIcon.clipsToBounds = YES;
    doctorIcon.userInteractionEnabled = YES;
    //医生详情
    UIButton *doctionDetail = [[UIButton alloc] initWithFrame:doctorIcon.bounds];
    [doctionDetail addTarget:self action:@selector(doctorDetail) forControlEvents:(UIControlEventTouchUpInside)];
    [doctorIcon addSubview:doctionDetail];
    [_headerView addSubview:doctorIcon];
    
    //医生姓名
    UILabel *doctorName = [[UILabel alloc] initWithFrame:CGRectMake(0, 233*Rate_NAV_H, SCREENWIDTH, 28*Rate_NAV_H)];
    doctorName.text = doctor.doctorName;
    doctorName.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    doctorName.textAlignment = NSTextAlignmentCenter;
    doctorName.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_headerView addSubview:doctorName];
    
    //医生信息（医院、科室）
    UILabel *doctorInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 256*Rate_NAV_H, SCREENWIDTH, 20*Rate_NAV_H)];
    doctorInfo.text = [NSString stringWithFormat:@"%@ %@",doctor.doctorHospital,doctor.doctorDepartment];
    doctorInfo.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    doctorInfo.textAlignment = NSTextAlignmentCenter;
    doctorInfo.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_headerView addSubview:doctorInfo];
    
    //医生星等级
    for(int i = 0; i < 5; i++)
    {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake((120 + 21*i)*Rate_NAV_W, 293*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
        if (i < [doctor.doctorStar intValue])
        {
            star.image = [UIImage imageNamed:@"star_in.png"];
        }
        else
        {
            star.image = [UIImage imageNamed:@"star.png"];
        }
        [_headerView addSubview:star];
    }
    
    //评论医生的人数
    UILabel *patientCount = [[UILabel alloc] initWithFrame:CGRectMake(229*Rate_NAV_W, 293*Rate_NAV_H, 100*Rate_NAV_W, 14*Rate_NAV_H)];
    patientCount.tag = 100;
    patientCount.text = [NSString stringWithFormat:@"(%@)",doctor.commentCount];
    patientCount.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    patientCount.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    patientCount.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:patientCount];
    
    //分割线
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 326*Rate_NAV_H, SCREENWIDTH, Rate_NAV_H)];
    line2.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line2];
    
    //10次追问机会提示信息
    UILabel *noticeLable = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 327*Rate_NAV_H, SCREENWIDTH, 69*Rate_NAV_H)];
    noticeLable.text = [NSString stringWithFormat:@"您有10次追问机会！\n医生回复仅为建议，有疑问请医院就诊"];
    noticeLable.numberOfLines = 2;
    noticeLable.textAlignment = NSTextAlignmentCenter;
    noticeLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.00];
    [_headerView addSubview:noticeLable];
    
    UILabel *line3 = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 396*Rate_NAV_H, 335*Rate_NAV_W, Rate_NAV_H)];
    line3.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line3];
}

#pragma mark -- 创建tableView
- (void)createTableViewWithHight:(CGFloat)heigt
{
    [self creatHeaderView];
    [self createDoctorInfo];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, self.view.frame.size.height-heigt-_timeView.frame.size.height) style:(UITableViewStylePlain)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = _headerView;
    _tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMessage)];
    [self.view addSubview:_tableView];
}

#pragma mark-- 下拉刷新
- (void)loadMessage
{
    [_tableView.mj_header endRefreshing];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    //time cell
    if ([object isKindOfClass:[NSString class]])
    {
        NSString *TimeCellIdentifier = [ChatTimeTableViewCell cellIdentifier];
        ChatTimeTableViewCell *timeCell = (ChatTimeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        if (timeCell == nil)
        {
            timeCell = [[ChatTimeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        timeCell.title = object;
        timeCell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        return timeCell;
    }
    else
    {
        MessageModel *model = object;
        if (model.bodyType == EMMessageBodyTypeText)
        {
            if ([model.text isEqualToString:@"量表已更新"])
            {
                NSString *ScaleCellIdentifier = @"ScaleTableViewCellID";
                ScaleTableViewCell *timeCell = (ScaleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ScaleCellIdentifier];
                if (!timeCell)
                {
                    timeCell = [[ScaleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ScaleCellIdentifier];
                    timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                timeCell.selectionStyle = UITableViewCellSeparatorStyleNone;
                return timeCell;
            }
            else
            {
                static NSString *cellID = @"textCellID";
                ChatTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (!cell)
                {
                    cell = [[ChatTextTableViewCell alloc] init];
                }
                cell.model = model;
                cell.selectionStyle = UITableViewCellSeparatorStyleNone;
                
                return cell;
            }
        }
        else if(model.bodyType == EMMessageBodyTypeImage)
        {
            static NSString *cellID = @"imageCellID";
            ChatImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell)
            {
                cell = [[ChatImageTableViewCell alloc] init];
            }
            cell.model = model;
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            return cell;
        }
        else
        {
            return nil;
        }
    }
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

#pragma mark -- 上传截止时间
- (void)uploadDoctorInfoWithMessage:(NSDate *)answerTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate dateWithTimeInterval:60*60*48 sinceDate:answerTime]];
    _model.answerTime = dateTime;
    [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadQuestionDeadline) andDictionary:@{@"AnswerTime":dateTime,@"QuestionID":_questionID}];
}

#pragma mark -- 查看医生详情
- (void)doctorDetail
{
    if ([FunctionHelper isExistenceNetwork])
    {
        if([_model.doctorID isEqualToString:@""])
        {
            [self showHint:@"请刷新界面"];
        }
        else
        {
            DoctorDetailsViewController * detail = [[DoctorDetailsViewController alloc] init];
            detail.doctorID = _model.doctorID;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
    else
    {
        [self showHint:@"检查网络连接"];
    }
}

#pragma mark -- 倒计时
- (void)timeChange:(NSTimer *)timer
{
    NSArray *temp = [[self getTimeIntervalWithEndTime:_model.answerTime] componentsSeparatedByString:@":"];
    if ([temp[0] intValue] <= 0 && [temp[1] intValue] <= 0 && [temp[2] intValue] <= 0)
    {
        [self cancelConversation];
    }
    else
    {
        _timeLable.text = [self getTimeIntervalWithEndTime:_model.answerTime];
    }
}

#pragma mark -- 结束咨询
- (void)stopConsult
{
    //判断是否有网络
    if([FunctionHelper isExistenceNetwork])
    {
        UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"结束咨询" message:@"是否结束咨询" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"结束", nil];
        [alterV show];
    }
    else
    {
        UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"网络出错" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alterV show];
    }
}

#pragma mark -- 取消对话
- (void)cancelConversation
{
    if ([FunctionHelper isBlankString:_doctorID])
    {
        _doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDoctorID"];
    }
    [_timer setFireDate:[NSDate distantFuture]];
    _isClosed = YES;
    [_chatToolbar removeFromSuperview];
    [_continueBtn removeFromSuperview];
    [self createTimeViewWithFrame:CGRectMake(0, self.view.frame.size.height-30, SCREENWIDTH, 30)];
    self.tableView.frame = CGRectMake(0, 0, SCREENWIDTH, self.view.frame.size.height-_timeView.frame.size.height);
    //跟新数据
    [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadQuestionState) andDictionary:@{@"IsClose":@"1",@"QuestionID":_questionID}];
    //医生的解决问题数加1
    [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadAnswerCountOrFullStar) andDictionary:@{@"DoctorID":_doctorID,@"AnswerCount":@"1",@"FullStarCount":@"0"}];
    //清除数据
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentQuestionID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentDoctorID"];
//#warning 添加去除“结束咨询”
    self.navigationItem.rightBarButtonItem = nil;
    //跳至评价界面
    CommendViewController *commend = [[CommendViewController alloc] init];
    commend.doctorID = _doctorID;
    commend.patientID = _patientInfo.PatientID;
    commend.isJump = YES;
    [self.navigationController pushViewController:commend animated:YES];
}

#pragma mark --继续追问按钮
- (void)continueAskButton
{
    [_chatToolbar removeFromSuperview];
    _continueBtn = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, self.view.frame.size.height-50, 331*Rate_NAV_W, 50)];
    _continueBtn.layer.cornerRadius = 25;
    _continueBtn.clipsToBounds = YES;
    _continueBtn.tag = 11;
    [_continueBtn setTitle:@"继续追问" forState:(UIControlStateNormal)];
    [_continueBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [_continueBtn setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
    [_continueBtn addTarget:self action:@selector(gotoAsk) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_continueBtn];
}

#pragma mark --询问是否继续追问
- (void)gotoAsk
{
    NSData *data = [_handle getDataFromNetWorkWithStringType:(DataModelBackTypeGetLeaveNumber) andPrimaryKey:_patientInfo.PatientID];
    if([[_handle objectFromeResponseString:data andType:(DataModelBackTypeGetLeaveNumber)] integerValue] > 0)
    {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"追问次数完毕" message:@"继续追问，您将消耗1个新问题来换取格外追问此医生10次的机会,是否继续?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        alertV.tag = 113;
        [alertV show];
    }
    else
    {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"追问次数完毕" message:@"继续追问将消耗1个新问题,您的剩余问题为0,是否购买?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        alertV.tag = 114;
        [alertV show];
    }
}

#pragma mark -- delegateAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 113)
    {
        if (buttonIndex == 1)
        {
            if([FunctionHelper uploadLeaveNumber:@"-1" withQuestionID:_patientInfo.PatientID])
            {
                _totalCount = [NSString stringWithFormat:@"%li",[_totalCount integerValue]+10];
                [FunctionHelper uploadAskCount:[NSString stringWithFormat:@"%@/%@",_askCount,_totalCount] withQuestionID:_questionID];
                [self showHint:@"您的问题已被激活，请继续追问"];
                UIButton *btn = (UIButton *)[self.view viewWithTag:103];
                [btn removeFromSuperview];
                [self createChatToolBar];
            }
        }
    }
    else if (alertView.tag == 114)
    {
        if (buttonIndex == 1)
        {
            ConsultRuleViewController *purchase = [[ConsultRuleViewController alloc] init];
            purchase.patientID = [EMClient sharedClient].currentUsername;
            [self.navigationController pushViewController:purchase animated:YES];
        }
        else
        {
            
        }
    }
    else if (alertView.tag == 111)
    {
//#warning 添加按钮点击判断
        if (buttonIndex == 1)
        {
            NSData *leaveData =  [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadLeaveNumber) andDictionary:@{@"LeaveNumber":@"1",@"PatientID":_patientInfo.PatientID}];
            if ([[_handle objectFromeResponseString:leaveData andType:(DataModelBackTypeUploadLeaveNumber)] isEqualToString:@"OK"])
            {
                if ([FunctionHelper isBlankString:_doctorID])
                {
                    _doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDoctorID"];
                }
                _isClosed = YES;
                //跟新数据
                [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadQuestionState) andDictionary:@{@"IsClose":@"1",@"QuestionID":_questionID}];
                //清除数据
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentQuestionID"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentDoctorID"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"抱歉" message:@"服务器出错，请稍后重试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
            }
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            [self cancelConversation];
        }
        else
        {
            
        }
    }
}

#pragma mark -- 获取时间间隔
- (NSString *)getTimeIntervalWithEndTime:(NSString *)endTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [NSDate date];
    NSDate *date2 = [formatter dateFromString:endTime];
    //    先定义一个遵循某个历法的日历对象
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    根据两个时间点，定义NSDateComponents对象，从而获取这两个时间点的时差
    NSDateComponents *dateComponents = [greCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date1 toDate:date2 options:0];
    return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)dateComponents.hour, (int)dateComponents.minute, (int)dateComponents.second];
}

#pragma mark --- 键盘即将出现
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat transformY = keyboardRect.origin.y - self.parentViewController.view.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}

#pragma mark --- 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat transformY = keyboardRect.origin.y - self.parentViewController.view.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}

#pragma mark - getter
- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil)
    {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

#pragma mark - getter
- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - getter
- (NSMutableArray *)historyMesssages
{
    if (_historyMesssages == nil)
    {
        _historyMesssages = [NSMutableArray array];
    }
    return _historyMesssages;
}

#pragma mark - setter
- (void)setIsViewDidAppear:(BOOL)isViewDidAppear
{
    _isViewDidAppear =isViewDidAppear;
    if (_isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        [_conversation markAllMessagesAsRead:nil];
    }
}

#pragma mark - private helper
#pragma mark -- 滑至底部
- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

#pragma mark -- 复制按钮
- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    if (_menuController == nil)
    {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil)
    {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (messageType == EMMessageBodyTypeText)
    {
        [_menuController setMenuItems:@[_copyMenuItem]];
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

#pragma mark -- 下载聊天记录
- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:@"获取消息失败"];
        }
    };
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage)
    {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
            [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error)
                {
                    [weakSelf _reloadTableViewDataWithMessage:message];
                }
                else
                {
                    [weakSelf showHint:@"音频获取失败"];
                }
            }];
        }
    }
}

#pragma mark -- 发送消息的回调
- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read
{
    //当前登录用户
    NSString *account = [[EMClient sharedClient] currentUsername];
    if (message.chatType != EMChatTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        return NO;
    }
    EMMessageBody *body = message.body;
    if (((body.type == EMMessageBodyTypeVideo) ||
         (body.type == EMMessageBodyTypeVoice) ||
         (body.type == EMMessageBodyTypeImage)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark -- 消息送达的回调
- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        isSend = [self shouldSendHasReadAckForMessage:message
                                                     read:isRead];
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
        }
    }
}

#pragma mark -- 标记消息已读
- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        isMark = NO;
    }
    return isMark;
}
#pragma mark -- 图片消息
- (void)_imageMessageCellSelected:(MessageModel *)model
{
    __weak CustomerChatViewController *weakSelf = self;
    EMImageMessageBody *imageBody = (EMImageMessageBody*)[model.message body];
    if ([imageBody type] == EMMessageBodyTypeImage)
    {
        if (imageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed)
        {
            if (imageBody.downloadStatus == EMDownloadStatusSuccessed)
            {
                //send the acknowledgement
                [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                NSString *localPath = model.message == nil ? model.fileLocalPath : [imageBody localPath];
                if (localPath && localPath.length > 0)
                {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    if (image)
                    {
                        [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
                    }
                    else
                    {
                        NSLog(@"Read %@ failed!", localPath);
                    }
                    return;
                }
            }
            [weakSelf showHudInView:weakSelf.view hint:@"图片下载失败"];
            [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                [weakSelf hideHud];
                if (!error)
                {
                    //send the acknowledgement
                    [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                    NSString *localPath = message == nil ? model.fileLocalPath : [(EMImageMessageBody*)message.body localPath];
                    if (localPath && localPath.length > 0)
                    {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        //                                weakSelf.isScrollToBottom = NO;
                        if (image)
                        {
                            [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [weakSelf showHint:@"图片加载失败"];
            }];
        }
        else
        {
            //get the message thumbnail
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error)
                {
                    [weakSelf _reloadTableViewDataWithMessage:model.message];
                }
                else
                {
                    [weakSelf showHint:@"图片预览失败"];
                }
            }];
        }
    }
}

#pragma mark - 加载消息
- (void)_loadMessagesBefore:(NSString*)messageId
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    __weak typeof(self) weakSelf = self;
    void (^refresh)(NSArray *messages) = ^(NSArray *messages) {
        dispatch_async(_messageQueue, ^{
            //Format the message
            NSArray *formattedMessages = [weakSelf formatMessages:messages];
            //Refresh the page
            dispatch_async(dispatch_get_main_queue(), ^{
                CustomerChatViewController *strongSelf = weakSelf;
                if (strongSelf)
                {
                    NSInteger scrollToIndex = 0;
                    if (isAppend)
                    {
                        [strongSelf.messsagesSource insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                        //Combine the message
                        id object = [strongSelf.dataArray firstObject];
                        if ([object isKindOfClass:[NSString class]])
                        {
                            NSString *timestamp = object;
                            [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                                if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                                {
                                    [strongSelf.dataArray removeObjectAtIndex:0];
                                    *stop = YES;
                                }
                            }];
                        }
                        scrollToIndex = [strongSelf.dataArray count];
                        [strongSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
                    }
                    else
                    {
                        [strongSelf.messsagesSource removeAllObjects];
                        [strongSelf.messsagesSource addObjectsFromArray:messages];
                        [strongSelf.dataArray removeAllObjects];
                        [strongSelf.dataArray addObjectsFromArray:formattedMessages];
                    }
                    EMMessage *latest = [strongSelf.messsagesSource lastObject];
                    strongSelf.messageTimeIntervalTag = latest.timestamp;
                    [strongSelf.tableView reloadData];
                    [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            });
            //re-download all messages that are not successfully downloaded
            for (EMMessage *message in messages)
            {
                [weakSelf _downloadMessageAttachments:message];
            }
            //send the read acknoledgement
            [weakSelf _sendHasReadResponseForMessages:messages
                                               isRead:NO];
        });
    };
    [self.conversation loadMessagesStartFromId:messageId count:(int)count searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count])
        {
            refresh(aMessages);
        }
    }];
}

#pragma mark - GestureRecognizer
- (void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [_chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataArray objectAtIndex:indexPath.row];
        if (![object isKindOfClass:[NSString class]])
        {
            ChatTextTableViewCell *cell = (ChatTextTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _menuIndexPath = indexPath;
            [self showMenuViewController:cell.backgroundImageView andIndexPath:indexPath messageType:cell.model.bodyType];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        
    }
    else
    {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil)
        {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            [self sendImageMessage:orgImage];
        }
        else
        {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f)
            {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset)
                    {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data.length > 10 * 1000 * 1000)
                            {
                                [self showHint:@"图片过大，无法发送"];
                                return;
                            }
                            if (data != nil)
                            {
                                [self sendImageMessageWithData:data];
                            }
                            else
                            {
                                [self showHint:@"图片过大，无法发送"];
                            }
                        }];
                    }
                }];
            }
            else
            {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset)
                    {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        if (fileData.length > 10 * 1000 * 1000)
                        {
                            [self showHint:@"图片过大，无法发送"];
                            return;
                        }
                        [self sendImageMessageWithData:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark - ChatMessageCellDelegate
- (void)messageTextCellSelected:(MessageModel *)model
{
    [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
    _scrollToBottomWhenAppear = NO;
}

- (void)messageImageCellSelected:(MessageModel *)model
{
    [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
    _scrollToBottomWhenAppear = NO;
    [self _imageMessageCellSelected:model];
}

- (void)statusButtonSelcted:(MessageModel * )model withImageMessageCell:(ChatImageTableViewCell *)messageCell
{
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error)
        {
            [weakself _refreshAfterSentMessage:message];
        }
        else
        {
            [weakself.tableView reloadData];
        }
    }];
    [self.tableView reloadData];
}

- (void)statusButtonSelcted:(MessageModel *)model withTextMessageCell:(ChatTextTableViewCell*)messageCell
{
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error)
        {
            [weakself _refreshAfterSentMessage:message];
        }
        else
        {
            [weakself.tableView reloadData];
        }
    }];
    [self.tableView reloadData];
}

#pragma mark - EMChatToolbarDelegate
- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
    
    [self _scrollViewToBottom:NO];
}

- (void)inputTextViewDidChange:(UITextView *)inputTextView
{
    //该判断用于联想输入
    if (inputTextView.text.length > 100)
    {
        inputTextView.text = [inputTextView.text substringToIndex:100];
    }
}

- (void)inputTextViewDidBeginEditing:(UITextView *)inputTextView
{
    
}

- (void)inputTextViewWillBeginEditing:(UITextView *)inputTextView
{
    if (_menuController == nil)
    {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)sendText:(NSString *)text
{
    if (text && text.length > 0)
    {
        [self sendTextMessage:text];
    }
}

#pragma mark - DoctorChatBarMoreViewDelegate
#pragma mark -- 发送量表更新
- (void)sendScaleUpdate:(DoctorChatToolBar *)chatTool
{
    GaugeViewController * gauge = [[GaugeViewController alloc] init];
    gauge.typeFlag = @"Doctor";
    gauge.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gauge animated:YES];
    gauge.hidesBottomBarWhenPushed = NO;
}

- (void)scaleTestUpdate:(NSNotification *)text
{
    [self sendTextMessage:@"量表已更新"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateScaleTest" object:nil];
}

#pragma mark -- 选择图片
- (void)sendPictureActionSheet:(DoctorChatToolBar *)chatTool
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"相册", @"拍照",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

#pragma mark -- actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
    {
        // Hide the keyboard
        [self.chatToolbar endEditing:YES];
        
        // Pop image picker
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        
        self.isViewDidAppear = NO;
        [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
    }
    else if (buttonIndex == 1)
    {
        [self.chatToolbar endEditing:YES];
        
#if TARGET_IPHONE_SIMULATOR
        [self showHint:@"模拟器不支持照相"];
#elif TARGET_OS_IPHONE
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        
        self.isViewDidAppear = NO;
        [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
#endif
        
    }
}

#pragma mark - Hyphenate
#pragma mark - EMChatManagerDelegate
- (void)didReceiveMessages:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages)
    {
        if ([self.conversation.conversationId isEqualToString:message.conversationId])
        {
            [self addMessageToDataSource:message progress:nil];
            [self _sendHasReadResponseForMessages:@[message]
                                           isRead:NO];
            if ([self _shouldMarkMessageAsRead])
            {
                [self.conversation markMessageAsReadWithId:message.messageId error:nil];
            }
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isCreateChatView"])
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCreateChatView"];
                NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *dateTime = [formatter stringFromDate:[NSDate dateWithTimeInterval:60*60*48 sinceDate:messageDate]];
                _model.answerTime = dateTime;
                //上传接诊时间
                NSData * data = [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadQuestionDeadline) andDictionary:@{@"AnswerTime":dateTime,@"QuestionID":_questionID}];
                [_handle objectFromeResponseString:data andType:(DataModelBackTypeUploadQuestionDeadline)];
                [_timer setFireDate:[NSDate distantPast]];
                [self createViewWhenConsuting];
            }
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages)
    {
        if ([self.conversation.conversationId isEqualToString:message.conversationId])
        {
            [self showHint:@"接受扩展消息"];
            break;
        }
    }
}

- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages)
    {
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages)
    {
        if (![self.conversation.conversationId isEqualToString:message.conversationId]){
            continue;
        }
        
        __block MessageModel * model = nil;
        __block BOOL isHave = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if([obj isKindOfClass:[MessageModel class]])
            {
                 model = (MessageModel *)obj;
                 if ([model.messageId isEqualToString:message.messageId])
                 {
                     model.message.isReadAcked = YES;
                     isHave = YES;
                     *stop = YES;
                 }
            }
         }];
        
        if(!isHave)
        {
            return;
        }
        [self.tableView reloadData];
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError
{
    [self _updateMessageStatus:aMessage];
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error
{
    if (!error)
    {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage)
        {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        else if([fileBody type] == EMMessageBodyTypeVideo)
        {
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        else if([fileBody type] == EMMessageBodyTypeVoice)
        {
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }
    else
    {
        
    }
}

#pragma mark - 格式化消息
- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0)
    {
        return formattedArray;
    }
    for (EMMessage *message in messages)
    {
        //Calculate time interval
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60)
        {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            timeStr = [messageDate formattedTime];
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        //Construct message model
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:_patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
        MessageModel * model = [[MessageModel alloc] initWithMessage:message photo:[[UIImage alloc] initWithData:imageData]];
        if (model)
        {
            [formattedArray addObject:model];
        }
    }
    return formattedArray;
}

#pragma mark -- 消息加入数据源数组
- (void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress
{
    NSLog(@"count1 == %li",_dataArray.count);
    [self.messsagesSource addObject:message];
    __weak CustomerChatViewController * weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArray addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark -- 发送图片消息
- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    NSString *messageId = nil;
    if ([self.messsagesSource count] > 0)
    {
        messageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    }
    else
    {
        messageId = nil;
    }
    [self _loadMessagesBefore:messageId count:self.messageCountOfPage append:YES];
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark -- 发送消息后刷新界面
- (void)_refreshAfterSentMessage:(EMMessage*)aMessage
{
    if ([self.messsagesSource count] && [EMClient sharedClient].options.sortMessageByServerTime)
    {
        NSString *msgId = aMessage.messageId;
        EMMessage *last = self.messsagesSource.lastObject;
        if ([last isKindOfClass:[EMMessage class]])
        {
            __block NSUInteger index = NSNotFound;
            index = NSNotFound;
            [self.messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:msgId])
                {
                    index = idx;
                    *stop = YES;
                }
            }];
            if (index != NSNotFound)
            {
                [self.messsagesSource removeObjectAtIndex:index];
                [self.messsagesSource addObject:aMessage];
                
                //格式化消息
                self.messageTimeIntervalTag = -1;
                NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:formattedMessages];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                return;
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark -- 发送消息
- (void)_sendMessage:(EMMessage *)message
{
    BOOL isScale;
    NSInteger count = [_askCount integerValue];
    EMMessageBody *msgBody = message.body;
    if (msgBody.type == EMMessageBodyTypeText)
    {
        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
        NSString *txt = textBody.text;
        if ([txt isEqualToString:@"量表已更新"])
        {
            isScale = YES;
        }
        else
        {
            message.ext = @{@"askCount":[NSString stringWithFormat:@"%li/%@",count+1,_totalCount]};
        }
    }
    else if (msgBody.type == EMMessageBodyTypeImage)
    {
        message.ext = @{@"askCount":[NSString stringWithFormat:@"%li/%@",count+1,_totalCount]};
    }
    
    [self addMessageToDataSource:message
                        progress:nil];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
        if (!aError)
        {
            if(!isScale)
            {
                weakself.askCount = [NSString stringWithFormat:@"%li",count+1];
                if ([weakself.askCount intValue] == [weakself.totalCount intValue])
                {
                    [self showHint:@"您的追问次数已消耗完毕"];
                    [self continueAskButton];
                }
            }
            [weakself _refreshAfterSentMessage:aMessage];
//              后台执行：
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!isScale)
                {
                    [FunctionHelper uploadAskCount:[NSString stringWithFormat:@"%@/%@",weakself.askCount,weakself.totalCount] withQuestionID:weakself.questionID];
                    [FunctionHelper uploadHistoryChatMessageWithMessage:message withQuestionID:weakself.questionID];
                }
            });
        }
        else
        {
            [weakself.tableView reloadData];
        }
    }];
}

#pragma mark -- 发送消息----无扩展消息
- (void)sendTextMessage:(NSString *)text
{
    NSDictionary *ext = nil;
    [self sendTextMessage:text withExt:ext];
}

#pragma mark -- 发送消息----扩展消息
- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                     to:self.conversation.conversationId
                                            messageType:EMChatTypeChat
                                             messageExt:ext];
    [self _sendMessage:message];
}

#pragma mark -- 发送图片消息----字节流
- (void)sendImageMessageWithData:(NSData *)imageData
{
    id progress = nil;
    progress = self;
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImageData:imageData
                                                                   to:self.conversation.conversationId
                                                          messageType:EMChatTypeChat
                                                           messageExt:nil];
    [self _sendMessage:message];
}

#pragma mark -- 发送图片消息 ---- 图片
- (void)sendImageMessage:(UIImage *)image
{
    id progress = nil;
    progress = self;
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                               to:self.conversation.conversationId
                                                      messageType:EMChatTypeChat
                                                       messageExt:nil];
    [self _sendMessage:message];
}

#pragma mark - notifycation
- (void)didBecomeActive
{
    self.dataArray = [[self formatMessages:self.messsagesSource] mutableCopy];
    [self.tableView reloadData];
    if (self.isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        [_conversation markAllMessagesAsRead:nil];
    }
}

#pragma mark - 刷新tableView
- (void)_reloadTableViewDataWithMessage:(EMMessage *)message
{
    if ([self.conversation.conversationId isEqualToString:message.conversationId])
    {
        for (int i = 0; i < self.dataArray.count; i ++)
        {
            id object = [self.dataArray objectAtIndex:i];
            if ([object isKindOfClass:[MessageModel class]])
            {
                MessageModel * model = object;
                if ([message.messageId isEqualToString:model.messageId])
                {
                    MessageModel * model = nil;
                    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:_patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    model = [[MessageModel alloc] initWithMessage:message photo:[[UIImage alloc] initWithData:imageData]];
                    
                    [self.tableView beginUpdates];
                    [self.dataArray replaceObjectAtIndex:i withObject:model];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
    }
}

#pragma mark -- 更新消息状态
- (void)_updateMessageStatus:(EMMessage *)aMessage
{
    BOOL isChatting = [aMessage.conversationId isEqualToString:self.conversation.conversationId];
    if (aMessage && isChatting)
    {
        MessageModel * model = nil;
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:_patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
        model = [[MessageModel alloc] initWithMessage:aMessage photo:[[UIImage alloc] initWithData:imageData]];
        if (model)
        {
            __block NSUInteger index = NSNotFound;
            [self.dataArray enumerateObjectsUsingBlock:^(MessageModel *model, NSUInteger idx, BOOL *stop)
            {
                if ([aMessage.messageId isEqualToString:model.message.messageId])
                {
                    index = idx;
                    *stop = YES;
                }
            }];
            
            if (index != NSNotFound)
            {
                [self.dataArray replaceObjectAtIndex:index withObject:model];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }
}

#pragma mark -- 复制按钮
- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0)
    {
        MessageModel * model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

#pragma mark -- 下拉刷新
- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
    __weak CustomerChatViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload)
        {
            [weakSelf.tableView reloadData];
        }
        if (isHeader)
        {
            [weakSelf.tableView.mj_header endRefreshing];
        }
        else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
