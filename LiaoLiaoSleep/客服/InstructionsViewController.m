//
//  InstructionsViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "InstructionsViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>
#import "InstructionTableViewCell.h"

#import "ImageViewController.h"
#import "AttentionViewController.h"
#import "QuestionViewController.h"
#import "GoodsInfoViewController.h"

@interface InstructionsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableV;
@property (nonatomic, copy)       NSArray *array;

@end

@implementation InstructionsViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"说明"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"说明"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"使用说明";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    
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
    
    self.array = @[@"btn_instructions.png",@"btn_principle.png",@"btn_careful.png",@"btn_question.png"];
    [self createTableView];
    // Do any additional setup after loading the view.
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createTableView
{
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:(UITableViewStyleGrouped)];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.showsVerticalScrollIndicator = NO;
    self.tableV.showsHorizontalScrollIndicator = NO;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableV];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return self.array.count;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Rate_W;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellId";
    
    InstructionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[InstructionTableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:cellID];
    }
    if (indexPath.section == 0)
    {
        cell.imageV.image = [UIImage imageNamed:self.array[indexPath.row]];
    }
    else
    {
        cell.imageV.image = [UIImage imageNamed:@"btn_information.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            ImageViewController *imageVC = [[ImageViewController alloc] init];
            imageVC.imageName = @"使用说明";
            [self.navigationController pushViewController:imageVC animated:YES];
        }
        else if (indexPath.row == 1)
        {
            ImageViewController *imageVC = [[ImageViewController alloc] init];
            imageVC.imageName = @"治疗原理";
            [self.navigationController pushViewController:imageVC animated:YES];
        }
        else if (indexPath.row == 2)
        {
            AttentionViewController *attentionVC  = [[AttentionViewController alloc] init];
            [self.navigationController pushViewController:attentionVC animated:YES];
        }
        else if (indexPath.row == 3)
        {
            QuestionViewController *questionVC  = [[QuestionViewController alloc] init];
            [self.navigationController pushViewController:questionVC animated:YES];
        }
    }
    else
    {
        GoodsInfoViewController *infoVC  = [[GoodsInfoViewController alloc] init];
        [self.navigationController pushViewController:infoVC animated:YES];
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
