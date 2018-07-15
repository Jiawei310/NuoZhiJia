//
//  MethodViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/25.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "MethodViewController.h"

@interface MethodViewController ()

@end

@implementation MethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    UILabel *titleLab = [[UILabel alloc] init];
//    titleLab.frame = CGRectMake(0, 0, 44.0, 100);
//    titleLab.text = self.title;
//    titleLab.textColor = [UIColor whiteColor];
//    UIBarButtonItem *titleBtnItem = [[UIBarButtonItem alloc] initWithCustomView:titleLab];
//
//    self.title = nil;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //添加返回按钮
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    
    backLogin.frame = CGRectMake(12, 30, 44, 100);
    [backLogin setTitle:self.title forState:UIControlStateNormal];
    self.title = nil;

    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 3)];
    _scrollView.pagingEnabled=YES;
    _scrollView.contentSize=CGSizeMake(SCREENWIDTH*6, 0);
    _scrollView.contentOffset=CGPointMake(0, 0);
    _scrollView.bounces=NO;
    
    UIImage *image = [UIImage imageNamed:@"use1.png"];
    //image.size.height *SCREENWIDTH/image.size.width
    CGFloat h = SCREENHEIGHT - 67;
    if (SCREENHEIGHT == 812) {
        h = SCREENHEIGHT - 88;
    }
    
    UIImageView  *imageview_one=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, h)];
    [imageview_one setImage:image];
    UIImageView *imageview_two=[[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, h)];
    image = [UIImage imageNamed:@"use2.png"];
    [imageview_two setImage:image];
    UIImageView *imageview_three=[[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH * 2, 0, SCREENWIDTH, h)];
    image = [UIImage imageNamed:@"use3.png"];
    [imageview_three setImage:image];
    UIImageView  *imageview_foure=[[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH * 3, 0, SCREENWIDTH, h)];
    image = [UIImage imageNamed:@"use4.png"];
    [imageview_foure setImage:image];
    UIImageView *imageview_five=[[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH * 4, 0, SCREENWIDTH, h)];
    image = [UIImage imageNamed:@"use5.png"];
    [imageview_five setImage:image];
    UIImageView *imageview_six=[[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH * 5, 0, SCREENWIDTH, h)];
    image = [UIImage imageNamed:@"use6.png"];
    [imageview_six setImage:image];
    
    [_scrollView addSubview:imageview_one];
    [_scrollView addSubview:imageview_two];
    [_scrollView addSubview:imageview_three];
    [_scrollView addSubview:imageview_foure];
    [_scrollView addSubview:imageview_five];
    [_scrollView addSubview:imageview_six];
    
    [self.view addSubview:_scrollView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
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
