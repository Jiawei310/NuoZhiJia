//
//  MyQuestionsViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/1.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "MyQuestionsViewController.h"

#import "Define.h"
#import "FunctionHelper.h"
#import "DataHandle.h"
#import "EMClient.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import <UMMobClick/MobClick.h>

#import "QuestionTableViewCell.h"

#import "ConsultQuestionModel.h"

#import "ReportShowViewController.h"
#import "CustomerChatViewController.h"
#import "DoctorTypeViewController.h"
#import "HistoryQuestionViewController.h"
#import "ConsultRuleViewController.h"
#import "SymptomDescViewController.h"

@interface MyQuestionsViewController ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

//视图部分
@property (strong, nonatomic)      UIView *headerView;//头部视图
@property (strong, nonatomic) UIImageView *queBgView;
@property (strong, nonatomic)      UIView *sectionHeaderView;//section头部视图
@property (strong, nonatomic) UITableView *tableV; //tableView
@property (strong, nonatomic)     UILabel *failureV;//失败提示图
@property (strong, nonatomic)     UILabel *numberLable;//剩余问题数
@property (strong, nonatomic)     UILabel *leaveLable; //剩余可问
@property (strong, nonatomic)    UIButton *purchasebtn; //立即购买
@property (strong, nonatomic)     UILabel *valuePizz;//匹兹堡数值
@property (strong, nonatomic)     UILabel *resultPizz;//匹兹堡结果
@property (strong, nonatomic)     UILabel *valueSelf;//交流自测数值
@property (strong, nonatomic)     UILabel *resultSelf;//交流自测结果

@property (copy, nonatomic)    DataHandle *handle;//数据处理对象
@property (copy, nonatomic)FunctionHelper *function;//方法处理对象

//数值部分
@property (strong, nonatomic) NSMutableArray *questionsArr;//问题数
@property (strong, nonatomic) NSString *leaveNumber;//剩余问题数
@property (copy, nonatomic)   NSString *questionID;//问题编号
@property (copy, nonatomic)   NSString *patientID;//用户编号
@property (copy, nonatomic)   NSString *doctorID;//医生编号
@property (assign, nonatomic) BOOL isClose;//是否关闭
@property (assign, nonatomic) BOOL isConsult;//是否在问
@property (assign, nonatomic) BOOL isFailure;//是否获取到数据；

@end

@implementation MyQuestionsViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    //导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Newnav.png"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"我的问题"];
    
    [[EMClient sharedClient].chatManager addDelegate:self];
    
    if([FunctionHelper isExistenceNetwork])
    {
        [self refreshingView];
    }
    else
    {
        [self getDataFromeLocalCache];
        [self evalutionForView];
        [self createFailureView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"我的问题"];
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //标题名
    self.navigationItem.title = @"我的问题";
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
    
    _patientInfo = [PatientInfo shareInstance];
    //数据处理对象
    _handle = [[DataHandle alloc] init];
    _patientID = _patientInfo.PatientID;
    NSLog(@"my == %@",_patientInfo.PatientID);
    [self createTableView];
    [self createAskButton];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 获取本地存储数据
- (void)getDataFromeLocalCache
{
    _leaveNumber = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"LeaveNumber_%@",_patientID]];
}

#pragma mark -- 执行网络请求
- (void)getDataFromNetWork
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"加载中";
    hud.mode = MBProgressHUDAnimationFade;
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetLeaveNumber) andPrimaryKey:_patientID];
    req.timeoutInterval = 5.0;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data)
        {
            NSData *data2;
            if (_isClose)
            {
                data2 = [_handle getDataFromNetWorkWithStringType:DataModelBackTypeGetClosedQuestions andPrimaryKey:_patientID];
            }
            else
            {
                data2 = [_handle getDataFromNetWorkWithStringType:DataModelBackTypeGetAnsweringQuestions andPrimaryKey:_patientID];
            }
            
            if (data2 && [self getScaleResult])
            {
                _isFailure = NO;
                hud.labelText = @"加载完成";
                [hud hide:YES afterDelay:0.1];
                [self prepareDataWithData1:data andData2:data2];
                [self evalutionForView];
            }
            else
            {
                hud.labelText = @"加载失败";
                [hud hide:YES afterDelay:0.5];
                [self createFailureView];
            }
        }
        else
        {
            hud.labelText = @"加载失败";
            [hud hide:YES afterDelay:0.5];
            [self createFailureView];
        }
    }];
}

