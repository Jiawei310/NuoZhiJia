//
//  ConfigRequireViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/20.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "ConfigRequireViewController.h"
#import "ConfigAnswerViewController.h"

@interface ConfigRequireViewController ()

@end

@implementation ConfigRequireViewController
{
    UITableView *configTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Configuration requirements";
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
    
    configTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:UITableViewStylePlain];
    //自动计算cell高度
    configTableView.estimatedRowHeight = 100.0f;
    configTableView.rowHeight = UITableViewAutomaticDimension;
    
    configTableView.tableFooterView=[[UIView alloc] init];
    configTableView.delegate=self;
    configTableView.dataSource=self;
    
    [self.view addSubview:configTableView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _configRequireArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"ConfigRequire";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text=[[_configRequireArray objectAtIndex:indexPath.row] objectForKey:@"Question"];
    cell.textLabel.font=[UIFont systemFontOfSize:18];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfigAnswerViewController *configAnswer=[[ConfigAnswerViewController alloc] init];
    
    configAnswer.answerDic=[_configRequireArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:configAnswer animated:YES];
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
