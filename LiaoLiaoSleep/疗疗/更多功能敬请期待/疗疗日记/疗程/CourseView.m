//
//  CourseViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/12/15.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "CourseView.h"

#import "Define.h"

#import "TreatmentInfo.h"
#import "TreatInfo.h"

#import "SetTreatmentViewController.h"

@interface CourseView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *courseView;//疗程view的第一部分视图（装载周月季度、症状描述数据显示）
@property (nonatomic ,strong) UIView *courseAboutView;//关于疗程部分视图
@property (nonatomic, copy) NSMutableArray *dateArray;
@property (nonatomic, copy) NSMutableArray *myDateArray;

@end

@implementation CourseView
{
    NSInteger currentPage;
    UIButton *courseBtn;
    UIButton *alertCourseBtn;
    UILabel *currentCourseLabel;
    UILabel *dateLabel;
    
    UIScrollView *dataScrollView;
}

- (instancetype)initWithFrame:(CGRect)frame andDateArray:(NSArray *)dateArray andtreatInfoArray:(NSArray *)treatInfoArray
{
    if (self == [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
        
        if (dateArray.count > 1)
        {
            currentPage = dateArray.count - 1;
        }
        else
        {
            currentPage = 0;
        }
        _dateArray = [NSMutableArray arrayWithArray:dateArray];
        
        [self prepareDateArray:dateArray andTreatInfoArray:treatInfoArray];
        [self createCourseView:dateArray];
        [self createDateView];
        [self createCourseAboutView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTreatment:) name:@"AlertTreatment" object:nil];
    }
    
    return self;
}

- (void)updateTreatment:(NSNotification *)notification
{
    TreatmentInfo *tmpTreatment = notification.userInfo[@"TreatmentInfo"];
    for (int i = 0; i < _dateArray.count; i++)
    {
        TreatmentInfo *tmp = [_dateArray objectAtIndex:i];
        if ([tmp.TreatmentID isEqualToString:tmpTreatment.TreatmentID])
        {
            tmp.GetUpTime = tmpTreatment.GetUpTime;
            tmp.TreatTimeOne = tmpTreatment.TreatTimeOne;
            tmp.TreatTimeTwo = tmpTreatment.TreatTimeTwo;
            tmp.GoToBedTime = tmpTreatment.GoToBedTime;
        }
    }
}

