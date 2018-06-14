//
//  AttentionViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/25.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "AttentionViewController.h"
#import "AttentionDetailViewController.h"

@interface AttentionViewController ()

@end

@implementation AttentionViewController
{
    NSArray *attentionArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Precautions";
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
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"AttentionList" ofType:@"plist"];
    attentionArray=[NSArray arrayWithContentsOfFile:plistPath];
    
    _attentionTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT/2) style:UITableViewStylePlain];
    //自动计算cell高度
    _attentionTableView.estimatedRowHeight = 100.0f;
    _attentionTableView.rowHeight = UITableViewAutomaticDimension;
    
    [_attentionTableView setTableFooterView:[[UIView alloc] init]];
    _attentionTableView.delegate=self;
    _attentionTableView.dataSource=self;
    
    [self.view addSubview:_attentionTableView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return attentionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"attentionTableViewCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text=[[attentionArray objectAtIndex:indexPath.row] objectForKey:@"question"];
    cell.textLabel.font=[UIFont systemFontOfSize:18];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到配置要求问题界面
    AttentionDetailViewController *attentionDetail=[[AttentionDetailViewController alloc] init];
    
    attentionDetail.index=indexPath.row;
    attentionDetail.questionAndAnswer=[attentionArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:attentionDetail animated:YES];
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
