//
//  SetTreatmentViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/20.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SetTreatmentViewController.h"
#import "Define.h"

#import "InterfaceModel.h"
#import "DataBaseOpration.h"
#import <UMMobClick/MobClick.h>
#import "JXTAlertManagerHeader.h"
#import "DatePickerView.h"
#import "YBDatePickerView.h"

#import "LiaoLiaoDiaryViewController.h"

@interface SetTreatmentViewController ()<InterfaceModelDelegate>

@property (nonatomic, strong) YBDatePickerView *pickerView;
@property (nonatomic, strong)      UIImageView *notice;
@property (nonatomic, copy)           NSString *startDate;
@property (nonatomic, copy)           NSString *wakeTime;
@property (nonatomic, copy)           NSString *cureTime1;
@property (nonatomic, copy)           NSString *cureTime2;
@property (nonatomic, copy)           NSString *sleepTime;
@property (nonatomic, assign)        NSInteger index;//时间设置类型（1:起床 2:理疗一 3:理疗二 4:睡觉）

@property (nonatomic, strong) UIButton *btnDate;    //开始日期按钮

@end

@implementation SetTreatmentViewController
{
    InterfaceModel *interfaceModel;
    NSArray *timeArray;
    TreatmentInfo *currentTreatmentInfo;                 //疗程类的一个全局变量
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    if ([_VCType isEqualToString:@"修改疗程"])
    {
        [MobClick beginLogPageView:@"修改疗程"];
    }
    else
    {
        [MobClick beginLogPageView:@"设置疗程"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    if ([_VCType isEqualToString:@"修改疗程"])
    {
        [MobClick endLogPageView:@"修改疗程"];
    }
    else
    {
        [MobClick endLogPageView:@"设置疗程"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"疗疗日记";
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
    
    //添加导航栏右边按钮，设备状态查看
    UIButton *comfirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45*Rate_NAV_W, 20*Rate_NAV_H)];
    [comfirmBtn addTarget:self action:@selector(comfirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [comfirmBtn setTitle:@"完成" forState:UIControlStateNormal];
    comfirmBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:comfirmBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [self prepareData];
    
    [self createFirstView];
    [self createSecondView];
    [self createThirdView];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareData
{
    //index初始化
    _index = 1;
    
    _wakeTime = @"07:00";
    _cureTime1 = @"10:00";
    _cureTime2 = @"15:00";
    _sleepTime = @"22:10";
    timeArray = @[@"07:00", @"10:00", @"15:00", @"22:00"];
    
//    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
//    NSArray *treatmentInfoArray = [dbOpration getTreatmentDataFromDataBase];
//    [dbOpration closeDataBase];
    
    
//    if (_treatmentInfo == nil)
//    {
//        if (treatmentInfoArray == nil || treatmentInfoArray.count == 0)
//        {
//            _wakeTime = @"07:00";
//            _cureTime1 = @"10:00";
//            _cureTime2 = @"15:00";
//            _sleepTime = @"22:10";
//            timeArray = @[@"07:00", @"10:00", @"15:00", @"22:00"];
//        }
//        else
//        {
//            TreatmentInfo *tmpInfo = [treatmentInfoArray objectAtIndex:0];
//            _wakeTime = tmpInfo.GetUpTime;
//            _cureTime1 = tmpInfo.TreatTimeOne;
//            _cureTime2 = tmpInfo.TreatTimeTwo;
//            _sleepTime = tmpInfo.GoToBedTime;
//            timeArray = @[@"07:00", @"10:00", @"15:00", @"22:00"];
//        }
//    }
//    else
//    {
//        _wakeTime = _treatmentInfo.GetUpTime;
//        _cureTime1 = _treatmentInfo.TreatTimeOne;
//        _cureTime2 = _treatmentInfo.TreatTimeTwo;
//        _sleepTime = _treatmentInfo.GoToBedTime;
//        timeArray = @[_wakeTime, _cureTime1, _cureTime2, _sleepTime];
//    }
}

#pragma mark ---- 完成后数据的存储
- (void)comfirmBtnClick:(UIButton *)sender
{
    currentTreatmentInfo = [[TreatmentInfo alloc] init];
    /*
     *判断从哪里进入的界面（1.从开始疗疗界面 2.从疗疗日记新设置一个疗程界面 3.点击疗程修改按钮）
     */
    if ([_VCType isEqualToString:@"开始疗疗"])
    {
        currentTreatmentInfo.PatientID = [PatientInfo shareInstance].PatientID;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMdd"];
        NSString *nowDateStr = [df stringFromDate:[NSDate date]];
        currentTreatmentInfo.TreatmentID = nowDateStr;
        [df setDateFormat:@"yyyy-MM-dd"];
        currentTreatmentInfo.StartDate = [df stringFromDate:[NSDate date]];
        currentTreatmentInfo.EndDate = [df stringFromDate:[[NSDate date] initWithTimeIntervalSinceNow:27*24*3600]];
        currentTreatmentInfo.GetUpTime = _wakeTime;
        currentTreatmentInfo.TreatTimeOne = _cureTime1;
        currentTreatmentInfo.TreatTimeTwo = _cureTime2;
        currentTreatmentInfo.GoToBedTime = _sleepTime;
        //上传服务器
        interfaceModel = [[InterfaceModel alloc] init];
        interfaceModel.delegate = self;
        [interfaceModel insertTreatmentSetInfoToServer:currentTreatmentInfo];
    }
    else if ([_VCType isEqualToString:@"设置疗程"])
    {
        currentTreatmentInfo.PatientID = [PatientInfo shareInstance].PatientID;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMdd"];
        NSString *nowDateStr = [df stringFromDate:[NSDate date]];
        currentTreatmentInfo.TreatmentID = nowDateStr;
        [df setDateFormat:@"yyyy-MM-dd"];
        currentTreatmentInfo.StartDate = [df stringFromDate:[NSDate date]];
        currentTreatmentInfo.EndDate = [df stringFromDate:[[NSDate date] initWithTimeIntervalSinceNow:27*24*3600]];
        currentTreatmentInfo.GetUpTime = _wakeTime;
        currentTreatmentInfo.TreatTimeOne = _cureTime1;
        currentTreatmentInfo.TreatTimeTwo = _cureTime2;
        currentTreatmentInfo.GoToBedTime = _sleepTime;
        //上传服务器
        interfaceModel = [[InterfaceModel alloc] init];
        interfaceModel.delegate = self;
        [interfaceModel insertTreatmentSetInfoToServer:currentTreatmentInfo];
    }
    else if ([_VCType isEqualToString:@"修改疗程"])
    {
        currentTreatmentInfo.PatientID = _treatmentInfo.PatientID;
        currentTreatmentInfo.TreatmentID = _treatmentInfo.TreatmentID;
        currentTreatmentInfo.StartDate = _treatmentInfo.StartDate;
        currentTreatmentInfo.EndDate = _treatmentInfo.EndDate;
        currentTreatmentInfo.GetUpTime = _wakeTime;
        currentTreatmentInfo.TreatTimeOne = _cureTime1;
        currentTreatmentInfo.TreatTimeTwo = _cureTime2;
        currentTreatmentInfo.GoToBedTime = _sleepTime;
        
        //上传服务器更新疗程修改信息
        interfaceModel = [[InterfaceModel alloc] init];
        interfaceModel.delegate = self;
        [interfaceModel updateTreatmentSetInfoToServer:currentTreatmentInfo];
    }
    
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    //创建通知
//    NSNotification *notification =[NSNotification notificationWithName:@"setTreatmentTime" object:nil userInfo:@{@"wakeTime":_wakeTime,@"cureTime1":_cureTime1,@"cureTime2":_cureTime2,@"sleepTime":_sleepTime}];
//    //通过通知中心发送注册推送
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma 疗程借口调研回调代理方法
- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeSetTreatment)
    {
        NSDictionary *tmpDic = value;
        //疗程设置成功
        if ([[tmpDic objectForKey:@"state"] isEqualToString:@"OK"])
        {
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            if ([_VCType isEqualToString:@"开始疗疗"])
            {
                //提示“疗程设置成功”
                jxt_showTextHUDTitleMessage(@"温馨提示", @"疗程设置成功");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
                //数据本地存储
                [dbOpration insertTreatmentInfo:currentTreatmentInfo];
                [dbOpration closeDataBase];
                //界面返回
                [self.navigationController popViewControllerAnimated:YES];
                //创建一个消息对象
                NSDictionary *treatmentDic = [NSDictionary dictionaryWithObjectsAndKeys:currentTreatmentInfo, @"TreatmentInfo", nil];
                NSNotification *notice = [NSNotification notificationWithName:@"StartLiaoLiao" object:nil userInfo:treatmentDic];
                //发送消息
                [[NSNotificationCenter defaultCenter] postNotification:notice];
            }
            else if ([_VCType isEqualToString:@"设置疗程"])
            {
                //提示“疗程设置成功”
                jxt_showTextHUDTitleMessage(@"温馨提示", @"疗程设置成功");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
                //数据本地存储
                [dbOpration insertTreatmentInfo:currentTreatmentInfo];
                //创建一个消息对象
                NSDictionary *treatmentDic = [NSDictionary dictionaryWithObjectsAndKeys:currentTreatmentInfo, @"TreatmentInfo", nil];
                NSNotification *notice = [NSNotification notificationWithName:@"SetTreatment" object:nil userInfo:treatmentDic];
                //发送消息
                [[NSNotificationCenter defaultCenter] postNotification:notice];
                
                //读取本地数据(所有疗程信息)
                NSArray *allTreatment = [dbOpration getTreatmentDataFromDataBase];
                [dbOpration closeDataBase];
                NSMutableArray *targetArray = [NSMutableArray array];
                //将取出的疗程数据进行判断，只需要自己疗程的数据
                if (allTreatment.count > 0)
                {
                    for (TreatmentInfo *tmp in allTreatment)
                    {
                        if ([tmp.PatientID isEqualToString:[PatientInfo shareInstance].PatientID])
                        {
                            [targetArray addObject:tmp];
                        }
                    }
                }
                //疗程设置完毕创建疗疗日记界面
                LiaoLiaoDiaryViewController *diaryVC = [[LiaoLiaoDiaryViewController alloc] init];
                diaryVC.courseArray = targetArray;
                [self.navigationController pushViewController:diaryVC animated:YES];
            }
        }
        else //疗程设置或修改失败
        {
            //提示“疗程设置失败”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"疗程设置失败");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeAltTreatment) //疗程设置或修改失败
    {
        NSDictionary *tmpDic = value;
        //疗程设置成功
        if ([[tmpDic objectForKey:@"state"] isEqualToString:@"OK"])
        {
            //提示“疗程修改成功”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"疗程修改成功");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
            //本地数据库修改疗程信息
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            [dbOpration updateTreatmentInfo:currentTreatmentInfo];
            [dbOpration closeDataBase];
            //创建一个消息对象
            NSDictionary *treatmentDic = [NSDictionary dictionaryWithObjectsAndKeys:currentTreatmentInfo, @"TreatmentInfo", nil];
            NSNotification *notice = [NSNotification notificationWithName:@"AlertTreatment" object:nil userInfo:treatmentDic];
            //发送消息
            [[NSNotificationCenter defaultCenter] postNotification:notice];
            //界面返回
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            //提示“疗程修改失败”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"疗程修改失败");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
    }
}

//创建界面上方的文字显示
- (void)createFirstView
{
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 15*Rate_NAV_H, 112*Rate_NAV_W, 20*Rate_NAV_H)];
    lable1.text = @"建议使用时间：";
    lable1.textColor = [UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1.0];
    lable1.font = [UIFont boldSystemFontOfSize:16*Rate_NAV_H];
    lable1.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:lable1];
    
    UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 40*Rate_NAV_H, 331*Rate_NAV_W, 70*Rate_NAV_H)];
    NSString *str2 = @"建议早上起床时间为7:00，上午理疗时间为10:00，下午理疗时间为15:00，晚上睡觉时间为22:00。不建议在睡前3小时使用；每天使用1-2次，每次20分钟，静卧尤佳。";
    lable2.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    lable2.text = str2;
    lable2.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    lable2.numberOfLines = 0;
    [self.view addSubview:lable2];
    
}

//创建界面中部的疗程日期选择
- (void)createSecondView
{
    UIView *lineViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 123*Rate_NAV_H, 375*Rate_NAV_W, Rate_NAV_H)];
    lineViewOne.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
    [self.view addSubview:lineViewOne];
    
    //日期标题
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(18*Rate_NAV_W, 124*Rate_NAV_H, 100*Rate_NAV_W, 50*Rate_NAV_H)];
    lable1.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    lable1.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    lable1.textAlignment = NSTextAlignmentCenter;
    lable1.text = @"疗程开始日期";
    [self.view addSubview:lable1];
    
    //为整个view添加button，可点击
    _btnDate = [[UIButton alloc] initWithFrame:CGRectMake(221*Rate_NAV_W, 124*Rate_NAV_H, 135*Rate_NAV_W, 50*Rate_NAV_H)];
    [_btnDate setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
    _btnDate.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    _btnDate.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    if (_treatmentInfo.StartDate == nil || _treatmentInfo.StartDate.length == 0)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy年MM月dd日"];
        NSString *nowDateStr = [df stringFromDate:[NSDate date]];
        [_btnDate setTitle:nowDateStr forState:UIControlStateNormal];
    }
    else
    {
        NSString *treatmentStart = [NSString stringWithFormat:@"%@年%@月%@日",[_treatmentInfo.StartDate substringWithRange:NSMakeRange(0, 4)],[_treatmentInfo.StartDate substringWithRange:NSMakeRange(5, 2)],[_treatmentInfo.StartDate substringWithRange:NSMakeRange(8, 2)]];
        [_btnDate setTitle:treatmentStart forState:UIControlStateNormal];
    }
    [self.view addSubview:_btnDate];
    
    UIView *lineViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 174*Rate_NAV_H, 375*Rate_NAV_W, Rate_NAV_H)];
    lineViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
    [self.view addSubview:lineViewTwo];
}

