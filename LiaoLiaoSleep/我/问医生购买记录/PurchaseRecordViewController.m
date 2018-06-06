//
//  PurchaseRecordViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 17/1/9.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "PurchaseRecordViewController.h"
#import "MBProgressHUD.h"
#import "DataHandle.h"
#import "MJRefresh.h"
#import "PurchaseRecordCell.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface PurchaseRecordViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)    UITableView *tableV;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong)     DataHandle *handle;
@property (nonatomic, copy)         NSString *page;

@end

@implementation PurchaseRecordViewController

- (void)viewWillAppear:(BOOL)animated
{
    //让下方tabbar隐藏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"问医生购买记录"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick beginLogPageView:@"问医生购买记录"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"问医生购买记录";
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
    
    _handle = [[DataHandle alloc]init];
    _page = @"1";
    _dataSource = [NSMutableArray array];
    [self createTableView];
    [self getDataFromNetWork];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - -准备数据
- (void)getDataFromNetWork
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"加载中";
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeGetPurchaseRecord) andDictionary:@{@"patientID":_patientID,@"page":_page}];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data)
        {
            hud.labelText = @"加载完成";
            [hud hide:YES afterDelay:0.1];
            [self prepareDataWithData:data];
        }
        else
        {
            hud.labelText = @"加载失败";
            [hud hide:YES afterDelay:0.5];
        }
    }];
}

#pragma mark -- 处理数据
- (void)prepareDataWithData:(NSData *)data
{
    [_tableV.mj_footer endRefreshing];
    NSArray *arr = [_handle objectFromeResponseString:data andType:(DataModelBackTypeGetPurchaseRecord)];
    if (arr.count == 0)
    {
        [_tableV.mj_footer endRefreshingWithNoMoreData];
    }
    else
    {
        for (NSDictionary *dic in arr)
        {
            [_dataSource addObject:dic];
        }
    }
    
    [_tableV reloadData];
}

#pragma mark - -创建tableView
- (void)createTableView
{
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableV.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    [self.view addSubview:_tableV];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70*Rate_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPat
{
    static NSString *cellIdentifier = @"purchaseRecordCell";
    PurchaseRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[PurchaseRecordCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIdentifier];
    }
    [cell setWithDictionary:_dataSource[indexPat.section]];
    
    return cell;
}

#pragma mark -- 加载更多数据
- (void)loadMore
{
    NSInteger count = [_page integerValue];
    _page = [NSString stringWithFormat:@"%li",count+1];
    [self getDataFromNetWork];
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
