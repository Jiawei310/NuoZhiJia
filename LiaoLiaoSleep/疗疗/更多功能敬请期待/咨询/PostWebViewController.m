//
//  PostWebViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/2/8.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "PostWebViewController.h"
#import <UMMobClick/MobClick.h>
#import "Define.h"

@interface PostWebViewController ()

@end

@implementation PostWebViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"资讯详情"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"资讯详情"];
}

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
    
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, SCREENHEIGHT)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_postURL]]];
    [self.view addSubview:webView];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
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
