//
//  QuestionViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "QuestionViewController.h"
#import "Question_InstructionTableViewCell.h"
#import "DetailQuestionViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface QuestionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableV;
@property (nonatomic, copy)       NSArray *dataSouce;

@end

@implementation QuestionViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"常见问题"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"常见问题"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"常见问题";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = [UIColor colorWithRed:0xF7/255.0 green:0xF8/255.0 blue:0xFA/255.0 alpha:1];
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
    
    [self getDataFromPlistFile];
    [self createTableView];
    // Do any additional setup after loading the view.
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//读取plist文件
- (void)getDataFromPlistFile
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"HelpInfo" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:strPath];
    self.dataSouce =[NSArray arrayWithArray:[dic allKeys]];
}

- (void)createTableView
{
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.showsVerticalScrollIndicator = NO;
    self.tableV.showsHorizontalScrollIndicator = NO;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableV];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSouce.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Rate_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str =  @"cellId";
    Question_InstructionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell)
    {
        cell = [[Question_InstructionTableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:str];
    }
    cell.title.text = self.dataSouce[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailQuestionViewController *detailVC = [[DetailQuestionViewController alloc] init];
    detailVC.key = self.dataSouce[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
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
