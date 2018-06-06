//
//  DoctorHomeViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/14.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "DoctorHomeViewController.h"

#import "Define.h"
#import "FunctionHelper.h"
#import "DataHandle.h"
#import "EMClient.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "UIViewController+HUD.h"
#import <UMMobClick/MobClick.h>

#import "AppDelegate.h"
#import "LiaoLiaoHomeViewController.h"
#import "SleepCircleViewController.h"
#import "ServiceHomeViewController.h"
#import "PersonalCenterViewController.h"

#import "MyQuestionsViewController.h"
#import "DoctorTypeViewController.h"
#import "ConsultRuleViewController.h"
#import "CustomerChatViewController.h"
#import "HotQuestionViewController.h"
#import "QuestionTableViewCell.h"
#import "ConsultQuestionModel.h"

@class LiaoLiaoHomeViewController;

@interface DoctorHomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,EMChatManagerDelegate>

//视图部分
@property (strong, nonatomic)      UIView *headerView;//头部视图
@property (strong, nonatomic) UIImageView *docBgView;
@property (strong, nonatomic)      UIView *askView;//提问按钮
@property (strong, nonatomic) UITableView *tableV; //tableView
@property (strong, nonatomic)     UILabel *noticePoint; //消息提示红点
@property (strong, nonatomic)     UILabel *numberLable;//剩余问题数
@property (strong, nonatomic)     UILabel *leaveLable; //剩余可问
@property (strong, nonatomic)    UIButton *purchasebtn; //立即购买
@property (strong, nonatomic)      UIView *infoView; //信息显示框
@property (strong, nonatomic) UIImageView *imageV; //背景图
@property (strong, nonatomic)     UILabel *failureV; //失败提示图

//获取数据处理
@property (copy, nonatomic) DataHandle * handle;//数据处理对象

//数值部分
@property (strong, nonatomic) NSMutableArray *questionsArr;//热门问题
@property (strong, nonatomic)       NSString *leaveNumber;//剩余问题数
@property (strong, nonatomic)       NSString *askNumber;//正在问答问题数
@property (strong, nonatomic)       NSString *closeNumber;//已关闭问题数
@property (copy, nonatomic)         NSString *patientID;//用户ID
@property (assign, nonatomic)          BOOL  isFirst;// 是否是第一次提问
@property (copy, nonatomic)         NSString *questionID;//问题编号
@property (copy, nonatomic)         NSString *doctorID;//医生ID
@property (assign, nonatomic)           BOOL isConsult;//是否关闭
@property (assign, nonatomic)           BOOL isNew;//是否有新消息；
@property (assign, nonatomic)           BOOL isFailure;//是否获取到数据；

@end

@implementation DoctorHomeViewController
{
    NSArray *consults;   //正在问答的问题数组
}

#pragma mark -- 控制器将要出现时，隐藏tabBar、导航栏
- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    //显示导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Newnav.png"] forBarMetrics:(UIBarMetricsDefault)];
    //设置导航栏半透明效果
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"问医生"];
    //接受环信消息代理
    [[EMClient sharedClient].chatManager addDelegate:self];
    
    _doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDoctorID"];
    
    //获取与该医生的对话
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:_doctorID type:EMConversationTypeChat createIfNotExist:NO];
    //判断是否有未读消息数
    if([conversation unreadMessagesCount] > 0)
    {
        _noticePoint.hidden = NO;
        _isNew = YES;
    }
    else
    {
        _noticePoint.hidden = YES;
        _isNew = NO;
    }
    if ([FunctionHelper isExistenceNetwork])
    {
        //刷新界面
        [self refreshView];
    }
    else
    {
        [self getDataFromLocalCache];
        [self createFailureView];
    }
}

#pragma mark -- 恢复tabbar
- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"问医生"];
    //移除环信消息代理
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //视图控制器名称
    self.navigationItem.title = @"问医生";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //视图控制器背景色
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
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
    
    _isFirst = YES;
    //数据处理对象
    _handle = [[DataHandle alloc] init];
    //当前登录的用户
    _patientID = [PatientInfo shareInstance].PatientID;
    [self createTableView];
    [self createAskButton];
}

