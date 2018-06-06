//
//  HistoryQuestionViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/23.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "HistoryQuestionViewController.h"

#import "Define.h"
#import "DataHandle.h"
#import "MJRefresh.h"
#import "UIImageView+EMWebCache.h"
#import <UMMobClick/MobClick.h>

#import "ConsultQuestionModel.h"
#import "DoctorInfoModel.h"

#import "ChatTextTableViewCell.h"
#import "ChatImageTableViewCell.h"
#import "ScaleTableViewCell.h"
#import "ChatTimeTableViewCell.h"

#import "DoctorDetailsViewController.h"
#import "CommendViewController.h"

@interface HistoryQuestionViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (strong, nonatomic)    UITableView *tableV;
@property (strong, nonatomic)         UIView *headerView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (copy, nonatomic)       DataHandle *handle;
@property (copy, nonatomic) ConsultQuestionModel *question;
@property (copy, nonatomic)      DoctorInfoModel *doctor;
@property (copy, nonatomic)   RecordMessageModel *message;
@property (copy, nonatomic)             NSString *page;

@end

@implementation HistoryQuestionViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"历史问题"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"历史问题"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"历史问题";
    
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
    
    _handle = [[DataHandle alloc] init];
    _patientID = [PatientInfo shareInstance].PatientID;
    _page = @"1";
    
    if(_isNotice)
    {
        UIAlertView * alterV = [[UIAlertView alloc] initWithTitle:@"问题已关闭" message:@"该问题已到截止时间" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alterV show];
        [self closeWhenTimeOver];
    }
    
    [self prepareData];
    [self createChatView];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 问题到达截止时间
- (void)closeWhenTimeOver
{
    NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDoctorID"];
    //如果到截止时间，则将问题关闭
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadQuestionState) andDictionary:@{@"IsClose":@"1",@"QuestionID":_questionID}];
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    if (data)
    {
        if ([[_handle objectFromeResponseString:data andType:(DataModelBackTypeUploadQuestionState)] isEqualToString:@"OK"])
        {
            //清空聊天记录
            [[EMClient sharedClient].chatManager deleteConversation:doctorID isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
            }];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentQuestionID"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentDoctorID"];
            NSMutableURLRequest *req1 = [_handle RequestForGetDataFromNetWorkWithJsonType:DataModelBackTypeUploadAnswerCountOrFullStar
                                                                            andDictionary:@{@"DoctorID":doctorID,@"AnswerCount":@"1",@"FullStarCount":@"0"}];
            NSData *data1 = [NSURLConnection sendSynchronousRequest:req1 returningResponse:nil error:nil];
            if (data1)
            {
                [_handle objectFromeResponseString:data1 andType:(DataModelBackTypeUploadAnswerCountOrFullStar)];
            }
        }
    }
}

#pragma mark -- 评价医生按钮
- (void)commentClick
{
    CommendViewController *comment = [[CommendViewController alloc] init];
    comment.doctorID = _question.doctorID;
    comment.patientID = _patientID;
    [self.navigationController pushViewController:comment animated:YES];
}

#pragma mark -- 准备数据
- (void)prepareData
{
    NSData *questionData = [_handle getDataFromNetWorkWithStringType:DataModelBackTypeGetQuestionDetail
                                                       andPrimaryKey:_questionID];
    NSArray *temp1 = [_handle objectFromeResponseString:questionData
                                                andType:DataModelBackTypeGetQuestionDetail];
    _question = [[ConsultQuestionModel alloc] initWithDictionary:temp1[0]];
    NSData *chatData = [_handle getDataFromNetWorkWithJsonType:DataModelBackTypeGetChatMessage
                                                 andDictionary:@{@"questionID":_questionID,@"page":_page}];
    _dataSource = [NSMutableArray arrayWithArray:[_handle objectFromeResponseString:chatData andType:DataModelBackTypeGetChatMessage]];
    NSData *doctorData  = [_handle getDataFromNetWorkWithStringType:DataModelBackTypeGetDoctorInfo
                                                      andPrimaryKey:_question.doctorID];
    NSArray *temp2 = [_handle objectFromeResponseString:doctorData
                                                andType:DataModelBackTypeGetDoctorInfo];
    if(temp2.count == 0)
    {
        _doctor = [[DoctorInfoModel alloc] init];
        UIAlertView *alterV = [[UIAlertView alloc] initWithTitle:@"出错" message:@"医生信息获取失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alterV show];
    }
    else
    {
        _doctor = [[DoctorInfoModel alloc] initWithDictionary:temp2[0]];
    }
    
}

#pragma mark -- 创建问题标签
- (void)creatQuestionInfo
{
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 178*Rate_NAV_H)];
    _headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 17*Rate_NAV_H, 46*Rate_NAV_W, 24*Rate_NAV_H)];
    imageV.image = [UIImage imageNamed:@"tab_ask.png"];
    [_headerView addSubview:imageV];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(258*Rate_NAV_W, 17*Rate_NAV_H, 101*Rate_NAV_W, 14*Rate_NAV_H)];
    time.text = _question.startTime;
    time.textColor = [UIColor colorWithRed:0.62 green:0.64 blue:0.64 alpha:1.0];
    time.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    time.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:time];
    
    UILabel *question = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 35*Rate_NAV_H, 290*Rate_NAV_W, 52*Rate_NAV_H)];
    question.text = _question.question;
    question.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    question.numberOfLines = 2;
    [_headerView addSubview:question];
    
}

#pragma mark -- 创建医生信息
- (void)createDoctorInfo
{
    _headerView.frame = CGRectMake(0, 0, SCREENWIDTH, 277*Rate_NAV_H);
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 76*Rate_NAV_H, SCREENWIDTH, 10*Rate_NAV_H)];
    line1.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line1];
    
    UIImageView *doctorIcon = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 70*Rate_NAV_H)/2, 108*Rate_NAV_H, 70*Rate_NAV_H, 70*Rate_NAV_H)];
