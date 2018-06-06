//
//  SleepCircleViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SleepCircleViewController.h"
#import "Define.h"

#import "SleepCircleCell.h"           //眠友圈cell
#import "SleepCircleModel.h"         //眠友圈model
#import <UMMobClick/MobClick.h>
#import "FunctionHelper.h"           //自定义方法库
#import "MJRefresh.h"               //三方刷新工具

#import "PostDetailViewController.h"  //帖子详情
#import "PostWebViewController.h"

@interface SleepCircleViewController ()<UITableViewDelegate,UITableViewDataSource>

//视图部分
@property (strong, nonatomic) UITableView *tableV;//数据显示于tableView上
@property (strong, nonatomic) UILabel *failureV;//数据获取失败时的提示

//属性值部分
@property (strong, nonatomic) NSMutableArray *dataSource; //存放数据
@property (copy, nonatomic) NSString *page;//数据分页显示的页数

@end

@implementation SleepCircleViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"资讯"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"资讯"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"资讯";
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
    
    //判断当前是否有网络
    if ([FunctionHelper isExistenceNetwork])
    {
        [self prepareData];
        [self createTableView];
    }
    else
    {
        [self createGetDataFailureView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToPostWebViewContriller:) name:@"pushToPostWebVC" object:nil];
    
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareData
{
    _dataSource = [NSMutableArray array];
    _page = @"1";
    
    SleepCircleModel * model = [[SleepCircleModel alloc] init];
    model.Title = @"\"鸡吉健康\" 新年礼盒 火热预售中......";
    model.Time = @"2016年12月29日 17:32";
    model.ImageUrl = @"";
    model.ImageName = @"main_one.jpg";
    model.Content = @"不一样的礼不一样的年，不一样的印象红红火火新一年！诺之嘉携手大鸿图，倾情推出\"鸡吉健康\"新年礼-疗疗、对联、红包、门幅、日历、健康茶饮，陪您过个健康中国年！";
    model.FavorCount = @"101";
    model.CommentCount = @"204";
    model.PostUrl = @"http://url.cn/44jSWg7";
    [_dataSource addObject:model];
    
    SleepCircleModel * model_1 = [[SleepCircleModel alloc] init];
    model_1.Title = @"什么是焦虑症？";
    model_1.Time = @"2016年12月13日 10:26";
    model_1.ImageUrl = @"";
    model_1.ImageName = @"main_two.jpg";
    model_1.Content = @"转自“医熠生辉中枢神经界”微信公众号";
    model_1.FavorCount = @"101";
    model_1.CommentCount = @"204";
    model_1.PostUrl = @"http://url.cn/44jDkmn";
    [_dataSource addObject:model_1];
    
    SleepCircleModel * model_2 = [[SleepCircleModel alloc] init];
    model_2.Title = @"疗疗失眠众测——来自专业医生的测试报告";
    model_2.Time = @"2016年12月09日 11:28";
    model_2.ImageUrl = @"";
    model_2.ImageName = @"main_three.jpg";
    model_2.Content = @"本次疗疗失眠和杏树林合作，在人群中随机选取30位对象进行试用测试，其改善率高达89%以上，欢迎前来咨询与试用。疗疗失眠基于专业医疗技术，让您拥有好睡眠，好精神。";
    model_2.FavorCount = @"101";
    model_2.CommentCount = @"204";
    model_2.PostUrl = @"http://url.cn/44j9Saz";
    [_dataSource addObject:model_2];
    
    SleepCircleModel * model_3 = [[SleepCircleModel alloc] init];
    model_3.Title = @"睡眠不好，容易诱发癌症";
    model_3.Time = @"2016年06月24日 13:29";
    model_3.ImageUrl = @"";
    model_3.ImageName = @"main_four.jpg";
    model_3.Content = @"睡眠不好与癌症的发生真的存在某种联系吗？ 美国斯坦福大学医学研究中心的科学家们研究证明……";
    model_3.FavorCount = @"101";
    model_3.CommentCount = @"204";
    model_3.PostUrl = @"http://mp.weixin.qq.com/s/621eE-_6sAm8uEqd3Qm_RQ";
    [_dataSource addObject:model_3];
    
    SleepCircleModel * model_4 = [[SleepCircleModel alloc] init];
    model_4.Title = @"母乳喂养 爱在起点——哺乳期失眠怎么办";
    model_4.Time = @"2016年05月18日 11:25";
    model_4.ImageUrl = @"";
    model_4.ImageName = @"main_five.jpg";
    model_4.Content = @"5月20日作为全国母乳喂养宣传日，由1990年5月10日卫生部决定的。希望新妈妈们母乳喂养，为爱赢在起点";
    model_4.FavorCount = @"101";
    model_4.CommentCount = @"204";
    model_4.PostUrl = @"http://mp.weixin.qq.com/s?__biz=MzAwODc2NTczMw==&mid=2654135204&idx=1&sn=dcb1d08504ca98e73fdc43b5174e48ba&mpshare=1&scene=23&srcid=0208GOpWzlHv4VPJHo1Qe4lZ#rd";
    [_dataSource addObject:model_4];
    
    SleepCircleModel * model_5 = [[SleepCircleModel alloc] init];
    model_5.Title = @"关于患有失眠、抑郁、焦虑的调查问卷";
    model_5.Time = @"2016年05月11日 16:05";
    model_5.ImageUrl = @"";
    model_5.ImageName = @"main_six.jpg";
    model_5.Content = @"学习、生活、工作，让我们的身体拼命奔跑，停止了，断线了，心就乱了，我们就掉队了。于是失眠、抑郁、焦虑……侵蚀着我们的身体。在喧嚣的城市里，我们懂您的感受，希望您有美满健康幸福的生活。";
    model_5.FavorCount = @"101";
    model_5.CommentCount = @"204";
    model_5.PostUrl = @"http://mp.weixin.qq.com/s?__biz=MzAwODc2NTczMw==&mid=2654135163&idx=1&sn=8ace51a51d7e5b9eaa6d0cc3374562ad&mpshare=1&scene=23&srcid=0208oHe2x97XdWp3YUKeob0J#rd";
    [_dataSource addObject:model_5];
    
    SleepCircleModel * model_6 = [[SleepCircleModel alloc] init];
    model_6.Title = @"CMEF参观指南，满足您全方位观展需求！";
    model_6.Time = @"2016年04月13日 09:24";
    model_6.ImageUrl = @"";
    model_6.ImageName = @"main_seven.jpg";
    model_6.Content = @"第75届中国国际医疗器械（春季）博览会\n第22届中国国际医疗器械设计与制造技术（春季）展览会\n2016年4月17日-20日\n国家会展中心（上海）一层展馆";
    model_6.FavorCount = @"101";
    model_6.CommentCount = @"204";
    model_6.PostUrl = @"http://mp.weixin.qq.com/s?__biz=MzAwODc2NTczMw==&mid=406651413&idx=1&sn=d9dfd6c4f1a8aad1050d877eb01239e5&mpshare=1&scene=23&srcid=0208WrRbgukpQ6C0HbBSDQoU#rd";
    [_dataSource addObject:model_6];
    
    SleepCircleModel * model_7 = [[SleepCircleModel alloc] init];
    model_7.Title = @"睡眠障碍";
    model_7.Time = @"2016年03月21日 09:11";
    model_7.ImageUrl = @"";
    model_7.ImageName = @"main_eight.jpg";
    model_7.Content = @"睡眠量不正常以及睡眠中出现异常行为的表现﹐也是睡眠和觉醒正常节律性交替紊乱的表现。可由多种因素引起，常与躯体疾病有关，包括睡眠失调和异态睡眠。睡眠与人的健康息息相关。";
    model_7.FavorCount = @"101";
    model_7.CommentCount = @"204";
    model_7.PostUrl = @"http://mp.weixin.qq.com/s?__biz=MzAwODc2NTczMw==&mid=405763865&idx=1&sn=b47e43dac41f8ec3680ed7e65b4d4a56&mpshare=1&scene=23&srcid=0208d4DHXsmA2zcUm6uVnyzL#rd";
    [_dataSource addObject:model_7];
    
    SleepCircleModel * model_8 = [[SleepCircleModel alloc] init];
    model_8.Title = @"疗疗失眠-智能化 非药物治疗 失眠 抑郁 焦虑或缓解症状";
    model_8.Time = @"2016年03月08日 09:18";
    model_8.ImageUrl = @"";
    model_8.ImageName = @"main_nine.jpg";
    model_8.Content = @"疗疗失眠-智能化 非药物治疗 失眠 抑郁 焦虑或缓解症状";
    model_8.FavorCount = @"101";
    model_8.CommentCount = @"204";
    model_8.PostUrl = @"http://mp.weixin.qq.com/s?__biz=MzAwODc2NTczMw==&mid=405462754&idx=1&sn=54ef78bc646417e383cf90aed52c5520&mpshare=1&scene=23&srcid=0208Mc5Ij4YZgFcrnN2bxFio#rd";
    [_dataSource addObject:model_8];
}

