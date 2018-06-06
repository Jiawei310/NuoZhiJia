//
//  DateChooseViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/1/12.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "DateChooseViewController.h"

#import "Define.h"

@interface DateChooseViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *startDateLabel;
@property (nonatomic, strong) UILabel *endDateLabel;

@end

@implementation DateChooseViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    
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
    
    [self createPartOneView];
    [self createPartTwoView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createPartOneView
{
    UILabel *label_One = [[UILabel alloc] initWithFrame:CGRectMake(20*Ratio_NAV_W, 10*Ratio_NAV_H, 150*Ratio_NAV_W, 20*Ratio_NAV_H)];
    label_One.textColor = [UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6B/255.0 alpha:1];
    label_One.font = [UIFont systemFontOfSize:14];
    label_One.text = @"请选择数据显示范围：";
    [self.view addSubview:label_One];
    
    UIView *view_One = [[UIView alloc] initWithFrame:CGRectMake(0, 40*Ratio_NAV_H, 375*Ratio_NAV_W, 80*Ratio_NAV_H)];
    view_One.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view_One];
    
    UIButton *btn_One = [[UIButton alloc] initWithFrame:CGRectMake(20*Ratio_NAV_W, 20*Ratio_NAV_H, 110*Ratio_NAV_W, 40*Ratio_NAV_H)];
    btn_One.tag = 1;
    [btn_One setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
    [btn_One setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_One setTitle:@"近三个月" forState:UIControlStateNormal];
    btn_One.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn_One addTarget:self action:@selector(selectDateRange:) forControlEvents:UIControlEventTouchUpInside];
    [view_One addSubview:btn_One];
    
    UIButton *btn_Two = [[UIButton alloc] initWithFrame:CGRectMake(135*Ratio_NAV_W, 20*Ratio_NAV_H, 110*Ratio_NAV_W, 40*Ratio_NAV_H)];
    btn_Two.tag = 2;
    [btn_Two setBackgroundImage:[UIImage imageNamed:@"screen_btn_notselected_bg"] forState:UIControlStateNormal];
    [btn_Two setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    [btn_Two setTitle:@"近半年" forState:UIControlStateNormal];
    btn_Two.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn_Two addTarget:self action:@selector(selectDateRange:) forControlEvents:UIControlEventTouchUpInside];
    [view_One addSubview:btn_Two];
    
    UIButton *btn_Three = [[UIButton alloc] initWithFrame:CGRectMake(250*Ratio_NAV_W, 20*Ratio_NAV_H, 110*Ratio_NAV_W, 40*Ratio_NAV_H)];
    btn_Three.tag = 3;
    [btn_Three setBackgroundImage:[UIImage imageNamed:@"screen_btn_notselected_bg"] forState:UIControlStateNormal];
    [btn_Three setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    [btn_Three setTitle:@"近一年" forState:UIControlStateNormal];
    btn_Three.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn_Three addTarget:self action:@selector(selectDateRange:) forControlEvents:UIControlEventTouchUpInside];
    [view_One addSubview:btn_Three];
}

- (void)selectDateRange:(UIButton *)sender
{
    
}

- (void)createPartTwoView
{
    UILabel *label_One = [[UILabel alloc] initWithFrame:CGRectMake(20*Ratio_NAV_W, 130*Ratio_NAV_H, 115*Ratio_NAV_W, 20*Ratio_NAV_H)];
    label_One.textColor = [UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6B/255.0 alpha:1];
    label_One.font = [UIFont systemFontOfSize:14];
    label_One.text = @"自定义日期范围：";
    [self.view addSubview:label_One];
    
    UITableView *dateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 161*Ratio_NAV_H, 375*Ratio_NAV_W, 100*Ratio_NAV_H)];
    dateTableView.backgroundColor = [UIColor whiteColor];
    dateTableView.delegate = self;
    dateTableView.dataSource = self;
    [self.view addSubview:dateTableView];
    
    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(22*Ratio_NAV_W, 532*Ratio_NAV_H, 331*Ratio_NAV_W, 50*Ratio_NAV_H)];
    [finishBtn setBackgroundImage:[UIImage imageNamed:@"signin_btn_bg1"] forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(completeSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
}

- (void)completeSelect
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Ratio_NAV_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"DateChooseViewCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    if(indexPath.row == 0)
    {
        cell.textLabel.textColor = [UIColor colorWithRed:0x91/255.0 green:0x9C/255.0 blue:0x9F/255.0 alpha:1];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.text = @"从";
        
        _startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Ratio_W, 0, 227*Ratio_W, 50*Ratio_NAV_H)];
        _startDateLabel.textColor = [UIColor colorWithRed:0x91/255.0 green:0x9C/255.0 blue:0x9F/255.0 alpha:1];
        _startDateLabel.font = [UIFont systemFontOfSize:16];
        _startDateLabel.textAlignment = NSTextAlignmentRight;
        _startDateLabel.text = @"2016年6月20日";
        [cell addSubview:_startDateLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.textColor = [UIColor colorWithRed:0x91/255.0 green:0x9C/255.0 blue:0x9F/255.0 alpha:1];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.text = @"至";
        
        _startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Ratio_W, 0, 227*Ratio_W, 50*Ratio_NAV_H)];
        _startDateLabel.textColor = [UIColor colorWithRed:0x91/255.0 green:0x9C/255.0 blue:0x9F/255.0 alpha:1];
        _startDateLabel.font = [UIFont systemFontOfSize:16];
        _startDateLabel.textAlignment = NSTextAlignmentRight;
        _startDateLabel.text = @"2016年9月20日";
        [cell addSubview:_startDateLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
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