#pragma mark -- 返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[LiaoLiaoHomeViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

#pragma mark -- 判断问医生是否是第一次使用
- (BOOL)isDoctorFirstOpen
{
    //判断是否是第一次启动App
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DoctorFirstStart"])
    {
        //第一次启动App,给予使用向导
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DoctorFirstStart"];
        NSLog(@"第一次打开问医生");
        
        return YES;
    }
    else
    {
        //不是第一次启动App
        NSLog(@"不是第一次打开问医生");
        
        return NO;
    }
}

#pragma mark -- 添加免责声明
- (void)createDisclaimer
{
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    maskView.backgroundColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:0.5];
    
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
}

#pragma mark -- 本地获取数据
- (void)getDataFromLocalCache
{
    _isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"IsFirstAsk_%@",_patientID]];
    _leaveNumber = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"LeaveNumber_%@",_patientID]];
    _askNumber = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"AskNumber_%@",_patientID]];
    _closeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ClosedNumber_%@",_patientID]];
}

#pragma mark - -从网络获取数据
- (void)getDataFromNetWork
{
    [self getIsFirst];
}

#pragma mark -- 获取是否第一次进入App
- (void)getIsFirst
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"正在加载";
    [hud show:YES];
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetIsFirstAsk) andPrimaryKey:_patientID];
    req.timeoutInterval = 3.0;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data)
        {
            hud.labelText = @"加载完";
            [hud hide:YES afterDelay:0.1];
            NSLog(@"PatientID = %@",[_handle objectFromeResponseString:data andType:(DataModelBackTypeGetIsFirstAsk)]);
            [self getAskNumberFromNetWorkWithData:data];
        }
        else
        {
            hud.labelText = @"加载失败";
            [hud hide:YES afterDelay:0.5];
            [self createFailureView];
        }
    }];
}

#pragma mark -- 网络获取正在问答的问题
- (void)getAskNumberFromNetWorkWithData:(NSData *)data
{
    if ([[_handle objectFromeResponseString:data andType:(DataModelBackTypeGetIsFirstAsk)] isEqualToString:@"YES"])
    {
        _isFirst = YES;
    }
    else
    {
        _isFirst = NO;
    }
    [[NSUserDefaults standardUserDefaults] setBool:_isFirst forKey:[NSString stringWithFormat:@"IsFirstAsk_%@",_patientID]];
    if (!_isFirst)
    {
        //正在问答问题数
        NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetAnsweringQuestions) andPrimaryKey:_patientID];
        req.timeoutInterval = 3.0;
        NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
        if (data)
        {
            consults = [_handle objectFromeResponseString:data andType:(DataModelBackTypeGetAnsweringQuestions)];
            if (consults.count == 0)
            {
                _askNumber = @"0";
                _isConsult = NO;
            }
            for (NSDictionary *dic in consults)
            {
                ConsultQuestionModel *consulting = [[ConsultQuestionModel alloc] initWithDictionary:dic];
                _questionID = consulting.questionID;
                _doctorID = consulting.doctorID;
                //判断是否正在问答
                if (![FunctionHelper isBlankString:consulting.answerTime])
                {
                    if (![self checkDateWithEndTime:consulting.answerTime])
                    {
                        [self closeWhenTimeOver];
                    }
                    else
                    {
                        //如果未到截止时间
                        _askNumber = [NSString stringWithFormat:@"%lu",(unsigned long)consults.count];
                        _isConsult = YES;
                    }
                }
                else
                {
                    //未到截止时间
                    _askNumber = [NSString stringWithFormat:@"%lu",(unsigned long)consults.count];
                    _doctorID = consulting.doctorID;
                    _isConsult = YES;
                }
            }
            [self getLeaveNumberAndClosedNumber];
        }
        else
        {
            [self createFailureView];
        }
    }
    else
    {
        _leaveNumber = @"10";
        _askNumber = @"0";
        _closeNumber = @"0";
        _questionsArr  = [NSMutableArray array];
        [self evaluationForView];
    }
}