#pragma mark-- 获取匹兹堡数据
- (BOOL)getScaleResult
{
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetPizzAndSelfTestValue) andPrimaryKey:_patientInfo.PatientID];
    req.timeoutInterval = 10.0;
    NSData * data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    if (data)
    {
        NSDictionary *dic = [_handle objectFromeResponseString:data andType:(DataModelBackTypeGetPizzAndSelfTestValue)];
        NSInteger value1 = [dic[@"Type1"] integerValue];
        _valuePizz.text =  [NSString stringWithFormat:@"%li",value1];
        _resultPizz.text = [self getResultForTheNumber:value1 andType:1];
        if ([_resultPizz.text isEqual:@"很差"])
        {
            _resultPizz.textColor = [UIColor redColor];
        }
        NSInteger value2 = [dic[@"Type3"] integerValue];
        _valueSelf.text =  [NSString stringWithFormat:@"%li",value2];
        _resultSelf.text = [self getResultForTheNumber:value2 andType:3];
        if ([_resultSelf.text isEqual:@"重度"])
        {
            _resultSelf.textColor = [UIColor redColor];
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -- 分数评断
- (NSString *)getResultForTheNumber:(NSInteger)Mark andType:(NSInteger)type
{
    if (type == 1)
    {
        if (Mark >= 0 && Mark <= 5)
        {
           return  @"很好";
        }
        else if (Mark >= 6 && Mark <= 10)
        {
            return @"一般";
        }
        else if (Mark >= 11 && Mark <= 15)
        {
            return @"较差";
        }
        else if (Mark >= 16 && Mark <= 21)
        {
            return @"很差";
        }
        else
        {
            return @"未知";
        }
    }
    else
    {
        if (Mark == 0)
        {
            return  @"无";
        }
        else if (Mark > 0 && Mark < 7)
        {
            return @"轻度";
        }
        else if (Mark >= 7 && Mark < 14)
        {
            return @"中度";
        }
        else if (Mark >= 14 && Mark <= 21)
        {
            return @"重度";
        }
        else
        {
            return @"未知";
        }
    }
}

#pragma mark -- 获取消息失败的提示框
- (void)createFailureView
{
    _isFailure = YES;
    [_failureV removeFromSuperview];
    _failureV = [[UILabel alloc] initWithFrame:CGRectMake(0, 244*Rate_NAV_H, SCREENWIDTH, 289*Rate_NAV_H)];
    _failureV.textColor = [UIColor lightGrayColor];
    _failureV.font = [UIFont systemFontOfSize:25*Rate_NAV_H];
    _failureV.numberOfLines = 0;
    _failureV.textAlignment = NSTextAlignmentCenter;
    if(![FunctionHelper isExistenceNetwork])
    {
        _failureV.text = @"获取数据失败\n请检查网络";
    }
    else
    {
        _failureV.text = @"服务器获取数据失败";
    }
    [_tableV addSubview:_failureV];
}

#pragma mark -- 仅刷新tableView
- (void)refreshTableView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"加载中";
    hud.mode = MBProgressHUDAnimationFade;
    DataModelBackType type;
    if (_isClose)
    {
        type = DataModelBackTypeGetClosedQuestions;
    }
    else
    {
        type = DataModelBackTypeGetAnsweringQuestions;
    }
    _questionsArr = [NSMutableArray array];
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:type andPrimaryKey:_patientID];
    req.timeoutInterval = 5.0;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data)
        {
            _isFailure = NO;
            hud.labelText = @"加载完成";
            [hud hide:YES afterDelay:0.1];
            NSArray *questions = [_handle objectFromeResponseString:data andType:type];
            if (questions.count > 0  && !_isClose)
            {
                _isConsult = YES;
                [_failureV removeFromSuperview];
            }
            else if (questions.count > 0  && _isClose)
            {
                [_failureV removeFromSuperview];
            }
            else if (questions.count == 0  && !_isClose)
            {
                _isConsult = NO;
            }
            else
            {
                [self createViewWithoutData];
            }
            
            for (NSDictionary *dic in questions)
            {
                ConsultQuestionModel *model = [[ConsultQuestionModel alloc] initWithDictionary:dic];
                model.questionID = dic[@"QuestionID"];
                model.patientID = dic[@"PatientID"];
                model.question = dic[@"Question"];
                _questionID = dic[@"QuestionID"];
                model.headerImage = _patientInfo.PhotoUrl;
                model.name = _patientInfo.PatientName;
                model.sex = _patientInfo.PatientSex;
                model.birth = _patientInfo.Birthday;
                model.startTime = dic[@"StartTime"];
                model.doctorID = dic[@"DoctorID"];
                _doctorID = dic[@"DoctorID"];
                model.answerTime = dic[@"AnswerTime"];
                [_questionsArr addObject:model];
            }
            [_tableV reloadData];
        }else
        {
            hud.labelText = @"加载失败";
            [hud hide:YES afterDelay:0.5];
            [self createFailureView];
            [_tableV reloadData];
        }
     }];
}