#pragma mark -- 创建未获取到数据的提示信息
- (void)createGetDataFailureView
{
    [_failureV removeFromSuperview];
    _failureV = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 603*Rate_NAV_H)];
    _failureV.textColor = [UIColor lightGrayColor];
    _failureV.font = [UIFont systemFontOfSize:25];
    _failureV.textAlignment = NSTextAlignmentCenter;
    if (![FunctionHelper isExistenceNetwork])
    {
        _failureV.text = @"网络连接失败";
    }
    else if(_dataSource.count == 0)
    {
        _failureV.text = @"暂时无数据";
    }
    else
    {
        _failureV.text = @"服务器获取数据失败";
    }
    [self.view addSubview:_failureV];
}

#pragma  mark -- 创建tableview
- (void)createTableView
{
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, SCREENHEIGHT) style:UITableViewStylePlain];
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    if ([_tableV respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _tableV.cellLayoutMarginsFollowReadableWidth = NO;
    }
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    //上拉刷新
    _tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    _tableV.mj_header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshView)];
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

#pragma mark -- 下拉刷新
- (void)refreshView
{
    [_tableV.mj_header endRefreshing];
    [self prepareData];
    [_tableV reloadData];
}

#pragma mark -- 上拉加载更多
- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    [_tableV.mj_footer endRefreshing];
    if (_page)
    {
        _tableV.mj_footer.state = MJRefreshStateNoMoreData;
    }
    else
    {
        [_tableV reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SleepCircleCell";
    SleepCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[SleepCircleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = _dataSource[indexPath.section];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostWebViewController *postWebVC = [[PostWebViewController alloc] init];
    SleepCircleModel *tmpModel = [[SleepCircleModel alloc] init];
    tmpModel = _dataSource[indexPath.section];
    postWebVC.postURL = tmpModel.PostUrl;
    [self.navigationController pushViewController:postWebVC animated:YES];
}

- (void)pushToPostWebViewContriller:(NSNotification *)modelURl
{
    PostWebViewController *postWebVC = [[PostWebViewController alloc] init];
    postWebVC.postURL = modelURl.userInfo[@"modelURL"];
    [self.navigationController pushViewController:postWebVC animated:YES];
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