//    [doctorIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.0.107:8085/%@",_doctor.doctorIcon]] placeholderImage:[UIImage imageNamed:@"headerImage_doctor"]];
    [doctorIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://211.161.200.73:8098/DoctorTempHeadImg/%@",_doctor.doctorIcon]] placeholderImage:[UIImage imageNamed:@"headerImage_doctor"]];
    doctorIcon.layer.cornerRadius = 35*Rate_NAV_H;
    doctorIcon.clipsToBounds = YES;
    doctorIcon.userInteractionEnabled = YES;
    [_headerView addSubview:doctorIcon];
    
    UIButton *doctionDetail = [[UIButton alloc] initWithFrame:doctorIcon.bounds];
    [doctionDetail addTarget:self action:@selector(doctorDetail) forControlEvents:(UIControlEventTouchUpInside)];
    [doctorIcon addSubview:doctionDetail];
    
    UILabel *doctorName = [[UILabel alloc] initWithFrame:CGRectMake(0, 183*Rate_NAV_H, SCREENWIDTH, 28*Rate_NAV_H)];
    doctorName.text = _doctor.doctorName;
    doctorName.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    doctorName.textAlignment = NSTextAlignmentCenter;
    doctorName.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_headerView addSubview:doctorName];
    
    UILabel *doctorInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 216*Rate_NAV_H, SCREENWIDTH, 20*Rate_NAV_H)];
    doctorInfo.text = [NSString stringWithFormat:@"%@ %@",_doctor.doctorHospital,_doctor.doctorDepartment];
    doctorInfo.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    doctorInfo.textAlignment = NSTextAlignmentCenter;
    doctorInfo.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_headerView addSubview:doctorInfo];
    
    for(int i = 0; i < 5; i++)
    {
        UIImageView * star = [[UIImageView alloc] initWithFrame:CGRectMake((120+21*i)*Rate_NAV_W, 243*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
        if (i < [_doctor.doctorStar intValue])
        {
            star.image = [UIImage imageNamed:@"star_in.png"];
        }
        else
        {
            star.image = [UIImage imageNamed:@"star.png"];
        }
        [_headerView addSubview:star];
    }
    
    UILabel *patientCount = [[UILabel alloc] initWithFrame:CGRectMake(229*Rate_NAV_W, 243*Rate_NAV_H, 100*Rate_NAV_W, 14*Rate_NAV_H)];
    patientCount.text = [NSString stringWithFormat:@"(%@)",_doctor.commentCount];
    patientCount.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    patientCount.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    patientCount.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:patientCount];
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 276*Rate_NAV_H, SCREENWIDTH, Rate_NAV_H)];
    line2.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line2];
}

#pragma  mark -- 创建聊天对话框
- (void)createChatView
{
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64) style:(UITableViewStyleGrouped)];
    _tableV.backgroundColor = [UIColor whiteColor];
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self creatQuestionInfo];
    [self createDoctorInfo];
    _tableV.tableHeaderView = _headerView;
    //上拉刷新
    _tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    [self.view addSubview:_tableV];
}

#pragma mark -- tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    NSData * chatData = [_handle getDataFromNetWorkWithJsonType:(DataModelBackTypeGetChatMessage) andDictionary:@{@"questionID":_questionID,@"page":_page}];
    NSArray * temp = [_handle objectFromeResponseString:chatData andType:(DataModelBackTypeGetChatMessage)];
    [_tableV.mj_footer endRefreshing];
    if (temp.count == 0)
    {
        _tableV.mj_footer.state = MJRefreshStateNoMoreData;
    }
    else
    {
        for (NSDictionary * dict in temp)
        {
            [_dataSource addObject:dict];
        }
        
        [_tableV reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _message = [[RecordMessageModel alloc] initWithDictionary:_dataSource[indexPath.row]];
    if (_message.messageType == Message_Time)
    {
        static NSString *cellID = @"MessageTimeCell";
        ChatTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell)
        {
            cell = [[ChatTimeTableViewCell alloc] init];
        }
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        cell.title = _message.message;
        
        return cell;
    }
    else if (_message.messageType == Message_Scale)
    {
        static NSString *cellID = @"MessageScaleCell";
        ScaleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell)
        {
            cell = [[ScaleTableViewCell alloc] init];
        }
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        cell.lable.text = _message.message;
        
        return cell;
    }
    else if (_message.messageType == Message_Text)
    {
        static NSString *cellID = @"MessageTextCell";
        ChatTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell)
        {
            cell = [[ChatTextTableViewCell alloc] init];
        }
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        [cell setRecodeMessage:_message];
        
        return cell;
    }
    else
    {
        static NSString *cellID = @"MessageImageCell";
        ChatImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell)
        {
            cell = [[ChatImageTableViewCell alloc] init];
        }
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        [cell setRecodeMessage:_message];
        
        return cell;
    }
}

#pragma mark -- 计算年龄
- (NSString *)getAgeWithBirth:(NSString *)birth
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //生日
    NSDate *birthDay = [dateFormatter dateFromString:birth];
    //当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
    NSLog(@"currentDate %@ birthDay %@",currentDateStr,birth);
    NSTimeInterval time=[currentDate timeIntervalSinceDate:birthDay];
    int age = ((int)time)/(3600*24*365);
    
    return [NSString stringWithFormat:@"%i",age];
}

#pragma mark -- 查看医生详情
- (void)doctorDetail
{
    DoctorDetailsViewController *detail = [[DoctorDetailsViewController alloc] init];
    detail.doctorID = _question.doctorID;
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