//日期按钮点击事件
- (void)pickerDate:(UIButton *)sender
{
    NSString *yearStr = [sender.titleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *monthStr = [sender.titleLabel.text substringWithRange:NSMakeRange(5, 2)];
    NSString *dayStr = [sender.titleLabel.text substringWithRange:NSMakeRange(8, 2)];
    DatePickerView *datePicker_YB = [[DatePickerView alloc] initWith:[yearStr integerValue] Month:[monthStr integerValue] Day:[dayStr integerValue]];
    [datePicker_YB show];
    
    __weak typeof(datePicker_YB) weakDatePicker = datePicker_YB;
    
    datePicker_YB.gotoSrceenOrderBlock = ^(NSString *valueStr){
        [weakDatePicker hide];
        if (![valueStr isEqualToString:sender.titleLabel.text])
        {
            [sender setTitle:valueStr forState:UIControlStateNormal];
        }
    };
}

//创建界面中部疗程内每日相关时间设置
- (void)createThirdView
{
    NSArray *typeArray = @[@"起床",@"理疗",@"理疗",@"睡觉"];
    
    //时间轴上的线条
    UIView *line = [[UILabel alloc] initWithFrame:CGRectMake(29*Rate_NAV_W + 7*Rate_NAV_H, 198.5*Rate_NAV_H, 2*Rate_NAV_H, 159*Rate_NAV_H)];
    line.backgroundColor = [UIColor colorWithRed:0x5E/255.0 green:0xC3/255.0 blue:0xD5/255.0 alpha:1.0];
    [self.view addSubview:line];
    
    for (int i = 0; i < 4; i++)
    {
        //时间轴上的圆点
        UIView *pointV = [[UIView alloc] initWithFrame:CGRectMake(29*Rate_NAV_W, (198.5 + i*50)*Rate_NAV_H, 16*Rate_NAV_H, 16*Rate_NAV_H)];
        pointV.layer.cornerRadius = 8*Rate_NAV_H;
        pointV.clipsToBounds = YES;
        pointV.backgroundColor = [UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0];
        [self.view addSubview:pointV];
        
        //疗程设置的时间
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(65*Rate_NAV_W, (189 + i*50)*Rate_NAV_H, 225*Rate_NAV_W, 35*Rate_NAV_H)];
        btn.tag = i+1;
        [btn setBackgroundImage:[UIImage imageNamed:@"dairy_physiotherapy_bg.png"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(datePicker:) forControlEvents:(UIControlEventTouchUpInside)];
        btn.userInteractionEnabled = NO;
        [self.view addSubview:btn];
        
        UILabel *datelabel = [[UILabel alloc] initWithFrame:CGRectMake(5*Rate_NAV_W, 5*Rate_NAV_H, 100*Rate_NAV_W, 25*Rate_NAV_H)];
        datelabel.tag = i+11;
        datelabel.textColor = [UIColor colorWithRed:0x70/255.0 green:0x76/255.0 blue:0x78/255.0 alpha:1];
        datelabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
        datelabel.text = timeArray[i];
        [btn addSubview:datelabel];
        
        //设置具体疗程时间标签
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170*Rate_NAV_W, 5*Rate_NAV_H, 50*Rate_NAV_W, 25*Rate_NAV_H)];
        typeLabel.textColor = [UIColor colorWithRed:0x70/255.0 green:0x76/255.0 blue:0x78/255.0 alpha:1];
        typeLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
        typeLabel.text = typeArray[i];
        typeLabel.textAlignment = NSTextAlignmentRight;
        [btn addSubview:typeLabel];
        
        if (i == 2)
        {
            _notice = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(btn.frame), CGRectGetMaxY(btn.frame), 163*Ratio, 22*Ratio)];
            _notice.image= [UIImage imageNamed:@"icon_advice.png"];
            _notice.hidden = YES;
            [self.view addSubview:_notice];
        }
    }
    
    UIImageView *alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70*Rate_NAV_W, 322*Rate_NAV_H, 16*Rate_NAV_H, 16*Rate_NAV_H)];
    [alertImageView setImage:[UIImage imageNamed:@"icon_advice"]];
    [self.view addSubview:alertImageView];
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(93*Rate_NAV_W, 322*Rate_NAV_H, 150*Rate_NAV_W, 17*Rate_NAV_H)];
    alertLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    alertLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    alertLabel.text = @"不建议在睡前3小时内使用";
    [self.view addSubview:alertLabel];
    
    //添加时间选择
