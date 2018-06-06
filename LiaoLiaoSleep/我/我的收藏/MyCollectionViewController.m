//
//  MyCollectionViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/15.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "PostDetailViewController.h"
#import "SquareCell.h"
#import "SquareModel.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "DataHandle.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface MyCollectionViewController ()<UITableViewDelegate,UITableViewDataSource>

//视图
@property (nonatomic, strong) UITableView *tableV;
@property (nonatomic, strong)     UILabel *failureV;

//数据处理对象
@property (nonatomic, copy) DataHandle *handle;

//属性值
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *selectorArray;//存放选中数据
@property (nonatomic, copy)         NSString *patientID;
@property (nonatomic, copy)         NSString *page;

@end

@implementation MyCollectionViewController

- (void)viewWillAppear:(BOOL)animated
{
    //让下方tabbar隐藏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"我的收藏"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的收藏"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];;
    
    self.navigationItem.title = @"我的收藏";
    
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
    
    UIButton *editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 22, 50, 20)];
    [editButton setTitle:@"编辑" forState:(UIControlStateNormal)];
    [editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = editButtonItem;
    
    _patientID = [PatientInfo shareInstance].PatientID;
    _handle = [[DataHandle alloc]init];
    _selectorArray = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self prepareData];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 编辑
- (void)edit:(UIButton *)btn
{
    if (_dataSource.count > 0)
    {
        [_tableV setEditing:!_tableV.editing animated:YES];
        if (_tableV.editing)
        {
            [btn setTitle:@"删除" forState:(UIControlStateNormal)];
        }
        else
        {
            [btn setTitle:@"编辑" forState:(UIControlStateNormal)];
            [self DeletePost];
        }
    }
}

- (void)reloadView {
    if(_dataSource.count == 0)
    {
        [self createGetDataFailureView];
    }
    else
    {
        [self createTableView];
    }
}

#pragma mark -- 准备数据
- (void)prepareData
{
    _dataSource = [NSMutableArray array];
    _page = @"1";
    NSData *data = [_handle getDataFromNetWorkWithJsonType:(DataModelBackTypeGetCollectedPost) andDictionary:@{@"patientID":_patientID,@"page":_page}];
    NSArray *temp = [_handle objectFromeResponseString:data andType:DataModelBackTypeGetCollectedPost];
    for (NSDictionary *dic in temp)
    {
        SquareModel *model = [[SquareModel alloc] initWithDictionary:dic];
        [_dataSource addObject:model];
    }
    [self reloadView];
}

#pragma mark -- 创建未获取到数据的提示信息
- (void)createGetDataFailureView
{
    [_failureV removeFromSuperview];
    _failureV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _failureV.textColor = [UIColor lightGrayColor];
    _failureV.font = [UIFont systemFontOfSize:25];
    _failureV.textAlignment = NSTextAlignmentCenter;
    _failureV.text = @"暂无收藏的帖子";
    [self.view addSubview:_failureV];
}

#pragma  mark -- 创建tableview
- (void)createTableView
{
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:(UITableViewStylePlain)];
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    [_tableV setEditing:NO animated:YES];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    //上拉刷新
    _tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    _tableV.allowsMultipleSelectionDuringEditing = YES;
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
    if (section == _dataSource.count-1)
    {
        return 15;
    }
    else
    {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"CollectionCellID%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    SquareCell *cell = [[SquareCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    cell.model = _dataSource[indexPath.section];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SquareModel *model= _dataSource[indexPath.section];
    //判断cell是否在被编辑
    if (_tableV.isEditing)
    {
        [_selectorArray addObject:model.PostID];
    }
    else
    {
        //取消cell的一直选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PostDetailViewController *detailVC = [[PostDetailViewController alloc] init];
        detailVC.postModel = model;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //从选中中取消
    if (_selectorArray.count > 0)
    {
        SquareModel *model= _dataSource[indexPath.section];
        [_selectorArray removeObject:model.PostID];
    }
}

//设置编辑风格EditingStyle
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //----通过表视图是否处于编辑状态来选择是左滑删除，还是多选删除。
    if (_tableV.editing)
    {
        //当表视图处于没有未编辑状态时选择多选删除
        return UITableViewCellEditingStyleDelete| UITableViewCellEditingStyleInsert;
    }
    else
    {
        //当表视图处于没有未编辑状态时选择左滑删除
        return UITableViewCellEditingStyleDelete;
    }
}

//根据不同的editingstyle执行数据删除操作（点击左滑删除按钮的执行的方法）
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        SquareModel *model = _dataSource[indexPath.section];
        if([[self DeletePostWithPostID:model.PostID] isEqualToString:@"OK"])
        {
            [_dataSource removeObjectAtIndex:indexPath.section];
            [_tableV deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:(UITableViewRowAnimationFade)];
        }
    }
    else if(editingStyle == (UITableViewCellEditingStyleDelete| UITableViewCellEditingStyleInsert))
    {
        
    }
}

#pragma mark --- 上拉刷新
- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    [_tableV.mj_footer endRefreshing];
    NSData *data = [_handle getDataFromNetWorkWithJsonType:(DataModelBackTypeGetCollectedPost) andDictionary:@{@"patientID":_patientID,@"page":_page}];
    NSArray *temp = [_handle objectFromeResponseString:data andType:DataModelBackTypeGetCollectedPost];
    if (temp.count == 0)
    {
        _tableV.mj_footer.state = MJRefreshStateNoMoreData;
    
    }else
    {
        for (NSDictionary *dic in temp)
        {
            SquareModel *model = [[SquareModel alloc] initWithDictionary:dic];
            [_dataSource addObject:model];
        }
        [_tableV reloadData];
    }
}

#pragma mark -- 删除帖子
- (NSString *)DeletePostWithPostID:(NSString *)postID
{
    NSData *data = [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeDeleteCollectedPost) andDictionary:@{@"postID":postID,@"patientID":_patientID}];
   return [_handle objectFromeResponseString:data andType:(DataModelBackTypeDeleteCollectedPost)];
}

#pragma mark -- 批量删除帖子
- (void)DeletePost
{
    for (int i = 0; i < _selectorArray.count; i++)
    {
        for (int j = 0; j < _dataSource.count; j++)
        {
            SquareModel *tmpModel = _dataSource[j];
            if ([tmpModel.PostID isEqualToString:_selectorArray[i]])
            {
                NSData *data = [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeDeleteCollectedPost) andDictionary:@{@"postID":tmpModel.PostID,@"patientID":_patientID}];
                if([[_handle objectFromeResponseString:data andType:(DataModelBackTypeDeleteCollectedPost)] isEqualToString:@"OK"])
                {
                    [_dataSource removeObject:tmpModel];
                    [_tableV deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:(UITableViewRowAnimationFade)];
                }
            }
        }
    }
    if (_selectorArray.count > 0)
    {
        [_selectorArray removeAllObjects];
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
