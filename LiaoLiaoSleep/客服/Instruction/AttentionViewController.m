//
//  AttentionViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "AttentionViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface AttentionViewController ()

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong)  UIView *firstView;
@property (nonatomic, strong)  UIView *secondView;
@property (nonatomic, strong)  UIView *thirdView;
@property (nonatomic, strong)  UIView *fourthView;

@end

@implementation AttentionViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"注意事项"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"注意事项"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"注意事项";
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
    
    [self getDataFromPlistFile];
    [self createFirstView];
    [self cretaeSecondView];
    [self createThirdView];
    [self createFourthView];
    // Do any additional setup after loading the view.
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//读取plist文件
- (void)getDataFromPlistFile
{
    NSString * strPath = [[NSBundle mainBundle] pathForResource:@"AttentionList" ofType:@"plist"];
    self.dataArr = [[NSArray alloc]initWithContentsOfFile:strPath];
}

- (void)createFirstView
{
    self.firstView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 140*Rate_H)];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(30*Rate_W, 30*Rate_H, SCREENWIDTH - 60*Rate_W, 20*Rate_H)];
    titleLable.text = [self.dataArr[0] objectForKey:@"question"];
    titleLable.font = Attention_QuestionFont;
    [_firstView addSubview:titleLable];
    
    UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(35*Rate_W, CGRectGetMaxY(titleLable.frame) + 5, SCREENWIDTH - 65*Rate_W, 120*Rate_H)];
    contentLable.text = [self.dataArr[0] objectForKey:@"answer"];
    contentLable.numberOfLines = 0;
    contentLable.font = Attention_AnswerFont;
    [_firstView addSubview:contentLable];
    
    [self.view addSubview:_firstView];
}

-(void)cretaeSecondView
{
    self.secondView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_firstView.frame) + 20*Rate_H, SCREENWIDTH, 115*Rate_H)];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(30*Rate_W, 30*Rate_H, SCREENWIDTH - 60*Rate_W, 45*Rate_H)];
    titleLable.numberOfLines = 0;
    titleLable.text = [self.dataArr[1] objectForKey:@"question"];
    titleLable.font = Attention_QuestionFont;
    [_secondView addSubview:titleLable];
    
    UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(35*Rate_W, CGRectGetMaxY(titleLable.frame) + 5, SCREENWIDTH - 65*Rate_W, 70*Rate_H)];
    contentLable.text = [self.dataArr[1] objectForKey:@"answer"];
    contentLable.numberOfLines = 0;
    contentLable.font = Attention_AnswerFont;
    [_secondView addSubview:contentLable];
    
    [self.view addSubview:_secondView];
}

- (void)createThirdView
{
    self.thirdView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_secondView.frame) + 20*Rate_H, SCREENWIDTH, 90*Rate_H)];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(30*Rate_W, 30*Rate_H, SCREENWIDTH - 60*Rate_W, 20*Rate_H)];
    titleLable.text = [self.dataArr[2] objectForKey:@"question"];
    titleLable.font = Attention_QuestionFont;
    [_thirdView addSubview:titleLable];
    
    UILabel *contentLable = [[UILabel alloc] initWithFrame:CGRectMake(35*Rate_W, CGRectGetMaxY(titleLable.frame) + 5, SCREENWIDTH - 65*Rate_W, 70*Rate_H)];
    contentLable.text = [self.dataArr[2] objectForKey:@"answer"];
    contentLable.numberOfLines = 0;
    contentLable.font = Attention_AnswerFont;
    [_thirdView addSubview:contentLable];
    
    [self.view addSubview:_thirdView];
}

- (void)createFourthView
{
    self.fourthView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_thirdView.frame) + 20*Rate_H, SCREENWIDTH, 60*Rate_H)];
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(30*Rate_W, 30*Rate_H, SCREENWIDTH - 60*Rate_W, 20*Rate_H)];
    titleLable.text = [self.dataArr[3] objectForKey:@"question"];
    titleLable.font = Attention_QuestionFont;
    [_fourthView addSubview:titleLable];
    
    UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(35*Rate_W, CGRectGetMaxY(titleLable.frame) + 5, SCREENWIDTH - 65*Rate_W, 40*Rate_H)];
    contentLable.text = [self.dataArr[3] objectForKey:@"answer"];
    contentLable.numberOfLines = 0;
    contentLable.font = Attention_AnswerFont;
    [_fourthView addSubview:contentLable];
    
    [self.view addSubview:_fourthView];
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