//    UIButton *sender = (UIButton*)[self.view viewWithTag:1];
//    sender.selected = YES;
//    UILabel *tmp = (UILabel *)[self.view viewWithTag:11];
//    [self createDatePicker:tmp.text];
}

//- (void)createDatePicker:(NSString *)time
//{
//    _pickerView = [[YBDatePickerView alloc] initWithFrame:CGRectMake(0, 377*Rate_NAV_H, 375*Rate_NAV_W, 222*Rate_NAV_H) andTime:time];
//    [self.view addSubview:_pickerView];
//    
//    [_pickerView sendTimePickValue:^(NSString *timeValue) {
//        if (self.index == 1)
//        {
//            UILabel *tmp = (UILabel *)[self.view viewWithTag:11];
//            tmp.text = [NSString stringWithFormat:@"%@",timeValue];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"HH:mm"];
//            _wakeTime = timeValue;
//            
//            NSString *timeNumStr = [timeValue stringByReplacingOccurrencesOfString:@":" withString:@""];
//            if ([timeNumStr integerValue] < 600 || [timeNumStr integerValue] > 800)
//            {
//                //提示“请合理安排作息时间，在22:30分前入睡更有利于睡眠健康”
//                jxt_showTextHUDTitleMessage(@"温馨提示", @"早上起床时间建议设定在6:00-8:00之间");
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    jxt_dismissHUD();
//                });
//            }
//            
//            _index = 2;
//            //添加时间选择
//            UIButton *senderOne = (UIButton*)[self.view viewWithTag:1];
//            senderOne.selected = NO;
//            UIButton *senderTwo = (UIButton*)[self.view viewWithTag:2];
//            senderTwo.selected = YES;
//            UIButton *senderThree = (UIButton*)[self.view viewWithTag:3];
//            senderThree.selected = NO;
//            UIButton *senderFour = (UIButton*)[self.view viewWithTag:4];
//            senderFour.selected = NO;
//            UILabel *nextTmp = (UILabel *)[self.view viewWithTag:12];
//            [self createDatePicker:nextTmp.text];
//        }
//        else if(self.index == 2)
//        {
//            UILabel *tmp = (UILabel *)[self.view viewWithTag:12];
//            tmp.text = [NSString stringWithFormat:@"%@",timeValue];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"HH:mm"];
//            _cureTime1 = timeValue;
//            
//            NSString *timeNumStr = [timeValue stringByReplacingOccurrencesOfString:@":" withString:@""];
//            if ([timeNumStr integerValue] < 900 || [timeNumStr integerValue] > 1100)
//            {
//                //提示“请合理安排作息时间，在22:30分前入睡更有利于睡眠健康”
//                jxt_showTextHUDTitleMessage(@"温馨提示", @"上午理疗时间建议设定在9:00-11:00之间");
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    jxt_dismissHUD();
//                });
//            }
//            
//            _index = 3;
//            //添加时间选择
//            UIButton *senderOne = (UIButton*)[self.view viewWithTag:1];
//            senderOne.selected = NO;
//            UIButton *senderTwo = (UIButton*)[self.view viewWithTag:2];
//            senderTwo.selected = NO;
//            UIButton *senderThree = (UIButton*)[self.view viewWithTag:3];
//            senderThree.selected = YES;
//            UIButton *senderFour = (UIButton*)[self.view viewWithTag:4];
//            senderFour.selected = NO;
//            UILabel *nextTmp = (UILabel *)[self.view viewWithTag:13];
//            [self createDatePicker:nextTmp.text];
//        }
//        else if(self.index == 3)
//        {
//            UILabel *tmp = (UILabel *)[self.view viewWithTag:13];
//            tmp.text = [NSString stringWithFormat:@"%@",timeValue];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"HH:mm"];
//            _cureTime2 = timeValue;
//            
//            NSString *timeNumStr = [timeValue stringByReplacingOccurrencesOfString:@":" withString:@""];
//            if ([timeNumStr integerValue] < 1400 || [timeNumStr integerValue] > 1600)
//            {
//                //提示“请合理安排作息时间，在22:30分前入睡更有利于睡眠健康”
//                jxt_showTextHUDTitleMessage(@"温馨提示", @"下午理疗时间建议设定在14:00-16:00之间");
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    jxt_dismissHUD();
//                });
//            }
//            
//            _index = 4;
//            //添加时间选择
//            UIButton *senderOne = (UIButton*)[self.view viewWithTag:1];
//            senderOne.selected = NO;
//            UIButton *senderTwo = (UIButton*)[self.view viewWithTag:2];
//            senderTwo.selected = NO;
//            UIButton *senderThree = (UIButton*)[self.view viewWithTag:3];
//            senderThree.selected = NO;
//            UIButton *senderFour = (UIButton*)[self.view viewWithTag:4];
//            senderFour.selected = YES;
//            UILabel *nextTmp = (UILabel *)[self.view viewWithTag:14];
//            [self createDatePicker:nextTmp.text];
//        }
//        else
//        {
//            UILabel *tmp = (UILabel *)[self.view viewWithTag:14];
//            tmp.text = [NSString stringWithFormat:@"%@",timeValue];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"HH:mm"];
//            _sleepTime = timeValue;
//            
//            NSString *timeNumStr = [timeValue stringByReplacingOccurrencesOfString:@":" withString:@""];
//            if ([timeNumStr integerValue] < 2200 || [timeNumStr integerValue] > 2300)
//            {
//                //提示“请合理安排作息时间，在22:30分前入睡更有利于睡眠健康”
//                jxt_showTextHUDTitleMessage(@"温馨提示", @"晚上睡觉时间建议设定在22:00-23:00之间");
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    jxt_dismissHUD();
//                });
//            }
//            
//            _index = 1;
//            //添加时间选择
//            UIButton *senderOne = (UIButton*)[self.view viewWithTag:1];
//            senderOne.selected = YES;
//            UIButton *senderTwo = (UIButton*)[self.view viewWithTag:2];
//            senderTwo.selected = NO;
//            UIButton *senderThree = (UIButton*)[self.view viewWithTag:3];
//            senderThree.selected = NO;
//            UIButton *senderFour = (UIButton*)[self.view viewWithTag:4];
//            senderFour.selected = NO;
//            UILabel *nextTmp = (UILabel *)[self.view viewWithTag:11];
//            [self createDatePicker:nextTmp.text];
//        }
//    }];
//}

#pragma mark ---- 选择起始日期
- (void)datePicker:(UIButton *)btn
{
//    self.index = btn.tag;
//    for (int i = 0; i < 4; i++)
//    {
//        if (i == btn.tag-1)
//        {
//            btn.selected = YES;
//            if (_pickerView == nil)
//            {
//                UILabel *tmp = (UILabel *)[self.view viewWithTag:i+11];
//                [self createDatePicker:tmp.text];
//            }
//            else
//            {
//                [_pickerView removeFromSuperview];
//                _pickerView = nil;
//                
//                UILabel *tmp = (UILabel *)[self.view viewWithTag:i+11];
//                [self createDatePicker:tmp.text];
//            }
//        }
//        else
//        {
//            UIButton *sender = (UIButton*)[self.view viewWithTag:i+1];
//            sender.selected = NO;
//        }
//    }
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