#pragma mark -- 获取剩余问题数和已关闭问题数
- (void)getLeaveNumberAndClosedNumber
{
    //1.创建队列组
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data1;
    __block NSData *data2;
    __block NSData *data3;
    dispatch_group_async(group, queue, ^{
        NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetLeaveNumber) andPrimaryKey:_patientID];
        req.timeoutInterval = 5.0;
        data1 = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    });
    dispatch_group_async(group, queue, ^{
        NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetClosedQuestions) andPrimaryKey:_patientID];
        req.timeoutInterval = 5.0;
        data2 = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    });
    dispatch_group_async(group, queue, ^{
        NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetHotQuestions) andPrimaryKey:_patientID];
        req.timeoutInterval = 5.0;
        data3 = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (data1 && data2)
        {
            _isFailure = NO;
            [self prepareDataWithData1:data1 andData2:data2 andData3:data3];
            [self evaluationForView];
        }
        else
        {
            [self createFailureView];
        }
    });
}

#pragma mark -- 问题到达截止时间
- (void)closeWhenTimeOver
{
    //如果到截止时间，则将问题关闭
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadQuestionState) andDictionary:@{@"IsClose":@"1",@"QuestionID":_questionID}];
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    if (data)
    {
        if ([[_handle objectFromeResponseString:data andType:(DataModelBackTypeUploadQuestionState)] isEqualToString:@"OK"])
        {
            [self showHint:@"您正在问答的问题时间已截止，系统已为您关闭"];
            //清空聊天记录
            [[EMClient sharedClient].chatManager deleteConversation:_doctorID isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                
            }];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentQuestionID"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentDoctorID"];
            NSMutableURLRequest *req1 = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadAnswerCountOrFullStar) andDictionary:@{@"DoctorID":_doctorID,@"AnswerCount":@"1",@"FullStarCount":@"0"}];
            NSData *data1 = [NSURLConnection sendSynchronousRequest:req1 returningResponse:nil error:nil];
            if (data1)
            {
                [_handle objectFromeResponseString:data1 andType:(DataModelBackTypeUploadAnswerCountOrFullStar)];
            }
        }
    }
    else
    {
        
    }
}

#pragma mark -- 处理网络请求的数据
- (void)prepareDataWithData1:(NSData *)data1 andData2:(NSData *)data2 andData3:(NSData *)data3
{
    #pragma mark -- 剩余问题数
    _leaveNumber = [_handle objectFromeResponseString:data1 andType:(DataModelBackTypeGetLeaveNumber)];
    
    #pragma mark -- 已关闭的问题数
    NSArray *closed = [_handle objectFromeResponseString:data2 andType:(DataModelBackTypeGetClosedQuestions)];
    _closeNumber = [NSString stringWithFormat:@"%lu",(unsigned long)closed.count];
    
    #pragma mark -- 热门问题数
    _questionsArr = [NSMutableArray array];
    NSArray *result = [_handle objectFromeResponseString:data3 andType:(DataModelBackTypeGetHotQuestions)];
    for (NSDictionary * list in result)
    {
        ConsultQuestionModel *model = [[ConsultQuestionModel alloc] init];
        model.questionID = list[@"QuestionID"];
        model.patientID = list[@"PatientID"];
        model.question = list[@"Question"];
        model.headerImage = list[@"HeaderImage"];
        model.name = list[@"Name"];
        model.sex = list[@"Sex"];
        model.birth = list[@"Birth"];
        model.startTime = list[@"StartTime"];
        [_questionsArr addObject:model];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_leaveNumber forKey:[NSString stringWithFormat:@"LeaveNumber_%@",_patientID]];
    [[NSUserDefaults standardUserDefaults] setObject:_askNumber forKey:[NSString stringWithFormat:@"AskNumber_%@",_patientID]];
    [[NSUserDefaults standardUserDefaults] setObject:_closeNumber forKey:[NSString stringWithFormat:@"ClosedNumber_%@",_patientID]];
}

