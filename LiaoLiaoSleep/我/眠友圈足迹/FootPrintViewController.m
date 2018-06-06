//
//  FootPrintViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/15.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "FootPrintViewController.h"
#import "PostDetailViewController.h"
#import "FootPrintCell.h"
#import "MJRefresh.h"
#import "DataHandle.h"
#include "Define.h"
#import <UMMobClick/MobClick.h>

@interface FootPrintViewController ()<UITableViewDelegate,UITableViewDataSource>

//视图
@property (nonatomic, strong)      UIView *headerV;
@property (nonatomic, strong) UITableView *tableV;
@property (nonatomic, strong)     UILabel *failureV;

//数据处理
@property(nonatomic, copy) DataHandle *handle;

//属性值
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, copy)         NSString *page;
@property(nonatomic, assign)           BOOL isReplay;

@end

@implementation FootPrintViewController

- (void)viewWillAppear:(BOOL)animated
{
    //让下方tabbar隐藏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"眠友圈足迹"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"眠友圈足迹"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"眠友圈足迹";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
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
    
    _handle = [[DataHandle alloc]init];
    [self prepareDataWithType:(DataModelBackTypeGetMyPublicPost)];
    [self createTableView];
}
//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 准备数据
- (void)prepareDataWithType:(DataModelBackType)type
{
    _dataSource = [NSMutableArray array];
    _page = @"1";
    NSData *data = [_handle getDataFromNetWorkWithJsonType:type andDictionary:@{@"patientID":[PatientInfo shareInstance].PatientID,@"page":_page}];
    NSArray *temp = [_handle objectFromeResponseString:data andType:type];
    if (temp == 0)
    {
        [self createGetDataFailureView];
    }
    else
    {
        [_failureV removeFromSuperview];
        for (NSDictionary *dic in temp)
        {
            FootPrintModel *model = [[FootPrintModel alloc] initWithDictionary:dic];
            if (type == DataModelBackTypeGetMyPublicPost)
            {
                model.HeaderImage = [PatientInfo shareInstance].PhotoUrl;
                model.isPublic = YES;
                model.PatientName = [PatientInfo shareInstance].PatientName;
            }
            [_dataSource addObject:model];
        }
    }
}

- (void)createHeaderView
{
    _headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    _headerV.userInteractionEnabled = YES;
    for (int  i = 0; i < 2; i++)
    {
        UIButton *btn  = [[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH/2*i, 0, SCREENWIDTH/2, 40)];
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(SCREENWIDTH/2*i, 39, SCREENWIDTH/2, 1)];
        NSString *title ;
        if (i == 0)
        {
            title = @"我发的帖子";
            [btn setTitleColor:[UIColor colorWithRed:0.20 green:0.73 blue:0.82 alpha:1.0] forState:(UIControlStateNormal)];
            line.layer.backgroundColor = [UIColor colorWithRed:0.20 green:0.73 blue:0.82 alpha:1.0].CGColor;
        }
        else
        {
            title = @"回复的帖子";
            [btn setTitleColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0] forState:(UIControlStateNormal)];
            line.layer.backgroundColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0].CGColor;
        }
        btn.tag = i+1;
        line.tag = i+11;
        [btn setTitle:title forState:(UIControlStateNormal)];
        [btn addTarget:self action:@selector(changeData:) forControlEvents:(UIControlEventTouchUpInside)];
        [_headerV addSubview:line];
        [_headerV addSubview:btn];
    }
}

#pragma mark -- 切换数据
- (void)changeData:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        _isReplay = NO;
        UIButton *btn = (UIButton *)[_headerV viewWithTag:2];
        UILabel *line1 = (UILabel *)[_headerV viewWithTag:11];
        UILabel *line2 = (UILabel *)[_headerV viewWithTag:12];
        [sender setTitleColor:[UIColor colorWithRed:0.20 green:0.73 blue:0.82 alpha:1.0] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0] forState:(UIControlStateNormal)];
        line1.layer.backgroundColor = [UIColor colorWithRed:0.20 green:0.73 blue:0.82 alpha:1.0].CGColor;
        line2.layer.backgroundColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0].CGColor;
        [self prepareDataWithType:DataModelBackTypeGetMyPublicPost];
        [_tableV reloadData];
    }
    else
    {
        _isReplay = YES;
        UIButton *btn = (UIButton *)[_headerV viewWithTag:1];
        UILabel *line1 = (UILabel *)[_headerV viewWithTag:11];
        UILabel *line2 = (UILabel *)[_headerV viewWithTag:12];
        [sender setTitleColor:[UIColor colorWithRed:0.20 green:0.73 blue:0.82 alpha:1.0] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0] forState:(UIControlStateNormal)];
        line1.layer.backgroundColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0].CGColor;
        line2.layer.backgroundColor = [UIColor colorWithRed:0.20 green:0.73 blue:0.82 alpha:1.0].CGColor;
        [self prepareDataWithType:DataModelBackTypeGetMyReplayPost];
        [_tableV reloadData];
    }
}

#pragma mark -- 创建未获取到数据的提示信息
- (void)createGetDataFailureView
{
    [_failureV removeFromSuperview];
    _failureV = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _failureV.textColor = [UIColor lightGrayColor];
    _failureV.font = [UIFont systemFontOfSize:25];
    _failureV.textAlignment = NSTextAlignmentCenter;
    if (_isReplay)
    {
        _failureV.text = @"暂无回复的帖子";
    }
    else
    {
       _failureV.text = @"暂无发布帖子"; 
    }
    [_tableV addSubview:_failureV];
}

#pragma mark -- 创建tableView
- (void)createTableView
{
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:(UITableViewStyleGrouped)];
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    //上拉刷新
    _tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    [self createHeaderView];
    _tableV.tableHeaderView = _headerV;
    [self.view addSubview:_tableV];
}

#pragma mark -- tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section != _dataSource.count-1)
    {
        return 0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"footPrintCellID";
    FootPrintCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[FootPrintCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    }
    cell.model = _dataSource[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FootPrintModel *model = _dataSource[indexPath.section];
    PostDetailViewController *detail = [[PostDetailViewController alloc] init];
    detail.postModel = model.postModel;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark -- 上拉加载数据
- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    [_tableV.mj_footer endRefreshing];
    NSArray *temp = [NSArray array];
    if (_isReplay)
    {
        NSData *data = [_handle getDataFromNetWorkWithJsonType:DataModelBackTypeGetMyReplayPost andDictionary:@{@"patientID":[PatientInfo shareInstance].PatientID,@"page":_page}];
        temp = [_handle objectFromeResponseString:data andType:DataModelBackTypeGetMyReplayPost];
    }
    else
    {
        NSData *data = [_handle getDataFromNetWorkWithJsonType:DataModelBackTypeGetMyPublicPost andDictionary:@{@"patientID":[PatientInfo shareInstance].PatientID,@"page":_page}];
        temp = [_handle objectFromeResponseString:data andType:DataModelBackTypeGetMyPublicPost];
    }
    if (temp.count == 0)
    {
        _tableV.mj_footer.state = MJRefreshStateNoMoreData;
    }
    else
    {
        for (NSDictionary *dic in temp)
        {
            FootPrintModel *model = [[FootPrintModel alloc]initWithDictionary:dic];
            [_dataSource addObject:model];
        }
        [_tableV reloadData];
    }
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
