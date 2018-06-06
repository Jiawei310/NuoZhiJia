//
//  DetailQuestionViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/18.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "DetailQuestionViewController.h"
#import "Define.h"

@interface DetailQuestionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableV;
@property (nonatomic, copy)              NSArray *dataSouce;//数据源存储
@property (nonatomic, strong)NSMutableDictionary *tempDic;  //存储是否展开

@end

@implementation DetailQuestionViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = _key;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = [UIColor lightGrayColor];
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
    
    self.tempDic = [NSMutableDictionary dictionary]; //初始化
    [self getDataFromPlistFile];//获取数据
    [self createTableView];//创建视图
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//读取plist文件
- (void)getDataFromPlistFile
{
    NSString * strPath = [[NSBundle mainBundle] pathForResource:@"HelpInfo" ofType:@"plist"];
    NSDictionary * dic = [[NSDictionary alloc]initWithContentsOfFile:strPath];
    self.dataSouce = [NSArray arrayWithArray:[dic objectForKey:self.key]];
    for (int i = 0; i < self.dataSouce.count; i++)
    {
        [self.tempDic setObject:@"ok" forKey:[NSString stringWithFormat:@"%i",i]];
    }
}

- (void)createTableView
{
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64) style:UITableViewStyleGrouped];
    self.tableV.backgroundColor = [UIColor whiteColor];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.showsVerticalScrollIndicator = NO;
    self.tableV.showsHorizontalScrollIndicator = NO;
    if ([_tableV respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _tableV.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableV.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableV.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableV.tableFooterView = [UIView new];
    [self.view addSubview:self.tableV];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSouce.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGSize titleSize = [[[self.dataSouce objectAtIndex:section] objectForKey:@"Question"] boundingRectWithSize:CGSizeMake(292*Rate_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16*Rate_H]} context:nil].size;
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, titleSize.height + 32*Rate_H)];
    btn.tag = section+1;
    [btn addTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(20*Rate_W, 16*Rate_H, 292*Rate_W, titleSize.height)];
    lable.text = [[self.dataSouce objectAtIndex:section] objectForKey:@"Question"];
    lable.font = [UIFont systemFontOfSize:16*Rate_H];
    lable.numberOfLines = 0;
    [btn addSubview:lable];
    
    UIImageView * imageV = [[UIImageView alloc] initWithFrame:CGRectMake(337*Rate_W, 18*Rate_H, 17*Rate_W, 9*Rate_H)];
    NSString * str = [NSString stringWithFormat:@"%ld",(long)section];
    //若未展开是箭头向上
    if([[self.tempDic objectForKey:str] isEqualToString:@"ok"] )
    {
        imageV.image = [UIImage imageNamed:@"question_arrow_up.png"];
    }
    //展开箭头向下
    else
    {
        imageV.image = [UIImage imageNamed:@"question_arrow_down.png"];
    }
    [btn addSubview:imageV];
    
    return btn;
}

- (CGFloat)tableView:(UITableView * )tableView heightForHeaderInSection:(NSInteger)section
{
    return 60*Rate_H;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
    if([[self.tempDic objectForKey:str] isEqualToString:@"ok"] )
    {
        return 0;
    }
    else
    {
        //计算文字长度返回
        NSDictionary *attrs = @{NSFontAttributeName :Question_AnswerFont};
        CGSize maxSize = CGSizeMake(SCREENWIDTH - 40*Rate_W, MAXFLOAT);
        NSString *str1 = [[self.dataSouce objectAtIndex:indexPath.section] objectForKey:@"Answer"];
        //根据字体得到nsstring的尺寸
        //计算文字占据的高度
        CGSize size = [str1 boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        return size.height + 28*Rate_H;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)click:(UIButton *)sender
{
    NSString * str = [NSString stringWithFormat:@"%ld",(long)sender.tag-1];
    NSLog(@"点击的第%@行",str);
    //点击收缩或展开
    if([[self.tempDic objectForKey:str] isEqualToString:@"ok"])
    {
        [self.tempDic setObject:@"no" forKey:str];
    }
    else
    {
        [self.tempDic setObject:@"ok" forKey:str];
    }
    //刷新当前被点击的行
    [self.tableV reloadSections:[NSIndexSet indexSetWithIndex:[str integerValue]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str =  @"cellId";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:str];
    }
    cell.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.97 alpha:1.0];
    cell.textLabel.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:14*Rate_H];
    cell.textLabel.numberOfLines = 0;
    if([[self.tempDic objectForKey:[NSString stringWithFormat:@"%li",indexPath.section]] isEqualToString:@"ok"] )
    {
        cell.textLabel.text = @"";
    }
    else
    {
        cell.textLabel.text = [[self.dataSouce objectAtIndex:indexPath.section] objectForKey:@"Answer"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:str] isEqualToString:@"ok"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:str];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"ok" forKey:str];
    }
    //刷新当前被点击的行
    [_tableV reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