#pragma mark -- 获取消息失败的提示框
- (void)createFailureView
{
    //写死几条热门问题
    NSString *sleepTipsPath = [[NSBundle mainBundle] pathForResource:@"HotQuestionList" ofType:@"plist"];
    _questionsArr = [NSMutableArray arrayWithContentsOfFile:sleepTipsPath];
    NSLog(@"%lu",(unsigned long)_questionsArr.count);
}

#pragma mark -- 获取消息失败的提示框
- (void)createViewWithoutData
{
    
}

#pragma mark -- 创建头部视图
- (void)createHeaderView
{
    //创建头部视图
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 194*Rate_NAV_H)];
    _headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"doc_main_bg.png"]];
    _headerView.userInteractionEnabled = YES;
    
    _docBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 194*Rate_NAV_H)];
    [_docBgView setImage:[UIImage imageNamed:@"doc_main_bg.png"]];
    _docBgView.userInteractionEnabled = YES;
    [_headerView addSubview:_docBgView];
    
    UIImageView *numberFrame = [[UIImageView alloc] initWithFrame:CGRectMake(30*Rate_NAV_W, 35*Rate_NAV_H, 92*Rate_NAV_W, 97*Rate_NAV_H)];
    numberFrame.image = [UIImage imageNamed:@"img_question_bg.png"];
    numberFrame.userInteractionEnabled = YES;
    [_docBgView addSubview:numberFrame];
    
    //显示剩余问题数 ，从后台获取存储于------leaveNumber
    _numberLable = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 4*Rate_NAV_H, 40*Rate_NAV_W, 50*Rate_NAV_H)];
    _numberLable.text = _leaveNumber;
    _numberLable.textAlignment = NSTextAlignmentCenter;
    _numberLable.textColor = [UIColor whiteColor];
    _numberLable.font = [UIFont fontWithName:@"DINPro-Regular" size:50*Rate_NAV_H];
    _numberLable.adjustsFontSizeToFitWidth = YES;
    [numberFrame addSubview:_numberLable];
    
    //显示“题”
    UILabel *tiLable = [[UILabel alloc] initWithFrame:CGRectMake(61*Rate_NAV_W, 36*Rate_NAV_H, 16*Rate_NAV_W, 16*Rate_NAV_H)];
    tiLable.text = @"题";
    tiLable.textColor = [UIColor whiteColor];
    tiLable.textAlignment = NSTextAlignmentLeft;
    tiLable.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    tiLable.adjustsFontSizeToFitWidth = YES;
    [numberFrame addSubview:tiLable];
    
    //显示“剩余可问字样”
    _leaveLable = [[UILabel alloc] initWithFrame:CGRectMake(16*Rate_NAV_W, 53*Rate_NAV_H, 60*Rate_NAV_W, 20*Rate_NAV_H)];
    _leaveLable.textAlignment = NSTextAlignmentCenter;
    _leaveLable.userInteractionEnabled = YES;
    _leaveLable.textColor = [UIColor whiteColor];
    _leaveLable.text = @"剩余可问";
    _leaveLable.font = [UIFont boldSystemFontOfSize:14*Rate_NAV_H];
    _leaveLable.hidden = YES;
    [numberFrame addSubview:_leaveLable];
    
    //立即购买按钮
    _purchasebtn = [[UIButton alloc] initWithFrame:CGRectMake(16*Rate_NAV_W, 53*Rate_NAV_H, 60*Rate_NAV_W, 20*Rate_NAV_H)];
    [_purchasebtn setTitle:@"立即购买" forState:(UIControlStateNormal)];
    [_purchasebtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [_purchasebtn addTarget:self action:@selector(consultRule) forControlEvents:(UIControlEventTouchUpInside)];
    _purchasebtn.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    _purchasebtn.hidden = YES;
    [numberFrame addSubview:_purchasebtn];
    
    //显示数据信息
    [self createInfoViewWithIsFirst:_isFirst];
    
    //咨询规则
    UIButton *consultBtn = [[UIButton alloc] initWithFrame:CGRectMake(278*Rate_NAV_W, 132*Rate_NAV_H, 72*Rate_NAV_H, 26*Rate_NAV_H)];
    [consultBtn setBackgroundImage:[UIImage imageNamed:@"btn_rule.png"] forState:(UIControlStateNormal)];
    [consultBtn addTarget:self action:@selector(consultRule) forControlEvents:(UIControlEventTouchUpInside)];
    [consultBtn becomeFirstResponder];
    [_docBgView addSubview:consultBtn];
}