#pragma mark -- 处理从服务器获取的数据
- (void)prepareDataWithData1:(NSData *)data1 andData2:(NSData *)data2
{
    _leaveNumber = [_handle objectFromeResponseString:data1 andType:(DataModelBackTypeGetLeaveNumber)];
    _questionsArr = [NSMutableArray array];
    DataModelBackType type;
    
    if (_isClose)
    {
        type = DataModelBackTypeGetClosedQuestions;
    }
    else
    {
        type = DataModelBackTypeGetAnsweringQuestions;
    }
    
    NSArray *questions = [_handle objectFromeResponseString:data2 andType:type];
    if (questions.count > 0  && !_isClose)
    {
        _isConsult = YES;
        [_failureV removeFromSuperview];
    }
    else if (questions.count > 0  && _isClose)
    {
        [_failureV removeFromSuperview];
    }
    else
    {
        _isConsult = NO;
        [self createViewWithoutData];
    }
    
    for (NSDictionary *dic in questions)
    {
        ConsultQuestionModel *model = [[ConsultQuestionModel alloc] initWithDictionary:dic];
        model.questionID = dic[@"QuestionID"];
        model.patientID = dic[@"PatientID"];
        model.question = dic[@"Question"];
        _questionID = dic[@"QuestionID"];
        model.headerImage = _patientInfo.PhotoUrl;
        model.name = _patientInfo.PatientName;
        model.sex = _patientInfo.PatientSex;
        model.birth = _patientInfo.Birthday;
        model.startTime = dic[@"StartTime"];
        model.doctorID = dic[@"DoctorID"];
        _doctorID = dic[@"DoctorID"];
        model.answerTime = dic[@"AnswerTime"];
        [_questionsArr addObject:model];
    }
}

#pragma mark -- 暂时无数据时的提示
- (void)createViewWithoutData
{
    [_failureV removeFromSuperview];
    _failureV = [[UILabel alloc] initWithFrame:CGRectMake(0, 244*Rate_NAV_H, SCREENWIDTH, 289*Rate_NAV_H)];
    _failureV.textColor = [UIColor lightGrayColor];
    _failureV.font = [UIFont systemFontOfSize:25*Rate_NAV_H];
    _failureV.numberOfLines = 0;
    _failureV.textAlignment = NSTextAlignmentCenter;
    if(_isClose)
    {
        _failureV.text = @"暂时无已关闭的问题";
    }
    else
    {
        _failureV.text = @"暂时无正在问答的问题";
    }
    [_tableV addSubview:_failureV];
}

