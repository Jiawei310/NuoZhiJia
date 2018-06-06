//
//  DoctorDetailsViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "DoctorDetailsViewController.h"

#import "Define.h"
#import "DataHandle.h"
#import "FunctionHelper.h"
#import "MJRefresh.h"
#import "UIImageView+EMWebCache.h"
#import <UMMobClick/MobClick.h>

#import "DoctorInfoModel.h"

#import "CommentTableViewCell.h"

@interface DoctorDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableV;
@property (strong, nonatomic)      UIView *headerView;
@property (strong, nonatomic) NSMutableArray *commentsArr;
@property (copy, nonatomic)  DoctorInfoModel *doctorInfoModel;
@property (copy, nonatomic) DataHandle *handle;
@property (copy, nonatomic)   NSString *commentCount;
@property (copy, nonatomic)   NSString *page;

@end

@implementation DoctorDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"医生详情"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"医生详情"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"医生详情";
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
    
    _handle = [[DataHandle alloc] init];
    _page = @"1";
    
    if ([FunctionHelper isExistenceNetwork])
    {
        [self prepareData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络出错" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    [self createTableView];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 准备数据
- (void)prepareData
{
    _commentsArr = [NSMutableArray array];
    _doctorInfoModel = [[DoctorInfoModel alloc] init];
    NSData *doctorData = [_handle getDataFromNetWorkWithStringType:(DataModelBackTypeGetDoctorInfo) andPrimaryKey:_doctorID];
    NSArray *temp = [_handle objectFromeResponseString:doctorData andType:(DataModelBackTypeGetDoctorInfo)];
    [_handle objectFromeResponseString:doctorData andType:(DataModelBackTypeGetDoctorInfo)];
    if (temp.count > 0)
    {
        NSDictionary *dic = temp[0];
        _doctorInfoModel.doctorID = [dic objectForKey:@"DoctorID"];
        _doctorInfoModel.doctorName = [dic objectForKey:@"DoctorName"];
        _doctorInfoModel.doctorHospital = [dic objectForKey:@"DoctorHospital"];
        _doctorInfoModel.doctorDepartment = [dic objectForKey:@"DoctorDepartment"];
        _doctorInfoModel.doctorLoction = [dic objectForKey:@"DoctorLoction"];
        _doctorInfoModel.doctorStar = [dic objectForKey:@"DoctorStar"];
        _doctorInfoModel.doctorIcon = [dic objectForKey:@"DoctorIcon"];
        _doctorInfoModel.doctorTap = [dic objectForKey:@"DoctorTap"];
        _doctorInfoModel.doctorBrief = [dic objectForKey:@"DoctorBrief"];
        _doctorInfoModel.questionCount = [dic objectForKey:@"QuestionCount"];
        _doctorInfoModel.fullStarCount = [dic objectForKey:@"FullStarCount"];
        _commentCount = [dic objectForKey:@"CommentCount"];
        NSData *commentData = [_handle getDataFromNetWorkWithJsonType:(DataModelBackTypeGetCommendInfo) andDictionary:@{@"doctorID":_doctorID,@"page":@"1"}];
        NSArray *temps = [_handle objectFromeResponseString:commentData andType:(DataModelBackTypeGetCommendInfo)];
        for (NSDictionary *dict in temps)
        {
            CommentModel *comment = [[CommentModel alloc] initWithDictionary:dict];
            [_commentsArr addObject:comment];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"数据出错" message:@"服务器获取数据出错" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark -- 创建医生信息
- (void)createDoctorInfo
{
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *doctorIcon = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 70*Rate_NAV_H)/2, 20*Rate_NAV_H, 70*Rate_NAV_H, 70*Rate_NAV_H)];
    [doctorIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://211.161.200.73:8098/DoctorTempHeadImg/%@",_doctorInfoModel.doctorIcon]] placeholderImage:[UIImage imageNamed:@"headerImage_doctor"]];
    doctorIcon.layer.cornerRadius = 35*Rate_NAV_H;
    doctorIcon.clipsToBounds = YES;
    [_headerView addSubview:doctorIcon];
    
    UILabel *doctorName = [[UILabel alloc] initWithFrame:CGRectMake(0, 95*Rate_NAV_H, SCREENWIDTH, 28*Rate_NAV_H)];
    doctorName.text = _doctorInfoModel.doctorName;
    doctorName.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    doctorName.textAlignment = NSTextAlignmentCenter;
    doctorName.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_headerView addSubview:doctorName];
    
    for(int i = 0; i < 5; i++)
    {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake((143 + 21*i)*Rate_NAV_W, 127*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
        if (i < 3)
        {
            star.image = [UIImage imageNamed:@"star_in.png"];
        }
        else
        {
            star.image = [UIImage imageNamed:@"star.png"];
        }
        
        [_headerView addSubview:star];
    }
    
    UILabel *doctorInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 148*Rate_NAV_H, SCREENWIDTH, 20*Rate_NAV_H)];
    doctorInfo.text = [NSString stringWithFormat:@"%@ %@",_doctorInfoModel.doctorHospital,_doctorInfoModel.doctorDepartment];
    doctorInfo.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    doctorInfo.textAlignment = NSTextAlignmentCenter;
    doctorInfo.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_headerView addSubview:doctorInfo];
    
//    UILabel *doctorTap = [[UILabel alloc] initWithFrame:CGRectMake(0, 171*Rate_NAV_H, SCREENWIDTH, 20*Rate_NAV_H)];
//    doctorTap.text = _doctorInfoModel.doctorTap;
//    doctorTap.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
//    doctorTap.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
//    doctorTap.textAlignment = NSTextAlignmentCenter;
//    doctorTap.adjustsFontSizeToFitWidth = YES;
//    [_headerView addSubview:doctorTap];
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 209*Rate_NAV_H, SCREENWIDTH, Rate_NAV_H)];
    line1.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line1];
    
    for (int i = 0; i < 2; i++)
    {
        UILabel *lableCount = [[UILabel alloc] initWithFrame:CGRectMake(188*i*Rate_NAV_W, 221*Rate_NAV_H, 187*Rate_NAV_W, 32*Rate_NAV_H)];
        UILabel *lableTitle = [[UILabel alloc] initWithFrame:CGRectMake(188*i*Rate_NAV_W, 252*Rate_NAV_H, 187*Rate_NAV_W, 17*Rate_NAV_H)];
        if (i == 0)
        {
            lableCount.text = _doctorInfoModel.questionCount;
            lableTitle.text = @"解答问题";
        }
        else
        {
            lableCount.text = _doctorInfoModel.fullStarCount;
            lableTitle.text = @"五星评价";
        }
        lableCount.textAlignment = NSTextAlignmentCenter;
        lableTitle.textAlignment = NSTextAlignmentCenter;
        lableCount.textColor = [UIColor colorWithRed:0.24 green:0.85 blue:0.76 alpha:1.00];
        lableTitle.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.00];
        lableCount.font = [UIFont systemFontOfSize:25*Rate_NAV_H];
        lableTitle.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
        [_headerView addSubview:lableCount];
        [_headerView addSubview:lableTitle];
    }
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(187*Rate_NAV_W, 222*Rate_NAV_H, Rate_NAV_W, 54*Rate_NAV_H)];
    line2.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line2];
    
    UILabel *line3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 288*Rate_NAV_H, SCREENWIDTH, 10*Rate_NAV_H)];
    line3.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line3];
}