#pragma mark -- 根据是否第一次进入
- (void)createInfoViewWithIsFirst:(BOOL)isFirst
{
    //创建之前先将该视图从界面去除
    [_infoView removeFromSuperview];
    //重新创建
    _infoView = [[UIView alloc] initWithFrame:CGRectMake(116*Rate_NAV_W, 0, 259*Rate_NAV_W, 132*Rate_NAV_H)];
    _infoView.backgroundColor = [UIColor clearColor];
    _infoView.userInteractionEnabled = YES;
    [_docBgView addSubview:_infoView];
    
    if (!isFirst)
    {
        //我的问题
        UILabel *myLable = [[UILabel alloc] initWithFrame:CGRectMake(45*Rate_NAV_W, 35*Rate_NAV_H, 170*Rate_NAV_W, 25*Rate_NAV_H)];
        myLable.text = @"我的问题";
        myLable.textColor = [UIColor whiteColor];
        myLable.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
        myLable.userInteractionEnabled = YES;
        [_infoView addSubview:myLable];
        
        CGSize size = [myLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:myLable.font,NSFontAttributeName, nil]];
        _noticePoint = [[UILabel alloc] initWithFrame:CGRectMake(myLable.frame.origin.x+size.width+5, myLable.frame.origin.y+5, 8, 8)];
        _noticePoint.layer.cornerRadius = 4;
        _noticePoint.clipsToBounds = YES;
        _noticePoint.backgroundColor = [UIColor redColor];
        _noticePoint.hidden = !_isNew;
        [_infoView addSubview:_noticePoint];
        
        //前进图标
        UIImageView *moveImageV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(myLable.frame), 43*Rate_NAV_H, 16*Rate_NAV_H, 12*Rate_NAV_H)];
        moveImageV.image = [UIImage imageNamed:@"icon_arrow_dark.png"];
        moveImageV.userInteractionEnabled = YES;
        [_infoView addSubview:moveImageV];
        
        //添加跳转button
        UIButton *myBtn = [[UIButton alloc] initWithFrame:CGRectMake(45*Rate_NAV_W, 35*Rate_NAV_H, 186*Rate_NAV_W, 25*Rate_NAV_H)];
        [myBtn addTarget:self action:@selector(myClick) forControlEvents:(UIControlEventTouchUpInside)];
        [_infoView addSubview:myBtn];
        
        //问题中
        UILabel *isAskLable = [[UILabel alloc] initWithFrame:CGRectMake(45*Rate_NAV_W, 72*Rate_NAV_H, 44*Rate_NAV_W, 20*Rate_NAV_H)];
        isAskLable.text = @"问答中";
        isAskLable.textColor = [UIColor whiteColor];
        isAskLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        [_infoView addSubview:isAskLable];
        
        //问题中的数量
        UILabel *valueAsk = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(isAskLable.frame) + 10*Rate_NAV_W, 74*Rate_NAV_H, 30*Rate_NAV_W, 20*Rate_NAV_H)];
        valueAsk.text = self.askNumber;
        valueAsk.textColor = [UIColor whiteColor];
        valueAsk.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        [_infoView addSubview:valueAsk];
        
        //已关闭
        UILabel *closeQuestion = [[UILabel alloc] initWithFrame:CGRectMake(45*Rate_NAV_W, 96*Rate_NAV_H, 44*Rate_NAV_W, 20*Rate_NAV_H)];
        closeQuestion.text = @"已关闭";
        closeQuestion.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        closeQuestion.textColor = [UIColor whiteColor];
        [_infoView addSubview:closeQuestion];
        
        //已关闭的数量
        UILabel *valueClose = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(closeQuestion.frame) + 10*Rate_NAV_W, 96*Rate_NAV_H, 30*Rate_NAV_W, 20*Rate_NAV_H)];
        valueClose.text = self.closeNumber;
        valueClose.textColor = [UIColor whiteColor];
        valueClose.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        [_infoView addSubview:valueClose];
    }
    else
    {
        //咨询提示
        UILabel *noticeLable = [[UILabel alloc] initWithFrame:CGRectMake(69*Rate_NAV_W, 34*Rate_NAV_H, 165*Rate_NAV_W, 75*Rate_NAV_H)];
        noticeLable.text = @"每个疗疗用户可以免费向心理医师线上咨询10次。";
        noticeLable.textColor = [UIColor whiteColor];
        noticeLable.numberOfLines = 0;
        noticeLable.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
        [_infoView addSubview:noticeLable];
    }
}