#pragma mark -- 头部视图
- (void)createHeaderView
{
    //创建头部视图
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 194*Rate_NAV_H)];
    _headerView.userInteractionEnabled = YES;
    _headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"doc_main_bg.png"]];
    
    _queBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 194*Rate_NAV_H)];
    [_queBgView setImage:[UIImage imageNamed:@"doc_main_bg.png"]];
    _queBgView.userInteractionEnabled = YES;
    [_headerView addSubview:_queBgView];
    
    UIImageView *numberFrame = [[UIImageView alloc] initWithFrame:CGRectMake(30*Rate_NAV_W, 35*Rate_NAV_H, 92*Rate_NAV_W, 97*Rate_NAV_H)];
    numberFrame.image = [UIImage imageNamed:@"img_question_bg.png"];
    numberFrame.userInteractionEnabled = YES;
    [_queBgView addSubview:numberFrame];
    
    //显示剩余问题数 ，从后台获取存储于------leaveNumber
    _numberLable = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 4*Rate_NAV_H, 40*Rate_NAV_W, 50*Rate_NAV_H)];
    _numberLable.text = @"";
    _numberLable.textAlignment = NSTextAlignmentCenter;
    _numberLable.textColor = [UIColor whiteColor];
    _numberLable.font = [UIFont fontWithName:@"DINPro-Regular" size:50*Rate_NAV_H];
    _numberLable.adjustsFontSizeToFitWidth = YES;
    [numberFrame addSubview:_numberLable];
    
    //显示“题”
    UILabel *tiLable = [[UILabel alloc] initWithFrame:CGRectMake(61*Rate_NAV_W, 36*Rate_NAV_H, 16*Rate_NAV_W, 16*Rate_NAV_H)];
    tiLable.text = @"题";
    tiLable.textColor = [UIColor whiteColor];
    tiLable.textAlignment = NSTextAlignmentCenter;
    tiLable.font = [UIFont boldSystemFontOfSize:11*Rate_NAV_H];
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
    _purchasebtn.titleLabel.font = [UIFont boldSystemFontOfSize:14*Rate_NAV_H];
    _purchasebtn.hidden = YES;
    [numberFrame addSubview:_purchasebtn];
    
    //最近健康状况
    UILabel *recentlyLable = [[UILabel alloc] initWithFrame:CGRectMake(161*Rate_NAV_W, 35*Rate_NAV_H, 170*Rate_NAV_W, 25*Rate_NAV_H)];
    recentlyLable.text = @"最近健康状况";
    recentlyLable.textColor = [UIColor whiteColor];
    recentlyLable.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_queBgView addSubview:recentlyLable];
    
    //前进图标
    UIImageView *moveImageV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(recentlyLable.frame), 43*Rate_NAV_H, 16*Rate_NAV_H, 12*Rate_NAV_H)];
    moveImageV.image = [UIImage imageNamed:@"icon_arrow_dark.png"];
    [_queBgView addSubview:moveImageV];
    
    //添加跳转button
    UIButton *myBtn = [[UIButton alloc] initWithFrame:CGRectMake(161*Rate_NAV_W, 35*Rate_NAV_H, 186*Rate_NAV_W, 25*Rate_NAV_H)];
    [myBtn addTarget:self action:@selector(healthClick) forControlEvents:(UIControlEventTouchUpInside)];
    [_queBgView addSubview:myBtn];
    
    //匹兹堡睡眠障碍
    UILabel *pizzLable = [[UILabel alloc] initWithFrame:CGRectMake(161*Rate_NAV_W, 72*Rate_NAV_H, 101*Rate_NAV_W, 20*Rate_NAV_H)];
    pizzLable.text = @"匹兹堡睡眠障碍";
    pizzLable.textColor = [UIColor whiteColor];
    pizzLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_queBgView addSubview:pizzLable];
    
    //匹兹堡障碍数值
    _valuePizz = [[UILabel alloc] initWithFrame:CGRectMake(285*Rate_NAV_W, 72*Rate_NAV_H, 20*Rate_NAV_W, 20*Rate_NAV_H)];
    _valuePizz.textColor = [UIColor whiteColor];
    _valuePizz.text = @"";
    _valuePizz.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    _valuePizz.textAlignment = NSTextAlignmentRight;
    [_queBgView addSubview:_valuePizz];
    
    //匹兹堡障碍标准
    _resultPizz = [[UILabel alloc] initWithFrame:CGRectMake(319*Rate_NAV_W, 72*Rate_NAV_H, 30*Rate_NAV_W, 20*Rate_NAV_H)];
    _resultPizz.text = @"";
    _resultPizz.textColor = [UIColor whiteColor];
    _resultPizz.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_queBgView addSubview:_resultPizz];
    
    //交流自评
    UILabel *selfLable = [[UILabel alloc] initWithFrame:CGRectMake(161*Rate_NAV_W, 96*Rate_NAV_H, 101*Rate_NAV_W, 20*Rate_NAV_H)];
    selfLable.text = @"焦虑自评";
    selfLable.textColor = [UIColor whiteColor];
    selfLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_queBgView addSubview:selfLable];
    
    //匹兹堡障碍数值
    _valueSelf = [[UILabel alloc] initWithFrame:CGRectMake(285*Rate_NAV_W, 96*Rate_NAV_H, 20*Rate_NAV_W, 20*Rate_NAV_H)];
    _valueSelf.textColor = [UIColor whiteColor];
    _valueSelf.text = @"";
    _valueSelf.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    _valueSelf.textAlignment = NSTextAlignmentRight;
    [_queBgView addSubview:_valueSelf];
    
    //交流标准
    _resultSelf = [[UILabel alloc] initWithFrame:CGRectMake(319*Rate_NAV_W, 96*Rate_NAV_H, 30*Rate_NAV_W, 20*Rate_NAV_H)];
    _resultSelf.text = @"";
    _resultSelf.textColor = [UIColor whiteColor];
    _resultSelf.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_queBgView addSubview:_resultSelf];
}

