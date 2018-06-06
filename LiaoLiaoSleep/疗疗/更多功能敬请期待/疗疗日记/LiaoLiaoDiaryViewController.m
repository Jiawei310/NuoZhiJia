//
//  LiaoLiaoDiaryViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/19.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "LiaoLiaoDiaryViewController.h"
#import "Define.h"

#import "InterfaceModel.h"
#import "DataBaseOpration.h"

#import "TreatmentInfo.h"
#import "SymptomView.h"
#import "CourseView.h"
#import <UMMobClick/MobClick.h>
#import "MoreFunctionViewController.h"
#import "SetTreatmentViewController.h"
#import "HistoryViewController.h"

@interface LiaoLiaoDiaryViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollV;
/*症状｜疗程 悬浮按钮*/
@property (nonatomic, strong) UIButton *symptomBtn;
@property (nonatomic, strong) UIButton *courseBtn;

@property (nonatomic, copy) NSArray *courseTreatArray;    //疗程治疗数据
@property (nonatomic, copy) NSArray *symptomFragmentArray;//碎片化数据

@end

@implementation LiaoLiaoDiaryViewController
{
    InterfaceModel *interfaceModel;  //接口类的全局变量
}

- (void)viewWillAppear:(BOOL)animated
{
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"疗疗日记"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"疗疗日记"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"疗疗日记";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
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
    
    //从本地获取数据
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    _courseTreatArray = [dbOpration getTreatDataFromDataBase];
    _symptomFragmentArray = [dbOpration getFragmentDataFromDataBase];
    [dbOpration closeDataBase];
    
    //显示症状的View
    SymptomView *symptomV = [[SymptomView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 563*Rate_NAV_H) andDateArray:_courseArray andFragmentArray:_symptomFragmentArray];
    [self.view addSubview:symptomV];
    [self suspendSymptomAndCourseBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToSetTreatmentVC:) name:@"pushToSetTreatmentVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToHistoryVC:) name:@"pushToHistoryVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTreatment:) name:@"AlertTreatment" object:nil];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    MoreFunctionViewController *moreVC = [[MoreFunctionViewController alloc] init];
    for (UIViewController *controller in self.navigationController.viewControllers)//遍历
    {
        if ([controller isKindOfClass:[moreVC class]])//这里判断是否为你想要跳转的页面
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)updateTreatment:(NSNotification *)notification
{
    TreatmentInfo *tmpTreatment = notification.userInfo[@"TreatmentInfo"];
    for (int i = 0; i < _courseArray.count; i++)
    {
        TreatmentInfo *tmp = [_courseArray objectAtIndex:i];
        if ([tmp.TreatmentID isEqualToString:tmpTreatment.TreatmentID])
        {
            tmp.GetUpTime = tmpTreatment.GetUpTime;
            tmp.TreatTimeOne = tmpTreatment.TreatTimeOne;
            tmp.TreatTimeTwo = tmpTreatment.TreatTimeTwo;
            tmp.GoToBedTime = tmpTreatment.GoToBedTime;
        }
    }
}

//症状｜疗程悬浮按钮
- (void)suspendSymptomAndCourseBtn
{
    UIView *suspendView = [[UIView alloc] initWithFrame:CGRectMake(135*Rate_NAV_W, 571*Rate_NAV_H, 105*Rate_NAV_W, 21*Rate_NAV_H)];
    [self.view addSubview:suspendView];
    [self.view bringSubviewToFront:suspendView];
    
    _symptomBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _symptomBtn.frame = CGRectMake(0, 0, 38*Rate_NAV_W, 21*Rate_NAV_H);
    _symptomBtn.tag = 0;
    [_symptomBtn setTitleColor:[UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1] forState:UIControlStateNormal];
    _symptomBtn.titleLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    [_symptomBtn setTitle:@"症状" forState:UIControlStateNormal];
    [_symptomBtn addTarget:self action:@selector(viewChange:) forControlEvents:UIControlEventTouchUpInside];
    [suspendView addSubview:_symptomBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(52*Rate_NAV_W, 3.5*Rate_NAV_H, Rate_NAV_W, 14*Rate_NAV_H)];
    lineView.backgroundColor = [UIColor colorWithRed:0xDD/255.0 green:0xDD/255.0 blue:0xDD/255.0 alpha:1];
    [suspendView addSubview:lineView];
    
    _courseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _courseBtn.frame = CGRectMake(67*Rate_NAV_W, 0, 38*Rate_NAV_W, 21*Rate_NAV_H);
    _courseBtn.tag = 1;
    [_courseBtn setTitleColor:[UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1] forState:UIControlStateNormal];
    _courseBtn.titleLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    [_courseBtn setTitle:@"疗程" forState:UIControlStateNormal];
    [_courseBtn addTarget:self action:@selector(viewChange:) forControlEvents:UIControlEventTouchUpInside];
    [suspendView addSubview:_courseBtn];
}

