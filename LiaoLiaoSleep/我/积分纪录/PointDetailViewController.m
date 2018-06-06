//
//  PointDetailViewController.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/8/24.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "PointDetailViewController.h"
#import "Define.h"
#import "MJRefresh.h"//三方刷新工具
#import "MBProgressHUD.h"//进度加载

#import "InterfaceModel.h"
#import "PointTableViewCell.h"

@interface PointDetailViewController ()<UITableViewDelegate, UITableViewDataSource, InterfaceModelDelegate>

@property (nonatomic, strong) UITableView *pointTableView;

@end

@implementation PointDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pointTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 16) style:UITableViewStylePlain];
    _pointTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _pointTableView.tableFooterView = [UIView new];
    _pointTableView.delegate = self;
    _pointTableView.dataSource = self;
    //上拉刷新
    _pointTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    [self.view addSubview:_pointTableView];
}

#pragma mark -- 上拉加载更多
- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    //调用积分接口
    InterfaceModel *interfaceM = [[InterfaceModel alloc] init];
    interfaceM.delegate = self;
    [interfaceM getPointFromServer:[PatientInfo shareInstance].PatientID pointPage:_page];
}

#pragma 借口调用的代理方法
- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypePoint)
    {
        NSArray *tmpArray = value;
        if (tmpArray.count > 0)
        {
            NSDictionary *tmpDic;
            for (int i = 0; i < tmpArray.count; i++)
            {
                tmpDic = [tmpArray objectAtIndex:i];
                [_pointDataSource addObject:tmpDic];
            }
            
            [_pointTableView reloadData];
        }
        
        [_pointTableView.mj_footer endRefreshing];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pointDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"PointCell";
    PointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PointTableViewCell" owner:self options:nil] lastObject];
    }
    
    PointModel *tmpModel = [[PointModel alloc] init];
    NSDictionary *tmpDic = [_pointDataSource objectAtIndex:indexPath.row];
    tmpModel.type = [tmpDic objectForKey:@"Type"];
    tmpModel.date = [tmpDic objectForKey:@"Date"];
    tmpModel.point = [tmpDic objectForKey:@"AddPoint"];
    cell.pModel = tmpModel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