#pragma mark -- 创建提问按钮
- (void)createAskButton
{
    UIView *askView = [[UIView alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 533*Rate_NAV_H, SCREENWIDTH - 44*Rate_NAV_W, 50*Rate_NAV_H)];
    askView.userInteractionEnabled = YES;
    askView.layer.cornerRadius = 25*Rate_NAV_H;
    askView.clipsToBounds = YES;
    askView.backgroundColor = [UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(96*Rate_NAV_W, 12*Rate_NAV_H, askView.frame.size.width - 199*Rate_NAV_W, 26*Rate_NAV_H)];
    imageV.image = [UIImage imageNamed:@"btn_questionmark.png"];
    imageV.userInteractionEnabled = YES;
    [askView addSubview:imageV];
    [self.view addSubview:askView];
    
    UIButton *askBtn = [[UIButton alloc] initWithFrame:askView.bounds];
    [askBtn addTarget:self action:@selector(askClick) forControlEvents:(UIControlEventTouchUpInside)];
    [askView addSubview:askBtn];
}

#pragma mark -- 给界面赋值
- (void)evalutionForView
{
    //刷新tableView
    [_tableV reloadData];
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
}

#pragma mark -- 创建问题显示tableview
- (void)createTableView
{
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64 - 70*Rate_NAV_H) style:UITableViewStylePlain];
    _tableV.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableV.mj_header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshingView)];
    [self createHeaderView];
    _tableV.tableHeaderView = _headerView;
    [self.view addSubview:_tableV];
}

#pragma mark -- 下拉刷新界面
- (void)refreshingView
{
    [self getDataFromNetWork];
    [_tableV.mj_header endRefreshing];
}

#pragma mark -- tableview delegate
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
    return 44*Rate_NAV_H;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44*Rate_NAV_H)];
    //正在问答
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 187*Rate_NAV_W, 44*Rate_NAV_H)];
    [btn1 setBackgroundColor:[UIColor whiteColor]];
    [btn1 setTitle:@"问答中" forState:(UIControlStateNormal)];
    btn1.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [btn1 addTarget:self action:@selector(Jump:) forControlEvents:(UIControlEventTouchUpInside)];
    btn1.tag = 111;
    [_sectionHeaderView addSubview:btn1];
    
    //分割线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(187*Rate_NAV_W, 10*Rate_NAV_H, Rate_NAV_W, 25*Rate_NAV_H)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_sectionHeaderView addSubview:line];
    
    //已关闭
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(188*Rate_NAV_W, 0, 187*Rate_NAV_W, 44*Rate_NAV_H)];
    [btn2 setBackgroundColor:[UIColor whiteColor]];
    [btn2 setTitle:@"已关闭" forState:(UIControlStateNormal)];
    btn2.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    
    [btn2 addTarget:self action:@selector(Jump:) forControlEvents:(UIControlEventTouchUpInside)];
    btn2.tag = 112;
    [_sectionHeaderView addSubview:btn2];
    
    if (_isClose)
    {
        [btn1 setTitleColor:[UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0] forState:(UIControlStateNormal)];
        [btn2 setTitleColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0] forState:(UIControlStateNormal)];
    }
    else
    {
        [btn1 setTitleColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0] forState:(UIControlStateNormal)];
        [btn2 setTitleColor:[UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0] forState:(UIControlStateNormal)];
    }
    
    return _sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

