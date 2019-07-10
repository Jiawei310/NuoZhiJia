//
//  AboutViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/1.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "AboutViewController.h"
#import "MethodViewController.h"
#import "PrincipleViewController.h"
#import "AttentionViewController.h"
#import "ProductInfoViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
{
    NSArray *aboutArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"About";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent=YES;
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
    
    _aboutTableView.contentInset=UIEdgeInsetsMake(-64, 0, 0, 0);
    _aboutTableView.tableFooterView=[[UIView alloc] init];
    _aboutTableView.delegate=self;
    _aboutTableView.dataSource=self;
    
    aboutArray=@[@"Use Instructions",@"Treatment Principle",@"Precautions",@"Product Information"];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aboutArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"AboutTableViewCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    if (SCREENWIDTH==320)
    {
        cell.textLabel.font=[UIFont systemFontOfSize:18];
    }
    else if (SCREENWIDTH==375)
    {
        cell.textLabel.font=[UIFont systemFontOfSize:20];
    }
    else
    {
        cell.textLabel.font=[UIFont systemFontOfSize:22];
    }
    cell.textLabel.text=[aboutArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        //跳转使用方法界面
        MethodViewController *method=[[MethodViewController alloc] init];
        
        [self.navigationController pushViewController:method animated:YES];
    }
    else if (indexPath.row==1)
    {
        //跳转治疗原理界面
        PrincipleViewController *principle=[[PrincipleViewController alloc] init];
        
        [self.navigationController pushViewController:principle animated:YES];
    }
    else if (indexPath.row==2)
    {
        //跳转注意事项界面
        AttentionViewController *attention=[[AttentionViewController alloc] init];
        
        [self.navigationController pushViewController:attention animated:YES];
    }
    else if (indexPath.row==3)
    {
        //跳转产品信息界面
        ProductInfoViewController *productInfo=[[ProductInfoViewController alloc] init];
        
        [self.navigationController pushViewController:productInfo animated:YES];
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
