//
//  SquareViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SquareViewController.h"
#import "Define.h"

#import "FunctionHelper.h"//自定义方法库
#import "DataHandle.h"//服务器获取数据
#import "InterfaceModel.h"
#import "SquareCell.h"
#import "SquareModel.h"
#import <UMMobClick/MobClick.h>
#import "UIImageView+EMWebCache.h"//图片加载
#import "UIViewController+HUD.h"
#import "MJRefresh.h"//三方刷新工具
#import "MBProgressHUD.h"//进度加载

#import "PublicPostViewController.h"//发布帖子视图控制器
#import "PostDetailViewController.h"//帖子详情视图控制器

@interface SquareViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) PatientInfo *patientInfo;

//视图
@property (strong, nonatomic) UITableView *tableV;        //数据显示于tableView上
@property (strong, nonatomic)      UIView *headerV;       //tableView头视图
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic)     UILabel *memberLable;   //显示成员人数
@property (strong, nonatomic)     UILabel *allPostLable;  //显示所有帖子数
@property (strong, nonatomic)     UILabel *todayPostLable;//今日发帖数
@property (strong, nonatomic)     UILabel *failureV;      //获取数据失败的提示

//数据处理对象
@property (copy, nonatomic) DataHandle * handle; //数据处理对象

//属性值
@property (nonatomic, strong) NSMutableArray *dataSource;    //数据源
@property (nonatomic, copy)         NSString *page;          //分页显示的页数
@property (nonatomic, copy)         NSString *allPostCount;  //所有帖子数
@property (nonatomic, copy)         NSString *membersCount;  //所有成员数
@property (nonatomic, copy)         NSString *todayPostCount;//今日新帖数
@property (nonatomic)                   BOOL isAll;          //显示所有帖子还是精华帖子

@end

@implementation SquareViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick beginLogPageView:@"眠友圈"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"眠友圈"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"眠友圈";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIButton *releaseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 22, 20, 20)];
    [releaseButton setBackgroundImage:[UIImage imageNamed:@"icon_post.png"] forState:(UIControlStateNormal)];
    [releaseButton addTarget:self action:@selector(publicPost) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *releaseButtonItem = [[UIBarButtonItem alloc] initWithCustomView:releaseButton];
    self.navigationItem.rightBarButtonItem = releaseButtonItem;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshView" object:nil];
    //注册刷新界面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefreshView:) name:@"RefreshView" object:nil];
    //注册个人信息修改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePatientInfo:) name:@"patientInfoChange" object:nil];
    
    _patientInfo = [PatientInfo shareInstance];
    //对象初始化
    _handle = [[DataHandle alloc] init];
    _page = @"1";
    _dataSource = [NSMutableArray array];
    //创建tableView
    [self createTableView];
    //判断是否有网络
    if ([FunctionHelper isExistenceNetwork])
    {
        //从网络获取广场信息
        [self getSquareInfoFromNetWork];
        //从网络获取帖子数据
        [self getDataFromNetWork];
    }
    else
    {
        //从本地获取广场信息
        [self getDataFromLocalCache];
        //网络连接失败提示
        [self createGetDataFailureViewWithError:@"请检查网络连接"];
    }

}

#pragma mark -- 接收到通知刷新数据
- (void)needRefreshView:(NSNotification *)text
{
    if([text.userInfo[@"state"] isEqualToString:@"post"])
    {
        [self refreshView];
    }
    else
    {
        NSInteger index = [text.userInfo[@"state"] integerValue];
        NSIndexPath *path=[NSIndexPath indexPathForRow:0 inSection:index];
        SquareCell *cell = (SquareCell *)[_tableV cellForRowAtIndexPath:path];
        cell.browserLable.text = text.userInfo[@"browserCount"];
        cell.favorLable.text = text.userInfo[@"favorCount"];
        cell.commentLable.text = text.userInfo[@"commentCount"];
    }
}

#pragma mark -- 个人信息修改通知方法
- (void)changePatientInfo:(NSNotification *)notification
{
    _patientInfo = [notification.userInfo objectForKey:@"patientInfo"];
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:_patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
    [_headerImageView setImage:[[UIImage alloc] initWithData:imageData]];
    [self refreshView];
}

#pragma mark -- 从本地获取数据
- (void)getDataFromLocalCache
{
    _allPostCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"AllPostCount"];
    _membersCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberCount"];
    _todayPostCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"TodayPostCount"];
    [self setValueForHeaderView];
}

#pragma mark -- 从网络获取广场信息
- (void)getSquareInfoFromNetWork
{
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetSquareInfo) andPrimaryKey:[self getCurrentDate]];
    req.timeoutInterval = 1;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data)
        {
            [self prepareDataForViewWithData:data andType:(DataModelBackTypeGetSquareInfo)];
        }
        else
        {
            [self getDataFromLocalCache];
        }
    }];
}

