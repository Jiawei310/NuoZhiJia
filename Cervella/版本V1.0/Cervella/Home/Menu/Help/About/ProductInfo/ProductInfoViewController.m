//
//  ProductInfoViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/25.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "ProductInfoViewController.h"

@interface ProductInfoViewController ()

@end

@implementation ProductInfoViewController
{
    NSArray *infoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Product Information";
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
    
    
    
    UIImageView *productInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64)];
    [productInfoImageView setImage:[UIImage imageNamed:@"product_info_bg.png"]];
    [self.view addSubview:productInfoImageView];
    
    UITableView *infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREENWIDTH/10, SCREENHEIGHT*2/3, SCREENWIDTH*4/5, SCREENHEIGHT*4/5) style:UITableViewStylePlain];
    if (SCREENWIDTH == 320)
    {
        infoTableView.frame = CGRectMake(SCREENWIDTH/15, SCREENHEIGHT*2/3, SCREENWIDTH*13/15, SCREENHEIGHT*4/5);
    }
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTableView.tableFooterView = [[UIView alloc] init];
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    [self.view addSubview:infoTableView];
    
    infoArray = @[@"Neurostyle Pte Ltd",@"Product：Cervella",@"Website：www.Neiro-style.com",@"Hotline：+65 6563 2678",@"Version：V1.0.0.2"];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    cell.textLabel.text = [infoArray objectAtIndex:indexPath.row];
    
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
