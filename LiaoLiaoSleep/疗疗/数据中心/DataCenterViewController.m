//
//  DataCenterViewController.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/4/21.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "DataCenterViewController.h"

#import "Define.h"

#import <UMMobClick/MobClick.h>

#import "ReportShowViewController.h"
#import "TreatDataViewController.h"

#define HeaderViewHeight  317*Ratio
#define FooterViewHeight  SCREENHEIGHT-HeaderViewHeight-49
#define BtnSpaceLeft      45*Ratio
#define BtnSpaceUp        42*Ratio
#define LabelSpaceLeft    34*Ratio
#define LabelSpaceUp      93*Ratio


@interface DataCenterViewController ()

@end

@implementation DataCenterViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    //显示导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Newnav.png"] forBarMetrics:(UIBarMetricsDefault)];
    //设置导航栏半透明效果
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"数据中心"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"数据中心"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"数据中心";
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
    
    [self addFunctionButton];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addFunctionButton
{
    /*
     * 症状按钮 实现
     */
    UIButton *symptomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (SCREENWIDTH-2)/3, (FooterViewHeight-1)/2)];
    symptomBtn.tag = 11;
    symptomBtn.backgroundColor = [UIColor whiteColor];
    symptomBtn.userInteractionEnabled = YES;
    [symptomBtn addTarget:self action:@selector(clickPush:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:symptomBtn];
    
    UIImageView *symptomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BtnSpaceLeft, BtnSpaceUp + 2*Ratio, 36*Ratio, 32*Ratio)];
    
    //创建标题
    UILabel *symptomLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelSpaceLeft, LabelSpaceUp, 58*Ratio, 20*Ratio)];
    symptomLabel.text = @"治疗数据";
    symptomLabel.userInteractionEnabled = YES;
    symptomLabel.font = [UIFont systemFontOfSize:14*Ratio];
    symptomLabel.textAlignment = NSTextAlignmentCenter;
    [symptomBtn addSubview:symptomLabel];
    //按钮设置
    symptomImageView.image = [UIImage imageNamed:@"治疗数据"];
    [symptomBtn addSubview:symptomImageView];
    
    /*
     * 疗程按钮实现
     */
    UIButton *courseBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH-2)/3, 0, (SCREENWIDTH-2)/3, (FooterViewHeight-1)/2)];
    courseBtn.tag = 12;
    courseBtn.backgroundColor = [UIColor whiteColor];
    courseBtn.userInteractionEnabled = YES;
    [courseBtn addTarget:self action:@selector(clickPush:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:courseBtn];
    
    UIImageView *courseImageV = [[UIImageView alloc] initWithFrame:CGRectMake(BtnSpaceLeft, BtnSpaceUp - 2*Ratio, 36*Ratio, 40*Ratio)];
    
    //创建标题
    UILabel *courselabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelSpaceLeft, LabelSpaceUp, 58*Ratio, 20*Ratio)];
    courselabel.text = @"评估数据";
    courselabel.userInteractionEnabled = YES;
    courselabel.font = [UIFont systemFontOfSize:14*Ratio];
    courselabel.textAlignment = NSTextAlignmentCenter;
    [courseBtn addSubview:courselabel];
    //按钮设置
    courseImageV.image = [UIImage imageNamed:@"评估数据"];
    [courseBtn addSubview:courseImageV];
}

- (void)clickPush:(UIButton *)sender
{
    if (sender.tag == 11)
    {
        //跳转治疗数据
        TreatDataViewController *treatData = [[TreatDataViewController alloc] initWithNibName:@"TreatDataViewController" bundle:nil];
        [self.navigationController pushViewController:treatData animated:YES];
    }
    else if (sender.tag == 12)
    {
        //跳转评估数据
        ReportShowViewController *reportShowVC = [[ReportShowViewController alloc] init];
        [self.navigationController pushViewController:reportShowVC animated:YES];
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