- (void)createDoctorBrief
{
    UIImageView *briefImage = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 312*Rate_NAV_H, 20*Rate_NAV_W, 22*Rate_NAV_H)];
    briefImage.image = [UIImage imageNamed:@"icon_evaluate.png"];
    [_headerView addSubview:briefImage];
    
    UILabel *topic = [[UILabel alloc] initWithFrame:CGRectMake(46*Rate_NAV_W, 311*Rate_NAV_H, 75*Rate_NAV_W, 25*Rate_NAV_H)];
    topic.text = @"医生简介";
    topic.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    topic.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_headerView addSubview:topic];
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 348*Rate_NAV_H, SCREENWIDTH, Rate_NAV_H)];
    line1.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line1];
    
    UILabel *brief = [[UILabel alloc] init];
    brief.text = _doctorInfoModel.doctorBrief;
    brief.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    brief.numberOfLines = 0;
    brief.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    CGSize size = [brief.text boundingRectWithSize:CGSizeMake(345*Rate_NAV_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14*Rate_NAV_H]} context:nil].size;
    brief.frame = CGRectMake(15*Rate_NAV_W, 362*Rate_NAV_H, 345*Rate_NAV_W, size.height);
    [_headerView addSubview:brief];
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(brief.frame) + 10*Rate_NAV_H, SCREENWIDTH, 10*Rate_NAV_H)];
    line2.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line2];
    
    _headerView.frame = CGRectMake(0, 0, SCREENWIDTH, CGRectGetMaxY(brief.frame) + 10*Rate_NAV_H);
}

- (void)createTableView
{
    [self createDoctorInfo];
    [self createDoctorBrief];
    
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64)];
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableHeaderView = _headerView;
    //上拉刷新
    _tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    //结束尾部刷新
    [_tableV.mj_footer endRefreshing];
    [self.view addSubview:_tableV];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commentsArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50*Rate_NAV_H;
}

- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    NSData *commentData = [_handle getDataFromNetWorkWithJsonType:(DataModelBackTypeGetCommendInfo) andDictionary:@{@"doctorID":_doctorID,@"page":_page}];
    NSArray *temps = [_handle objectFromeResponseString:commentData andType:(DataModelBackTypeGetCommendInfo)];
    [_tableV.mj_footer endRefreshing];
    if (temps.count == 0)
    {
        _tableV.mj_footer.state = MJRefreshStateNoMoreData;
    }
    else
    {
        for (NSDictionary *dict in temps)
        {
            CommentModel *comment = [[CommentModel alloc] initWithDictionary:dict];
            [_commentsArr addObject:comment];
        }
        [_tableV reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [[CommentTableViewCell alloc] init];
    CommentModel *model = _commentsArr[indexPath.row];
    
    return [cell getCellHeight:model.commentContent];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENHEIGHT, 49*Rate_NAV_H)];
    UIImageView *topicImage = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 18*Rate_NAV_H, 24*Rate_NAV_H, 23*Rate_NAV_H)];
    topicImage.image = [UIImage imageNamed:@"icon_evaluate.png"];
    [view addSubview:topicImage];
    
    UILabel *topic = [[UILabel alloc] initWithFrame:CGRectMake(46*Rate_NAV_W, 17*Rate_NAV_H, 329*Rate_NAV_W, 25*Rate_NAV_H)];
    topic.text = [NSString stringWithFormat:@"用户评价(%@)",_commentCount];
    topic.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    topic.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [view addSubview:topic];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 49*Rate_NAV_H, SCREENWIDTH, Rate_NAV_H)];
    line.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [view addSubview:line];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"doctorDetailCellID";
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[CommentTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    }
    cell.model = _commentsArr[indexPath.row];
    
    return cell;
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
