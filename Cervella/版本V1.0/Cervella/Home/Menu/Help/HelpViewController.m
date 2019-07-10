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
#import "MethodViewController.h"
#import "PrincipleViewController.h"
#import "AttentionViewController.h"
#import "ProductInfoViewController.h"
#import "ShowLinkViewController.h"

#import "WebViewController.h"
#import "AboutCervellaViewController.h"

@interface HelpViewController ()
@property (nonatomic, strong) UILabel *deviceLab;
@end

@implementation HelpViewController
{
    
    NSArray *helpArray;

    NSArray *configRequireArray;
    NSArray *clinicalUseArray;
    NSArray *softwareOptionArray;
    NSArray *commonProArray;
    NSArray *relatedConsumArray;
    
    BluetoothInfo *_bluetoothInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.title = @"Help";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent=YES;
    
//    UILabel *titleLab = [[UILabel alloc] init];
//    titleLab.frame = CGRectMake(0, 0, 44.0, 100);
//    titleLab.text = @"Help";
//    titleLab.textColor = [UIColor whiteColor];
//    UIBarButtonItem *titleBtnItem = [[UIBarButtonItem alloc] initWithCustomView:titleLab];
    
    
    //添加返回按钮
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    backLogin.frame = CGRectMake(12, 30, 44, 100);
    [backLogin setTitle:@"Help" forState:UIControlStateNormal];
    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    
    [self.view addSubview:self.deviceLab];
    
    if (self.bluetoothInfo.deviceName) {
        self.deviceLab.hidden = NO;
        self.deviceLab.text = [NSString stringWithFormat:@"Cervella Serial Number:%@",self.bluetoothInfo.deviceName];
    } else {
        self.deviceLab.hidden = YES;
    }

    
    _helpTableView.delegate=self;
    _helpTableView.dataSource=self;
    
    helpArray = @[@"Quick Start Guide",@"Owner’s Manual",@"Precautions",@"FAQs",@"Operation",@"Consumables and Accessories Ordering",@"About Cervella"];

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
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"HelpTableViewCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = [helpArray objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        
        MethodViewController *vc = [[MethodViewController alloc] init];
        vc.title = helpArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cervella.us/manual"]];
    }
    else if (indexPath.row==2)
    {
        CommonProViewController *commonPro=[[CommonProViewController alloc] init];
        commonPro.title = helpArray[indexPath.row];
        NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"AttentionList" ofType:@"plist"];
        commonPro.commonProArray=[NSArray arrayWithContentsOfFile:plistPath];
        [self.navigationController pushViewController:commonPro animated:YES];
    }
    else if (indexPath.row==3)
    {
        CommonProViewController *commonPro=[[CommonProViewController alloc] init];
        commonPro.title = helpArray[indexPath.row];
        commonPro.commonProArray=softwareOptionArray;
        [self.navigationController pushViewController:commonPro animated:YES];
    }
    else if (indexPath.row==4)
    {
        CommonProViewController *commonPro=[[CommonProViewController alloc] init];
        commonPro.title = helpArray[indexPath.row];
        commonPro.commonProArray=commonProArray;
        [self.navigationController pushViewController:commonPro animated:YES];
    }
    else if (indexPath.row==5)
    {
//        ShowLinkViewController *vc = [[ShowLinkViewController alloc] init];
//        vc.title = helpArray[indexPath.row];
//        vc.linkStr = @"https://cervella.us/shop";
//        [self.navigationController pushViewController:vc animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cervella.us/shop"]];

    }
    else if (indexPath.row==6)
    {
        AboutCervellaViewController *vc = [[AboutCervellaViewController alloc] init];
        vc.title = helpArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UILabel *)deviceLab {
    if (!_deviceLab) {
        _deviceLab = [[UILabel alloc] init];
        _deviceLab.frame = CGRectMake(0,
                                      SCREENHEIGHT- 40,
                                      SCREENWIDTH,
                                      30);
        _deviceLab.textAlignment = NSTextAlignmentCenter;
        _deviceLab.textColor = [UIColor grayColor];
        _deviceLab.font = [UIFont systemFontOfSize:14];
    }
    return _deviceLab;
}

- (BluetoothInfo *)bluetoothInfo {
    //从数据库读取之前绑定设备
    _bluetoothInfo = nil;
    DataBaseOpration *dataBaseOpration = [[DataBaseOpration alloc] init];
    NSArray *bluetoothInfoArray=[dataBaseOpration getBluetoothDataFromDataBase];
    
    if (bluetoothInfoArray.count>0)
    {
        _bluetoothInfo = [bluetoothInfoArray objectAtIndex:0];
    }
    [dataBaseOpration closeDataBase];
    return _bluetoothInfo;
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