#pragma mark -- tableview dataSoure
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"MyQuestionCellID%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    
    QuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[QuestionTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.model = self.questionsArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isClose)
    {
        ConsultQuestionModel *model = self.questionsArr[indexPath.row];
        if ([FunctionHelper isBlankString:model.answerTime])
        {
            UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"未接诊" message:@"抱歉，该问题无医生接诊信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alterV show];
        }
        else
        {
            HistoryQuestionViewController *consult = [[HistoryQuestionViewController alloc] init];
            consult.questionID = model.questionID;
            consult.isCommend = YES;
            [self.navigationController pushViewController:consult animated:YES];
        }
    }
    else
    {
        ConsultQuestionModel *model = self.questionsArr[indexPath.row];
        if ([model.answerTime isEqual:@""] || [FunctionHelper checkDateWithEndTime:model.answerTime])
        {
            CustomerChatViewController *consult = [[CustomerChatViewController alloc] initWithConversationChatter:model.doctorID];
            //正在问答
            consult.isAsking = YES;
            consult.questionID = model.questionID;
            consult.doctorID = model.doctorID;
            consult.endTime = model.answerTime;
            consult.patientInfo = _patientInfo;
            [self.navigationController pushViewController:consult animated:YES];
        }
        else
        {
            ConsultQuestionModel *model = self.questionsArr[indexPath.row];
            if ([FunctionHelper isBlankString:model.answerTime])
            {
                UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"未接诊" message:@"抱歉，该问题无医生接诊信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alterV show];
            }
            else
            {
                HistoryQuestionViewController *consult = [[HistoryQuestionViewController alloc] init];
                consult.questionID = model.questionID;
                consult.isCommend = YES;
                consult.isNotice = YES;
                [self.navigationController pushViewController:consult animated:YES];
            }
        }
    }
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

#pragma mark -- 切换视图
- (void)Jump:(UIButton *)sender
{
    if (sender.tag == 111)
    {
        [sender setTitleColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0] forState:(UIControlStateNormal)];
        UIButton *btn = (UIButton *)[_sectionHeaderView viewWithTag:112];
        [btn setTitleColor:[UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0] forState:(UIControlStateNormal)];
        _isClose = NO;
    }
    else
    {
        [sender setTitleColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0] forState:(UIControlStateNormal)];
        UIButton *btn = (UIButton *)[_sectionHeaderView viewWithTag:111];
        [btn setTitleColor:[UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0] forState:(UIControlStateNormal)];
        _isClose = YES;
    }
    
    [self refreshTableView];
}

#pragma mark --- 向医生提问
- (void)askClick
{
    //是否有网
    if(![FunctionHelper isExistenceNetwork])
    {
        UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"网络连接失败" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alterV show];
    }
    else
    {
        //是否有问题
        if (_isConsult)
        {
            UIAlertView *alerV = [[UIAlertView alloc] initWithTitle:@"向医生提问" message:@"您当前正在问答的会话未结束，是否前往当前会话？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往", nil];
            [alerV show];
        }
        else
        {
            if (_isFailure)
            {
                UIAlertView *alerV = [[UIAlertView alloc] initWithTitle:@"出错" message:@"获取数据出错" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
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
//                    SymptomDescViewController *writeVC = [[SymptomDescViewController alloc] init];
//                    [self.navigationController pushViewController:writeVC animated:YES];
                    DoctorTypeViewController *dtVC = [[DoctorTypeViewController alloc] init];
//                    dtVC.questionArray = consults;
                    [self.navigationController pushViewController:dtVC animated:YES];
                }
            }
        }
    }
}

#pragma mark -- 购买
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

#pragma mark -- delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
    {
        
    }
    else
    {
        //跳转至咨询规则
        if (alertView.tag == 13)
        {
            ConsultRuleViewController *consult = [[ConsultRuleViewController alloc] init];
            consult.patientID = _patientID;
            [self.navigationController pushViewController:consult animated:YES];
        }
        else
        {
            //跳转至正在问答界面
            CustomerChatViewController *consultView = [[CustomerChatViewController alloc] initWithConversationChatter:_doctorID];
            consultView.questionID = _questionID;
            consultView.patientInfo = _patientInfo;
            consultView.isAsking = YES;
            [self.navigationController pushViewController:consultView animated:YES];
        }
    }
}

#pragma mark -- 最近健康状况
- (void)healthClick
{
    ReportShowViewController *reportShowVC = [[ReportShowViewController alloc] init];
    [self.navigationController pushViewController:reportShowVC animated:YES];
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
