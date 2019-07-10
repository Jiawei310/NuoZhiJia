//
//  SoftwareAnswerViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/20.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "SoftwareAnswerViewController.h"

@interface SoftwareAnswerViewController ()

@end

@implementation SoftwareAnswerViewController
{
    UITableView *softwareAnswerTableView;
    NSArray *questionAndAnswer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Answer";
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
    
    softwareAnswerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:UITableViewStylePlain];
    //自动计算cell高度
    softwareAnswerTableView.estimatedRowHeight = 100.0f;
    softwareAnswerTableView.rowHeight = UITableViewAutomaticDimension;
    
    softwareAnswerTableView.tableFooterView = [[UIView alloc] init];
    softwareAnswerTableView.delegate = self;
    softwareAnswerTableView.dataSource = self;
    
    [self.view addSubview:softwareAnswerTableView];
    
    questionAndAnswer = [NSArray arrayWithObjects:[_answerDic objectForKey:@"Question"],[_answerDic objectForKey:@"Answer"], nil];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return questionAndAnswer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"SoftwareAnswer";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text = [questionAndAnswer objectAtIndex:indexPath.row];
    if (indexPath.row == 1)
    {
        cell.textLabel.textColor=UIColorWithRGBA(20.0f, 80.0f, 200.0f, 0.7f);
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    
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