#pragma mark -- 创建提问按钮
- (void)createAskButton
{
    _askView = [[UIView alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, SCREENHEIGHT - 70*Rate_NAV_H - 64, SCREENWIDTH - 44*Rate_NAV_W, 50*Rate_NAV_H)];
    _askView.userInteractionEnabled = YES;
    _askView.layer.cornerRadius = 25*Rate_NAV_H;
    _askView.clipsToBounds = YES;
    _askView.backgroundColor = [UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0];

    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(96*Rate_NAV_W, 12*Rate_NAV_H, _askView.frame.size.width - 199*Rate_NAV_W, 26*Rate_NAV_H)];
    imageV.image = [UIImage imageNamed:@"btn_questionmark.png"];
    imageV.userInteractionEnabled = YES;
    [_askView addSubview:imageV];
    [self.view addSubview:_askView];
    
    UIButton *askBtn = [[UIButton alloc] initWithFrame:_askView.bounds];
    [askBtn addTarget:self action:@selector(askClick) forControlEvents:(UIControlEventTouchUpInside)];
    [_askView addSubview:askBtn];
}

#pragma mark -- 创建tableView
- (void)createTableView
{
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 50*Rate_NAV_H - 64) style:UITableViewStylePlain];
    if ([_tableV respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _tableV.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.tableV.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.estimatedRowHeight = 96*Rate_NAV_H;
    self.tableV.rowHeight = UITableViewAutomaticDimension;
    self.tableV.mj_header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshView)];
    [self createHeaderView];
    self.tableV.tableHeaderView = _headerView;
    _tableV.tableFooterView = [UIView new];
    [self.view addSubview:self.tableV];
}

#pragma mark -- 下拉刷新
- (void)refreshView
{
    if ([FunctionHelper isExistenceNetwork])
    {
        [self getIsFirst];
    }
    [_tableV.mj_header endRefreshing];
}

#pragma mark -- 界面UI赋值
- (void)evaluationForView
{
    //我的剩余问题数
    _numberLable.text = _leaveNumber;
    //剩余可问/立即购买
    if([_leaveNumber intValue] == 0)
    {
        _leaveLable.hidden = YES;
        _purchasebtn.hidden = NO;
    }
    else
    {
        _leaveLable.hidden = NO;
        _purchasebtn.hidden = YES;
    }
    //根据是否提问过创建提示信息视图或我的问题数据
    [self createInfoViewWithIsFirst:_isFirst];
    
    if (_questionsArr.count == 0)
    {
        //写死几条热门问题
        NSString *sleepTipsPath = [[NSBundle mainBundle] pathForResource:@"HotQuestionList" ofType:@"plist"];
        _questionsArr = [NSMutableArray arrayWithContentsOfFile:sleepTipsPath];
        NSLog(@"%lu",(unsigned long)_questionsArr.count);
        [_tableV reloadData];
    }
    else
    {
        //刷新tableView
        [_tableV reloadData];
    }
}

