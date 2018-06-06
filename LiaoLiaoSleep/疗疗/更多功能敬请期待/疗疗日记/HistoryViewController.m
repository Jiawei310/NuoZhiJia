//
//  HistoryViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/1/15.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "HistoryViewController.h"
#import "Define.h"

@interface HistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *historyTableView;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    
    _historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 603*Rate_NAV_H) style:UITableViewStylePlain];
    _historyTableView.tableFooterView = [[UIView alloc] init];
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    [self.view addSubview:_historyTableView];
    
    _historyTableView.separatorColor=[UIColor colorWithWhite:0.7 alpha:0.9];
    if ([_historyTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_historyTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_historyTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_historyTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//tableview的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _historyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84*Rate_NAV_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identity=@"History";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSArray *tmpArr = [_historyArray objectAtIndex:indexPath.row];
    NSString *str_One = [[[tmpArr objectAtIndex:0] objectForKey:@"StartDate"] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    NSString *str_Two = [[[tmpArr objectAtIndex:tmpArr.count-1] objectForKey:@"EndDate"] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(13*Rate_NAV_W, 10*Rate_NAV_H, 145*Rate_NAV_W, 20*Rate_NAV_H)];
    dateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    dateLabel.font = [UIFont systemFontOfSize:18];
    dateLabel.text = [NSString stringWithFormat:@"%@-%@",[str_One substringWithRange:NSMakeRange(0, 7)],[str_Two substringWithRange:NSMakeRange(0, 7)]];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:dateLabel];
    
    UILabel *courseLabel = [[UILabel alloc] initWithFrame:CGRectMake(226*Rate_NAV_W, 10*Rate_NAV_H, 57*Rate_NAV_W, 20*Rate_NAV_H)];
    courseLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    courseLabel.font = [UIFont systemFontOfSize:14];
    courseLabel.text = [NSString stringWithFormat:@"%ld个疗程",(unsigned long)tmpArr.count];
    [cell.contentView addSubview:courseLabel];
    
    UILabel *sysmptomLabel = [[UILabel alloc] initWithFrame:CGRectMake(13*Rate_NAV_W, 35*Rate_NAV_H, 280*Rate_NAV_W, 40*Rate_NAV_H)];
    sysmptomLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    sysmptomLabel.font = [UIFont systemFontOfSize:14];
    sysmptomLabel.text = @"主要症状：做噩梦、入睡困难、易醒早醒、呼吸不畅等针状。";
    sysmptomLabel.numberOfLines = 0;
    [cell.contentView addSubview:sysmptomLabel];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //选中那一个cell，跳转到历史数据查看
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