#pragma -以下是疗程选项的界面搭建、逻辑处理
//创建疗程界面第一部分视图
- (void)createCourseView:(NSArray *)dateArray
{
    _courseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 401*Rate_NAV_H)];
    _courseView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_courseView];
    
    courseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    courseBtn.frame = CGRectMake(23*Rate_NAV_W, 20*Rate_NAV_H, 60*Rate_NAV_W, 20*Rate_NAV_H);
    [courseBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    courseBtn.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    if (currentPage == 0)
    {
        courseBtn.hidden = YES;
    }
    else
    {
        [courseBtn setTitle:[NSString stringWithFormat:@"第%ld疗程",(long)currentPage] forState:UIControlStateNormal];
    }
    [courseBtn addTarget:self action:@selector(viewHistory:) forControlEvents:UIControlEventTouchUpInside];
    [_courseView addSubview:courseBtn];
    
    currentCourseLabel = [[UILabel alloc] initWithFrame:CGRectMake(150*Rate_NAV_W, 16*Rate_NAV_H, 75*Rate_NAV_W, 25*Rate_NAV_H)];
    currentCourseLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    currentCourseLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    currentCourseLabel.textAlignment = NSTextAlignmentCenter;
    if (currentPage == 0)
    {
        if (dateArray.count > 1)
        {
            currentCourseLabel.text = [NSString stringWithFormat:@"第%ld疗程",(long)currentPage + 1];
        }
        else if (dateArray.count == 1)
        {
            currentCourseLabel.text = @"当前疗程";
        }
    }
    else
    {
        currentCourseLabel.text = @"当前疗程";
    }
    [_courseView addSubview:currentCourseLabel];
    
    alertCourseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    alertCourseBtn.frame = CGRectMake(300*Rate_NAV_W, 20*Rate_NAV_H, 60*Rate_NAV_W, 20*Rate_NAV_H);
    alertCourseBtn.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    if (currentPage == 0)
    {
        if (dateArray.count > 1)
        {
            [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
            [alertCourseBtn setTitle:[NSString stringWithFormat:@"第%ld疗程",(long)currentPage + 2] forState:UIControlStateNormal];
        }
        else if (dateArray.count == 1)
        {
            [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
            [alertCourseBtn setTitle:@"查看疗程" forState:UIControlStateNormal];
        }
    }
    else
    {
        [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
        [alertCourseBtn setTitle:@"查看疗程" forState:UIControlStateNormal];
    }
    [alertCourseBtn addTarget:self action:@selector(alertCourseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_courseView addSubview:alertCourseBtn];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(116*Rate_NAV_W, 56*Rate_NAV_H, 143*Rate_NAV_W, 22*Rate_NAV_H)];
    dateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    //疗程开、结束日期拼接
    TreatmentInfo *dicTmp = [dateArray objectAtIndex:currentPage];
    NSString *startDateStr = [dicTmp.StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    NSString *endDateStr = [dicTmp.EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    dateLabel.text = [NSString stringWithFormat:@"%@-%@",[startDateStr substringWithRange:NSMakeRange(2, 8)],[endDateStr substringWithRange:NSMakeRange(2, 8)]];
    [_courseView addSubview:dateLabel];
    
    UIView *tagOneView = [[UIView alloc] initWithFrame:CGRectMake(26*Rate_NAV_W, 371*Rate_NAV_H, 10*Rate_NAV_H, 10*Rate_NAV_H)];
    tagOneView.backgroundColor = [UIColor colorWithRed:0 green:0xFF/255.0 blue:0 alpha:1];
    [_courseView addSubview:tagOneView];
    UILabel *tagOneLabel = [[UILabel alloc] initWithFrame:CGRectMake(46*Rate_NAV_W, 366*Rate_NAV_H, 90*Rate_NAV_W, 20*Rate_NAV_H)];
    tagOneLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    tagOneLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    tagOneLabel.textAlignment = NSTextAlignmentLeft;
    tagOneLabel.text = @"标准 每天2次";
    [_courseView addSubview:tagOneLabel];
    
    UIView *tagTwoView = [[UIView alloc] initWithFrame:CGRectMake(142*Rate_NAV_W, 371*Rate_NAV_H, 10*Rate_NAV_H, 10*Rate_NAV_H)];
    tagTwoView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    [_courseView addSubview:tagTwoView];
    UILabel *tagTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(162*Rate_NAV_W, 366*Rate_NAV_H, 90*Rate_NAV_W, 20*Rate_NAV_H)];
    tagTwoLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    tagTwoLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    tagTwoLabel.textAlignment = NSTextAlignmentLeft;
    tagTwoLabel.text = @"轻度 每天1次";
    [_courseView addSubview:tagTwoLabel];
    
    UIImageView *tagThreeView = [[UIImageView alloc] initWithFrame:CGRectMake(258*Rate_NAV_W, 371*Rate_NAV_H, 10*Rate_NAV_H, 10*Rate_NAV_H)];
    [tagThreeView setImage:[UIImage imageNamed:@"flag"]];
    [_courseView addSubview:tagThreeView];
    UILabel *tagThreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(278*Rate_NAV_W, 366*Rate_NAV_H, 60*Rate_NAV_W, 20*Rate_NAV_H)];
    tagThreeLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    tagThreeLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    tagThreeLabel.textAlignment = NSTextAlignmentLeft;
    tagThreeLabel.text = @"未做治疗";
    [_courseView addSubview:tagThreeLabel];
}

- (void)prepareDateArray:(NSArray *)dateArray andTreatInfoArray:(NSArray *)treatInfoArray
{
    _myDateArray = [NSMutableArray array];

    for (int i = 0; i < dateArray.count; i++)
    {
        TreatmentInfo *dicTmp = [dateArray objectAtIndex:i];
        NSString *startDateStr = dicTmp.StartDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [dateFormatter dateFromString:startDateStr];
        NSMutableArray *tmpDateArray = [NSMutableArray array];
        for (int j = 0; j < 28; j++)
        {
            NSDate *courseDate = [startDate dateByAddingTimeInterval:j*24*3600];
            NSString *courseDateStr = [dateFormatter stringFromDate:courseDate];
            NSMutableArray *treatCountArray = [NSMutableArray array];
            for (TreatInfo *tmp in treatInfoArray)
            {
                NSString *tmpStr = tmp.BeginTime;
                NSString *str_1 = [tmpStr substringWithRange:NSMakeRange(0, 4)];
                NSString *str_2 = [tmpStr substringWithRange:NSMakeRange(5, 2)];
                NSString *str_3 = [tmpStr substringWithRange:NSMakeRange(8, 2)];
                NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",str_1,str_2,str_3];
                if ([dateStr isEqualToString:courseDateStr])
                {
                    [treatCountArray addObject:tmp];
                }
            }
            if (treatCountArray.count > 0)
            {
                int count = 0;
                for (TreatInfo *myTmp in treatCountArray)
                {
                    if ([myTmp.CureTime integerValue] > 10)
                    {
                        count ++;
                    }
                }
                
                if (count >= 2)
                {
                    [tmpDateArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"2",courseDateStr, nil]];
                }
                else if (count == 1)
                {
                    [tmpDateArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",courseDateStr, nil]];
                }
                else
                {
                    [tmpDateArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0",courseDateStr, nil]];
                }
            }
            else
            {
                [tmpDateArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0",courseDateStr, nil]];
            }
        }
        [_myDateArray addObject:tmpDateArray];
    }
}

//创建日期显示View
- (void)createDateView
{
    dataScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 90*Rate_NAV_H, 375*Rate_NAV_W, 271*Rate_NAV_H)];
    dataScrollView.showsVerticalScrollIndicator = NO;
    dataScrollView.showsHorizontalScrollIndicator = NO;
    dataScrollView.pagingEnabled = YES;
    dataScrollView.contentSize = CGSizeMake(SCREENWIDTH*_myDateArray.count,0);
    dataScrollView.contentOffset = CGPointMake(currentPage*SCREENWIDTH, 0);
    dataScrollView.delegate = self;
    [_courseView addSubview:dataScrollView];
    
    for (int k = 0; k < _myDateArray.count; k++)
    {
        NSArray *tmpArray = [_myDateArray objectAtIndex:k];
        NSMutableArray *dateArray = [NSMutableArray array];
        NSMutableArray *cureArray = [NSMutableArray array];
        for (int i = 0; i < tmpArray.count; i++)
        {
            NSDictionary *tmpDic = [tmpArray objectAtIndex:i];
            NSString *key = [tmpDic allKeys][0];
            NSString *value = [tmpDic allValues][0];
            
            [dateArray addObject:key];
            [cureArray addObject:value];
        }
        
        for (int i = 0; i < 4; i++)
        {
            for (int j= 0; j < 7; j++)
            {
                //日期一般背景色都是白色，天蓝色背景的表示是当天
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W, (20 + 69*i)*Rate_NAV_H, 28*Rate_NAV_H, 28*Rate_NAV_H)];
                [dataScrollView addSubview:btn];
                
                //数组当中的日期
                NSString *cureDateStr = [dateArray objectAtIndex:i*7+j];
                NSString *isCure = [cureArray objectAtIndex:i*7+j];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *cureDate = [dateFormatter dateFromString:cureDateStr];
                //添加开始月份显示
                if (i == 0 && j == 0)
                {
                    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((22 + 375*k)*Rate_NAV_W, 2*Rate_NAV_H, 28*Rate_NAV_H, 20*Rate_NAV_H)];
                    monthLabel.textColor = [UIColor colorWithRed:0x9B/255.0 green:0xA5/255.0 blue:0xA8/255.0 alpha:1];
                    monthLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
                    monthLabel.adjustsFontSizeToFitWidth = YES;
                    monthLabel.textAlignment = NSTextAlignmentCenter;
                    monthLabel.text = [NSString stringWithFormat:@"%@月",[cureDateStr substringWithRange:NSMakeRange(5, 2)]];
                    [dataScrollView addSubview:monthLabel];
                }
                //获取固定格式的当前日期时间
                NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
                NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
                
                if ([cureDate compare:currentDate] == NSOrderedAscending)
                {
                    if ([[cureDateStr substringWithRange:NSMakeRange(8, 2)] isEqualToString:@"01"])
                    {
                        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W, (2 + 69*i)*Rate_NAV_H, 28*Rate_NAV_H, 20*Rate_NAV_H)];
                        monthLabel.textColor = [UIColor colorWithRed:0x9B/255.0 green:0xA5/255.0 blue:0xA8/255.0 alpha:1];
                        monthLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
                        monthLabel.adjustsFontSizeToFitWidth = YES;
                        monthLabel.textAlignment = NSTextAlignmentCenter;
                        monthLabel.text = [NSString stringWithFormat:@"%@月",[cureDateStr substringWithRange:NSMakeRange(5, 2)]];
                        [dataScrollView addSubview:monthLabel];
                    }
                    if ([isCure isEqualToString:@"2"])
                    {
                        [btn setBackgroundColor:[UIColor whiteColor]];
                        btn.layer.cornerRadius = 14*Rate_NAV_H;
                        [btn setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
                        btn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
                        [btn setTitle:[cureDateStr substringWithRange:NSMakeRange(8, 2)] forState:UIControlStateNormal];
                        //圆点代表今天治疗两次并且每次时间均超过10分钟
                        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W + 10*Rate_NAV_H, (51 + 69*i)*Rate_NAV_H, 8*Rate_NAV_H, 8*Rate_NAV_H)];
                        myView.backgroundColor = [UIColor colorWithRed:0 green:0xFF/255.0 blue:0 alpha:1];
                        [dataScrollView addSubview:myView];
                    }
                    else if ([isCure isEqualToString:@"1"])
                    {
                        [btn setBackgroundColor:[UIColor whiteColor]];
                        btn.layer.cornerRadius = 14*Rate_NAV_H;
                        [btn setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
                        btn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
                        [btn setTitle:[cureDateStr substringWithRange:NSMakeRange(8, 2)] forState:UIControlStateNormal];
                        //圆点代表今天治疗只有一次时间超过10分钟
                        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W + 10*Rate_NAV_H, (51 + 69*i)*Rate_NAV_H, 8*Rate_NAV_H, 8*Rate_NAV_H)];
                        myView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
                        [dataScrollView addSubview:myView];
                    }
                    else if ([isCure isEqualToString:@"0"])
                    {
                        [btn setBackgroundColor:[UIColor whiteColor]];
                        btn.layer.cornerRadius = 14*Rate_NAV_H;
                        [btn setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
                        btn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
                        [btn setTitle:[cureDateStr substringWithRange:NSMakeRange(8, 2)] forState:UIControlStateNormal];
                        
                        //红旗代表今天没有治疗或者每次治疗时间均低于10分钟
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W + 10*Rate_NAV_H, (51 + 69*i)*Rate_NAV_H, 8*Rate_NAV_H, 9*Rate_NAV_H)];
                        imageView.image = [UIImage imageNamed:@"flag"];
                        [dataScrollView addSubview:imageView];
                    }
                }
                else if ([cureDate compare:currentDate] == NSOrderedSame)
                {
                    if ([[cureDateStr substringWithRange:NSMakeRange(8, 2)] isEqualToString:@"01"])
                    {
                        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W, (2 + 69*i)*Rate_NAV_H, 28*Rate_NAV_H, 20*Rate_NAV_H)];
                        monthLabel.textColor = [UIColor colorWithRed:0x9B/255.0 green:0xA5/255.0 blue:0xA8/255.0 alpha:1];
                        monthLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
                        monthLabel.adjustsFontSizeToFitWidth = YES;
                        monthLabel.textAlignment = NSTextAlignmentCenter;
                        monthLabel.text = [NSString stringWithFormat:@"%@月",[cureDateStr substringWithRange:NSMakeRange(5, 2)]];
                        [dataScrollView addSubview:monthLabel];
                    }
                    
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    [btn setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
                    btn.layer.cornerRadius = 14*Rate_NAV_H;
                    [btn setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
                    [btn setTitle:[cureDateStr substringWithRange:NSMakeRange(8, 2)] forState:UIControlStateNormal];
                    
                    //圆点代表今天治疗时间超过10分钟
                    if ([isCure isEqualToString:@"2"])
                    {
                        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W + 10*Rate_NAV_H, (51 + 69*i)*Rate_NAV_H, 8*Rate_NAV_H, 8*Rate_NAV_H)];
                        myView.backgroundColor = [UIColor colorWithRed:0 green:0xFF/255.0 blue:0 alpha:1];
                        [dataScrollView addSubview:myView];
                    }
                    else if ([isCure isEqualToString:@"1"])
                    {
                        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W + 10*Rate_NAV_H, (51 + 69*i)*Rate_NAV_H, 8*Rate_NAV_H, 8*Rate_NAV_H)];
                        myView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
                        [dataScrollView addSubview:myView];
                    }
                    else if ([isCure isEqualToString:@"0"])
                    {
                        //红旗代表今天没有治疗或者每次治疗时间均低于10分钟
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W + 10*Rate_NAV_H, (51 + 69*i)*Rate_NAV_H, 8*Rate_NAV_H, 9*Rate_NAV_H)];
                        imageView.image = [UIImage imageNamed:@"flag"];
                        [dataScrollView addSubview:imageView];
                    }
                }
                else if ([cureDate compare:currentDate] == NSOrderedDescending)
                {
                    if ([[cureDateStr substringWithRange:NSMakeRange(8, 2)] isEqualToString:@"01"])
                    {
                        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((22 + 52*j + 375*k)*Rate_NAV_W, (2 + 69*i)*Rate_NAV_H, 28*Rate_NAV_H, 20*Rate_NAV_H)];
                        monthLabel.textColor = [UIColor colorWithRed:0x9B/255.0 green:0xA5/255.0 blue:0xA8/255.0 alpha:1];
                        monthLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
                        monthLabel.adjustsFontSizeToFitWidth = YES;
                        monthLabel.textAlignment = NSTextAlignmentCenter;
                        monthLabel.text = [NSString stringWithFormat:@"%@月",[cureDateStr substringWithRange:NSMakeRange(5, 2)]];
                        [dataScrollView addSubview:monthLabel];
                    }
                    
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    btn.layer.cornerRadius = 14*Rate_NAV_H;
                    [btn setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
                    [btn setTitle:[cureDateStr substringWithRange:NSMakeRange(8, 2)] forState:UIControlStateNormal];
                }
            }
        }
    }
}

