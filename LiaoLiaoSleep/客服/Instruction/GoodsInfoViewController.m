//
//  GoodsInfoViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/18.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "GoodsInfoViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface GoodsInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation GoodsInfoViewController
{
    NSArray *infoArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"产品信息"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"产品信息"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"产品信息";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = [UIColor whiteColor];
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
    
    [self addProductInfoView];
}

- (void)addProductInfoView
{
    UIImageView *productInfoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64)];
    [productInfoImageView setImage:[UIImage imageNamed:@"product_info_bg.png"]];
    [self.view addSubview:productInfoImageView];
    
    UITableView *infoTableView=[[UITableView alloc] initWithFrame:CGRectMake(50*Rate_W, 350*Rate_H, 275*Rate_W, 150*Rate_H) style:UITableViewStylePlain];
    infoTableView.scrollEnabled = NO;
    infoTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    infoTableView.tableFooterView=[[UIView alloc] init];
    infoTableView.delegate=self;
    infoTableView.dataSource=self;
    [self.view addSubview:infoTableView];
    
    NSString *vStr = [NSString stringWithFormat:@"版  本  号：V%@",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]];
    infoArray = @[@"上海诺之嘉医疗器械有限公司",@"产品名称：疗疗失眠",@"网       址：www.nuozhijia.com.cn",@"服务热线：400-680-0272", vStr];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30*Rate_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15*Rate_H]];
    cell.textLabel.text=[infoArray objectAtIndex:indexPath.row];
    
    return cell;
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
