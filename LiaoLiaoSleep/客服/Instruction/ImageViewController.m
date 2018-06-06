//
//  ImageViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "ImageViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:_imageName];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:_imageName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = _imageName;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
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
    
    [self createImageView];
    // Do any additional setup after loading the view.
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createImageView
{
    if ([_imageName isEqualToString:@"治疗原理"])
    {
        UIImageView * theoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64)];
        [theoryImageView setImage:[UIImage imageNamed:@"cure_theory"]];
        [self.view addSubview:theoryImageView];
    }
    else if ([_imageName isEqualToString:@"使用说明"])
    {
        
        UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64)];
        scrollView.pagingEnabled=YES;
        scrollView.contentSize=CGSizeMake(SCREENWIDTH*5, 0);
        scrollView.contentOffset=CGPointMake(0, 0);
        scrollView.bounces=NO;
        
        CGFloat hightUnit = (SCREENHEIGHT -64)/1688;
        CGFloat width = 748*hightUnit;
        CGFloat x = (SCREENWIDTH - width)/2;
        
        UIImageView  *imageview_one=[[UIImageView alloc] initWithFrame:CGRectMake(x, 0, width, SCREENHEIGHT - 64)];
        [imageview_one setImage:[UIImage imageNamed:@"user1.png"]];
        UIImageView *imageview_two=[[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH + x, 0, width, SCREENHEIGHT - 64)];
        [imageview_two setImage:[UIImage imageNamed:@"user2.png"]];
        UIImageView *imageview_three=[[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH*2 + x, 0, width, SCREENHEIGHT - 64)];
        [imageview_three setImage:[UIImage imageNamed:@"user3.png"]];
        UIImageView  *imageview_foure=[[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH*3 + x, 0, width, SCREENHEIGHT - 64)];
        [imageview_foure setImage:[UIImage imageNamed:@"user4.png"]];
        UIImageView *imageview_five=[[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH*4 + x, 0, width, SCREENHEIGHT - 64)];
        [imageview_five setImage:[UIImage imageNamed:@"user5.png"]];
        
        [scrollView addSubview:imageview_one];
        [scrollView addSubview:imageview_two];
        [scrollView addSubview:imageview_three];
        [scrollView addSubview:imageview_foure];
        [scrollView addSubview:imageview_five];
        
        [self.view addSubview:scrollView];
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
