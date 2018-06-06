//
//  MoreFunctionViewController.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/4/21.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "MoreFunctionViewController.h"

#import "Define.h"
#import "DataBaseOpration.h"
#import <UMMobClick/MobClick.h>
#import "LiaoLiaoDiaryViewController.h"
#import "SetNoticeViewController.h"
#import "SleepCircleViewController.h"

#define HeaderViewHeight  317*Ratio
#define FooterViewHeight  SCREENHEIGHT-HeaderViewHeight-49
#define BtnSpaceLeft      45*Ratio
#define BtnSpaceUp        42*Ratio
#define LabelSpaceLeft    34*Ratio
#define LabelSpaceUp      93*Ratio

@interface MoreFunctionViewController ()

@property (nonatomic,copy) NSMutableArray *treatmentArray; //疗程数据数组

@end

@implementation MoreFunctionViewController

#pragma mark -- 控制器将要出现时，隐藏tabBar、导航栏
-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    //显示导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Newnav.png"] forBarMetrics:(UIBarMetricsDefault)];
    //设置导航栏半透明效果
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"更多功能"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"更多功能"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"更多功能";
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
    
    [self prepareData];
    
    [self addFunctionButton];
    
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(treatmentChange:) name:@"StartLiaoLiao" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(treatmentChange:) name:@"SetTreatment" object:nil];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//数据准备
-(void)prepareData
{
    //读取本地数据(所有疗程信息)
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSArray *allTreatment = [dbOpration getTreatmentDataFromDataBase];
    [dbOpration closeDataBase];
    //将取出的疗程数据进行判断，只需要自己疗程的数据
    if (allTreatment.count > 0)
    {
        _treatmentArray = [NSMutableArray array];
        for (TreatmentInfo *tmp in allTreatment)
        {
            if ([tmp.PatientID isEqualToString:[PatientInfo shareInstance].PatientID])
            {
                [_treatmentArray addObject:tmp];
            }
        }
    }
}

//添加新的疗程到数组中
- (void)treatmentChange:(NSNotification *)notification
{
    if (_treatmentArray == nil)
    {
        _treatmentArray = [NSMutableArray array];
    }
    [_treatmentArray addObject:notification.userInfo[@"TreatmentInfo"]];
}

- (void)addFunctionButton
{
    /*
     * 症状按钮 实现
     */
    UIButton *symptomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (SCREENWIDTH - 2)/3, (FooterViewHeight - 1)/2)];
    symptomBtn.tag = 11;
    symptomBtn.backgroundColor = [UIColor whiteColor];
    symptomBtn.userInteractionEnabled = YES;
    [symptomBtn addTarget:self action:@selector(clickPush:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:symptomBtn];
    
    UIImageView *symptomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BtnSpaceLeft, BtnSpaceUp, 36*Ratio, 37*Ratio)];
    
    //创建标题
    UILabel *symptomLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelSpaceLeft, LabelSpaceUp, 58*Ratio, 20*Ratio)];
    symptomLabel.text = @"疗疗日记";
    symptomLabel.userInteractionEnabled = YES;
    symptomLabel.font = [UIFont systemFontOfSize:14*Ratio];
    symptomLabel.textAlignment = NSTextAlignmentCenter;
    [symptomBtn addSubview:symptomLabel];
    //按钮设置
    symptomImageView.image = [UIImage imageNamed:@"icon_schedule"];
    [symptomBtn addSubview:symptomImageView];
    
    /*
     * 咨询按钮 实现
     */
    UIButton *consultBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH-2)/3 + 1, 0, (SCREENWIDTH-2)/3, (FooterViewHeight-1)/2)];
    consultBtn.tag = 12;
    consultBtn.backgroundColor = [UIColor whiteColor];
    consultBtn.userInteractionEnabled = YES;
    [consultBtn addTarget:self action:@selector(clickPush:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:consultBtn];
    
    UIImageView *consultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BtnSpaceLeft, BtnSpaceUp, 36*Ratio, 37*Ratio)];
    
    //创建标题
    UILabel *consultLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelSpaceLeft, LabelSpaceUp, 58*Ratio, 20*Ratio)];
    consultLabel.text = @"资讯";
    consultLabel.userInteractionEnabled = YES;
    consultLabel.font = [UIFont systemFontOfSize:14*Ratio];
    consultLabel.textAlignment = NSTextAlignmentCenter;
    [consultBtn addSubview:consultLabel];
    //按钮设置
    consultImageView.image = [UIImage imageNamed:@"资讯"];
    [consultBtn addSubview:consultImageView];
}

- (void)clickPush:(UIButton *)sender
{
    if (sender.tag == 11)
    {
        if ([self judgeCourseOfTreatment])
        {
            LiaoLiaoDiaryViewController *diaryVC = [[LiaoLiaoDiaryViewController alloc] init];
            diaryVC.courseArray = _treatmentArray;
            [self.navigationController pushViewController:diaryVC animated:YES];
        }
        else
        {
            SetNoticeViewController *setNoticeVC = [[SetNoticeViewController alloc] init];
            setNoticeVC.VCType = @"设置疗程";
            [self.navigationController pushViewController:setNoticeVC animated:YES];
        }
    }
    else if (sender.tag == 12)
    {
        SleepCircleViewController *sleepCircleVC = [[SleepCircleViewController alloc] init];
        [self.navigationController pushViewController:sleepCircleVC animated:YES];
    }
}

/*
 * 判断当前日期是否在疗程内
 * 1.如果在疗程内则显示该疗程的治疗清楚
 * 2.如果不在疗程内显示设置疗程的按钮
 */
- (BOOL)judgeCourseOfTreatment
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *nowDate = [NSDate date];
    NSString *nowDateStr = [df stringFromDate:nowDate];
    
    if (_treatmentArray.count > 0)
    {
        TreatmentInfo *treatmentDic = [_treatmentArray objectAtIndex:_treatmentArray.count-1];
        NSString *treatmentEndDateStr = treatmentDic.EndDate;
        NSInteger numOne = [self dateTimeDifferenceWithStartTime:nowDateStr endTime:treatmentEndDateStr];
        
        if (numOne < 0)//表示当前日期不在最近疗程内
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

/**
 * 开始到结束的时间差的天数
 */
- (NSInteger)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    NSInteger day = value / (24 * 3600);
    return day;
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
