//
//  PointInstructViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/12/9.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PointInstructViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface PointInstructViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation PointInstructViewController
{
    NSArray *tableArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    //让下方tabbar隐藏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"积分说明"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"积分说明"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"积分说明";
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
    
    [self creatInstructionTableView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)creatInstructionTableView
{
    UITableView *instructTableView = [[UITableView alloc] initWithFrame:CGRectMake(10*Rate_W, 10*Rate_H, 355*Rate_W, 385*Rate_H)];
    instructTableView.scrollEnabled = NO;
    if ([instructTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        instructTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [instructTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    instructTableView.layer.cornerRadius = 3*Rate_H;
    instructTableView.delegate = self;
    instructTableView.dataSource = self;
    [self.view addSubview:instructTableView];
    
    tableArray = @[@{@"name":@"任务名",@"description":@"任务描述",@"reward":@"积分奖励"},@{@"name":@"每日疗程",@"description":@"坚持完成一次治疗",@"reward":@"1-5分／次"},@{@"name":@"完成疗程",@"description":@"坚持完成一个疗程",@"reward":@"20分／次"},@{@"name":@"完评价医生",@"description":@"在问医生给医生评价",@"reward":@"5分／次"},@{@"name":@"发帖被赞",@"description":@"在广场发帖，并获得眠友点赞",@"reward":@"1分／次"},@{@"name":@"评论",@"description":@"在眠友圈评论帖子",@"reward":@"2分／次"},@{@"name":@"优质评论",@"description":@"评论被点赞",@"reward":@"5分／次"}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 50*Rate_H;
    }
    else
    {
        return 56*Rate_H;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSDictionary *tmpDic = [tableArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 107*Rate_W, 50*Rate_H)];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:14*Rate_H];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = [tmpDic objectForKey:@"name"];
        [cell addSubview:nameLabel];
        
        UIView *lineOneView = [[UIView alloc] initWithFrame:CGRectMake(107*Rate_W, 13*Rate_H, Rate_W, 24*Rate_H)];
        lineOneView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:lineOneView];
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(108*Rate_W, 0, 138*Rate_W, 50*Rate_H)];
        descriptionLabel.textColor = [UIColor whiteColor];
        descriptionLabel.font = [UIFont systemFontOfSize:14*Rate_H];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.text = [tmpDic objectForKey:@"description"];
        [cell addSubview:descriptionLabel];
        
        UIView *lineTwoView = [[UIView alloc] initWithFrame:CGRectMake(247*Rate_W, 13*Rate_H, Rate_W, 24*Rate_H)];
        lineTwoView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:lineTwoView];
        
        UILabel *rewardLabel = [[UILabel alloc] initWithFrame:CGRectMake(248*Rate_W, 0, 107*Rate_W, 50*Rate_H)];
        rewardLabel.textColor = [UIColor whiteColor];
        rewardLabel.font = [UIFont systemFontOfSize:14*Rate_H];
        rewardLabel.textAlignment = NSTextAlignmentCenter;
        rewardLabel.text = [tmpDic objectForKey:@"reward"];
        [cell addSubview:rewardLabel];
    }
    else
    {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 107*Rate_W, 50*Rate_H)];
        nameLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        nameLabel.font = [UIFont systemFontOfSize:12*Rate_H];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = [tmpDic objectForKey:@"name"];
        [cell addSubview:nameLabel];
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(108*Rate_W, 0, 138*Rate_W, 50*Rate_H)];
        descriptionLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        descriptionLabel.font = [UIFont systemFontOfSize:12*Rate_H];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.text = [tmpDic objectForKey:@"description"];
        [cell addSubview:descriptionLabel];
        
        UILabel *rewardLabel = [[UILabel alloc] initWithFrame:CGRectMake(248*Rate_W, 0, 107*Rate_W, 50*Rate_H)];
        rewardLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        rewardLabel.font = [UIFont systemFontOfSize:12*Rate_H];
        rewardLabel.textAlignment = NSTextAlignmentCenter;
        rewardLabel.text = [tmpDic objectForKey:@"reward"];
        [cell addSubview:rewardLabel];
    }
    
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
