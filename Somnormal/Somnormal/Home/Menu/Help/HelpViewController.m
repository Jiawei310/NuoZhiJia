//
//  HelpViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/7.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "HelpViewController.h"
#import "ConfigRequireViewController.h"
#import "ClinicalUseViewController.h"
#import "SoftwareOptionViewController.h"
#import "CommonProViewController.h"
#import "RelatedConsumViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
{
    NSArray *helpArray;
    
    NSArray *configRequireArray;
    NSArray *clinicalUseArray;
    NSArray *softwareOptionArray;
    NSArray *commonProArray;
    NSArray *relatedConsumArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Help";
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
    
    _helpTableView.contentInset=UIEdgeInsetsMake(-64, 0, 0, 0);
    _helpTableView.delegate=self;
    _helpTableView.dataSource=self;
    
    helpArray=@[@"Configuration requirements",@"Clinical use",@"Software opration",@"FAQ",@"Related consumables"];
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"HelpInfo" ofType:@"plist"];
    NSDictionary *helpInfoDic=[[NSDictionary alloc] initWithContentsOfFile:plistPath];
    configRequireArray=[helpInfoDic objectForKey:@"配置要求"];
    clinicalUseArray=[helpInfoDic objectForKey:@"临床使用"];
    softwareOptionArray=[helpInfoDic objectForKey:@"软件操作"];
    commonProArray=[helpInfoDic objectForKey:@"常见问题"];
    relatedConsumArray=[helpInfoDic objectForKey:@"相关耗材"];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return helpArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"HelpTableViewCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = [helpArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        //跳转到配置要求问题界面
        ConfigRequireViewController *configRequire=[[ConfigRequireViewController alloc] init];
        
        configRequire.configRequireArray=configRequireArray;
        [self.navigationController pushViewController:configRequire animated:YES];
    }
    else if (indexPath.row == 1)
    {
        //跳转到临床使用问题界面
        ClinicalUseViewController *clinicalUse=[[ClinicalUseViewController alloc] init];
        
        clinicalUse.clinicalUseArray=clinicalUseArray;
        [self.navigationController pushViewController:clinicalUse animated:YES];
    }
    else if (indexPath.row==2)
    {
        //跳转到软件操作问题界面
        SoftwareOptionViewController *softwareOption=[[SoftwareOptionViewController alloc] init];
        
        softwareOption.softwareOptionArray=softwareOptionArray;
        [self.navigationController pushViewController:softwareOption animated:YES];
    }
    else if (indexPath.row==3)
    {
        //跳转到常见问题问题界面
        CommonProViewController *commonPro=[[CommonProViewController alloc] init];
        
        commonPro.commonProArray=commonProArray;
        [self.navigationController pushViewController:commonPro animated:YES];
    }
    else if (indexPath.row==4)
    {
        //跳转到相关耗材问题界面
        RelatedConsumViewController *relatedConsum=[[RelatedConsumViewController alloc] init];
        
        relatedConsum.relatedConsumArray=relatedConsumArray;
        [self.navigationController pushViewController:relatedConsum animated:YES];
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