//点击左侧第几疗程按钮切换疗程
- (void)viewHistory:(UIButton *)sender
{
    currentPage--;
    dataScrollView.contentOffset = CGPointMake(currentPage*SCREENWIDTH, 0);
    if (currentPage == 0)
    {
        [courseBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [courseBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
    }
}

//修改疗程 按钮点击事件
- (void)alertCourseBtnClick:(UIButton *)sender
{
    if (currentPage == _myDateArray.count - 1)
    {
        //跳转到疗程修改界面（传递或者获取用户的疗程信息，之后用户对疗程信息进行修改）
        TreatmentInfo *treatmentInfo = [_dateArray objectAtIndex:currentPage];
        NSDictionary *myTreatmentDic = [NSDictionary dictionaryWithObjectsAndKeys:treatmentInfo,@"treatmentIfo", nil];
        NSNotification *notification = [NSNotification notificationWithName:@"pushToSetTreatmentVC" object:nil userInfo:myTreatmentDic];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else
    {
        currentPage++;
        dataScrollView.contentOffset = CGPointMake(currentPage*SCREENWIDTH, 0);
        if (currentPage == _myDateArray.count - 1)
        {
            [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
        }
        else
        {
            [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        }
    }
}

#pragma mark----------dataScrollView的代理方法，为了获取当前页
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 根据当前的x坐标和页宽度计算出当前页数
    currentPage = floor((scrollView.contentOffset.x - SCREENWIDTH / 2) / SCREENWIDTH) + 1;
    if (currentPage == _myDateArray.count - 1)
    {
        courseBtn.hidden = NO;
        [courseBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        [courseBtn setTitle:[NSString stringWithFormat:@"第%ld疗程",(long)currentPage] forState:UIControlStateNormal];
        [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
        [alertCourseBtn setTitle:@"查看疗程" forState:UIControlStateNormal];
        currentCourseLabel.text = @"当前疗程";
        //疗程开、结束日期拼接
        TreatmentInfo *dicTmp = [_dateArray objectAtIndex:currentPage];
        NSString *startDateStr = [dicTmp.StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        NSString *endDateStr = [dicTmp.EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        dateLabel.text = [NSString stringWithFormat:@"%@-%@",[startDateStr substringWithRange:NSMakeRange(2, 8)],[endDateStr substringWithRange:NSMakeRange(2, 8)]];
    }
    else if (currentPage == 0)
    {
        courseBtn.hidden = YES;
        [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        [alertCourseBtn setTitle:[NSString stringWithFormat:@"第%ld疗程",(long)currentPage+2] forState:UIControlStateNormal];
        currentCourseLabel.text = [NSString stringWithFormat:@"第%ld疗程",(long)currentPage + 1];
        //疗程开、结束日期拼接
        TreatmentInfo *dicTmp = [_dateArray objectAtIndex:currentPage];
        NSString *startDateStr = [dicTmp.StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        NSString *endDateStr = [dicTmp.EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        dateLabel.text = [NSString stringWithFormat:@"%@-%@",[startDateStr substringWithRange:NSMakeRange(2, 8)],[endDateStr substringWithRange:NSMakeRange(2, 8)]];
    }
    else
    {
        courseBtn.hidden = NO;
        [courseBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        [courseBtn setTitle:[NSString stringWithFormat:@"第%ld疗程",(long)currentPage] forState:UIControlStateNormal];
        [alertCourseBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        [alertCourseBtn setTitle:[NSString stringWithFormat:@"第%ld疗程",(long)currentPage+2] forState:UIControlStateNormal];
        currentCourseLabel.text = [NSString stringWithFormat:@"第%ld疗程",(long)currentPage + 1];
        //疗程开、结束日期拼接
        TreatmentInfo *dicTmp = [_dateArray objectAtIndex:currentPage];
        NSString *startDateStr = [dicTmp.StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        NSString *endDateStr = [dicTmp.EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        dateLabel.text = [NSString stringWithFormat:@"%@-%@",[startDateStr substringWithRange:NSMakeRange(2, 8)],[endDateStr substringWithRange:NSMakeRange(2, 8)]];
    }
}

//创建疗程界面关于疗程部分视图
- (void)createCourseAboutView
{
    _courseAboutView = [[UIView alloc] initWithFrame:CGRectMake(0, 411*Rate_NAV_H, 375*Rate_NAV_W, 121*Rate_NAV_H)];
    _courseAboutView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_courseAboutView];
    
    UILabel *courseAboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 11*Rate_NAV_H, 80*Rate_NAV_W, 22*Rate_NAV_H)];
    courseAboutLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1];
    courseAboutLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    courseAboutLabel.textAlignment = NSTextAlignmentLeft;
    courseAboutLabel.text = @"关于疗程：";
    [_courseAboutView addSubview:courseAboutLabel];
    
    UILabel *courseContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 40*Rate_NAV_H, 331*Rate_NAV_W, 70*Rate_NAV_H)];
    courseContentLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    courseContentLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    courseContentLabel.textAlignment = NSTextAlignmentLeft;
    NSString *courseContentLabelText = @"标准疗程为4周，每天使用两次。建议上下午各一次，时间间隔3小时以上。";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:courseContentLabelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [courseContentLabelText length])];
    courseContentLabel.attributedText =  attributedString;
    courseContentLabel.numberOfLines = 0;
    [courseAboutLabel adjustsFontSizeToFitWidth];
    [_courseAboutView addSubview:courseContentLabel];
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