- (void)viewChange:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        [_symptomBtn setTitleColor:[UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1] forState:UIControlStateNormal];
        [_courseBtn setTitleColor:[UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1] forState:UIControlStateNormal];
        
        //移除疗程的View
        
        //显示症状的View
        SymptomView *symptomV = [[SymptomView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 563*Rate_NAV_H) andDateArray:_courseArray andFragmentArray:_symptomFragmentArray];
        [self.view addSubview:symptomV];
    }
    else
    {
        [_symptomBtn setTitleColor:[UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1] forState:UIControlStateNormal];
        [_courseBtn setTitleColor:[UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1] forState:UIControlStateNormal];
        
        //移除症状的View
        
        //显示疗程的View
        CourseView *courseV = [[CourseView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 563*Rate_NAV_H) andDateArray:_courseArray andtreatInfoArray:_courseTreatArray];
        [self.view addSubview:courseV];
    }
}

- (void)pushToSetTreatmentVC:(NSNotification *)notification
{
    TreatmentInfo *tmpInfo = notification.userInfo[@"treatmentIfo"];
    
    SetTreatmentViewController * setVC = [[SetTreatmentViewController alloc] init];
    setVC.VCType = @"修改疗程";
    setVC.treatmentInfo = tmpInfo;
    [self.navigationController pushViewController:setVC animated:YES];
}

- (void)pushToHistoryVC:(NSNotification *)array
{
    NSArray *myHistoryArray = array.userInfo[@"arrayOne"];
    HistoryViewController *historyVC = [[HistoryViewController alloc] init];
    historyVC.historyArray = myHistoryArray;
    [self.navigationController pushViewController:historyVC animated:YES];
}

//将疗程数据跟本地数据同步
- (void)localDataSynchronization:(NSArray *)valueArr
{
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSArray *treatmentArr = [dbOpration getTreatmentDataFromDataBase];
    if (treatmentArr.count == 0 || treatmentArr == nil)
    {
        TreatmentInfo *tmpTreatment = [[TreatmentInfo alloc] init];
        for (int i = 0; i < valueArr.count; i++)
        {
            tmpTreatment.PatientID = [[valueArr objectAtIndex:i] objectForKey:@"PatientID"];
            tmpTreatment.TreatmentID = [[valueArr objectAtIndex:i] objectForKey:@"TreatmentID"];
            tmpTreatment.StartDate = [[valueArr objectAtIndex:i] objectForKey:@"StartDate"];
            tmpTreatment.EndDate = [[valueArr objectAtIndex:i] objectForKey:@"EndDate"];
            tmpTreatment.GetUpTime = [[valueArr objectAtIndex:i] objectForKey:@"GetUpTime"];
            tmpTreatment.TreatTimeOne = [[valueArr objectAtIndex:i] objectForKey:@"TreatTimeOne"];
            tmpTreatment.TreatTimeTwo = [[valueArr objectAtIndex:i] objectForKey:@"TreatTimeTwo"];
            tmpTreatment.GoToBedTime = [[valueArr objectAtIndex:i] objectForKey:@"GoToBedTime"];
            [dbOpration insertTreatmentInfo:tmpTreatment];
        }
        [dbOpration closeDataBase];
    }
    else
    {
        TreatmentInfo *tmpTreatment;
        for (int i = 0; i < valueArr.count; i++)
        {
            NSString *startStr = [[valueArr objectAtIndex:i] objectForKey:@"StartDate"];
            for (TreatmentInfo *tmp in treatmentArr)
            {
                if ([tmp.StartDate isEqualToString:startStr])
                {
                    tmpTreatment = [[TreatmentInfo alloc] init];
                    break;
                }
            }
            if (tmpTreatment == nil)
            {
                tmpTreatment = [[TreatmentInfo alloc] init];
                tmpTreatment.PatientID = [[valueArr objectAtIndex:i] objectForKey:@"PatientID"];
                tmpTreatment.TreatmentID = [[valueArr objectAtIndex:i] objectForKey:@"TreatmentID"];
                tmpTreatment.StartDate = [[valueArr objectAtIndex:i] objectForKey:@"StartDate"];
                tmpTreatment.EndDate = [[valueArr objectAtIndex:i] objectForKey:@"EndDate"];
                tmpTreatment.GetUpTime = [[valueArr objectAtIndex:i] objectForKey:@"GetUpTime"];
                tmpTreatment.TreatTimeOne = [[valueArr objectAtIndex:i] objectForKey:@"TreatTimeOne"];
                tmpTreatment.TreatTimeTwo = [[valueArr objectAtIndex:i] objectForKey:@"TreatTimeTwo"];
                tmpTreatment.GoToBedTime = [[valueArr objectAtIndex:i] objectForKey:@"GoToBedTime"];
                [dbOpration insertTreatmentInfo:tmpTreatment];
            }
        }
        [dbOpration closeDataBase];
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