#pragma mark -- 获取当前日期
- (NSString *)getCurrentDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    return  [formatter stringFromDate:[NSDate date]];
}

#pragma mark -- 从网络获取帖子数据
- (void)getDataFromNetWork
{
    DataModelBackType type;
    if (_isAll)
    {
        type = DataModelBackTypeGetAllPost;
    }
    else
    {
        type = DataModelBackTypeGetCreamPost;
    }
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"加载中";
    NSMutableURLRequest * req = [_handle RequestForGetDataFromNetWorkWithStringType:type andPrimaryKey:_page];
    req.timeoutInterval = 5.0;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError)
        {
            hud.labelText = @"网络繁忙，请稍后再试";
            [hud hide:YES afterDelay:0.5];
            [self createGetDataFailureViewWithError:@"获取数据失败"];
        }
        else
        {
            if (data)
            {
                hud.labelText = @"加载完成";
                [hud hide:YES afterDelay:0.1];
                [self prepareDataForViewWithData:data andType:type];
            }
            else
            {
                hud.labelText = @"加载失败";
                [hud hide:YES afterDelay:0.5];
                [self createGetDataFailureViewWithError:@"获取数据失败"];
            }
        }
    }];
}

#pragma mark -- 处理从网络获取的数据
- (void)prepareDataForViewWithData:(NSData *)data andType:(DataModelBackType )type
{
    if(type == DataModelBackTypeGetSquareInfo)
    {
        NSDictionary *dic = [_handle objectFromeResponseString:data andType:type];
        _allPostCount = [dic objectForKey:@"AllPostCount"];
        _membersCount = [dic objectForKey:@"MemberCount"];
        _todayPostCount = [dic objectForKey:@"TodayPostCount"];
        [[NSUserDefaults standardUserDefaults] setObject:_allPostCount forKey:@"AllPostCount"];
        [[NSUserDefaults standardUserDefaults] setObject:_membersCount forKey:@"MemberCount"];
        [[NSUserDefaults standardUserDefaults] setObject:_todayPostCount forKey:@"TodayPostCount"];
        [self setValueForHeaderView];
    }
    else
    {
        NSArray *temp = [_handle objectFromeResponseString:data andType:type];
        if (temp.count == 0)
        {
            _tableV.mj_footer.state = MJRefreshStateNoMoreData;
        }
        for (NSDictionary *dic in temp)
        {
            [_failureV removeFromSuperview];
            SquareModel *model = [[SquareModel alloc] initWithDictionary:dic];
            [_dataSource addObject:model];
        }
        [_tableV reloadData];
        if (_dataSource.count == 0)
        {
            [self createGetDataFailureViewWithError:@"暂时无数据"];
        }
    }
}

#pragma mark -- 发布帖子
- (void)publicPost
{
    PublicPostViewController *public = [[PublicPostViewController alloc] init];
    public.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:public animated:YES];
}

#pragma mark -- 创建未获取到数据的提示信息
- (void)createGetDataFailureViewWithError:(NSString *)error
{
    [_failureV removeFromSuperview];
    _failureV = [[UILabel alloc] initWithFrame:CGRectMake(0, 220*Rate_H, SCREENWIDTH, 382*Rate_H)];
    _failureV.textColor = [UIColor lightGrayColor];
    _failureV.font = [UIFont systemFontOfSize:25];
    _failureV.textAlignment = NSTextAlignmentCenter;
    _failureV.text = error;
    [_tableV addSubview:_failureV];
}

