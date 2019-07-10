//
//  SoftwareOptionViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/20.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "SoftwareOptionViewController.h"
#import "SoftwareAnswerViewController.h"

@interface SoftwareOptionViewController ()

@end

@implementation SoftwareOptionViewController
{
    UITableView *softwareTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Software operation";
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
    
    softwareTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:UITableViewStylePlain];
    //自动计算cell高度
    softwareTableView.estimatedRowHeight = 100.0f;
    softwareTableView.rowHeight = UITableViewAutomaticDimension;
    
    softwareTableView.tableFooterView = [[UIView alloc] init];
    softwareTableView.delegate = self;
    softwareTableView.dataSource = self;
    
    [self.view addSubview:softwareTableView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _softwareOptionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"ConfigRequire";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [[_softwareOptionArray objectAtIndex:indexPath.row] objectForKey:@"Question"];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SoftwareAnswerViewController *softwareAnswer = [[SoftwareAnswerViewController alloc] init];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"回答";
    [temporaryBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    softwareAnswer.questionIndex = indexPath.row;
    softwareAnswer.answerDic = [_softwareOptionArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:softwareAnswer animated:YES];
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