#pragma mark--- tableDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.questionsArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50*Rate_NAV_H;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton * btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50*Rate_NAV_H)];
    [btn1 setTitle:@"热门问题精选" forState:(UIControlStateNormal)];
    [btn1 setBackgroundColor:[UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1]];
    btn1.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [btn1 setTitleColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0] forState:(UIControlStateNormal)];
    return btn1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Rate_NAV_H;
}

#pragma mark -- tableview datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //写死帖子的现实
    static NSString *CellIdentifier = @"DoctorHomeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dic = _questionsArr[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    cell.textLabel.text = [dic objectForKey:@"title"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark -- tableView点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HotQuestionViewController *consult = [[HotQuestionViewController alloc] init];
    consult.hotQuestionDic = _questionsArr[indexPath.row];
    [self.navigationController pushViewController:consult animated:YES];
}

#pragma mark -- 我的问题
- (void)myClick
{
    //跳转至我的界面
    MyQuestionsViewController *myVC = [[MyQuestionsViewController alloc] init];
    myVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myVC animated:YES];
}

#pragma mark -- 咨询规则
- (void)consultRule
{
    if ([FunctionHelper isExistenceNetwork])
    {
        ConsultRuleViewController *consult = [[ConsultRuleViewController alloc] init];
        consult.patientID = _patientID;
        [self.navigationController pushViewController:consult animated:YES];
    }
    else
    {
        UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"网络连接失败" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alterV show];
    }
}

#pragma mark --- 向医生提问
- (void)askClick
{
    if([FunctionHelper isExistenceNetwork])
    {
        if(_isFailure)
        {
            UIAlertView *alerV = [[UIAlertView alloc] initWithTitle:@"出错" message:@"获取数据出错？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alerV show];
        }
        else
        {
            if ([_leaveNumber intValue] == 0)
            {
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"向医生提问" message:@"您的剩余问题不足" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即购买", nil];
                alertV.tag = 13;
                [alertV show];
            }
            else
            {
                DoctorTypeViewController *dtVC = [[DoctorTypeViewController alloc] init];
                dtVC.questionArray = consults;
                [self.navigationController pushViewController:dtVC animated:YES];
            }
        }
    }
    else
    {
        UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"网络连接失败" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alterV show];
    }
}

#pragma mark -- delegateForAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        
    }
    else
    {
        if (alertView.tag == 13)
        {
            //需要支付
            ConsultRuleViewController *consult = [[ConsultRuleViewController alloc] init];
            consult.patientID = _patientID;
            [self.navigationController pushViewController:consult animated:YES];
        }
        else
        {
            //前往正在问答的界面
            CustomerChatViewController *consultView = [[CustomerChatViewController alloc] initWithConversationChatter:_doctorID];
            consultView.questionID = _questionID;
            NSLog(@"%@",_questionID);
            consultView.isAsking = YES;
            [self.navigationController pushViewController:consultView animated:YES];
        }
    }
}

#pragma mark --- 接收到消息的回调
- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages)
    {
        if ([message.conversationId isEqualToString:_doctorID])
        {
            _noticePoint.hidden = NO;
        }
    }
}

#pragma mark -- 判断时间是否过期
- (BOOL)checkDateWithEndTime:(NSString *)endTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [NSDate date];
    NSDate *date2 = [formatter dateFromString:endTime];
    //    先定义一个遵循某个历法的日历对象
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    根据两个时间点，定义NSDateComponents对象，从而获取这两个时间点的时差
    NSDateComponents *dateComponents = [greCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date1 toDate:date2 options:0];
    if ((int)dateComponents.hour >0 || (int)dateComponents.minute > 0 || (int)dateComponents.second > 0)
    {
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