#pragma  mark -- 创建headerView
- (void)createHeaderView
{
    _headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 181*Rate_H)];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 180*Rate_H)];
    backgroundImage.image = [UIImage imageNamed:@"mian_pg_bg.png"];
    [_headerV addSubview:backgroundImage];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 60*Rate_H)/2, 15*Rate_H, 60*Rate_H, 60*Rate_H)];
    _headerImageView.layer.cornerRadius = 30*Rate_H;
    _headerImageView.clipsToBounds = YES;
    if (_patientInfo.Picture == nil || _patientInfo.Picture.length == 0)
    {
        [_headerImageView setImage:[UIImage imageNamed:@"Default"]];
    }
    else
    {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:_patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
        [_headerImageView setImage:[[UIImage alloc] initWithData:imageData]];
    }
    [_headerV addSubview:_headerImageView];
    
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/4, 78*Rate_H, SCREENWIDTH/2, 22*Rate_H)];
    nameLable.text = _patientInfo.PatientName;
    nameLable.textAlignment = NSTextAlignmentCenter;
    nameLable.font = [UIFont systemFontOfSize:16];
    nameLable.adjustsFontSizeToFitWidth = YES;
    nameLable.textColor = [UIColor whiteColor];
    [_headerV addSubview:nameLable];
    
    UILabel *tapLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 117*Rate_H, SCREENWIDTH, 20*Rate_H)];
    tapLable.text = @"因疗疗而结缘，属于眠友们分享交流天地";
    tapLable.textAlignment = NSTextAlignmentCenter;
    tapLable.font = [UIFont systemFontOfSize:14];
    tapLable.textColor = [UIColor whiteColor];
    [_headerV addSubview:tapLable];
    
    _memberLable = [[UILabel alloc] initWithFrame:CGRectMake(23*Rate_W, 147*Rate_H, (SCREENWIDTH - 46*Rate_W)/3, 17*Rate_H)];
    _memberLable.textAlignment = NSTextAlignmentLeft;
    _memberLable.font = [UIFont systemFontOfSize:14];
    _memberLable.textColor = [UIColor whiteColor];
    [_headerV addSubview:_memberLable];
    
    _allPostLable = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - (SCREENWIDTH - 46*Rate_W)/3)/2, 147*Rate_H, (SCREENWIDTH - 46*Rate_W)/3, 17*Rate_H)];
    _allPostLable.textAlignment = NSTextAlignmentCenter;
    _allPostLable.font = [UIFont systemFontOfSize:14];
    _allPostLable.textColor = [UIColor whiteColor];
    [_headerV addSubview:_allPostLable];
    
    _todayPostLable = [[UILabel alloc] initWithFrame:CGRectMake(23*Rate_W + (SCREENWIDTH - 46*Rate_W)*2/3, 147*Rate_H, (SCREENWIDTH - 46*Rate_W)/3, 17*Rate_H)];
    _todayPostLable.textAlignment = NSTextAlignmentRight;
    _todayPostLable.font = [UIFont systemFontOfSize:14];
    _todayPostLable.textColor = [UIColor whiteColor];
    [_headerV addSubview:_todayPostLable];
    
    [self loadPostData];
}

#pragma  mark -- headerView中的控件赋值
- (void)setValueForHeaderView
{
    _memberLable.text = [NSString stringWithFormat:@"成员: %@",_membersCount];
    _allPostLable.text = [NSString stringWithFormat:@"帖子: %@",_allPostCount];
   _todayPostLable.text = [NSString stringWithFormat:@"今日新帖: %@",_todayPostCount];
    if ([_membersCount intValue] >= 10000)
    {
        _memberLable.text =@"成员: 1万+";
    }
    if ([_allPostCount intValue] >= 10000)
    {
        _memberLable.text =@"帖子: 1万+";
    }
    if ([_todayPostCount intValue] >= 10000)
    {
        _memberLable.text =@"今日新帖: 1万+";
    }
}

#pragma  mark -- 创建tableview
- (void)createTableView
{
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    //下拉刷新
    _tableV.mj_header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshView)];
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
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"SquareCellID%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    SquareCell *cell = [[SquareCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = _dataSource[indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SquareModel *model = _dataSource[indexPath.section];
    PostDetailViewController *vc= [[PostDetailViewController alloc] init];
    vc.postModel = model;
    vc.index = indexPath.section;
    //若成功则跳转
    if([self updatePostCountWithPostID:model.PostID andType:@"1"])
    {
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        //否则提示
        [self showHint:@"服务器出错，请稍后再试"];
    }
}

#pragma mark --- 下拉刷新
- (void)refreshView
{
    _dataSource = [NSMutableArray array];
    if([FunctionHelper isExistenceNetwork])
    {
        [self getSquareInfoFromNetWork];
        _page = @"1";
        _dataSource = [NSMutableArray array];
        [self getDataFromNetWork];
    }
    [_tableV reloadData];
    [_tableV.mj_header endRefreshing];
}

#pragma mark --- 上拉刷新
- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    [self getDataFromNetWork];
    [_tableV.mj_footer endRefreshing];
}

#pragma mark -- 切换数据
- (void)loadPostData
{
    _isAll = YES;
    UILabel *line1 = (UILabel *)[_headerV viewWithTag:11];
    UILabel *line2 = (UILabel *)[_headerV viewWithTag:12];
    UIButton *btn = (UIButton *)[_headerV viewWithTag:1];
    line1.layer.backgroundColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0].CGColor;
    line2.layer.backgroundColor = [UIColor colorWithRed:0.20 green:0.73 blue:0.82 alpha:1.0].CGColor;
    [btn setTitleColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0] forState:(UIControlStateNormal)];
    //#warning 此处添加数值初始化
    _page = @"1";
    _dataSource = [NSMutableArray array];
}

#pragma mark -- 修改帖子数据
- (BOOL)updatePostCountWithPostID:(NSString *)postID andType:(NSString *)type
{
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPostCount) andDictionary:@{@"postID":postID,@"type":type}];
    req.timeoutInterval = 1;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    if (data)
    {
        if([[_handle objectFromeResponseString:data andType:(DataModelBackTypeUploadPostCount)] isEqualToString:@"OK"])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
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
