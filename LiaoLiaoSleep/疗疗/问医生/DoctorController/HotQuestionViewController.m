//
//  HotQuestionViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/3/10.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "HotQuestionViewController.h"

#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface HotQuestionViewController ()

@end

@implementation HotQuestionViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"热门问题"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"热门问题"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //视图控制器名称
    self.navigationItem.title = @"热门问题";
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    [self createView];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createView
{
    UIScrollView *resultScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 603*Rate_NAV_H)];
    resultScrollView.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    [self.view addSubview:resultScrollView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 20*Rate_NAV_H, 345*Rate_NAV_W, 25*Rate_NAV_H)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20*Rate_NAV_H];
    titleLabel.text = [_hotQuestionDic objectForKey:@"title"];
    [resultScrollView addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 70*Rate_NAV_H, 345*Rate_NAV_W, 260*Rate_NAV_H)];
    contentLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    contentLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    contentLabel.numberOfLines = 0;
    //设置行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    NSDictionary *dic = @{NSKernAttributeName:@1.5f, NSParagraphStyleAttributeName:paragraphStyle};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:[_hotQuestionDic objectForKey:@"content"] attributes:dic];
    contentLabel.attributedText = attributeStr;
    CGSize contentLabelSize = [contentLabel sizeThatFits:CGSizeMake(345*Ratio_W, MAXFLOAT)];
    contentLabel.frame = CGRectMake(15*Rate_NAV_W, 70*Rate_NAV_H, 345*Rate_NAV_W, contentLabelSize.height);
    [resultScrollView addSubview:contentLabel];
    
    if (contentLabelSize.height + 70*Rate_NAV_W > SCREENHEIGHT - 64)
    {
        resultScrollView.contentSize = CGSizeMake(SCREENWIDTH, contentLabelSize.height + 70*Rate_NAV_W);
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
