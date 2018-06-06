//
//  SymptomViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/12/13.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SymptomView.h"
#import "Define.h"

#import "TreatmentInfo.h"
#import "FragmentInfo.h"

#import "YBStatusView.h"

@interface SymptomView ()<YBStatusViewDelegate,UIScrollViewDelegate>

/*
 *日期类型：
 *1.默认为0，表示周
 *2.为1时，表示月
 *3.为2时。表示季度
 */
@property (nonatomic, assign) NSInteger dateType;

@property (nonatomic, strong) UIView *symptomView;//症状view的第一部分视图（装载周月季度、症状描述数据显示）
@property (nonatomic ,strong) UIView *symptomAssessmentView;//症状评估部分视图
@property (nonatomic, strong) UIView *symptomChildView;//用于添加圆点说明的View

@property (nonatomic, strong) UIButton *leftBtn;//左箭头按钮
@property (nonatomic, strong) UIButton *rightBtn;//右箭头按钮

@property (nonatomic, strong) UIScrollView *symptomShowScroll;//症状描述
@property (nonatomic, strong) UIScrollView *dateShowScroll;//日期（周：日期；月：第几周；季度：第几疗程）
@property (nonatomic, strong) UIScrollView *dataShowScroll;//数据圆点

@property (nonatomic, strong) UIButton *moreSymptomBtn;//更多按钮

@property (nonatomic, copy) NSArray *dateArray;
@property (nonatomic, copy) NSArray *fragmentArray;
@property (nonatomic, copy) NSMutableArray *weekFragmentArray;
@property (nonatomic, copy) NSMutableArray *monthFragmentArray;
@property (nonatomic, copy) NSMutableArray *quarterFragmentArray;

@property (nonatomic, copy) NSArray *descArray;  //降序症状评估数组

@end

@implementation SymptomView
{
    int currentPage;
}

- (instancetype)initWithFrame:(CGRect)frame andDateArray:(NSArray *)dateArray andFragmentArray:(NSArray *)fragmentArray
{
    if (self == [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
        
        _dateArray = dateArray;
        _fragmentArray = fragmentArray;
        
        [self handleFragmentDataByWeek:fragmentArray];
        
        [self createSymptomView];
        
        //根据dateType加载不同的数据（默认先加载周）
        [self createSymptomDataViewByWeek];
        
        [self createSymptomAssessmentView];
    }
    
    return self;
}

//按周来对fragmentArray数组进行处理
- (void)handleFragmentDataByWeek:(NSArray *)fragmentArray
{
    _weekFragmentArray = [NSMutableArray array];
    
    TreatmentInfo *dicTmp = [_dateArray objectAtIndex:_dateArray.count-1];
    NSString *startDateStr = dicTmp.StartDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [dateFormatter dateFromString:startDateStr];
    for (int i = 0; i < 28; i++)
    {
        NSDate *tmpDate = [startDate dateByAddingTimeInterval:i*24*3600];
        NSString *tmpDateStr = [dateFormatter stringFromDate:tmpDate];
        NSString *key = [[tmpDateStr substringWithRange:NSMakeRange(5, 5)] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        
        FragmentInfo *tmp;
        for (FragmentInfo *fragTmp in fragmentArray)
        {
            if ([fragTmp.CollectDate isEqualToString:tmpDateStr])
            {
                tmp = fragTmp;
                break;
            }
        }
        if (tmp != nil)
        {
            NSArray *symptomArray = @[tmp.BadDream, tmp.SleepDifficult, tmp.EasyWakeUp, tmp.BreathDifficult, tmp.Cold, tmp.Snore, tmp.NightUp, tmp.Pain, tmp.Hot, tmp.Other];
            NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:symptomArray,key, nil];
            [_weekFragmentArray addObject:tmpDic];
        }
        else
        {
            NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
            if ([self dateTimeDifferenceWithStartTime:tmpDateStr endTime:currentDateStr] >= 0)//缺失
            {
                NSArray *symptomArray = @[@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1"];
                NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:symptomArray,key, nil];
                [_weekFragmentArray addObject:tmpDic];
            }
            else//时间未到
            {
                NSArray *symptomArray = @[@"-2",@"-2",@"-2",@"-2",@"-2",@"-2",@"-2",@"-2",@"-2",@"-2"];
                NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:symptomArray,key, nil];
                [_weekFragmentArray addObject:tmpDic];
            }
        }
    }
    [self symptomSort];
}

/**
 * 开始到结束的时间差的天数
 */
- (NSInteger)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *startD = [date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    NSInteger day = value / (24 * 3600);
    return day;
}


//计算哪些症状引起睡眠质量（排序）
- (void)symptomSort
{
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@{@"0":@"0"}, @{@"1":@"0"}, @{@"2":@"0"}, @{@"3":@"0"}, @{@"4":@"0"}, @{@"5":@"0"}, @{@"6":@"0"}, @{@"7":@"0"}, @{@"8":@"0"}, @{@"9":@"0"}, nil];
    for (int i = 0; i < _weekFragmentArray.count; i++)
    {
        NSArray *valueArray = [[_weekFragmentArray objectAtIndex:i] allValues][0];
        for (int j = 0; j < 10; j++)
        {
            NSString *strOne = [[arr objectAtIndex:j] allValues][0];
            NSString *strTwo = [valueArray objectAtIndex:j];
            NSString *str;
            if ([strTwo isEqualToString:@"-1"])
            {
                str = [NSString stringWithFormat:@"%d",[strOne intValue]];
            }
            else
            {
                str = [NSString stringWithFormat:@"%d",[strOne intValue]+[strTwo intValue]];
            }
            [arr replaceObjectAtIndex:j withObject:@{[NSString stringWithFormat:@"%d",j]:str}];
        }
    }
    //对arr数组进行排序（降序）
    _descArray = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSString *strOne = [obj1 allValues][0];
        NSString *strTwo = [obj2 allValues][0];
        if ([strOne intValue] >= [strTwo intValue])
        {
            return kCFCompareLessThan;
        }
        else
        {
            return kCFCompareGreaterThan;
        }
    }];
}

//按月来对fragmentArray数组进行处理
- (void)handleFragmentDataByMonth:(NSArray *)fragmentArray
{
    _monthFragmentArray = [NSMutableArray array];
    
    TreatmentInfo *dicTmp = [_dateArray objectAtIndex:_dateArray.count-1];
    NSString *startDateStr = dicTmp.StartDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [dateFormatter dateFromString:startDateStr];
    
    for (int i = 0; i < 4; i++)
    {
        int tmp_1 = 0,tmp_2 = 0,tmp_3 = 0,tmp_4 = 0,tmp_5 = 0,tmp_6 = 0,tmp_7 = 0,tmp_8 = 0,tmp_9 = 0,tmp_10 = 0;
        for (int j = 0; j < 7; j++)
        {
            NSDate *tmpDate = [startDate dateByAddingTimeInterval:(i*7+j)*24*3600];
            NSString *tmpDateStr = [dateFormatter stringFromDate:tmpDate];
            
            FragmentInfo *tmp;
            for (FragmentInfo *dic in fragmentArray)
            {
                if ([dic.CollectDate isEqualToString:tmpDateStr])
                {
                    tmp = dic;
                    break;
                }
            }
            if (tmp != nil)
            {
                tmp_1 += [tmp.BadDream intValue];
                tmp_2 += [tmp.SleepDifficult intValue];
                tmp_3 += [tmp.EasyWakeUp intValue];
                tmp_4 += [tmp.BreathDifficult intValue];
                tmp_5 += [tmp.Cold intValue];
                tmp_6 += [tmp.Snore intValue];
                tmp_7 += [tmp.NightUp intValue];
                tmp_8 += [tmp.Pain intValue];
                tmp_9 += [tmp.Hot intValue];
                tmp_10 += [tmp.Other intValue];
            }
        }
        NSString *key = [NSString stringWithFormat:@"第%d周",i+1];
        NSArray *symptomArray = @[[NSString stringWithFormat:@"%d",tmp_1],[NSString stringWithFormat:@"%d",tmp_2],[NSString stringWithFormat:@"%d",tmp_3],[NSString stringWithFormat:@"%d",tmp_4],[NSString stringWithFormat:@"%d",tmp_5],[NSString stringWithFormat:@"%d",tmp_6],[NSString stringWithFormat:@"%d",tmp_7],[NSString stringWithFormat:@"%d",tmp_8],[NSString stringWithFormat:@"%d",tmp_9],[NSString stringWithFormat:@"%d",tmp_10]];
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:symptomArray,key, nil];
        [_monthFragmentArray addObject:tmpDic];
    }
}

//按季度来对fragmentArray数组进行处理
- (void)handleFragmentDataByQuarter:(NSArray *)fragmentArray
{
    _quarterFragmentArray = [NSMutableArray array];
    
    for (int i = 0; i < _dateArray.count; i++)
    {
        TreatmentInfo *dicTmp = [_dateArray objectAtIndex:i];
        NSString *startDateStr = dicTmp.StartDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [dateFormatter dateFromString:startDateStr];
        
        int tmp_1 = 0,tmp_2 = 0,tmp_3 = 0,tmp_4 = 0,tmp_5 = 0,tmp_6 = 0,tmp_7 = 0,tmp_8 = 0,tmp_9 = 0,tmp_10 = 0;
        for (int j = 0; j < 28; j++)
        {
            NSDate *tmpDate = [startDate dateByAddingTimeInterval:j*24*3600];
            NSString *tmpDateStr = [dateFormatter stringFromDate:tmpDate];
            
            FragmentInfo *tmp;
            for (FragmentInfo *dic in fragmentArray)
            {
                if ([dic.CollectDate isEqualToString:tmpDateStr])
                {
                    tmp = dic;
                    break;
                }
            }
            if (tmp != nil)
            {
                tmp_1 += [tmp.BadDream intValue];
                tmp_2 += [tmp.SleepDifficult intValue];
                tmp_3 += [tmp.EasyWakeUp intValue];
                tmp_4 += [tmp.BreathDifficult intValue];
                tmp_5 += [tmp.Cold intValue];
                tmp_6 += [tmp.Snore intValue];
                tmp_7 += [tmp.NightUp intValue];
                tmp_8 += [tmp.Pain intValue];
                tmp_9 += [tmp.Hot intValue];
                tmp_10 += [tmp.Other intValue];
            }
        }
        NSString *key = [NSString stringWithFormat:@"第%d疗程",i+1];
        NSArray *symptomArray = @[[NSString stringWithFormat:@"%d",tmp_1],[NSString stringWithFormat:@"%d",tmp_2],[NSString stringWithFormat:@"%d",tmp_3],[NSString stringWithFormat:@"%d",tmp_4],[NSString stringWithFormat:@"%d",tmp_5],[NSString stringWithFormat:@"%d",tmp_6],[NSString stringWithFormat:@"%d",tmp_7],[NSString stringWithFormat:@"%d",tmp_8],[NSString stringWithFormat:@"%d",tmp_9],[NSString stringWithFormat:@"%d",tmp_10]];
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:symptomArray,key, nil];
        [_quarterFragmentArray addObject:tmpDic];
    }
}

#pragma -以下是症状选项的界面搭建、逻辑处理
- (void)createSymptomView
{
    _symptomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 453*Rate_NAV_H)];
    _symptomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_symptomView];
    
    YBStatusView *statusView = [[YBStatusView alloc] initWithFrame:CGRectMake(21*Rate_NAV_W, 20*Rate_NAV_H, 333*Rate_NAV_W, 27*Rate_NAV_H) andTitleArray:@[@"周",@"月",@"季度"]];
    statusView.delegate = self;
    [_symptomView addSubview:statusView];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(116*Rate_NAV_W, 56*Rate_NAV_H, 143*Rate_NAV_W, 22*Rate_NAV_H)];
    dateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    TreatmentInfo *dicTmpStart = [_dateArray objectAtIndex:_dateArray.count-1];
    TreatmentInfo *dicTmpEnd = [_dateArray objectAtIndex:_dateArray.count-1];
    NSString *startDateStr = [dicTmpStart.StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    NSString *endDateStr = [dicTmpEnd.EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    dateLabel.text = [NSString stringWithFormat:@"%@-%@",[startDateStr substringWithRange:NSMakeRange(2, 8)],[endDateStr substringWithRange:NSMakeRange(2, 8)]];
    [_symptomView addSubview:dateLabel];
}

//将疗程分组数组内元素进行排序
//冒泡排序
- (void)bubbleSort:(NSMutableArray *)array
{
    for (int j = 0; j < array.count-1; j++)
    {
        for (int i = 0; i < array.count-1-j; i++)
        {
            NSArray *index_One = [array objectAtIndex:i];
            NSArray *index_Two = [array objectAtIndex:i+1];
            
            NSDictionary *dicTmpOne = [index_One objectAtIndex:0];
            NSString *treatmentID_One = [dicTmpOne objectForKey:@"TreatmentID"];
            NSArray *arrayTmpOne = [treatmentID_One componentsSeparatedByString:@"-"]; //字符串按照'-'分隔成数组
            
            NSDictionary *dicTmpTwo = [index_Two objectAtIndex:0];
            NSString *treatmentID_Two = [dicTmpTwo objectForKey:@"TreatmentID"];
            NSArray *arrayTmpTwo = [treatmentID_Two componentsSeparatedByString:@"-"]; //字符串按照'-'分隔成数组
            
            if ([arrayTmpOne[0] intValue] >= [arrayTmpTwo[0] intValue])
            {
                [array exchangeObjectAtIndex:i withObjectAtIndex:i+1];
            }
        }
    }
}

//按周画图
- (void)createSymptomDataViewByWeek
{
    _symptomChildView = [[UIView alloc] initWithFrame:CGRectMake(21*Rate_NAV_W, 87*Rate_NAV_H, 333*Rate_NAV_W, 30*Rate_NAV_H)];
    _symptomChildView.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    [_symptomView addSubview:_symptomChildView];
    
    UIView *existView = [[UIView alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 7*Rate_NAV_H, 16*Rate_NAV_H, 16*Rate_NAV_H)];
    existView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x91/255.0 blue:0x5F/255.0 alpha:1];
    existView.layer.cornerRadius = 8*Rate_NAV_H;
    [_symptomChildView addSubview:existView];
    UILabel *existLabel = [[UILabel alloc] initWithFrame:CGRectMake(36*Rate_NAV_W, 0, 50*Rate_NAV_W, 30*Rate_NAV_H)];
    existLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    existLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    existLabel.text = @"：有症状";
    [_symptomChildView addSubview:existLabel];
    
    UIView *noExistView = [[UIView alloc] initWithFrame:CGRectMake(96*Rate_NAV_W, 7*Rate_NAV_H, 16*Rate_NAV_H, 16*Rate_NAV_H)];
    noExistView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    noExistView.layer.cornerRadius = 8*Rate_NAV_H;
    [_symptomChildView addSubview:noExistView];
    UILabel *noExistLabel = [[UILabel alloc] initWithFrame:CGRectMake(112*Rate_NAV_W, 0, 50*Rate_NAV_W, 30*Rate_NAV_H)];
    noExistLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    noExistLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    noExistLabel.text = @"：无症状";
    [_symptomChildView addSubview:noExistLabel];
    
    UIView *defectView = [[UIView alloc] initWithFrame:CGRectMake(172*Rate_NAV_W, 7*Rate_NAV_H, 16*Rate_NAV_H, 16*Rate_NAV_H)];
    defectView.backgroundColor = [UIColor whiteColor];
    defectView.layer.cornerRadius = 8*Rate_NAV_H;
    defectView.layer.borderWidth = 1;
    defectView.layer.borderColor = [UIColor colorWithRed:0xF0/255.0 green:0x64/255.0 blue:0x64/255.0 alpha:1].CGColor;
    [_symptomChildView addSubview:defectView];
    UILabel *defectLabel = [[UILabel alloc] initWithFrame:CGRectMake(188*Rate_NAV_W, 0, 50*Rate_NAV_W, 30*Rate_NAV_H)];
    defectLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    defectLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    defectLabel.text = @"：缺失";
    [_symptomChildView addSubview:defectLabel];
    
    UIView *noGoView = [[UIView alloc] initWithFrame:CGRectMake(248*Rate_NAV_W, 7*Rate_NAV_H, 16*Rate_NAV_H, 16*Rate_NAV_H)];
    noGoView.backgroundColor = [UIColor colorWithRed:0x14/255.0 green:0xB2/255.0 blue:0xCE/255.0 alpha:0.2];
    noGoView.layer.cornerRadius = 8*Rate_NAV_H;
    [_symptomChildView addSubview:noGoView];
    UILabel *noGoLabel = [[UILabel alloc] initWithFrame:CGRectMake(264*Rate_NAV_W, 0, 50*Rate_NAV_W, 30*Rate_NAV_H)];
    noGoLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    noGoLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    noGoLabel.text = @"：未进行";
    [_symptomChildView addSubview:noGoLabel];
    
    
    _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(67*Rate_NAV_W, 127*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
    [_leftBtn setImage:[UIImage imageNamed:@"diary_left_no"] forState:UIControlStateNormal];
    [_symptomView addSubview:_leftBtn];
    
    _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(341*Rate_NAV_W, 127*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
    [_rightBtn setImage:[UIImage imageNamed:@"diary_right_yes"] forState:UIControlStateNormal];
    [_symptomView addSubview:_rightBtn];
    
    //时间ScrollView
    _dateShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(91*Rate_NAV_W, 125*Rate_NAV_H, 240*Rate_NAV_W, 17*Rate_NAV_H)];
    _dateShowScroll.showsHorizontalScrollIndicator = NO;
    _dateShowScroll.showsVerticalScrollIndicator = NO;
    _dateShowScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, 70*(int)(_weekFragmentArray.count/2)*Rate_NAV_W + 30*Rate_NAV_W);
    _dateShowScroll.tag = 0;
    _dateShowScroll.delegate = self;
    [_symptomView addSubview:_dateShowScroll];
    //添加滑动日期
    for (int i = 0; i < _weekFragmentArray.count; i++)
    {
        if (i%2 == 0)
        {
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(70*(i/2)*Rate_NAV_W, 0, 30*Rate_NAV_W, 17*Rate_NAV_H)];
            dateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
            dateLabel.font = [UIFont systemFontOfSize:10*Rate_NAV_H];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            dateLabel.text = [[_weekFragmentArray objectAtIndex:i] allKeys][0];
            [_dateShowScroll addSubview:dateLabel];
        }
    }
    
    NSArray *labelTextArray = @[@"做噩梦",@"入睡困难",@"易醒早醒",@"呼吸不畅",@"感觉冷",@"咳嗽打鼾",@"起夜",@"疼痛不适",@"感觉热",@"其他"];
    //症状描述ScrollView
    _symptomShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(21*Rate_NAV_W, 152*Rate_NAV_H, 58*Rate_NAV_W, 220*Rate_NAV_H)];
    _symptomShowScroll.showsHorizontalScrollIndicator = NO;
    _symptomShowScroll.showsVerticalScrollIndicator = NO;
    [_symptomView addSubview:_symptomShowScroll];
    for (int i = 0; i < 10; i++)
    {
        UILabel *symptomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, i*38*Rate_NAV_H, 58*Rate_NAV_W, 20*Rate_NAV_H)];
        symptomLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        symptomLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        symptomLabel.textAlignment = NSTextAlignmentLeft;
        symptomLabel.text = [labelTextArray objectAtIndex:i];
        
        [_symptomShowScroll addSubview:symptomLabel];
    }
    
    //症状数据ScrollView
    _dataShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(98*Rate_NAV_W, 155*Rate_NAV_H, 255*Rate_NAV_W, 222*Rate_NAV_H)];
    _dataShowScroll.showsHorizontalScrollIndicator = NO;
    _dataShowScroll.showsVerticalScrollIndicator = NO;
    _dataShowScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, (35*_weekFragmentArray.count + 10)*Rate_NAV_W);
    _dataShowScroll.tag = 1;
    _dataShowScroll.delegate = self;
    [_symptomView addSubview:_dataShowScroll];
    //添加症状滑动数据点
    for (int i = 0; i < _weekFragmentArray.count; i++)
    {
        NSArray *tmpArr = [[_weekFragmentArray objectAtIndex:i] allObjects][0];
        for (int j = 0; j < 10; j++)
        {
            NSString *tmpStr = [tmpArr objectAtIndex:j];
            UIView *cicleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16*Rate_NAV_H, 16*Rate_NAV_H)];
            cicleView.center = CGPointMake(8*Rate_NAV_W + 35*i*Rate_NAV_W, 8*Rate_NAV_H + 38*j*Rate_NAV_H);
            cicleView.layer.cornerRadius = 8*Rate_NAV_H;
            [_dataShowScroll addSubview:cicleView];
            
            if ([tmpStr isEqualToString:@"-2"])
            {
                cicleView.backgroundColor = [UIColor colorWithRed:0x14/255.0 green:0xB2/255.0 blue:0xCE/255.0 alpha:0.2];
            }
            else if ([tmpStr isEqualToString:@"-1"])
            {
                cicleView.backgroundColor = [UIColor whiteColor];
                cicleView.layer.borderWidth = 1;
                cicleView.layer.borderColor = [UIColor colorWithRed:0xF0/255.0 green:0x64/255.0 blue:0x64/255.0 alpha:1].CGColor;
            }
            else if ([tmpStr isEqualToString:@"0"])
            {
                cicleView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
            }
            else if ([tmpStr isEqualToString:@"1"])
            {
                cicleView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x91/255.0 blue:0x5F/255.0 alpha:1];;
            }
        }
    }
    //症状第一部分视图最下方更多展开按钮
    _moreSymptomBtn = [[UIButton alloc] initWithFrame:CGRectMake(174.5*Rate_NAV_W, 424*Rate_NAV_H, 26*Rate_NAV_W, 14*Rate_NAV_H)];
    [_moreSymptomBtn setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
    [_moreSymptomBtn addTarget:self action:@selector(moreSymptomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_symptomView addSubview:_moreSymptomBtn];
}

//按月画图
- (void)createSymptomDataViewByMonth
{
    _symptomChildView = [[UIView alloc] initWithFrame:CGRectMake(21*Rate_NAV_W, 84*Rate_NAV_H, 333*Rate_NAV_W, 45*Rate_NAV_H)];
    _symptomChildView.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    [_symptomView addSubview:_symptomChildView];
    
    UIView *severeView = [[UIView alloc] initWithFrame:CGRectMake(11*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    severeView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x66/255.0 blue:0x64/255.0 alpha:1];
    severeView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:severeView];
    UILabel *severeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25*Rate_NAV_W, 9*Rate_NAV_H, 39*Rate_NAV_W, 12*Rate_NAV_H)];
    severeLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    severeLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    severeLabel.text = @"：重度";
    [_symptomChildView addSubview:severeLabel];
    
    UIView *moderateView = [[UIView alloc] initWithFrame:CGRectMake(78*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    moderateView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xB8/255.0 blue:0x5A/255.0 alpha:1];
    moderateView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:moderateView];
    UILabel *moderateLabel = [[UILabel alloc] initWithFrame:CGRectMake(92*Rate_NAV_W, 9*Rate_NAV_H, 38*Rate_NAV_W, 12*Rate_NAV_H)];
    moderateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    moderateLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    moderateLabel.text = @"：中度";
    [_symptomChildView addSubview:moderateLabel];
    
    UIView *slightView = [[UIView alloc] initWithFrame:CGRectMake(141*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    slightView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    slightView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:slightView];
    UILabel *slightLabel = [[UILabel alloc] initWithFrame:CGRectMake(155*Rate_NAV_W, 9*Rate_NAV_H, 38*Rate_NAV_W, 13*Rate_NAV_H)];
    slightLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    slightLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    slightLabel.text = @"：轻度";
    [_symptomChildView addSubview:slightLabel];
    
    UIView *noExistView = [[UIView alloc] initWithFrame:CGRectMake(197*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    noExistView.layer.borderWidth = 1;
    noExistView.layer.borderColor = [UIColor colorWithRed:0x33/255.0 green:0xC5/255.0 blue:0xDF/255.0 alpha:1].CGColor;
    noExistView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:noExistView];
    UILabel *noExistLabel = [[UILabel alloc] initWithFrame:CGRectMake(211*Rate_NAV_W, 9*Rate_NAV_H, 50*Rate_NAV_W, 12*Rate_NAV_H)];
    noExistLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    noExistLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    noExistLabel.text = @"：无症状";
    [_symptomChildView addSubview:noExistLabel];
    
    UIView *defectView = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    defectView.layer.borderWidth = 1;
    defectView.layer.borderColor = [UIColor colorWithRed:0xF0/255.0 green:0x64/255.0 blue:0x64/255.0 alpha:1].CGColor;
    defectView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:defectView];
    UILabel *defectLabel = [[UILabel alloc] initWithFrame:CGRectMake(285*Rate_NAV_W, 9*Rate_NAV_H, 37*Rate_NAV_W, 12*Rate_NAV_H)];
    defectLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    defectLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    defectLabel.text = @"：缺失";
    [_symptomChildView addSubview:defectLabel];
    
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(109*Rate_NAV_W, 26*Rate_NAV_H, 116*Rate_NAV_W, 19*Rate_NAV_H)];
    instructionLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    instructionLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    instructionLabel.text = @"数字为1周内症状次数";
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    [_symptomChildView addSubview:instructionLabel];
    
    _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(67*Rate_NAV_W, 136*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
    [_leftBtn setImage:[UIImage imageNamed:@"diary_left_no"] forState:UIControlStateNormal];
    [_symptomView addSubview:_leftBtn];
    
    _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(341*Rate_NAV_W, 136*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
    [_rightBtn setImage:[UIImage imageNamed:@"diary_right_yes"] forState:UIControlStateNormal];
    [_symptomView addSubview:_rightBtn];
    
    //时间ScrollView
    _dateShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(86*Rate_NAV_W, 134*Rate_NAV_H, 250*Rate_NAV_W, 17*Rate_NAV_H)];
    _dateShowScroll.showsHorizontalScrollIndicator = NO;
    _dateShowScroll.showsVerticalScrollIndicator = NO;
    _dateShowScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, (70*_monthFragmentArray.count - 30)*Rate_NAV_W);
    _dateShowScroll.tag = 0;
    _dateShowScroll.delegate = self;
    [_symptomView addSubview:_dateShowScroll];
    //添加滑动日期
    for (int i = 0; i < _monthFragmentArray.count; i++)
    {
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(70*i*Rate_NAV_W, 0, 40*Rate_NAV_W, 17*Rate_NAV_H)];
        dateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        dateLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.text = [[_monthFragmentArray objectAtIndex:i] allKeys][0];
        [_dateShowScroll addSubview:dateLabel];
    }
    
    NSArray *labelTextArray = @[@"做噩梦",@"入睡困难",@"易醒早醒",@"呼吸不畅",@"感觉冷",@"咳嗽打鼾",@"起夜",@"疼痛不适",@"感觉热",@"其他"];
    //症状描述ScrollView
    _symptomShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(21*Rate_NAV_W, 161*Rate_NAV_H, 58*Rate_NAV_W, 220*Rate_NAV_H)];
    _symptomShowScroll.showsHorizontalScrollIndicator = NO;
    _symptomShowScroll.showsVerticalScrollIndicator = NO;
    [_symptomView addSubview:_symptomShowScroll];
    for (int i = 0; i < 10; i++)
    {
        UILabel *symptomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (2+i*38)*Rate_NAV_H, 58*Rate_NAV_W, 20*Rate_NAV_H)];
        symptomLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        symptomLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        symptomLabel.textAlignment = NSTextAlignmentLeft;
        symptomLabel.text = [labelTextArray objectAtIndex:i];
        
        [_symptomShowScroll addSubview:symptomLabel];
    }
    
    //症状数据ScrollView
    _dataShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(86*Rate_NAV_W, 161*Rate_NAV_H, 267*Rate_NAV_W, 222*Rate_NAV_H)];
    _dataShowScroll.showsHorizontalScrollIndicator = NO;
    _dataShowScroll.showsVerticalScrollIndicator = NO;
    _dataShowScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, (70*_monthFragmentArray.count - 12)*Rate_NAV_W);
    _dataShowScroll.tag = 1;
    _dataShowScroll.delegate = self;
    [_symptomView addSubview:_dataShowScroll];
    //添加症状滑动数据点
    for (int i = 0; i < _monthFragmentArray.count; i++)
    {
        NSArray *numArray = [[_monthFragmentArray objectAtIndex:i] allValues][0];
        for (int j = 0; j < 10; j++)
        {
            UIButton *circleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22*Rate_NAV_H, 22*Rate_NAV_H)];
            circleBtn.center = CGPointMake(11*Rate_NAV_W + (9 + 70*i)*Rate_NAV_W, (12 + 38*j)*Rate_NAV_H);
            circleBtn.layer.cornerRadius = 11*Rate_NAV_H;
            circleBtn.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x66/255.0 blue:0x64/255.0 alpha:1];
            circleBtn.titleLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
            NSString *numStr = [numArray objectAtIndex:j];
            if ([numStr intValue] == 0)
            {
                [circleBtn setBackgroundColor:[UIColor whiteColor]];
                [circleBtn setTitleColor:[UIColor colorWithRed:0x33/255.0 green:0xC5/255.0 blue:0xDF/255.0 alpha:1] forState:UIControlStateNormal];
                circleBtn.layer.borderWidth = 1;
                circleBtn.layer.borderColor = [UIColor colorWithRed:0x33/255.0 green:0xC5/255.0 blue:0xDF/255.0 alpha:1].CGColor;
            }
            else if ([numStr intValue] >= 1 && [numStr intValue] <= 2)
            {
                [circleBtn setBackgroundColor:[UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1]];
                [circleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else if ([numStr intValue] >= 3 && [numStr intValue] <= 4)
            {
                [circleBtn setBackgroundColor:[UIColor colorWithRed:0xFF/255.0 green:0xB8/255.0 blue:0x5A/255.0 alpha:1]];
                [circleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else if ([numStr intValue] >= 5 && [numStr intValue] <= 7)
            {
                [circleBtn setBackgroundColor:[UIColor colorWithRed:0xFF/255.0 green:0xB8/255.0 blue:0x5A/255.0 alpha:1]];
                [circleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            [circleBtn setTitle:numStr forState:UIControlStateNormal];
            [circleBtn addTarget:self action:@selector(jumpToWeekDataShow:) forControlEvents:UIControlEventTouchUpInside];
            [_dataShowScroll addSubview:circleBtn];
        }
    }
    //症状第一部分视图最下方更多展开按钮
    _moreSymptomBtn = [[UIButton alloc] initWithFrame:CGRectMake(174.5*Rate_NAV_W, 424*Rate_NAV_H, 26*Rate_NAV_W, 14*Rate_NAV_H)];
    [_moreSymptomBtn setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
    [_moreSymptomBtn addTarget:self action:@selector(moreSymptomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_symptomView addSubview:_moreSymptomBtn];
}

//点击跳转到对应的周数据
- (void)jumpToWeekDataShow:(UIButton *)sender
{
    
}

//按季度画图
- (void)createSymptomDataViewByQuarter
{
    _symptomChildView = [[UIView alloc] initWithFrame:CGRectMake(21*Rate_NAV_W, 84*Rate_NAV_H, 333*Rate_NAV_W, 45*Rate_NAV_H)];
    _symptomChildView.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    [_symptomView addSubview:_symptomChildView];
    
    UIView *severeView = [[UIView alloc] initWithFrame:CGRectMake(11*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    severeView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x66/255.0 blue:0x64/255.0 alpha:1];
    severeView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:severeView];
    UILabel *severeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25*Rate_NAV_W, 9*Rate_NAV_H, 39*Rate_NAV_W, 12*Rate_NAV_H)];
    severeLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    severeLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    severeLabel.text = @"：重度";
    [_symptomChildView addSubview:severeLabel];
    
    UIView *moderateView = [[UIView alloc] initWithFrame:CGRectMake(78*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    moderateView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xB8/255.0 blue:0x5A/255.0 alpha:1];
    moderateView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:moderateView];
    UILabel *moderateLabel = [[UILabel alloc] initWithFrame:CGRectMake(92*Rate_NAV_W, 9*Rate_NAV_H, 38*Rate_NAV_W, 12*Rate_NAV_H)];
    moderateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    moderateLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    moderateLabel.text = @"：中度";
    [_symptomChildView addSubview:moderateLabel];
    
    UIView *slightView = [[UIView alloc] initWithFrame:CGRectMake(141*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    slightView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    slightView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:slightView];
    UILabel *slightLabel = [[UILabel alloc] initWithFrame:CGRectMake(155*Rate_NAV_W, 9*Rate_NAV_H, 38*Rate_NAV_W, 13*Rate_NAV_H)];
    slightLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    slightLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    slightLabel.text = @"：轻度";
    [_symptomChildView addSubview:slightLabel];
    
    UIView *noExistView = [[UIView alloc] initWithFrame:CGRectMake(197*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    noExistView.layer.borderWidth = 1;
    noExistView.layer.borderColor = [UIColor colorWithRed:0x33/255.0 green:0xC5/255.0 blue:0xDF/255.0 alpha:1].CGColor;
    noExistView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:noExistView];
    UILabel *noExistLabel = [[UILabel alloc] initWithFrame:CGRectMake(211*Rate_NAV_W, 9*Rate_NAV_H, 50*Rate_NAV_W, 12*Rate_NAV_H)];
    noExistLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    noExistLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    noExistLabel.text = @"：无症状";
    [_symptomChildView addSubview:noExistLabel];
    
    UIView *defectView = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 8*Rate_NAV_H, 14*Rate_NAV_H, 14*Rate_NAV_H)];
    defectView.layer.borderWidth = 1;
    defectView.layer.borderColor = [UIColor colorWithRed:0xF0/255.0 green:0x64/255.0 blue:0x64/255.0 alpha:1].CGColor;
    defectView.layer.cornerRadius = 7*Rate_NAV_H;
    [_symptomChildView addSubview:defectView];
    UILabel *defectLabel = [[UILabel alloc] initWithFrame:CGRectMake(285*Rate_NAV_W, 9*Rate_NAV_H, 37*Rate_NAV_W, 12*Rate_NAV_H)];
    defectLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    defectLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    defectLabel.text = @"：缺失";
    [_symptomChildView addSubview:defectLabel];
    
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(90*Rate_NAV_W, 26*Rate_NAV_H, 153*Rate_NAV_W, 19*Rate_NAV_H)];
    instructionLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    instructionLabel.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    instructionLabel.text = @"数字为1个疗程内症状次数";
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    [_symptomChildView addSubview:instructionLabel];
    
    _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(67*Rate_NAV_W, 136*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
    [_leftBtn setImage:[UIImage imageNamed:@"diary_left_no"] forState:UIControlStateNormal];
    [_symptomView addSubview:_leftBtn];
    
    _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(341*Rate_NAV_W, 136*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
    [_rightBtn setImage:[UIImage imageNamed:@"diary_right_yes"] forState:UIControlStateNormal];
    [_symptomView addSubview:_rightBtn];
    
    //时间ScrollView
    _dateShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(86*Rate_NAV_W, 134*Rate_NAV_H, 250*Rate_NAV_W, 17*Rate_NAV_H)];
    _dateShowScroll.showsHorizontalScrollIndicator = NO;
    _dateShowScroll.showsVerticalScrollIndicator = NO;
    _dateShowScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, (96*_quarterFragmentArray.count - 46)*Rate_NAV_W);
    _dateShowScroll.tag = 0;
    _dateShowScroll.delegate = self;
    [_symptomView addSubview:_dateShowScroll];
    //添加滑动日期
    for (int i = 0; i < _quarterFragmentArray.count; i++)
    {
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(96*i*Rate_NAV_W, 0, 50*Rate_NAV_W, 17*Rate_NAV_H)];
        dateLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        dateLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.text = [[_quarterFragmentArray objectAtIndex:i] allKeys][0];
        [_dateShowScroll addSubview:dateLabel];
    }
    
    NSArray *labelTextArray = @[@"做噩梦",@"入睡困难",@"易醒早醒",@"呼吸不畅",@"感觉冷",@"咳嗽打鼾",@"起夜",@"疼痛不适",@"感觉热",@"其他"];
    //症状描述ScrollView
    _symptomShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(21*Rate_NAV_W, 161*Rate_NAV_H, 58*Rate_NAV_W, 220*Rate_NAV_H)];
    _symptomShowScroll.showsHorizontalScrollIndicator = NO;
    _symptomShowScroll.showsVerticalScrollIndicator = NO;
    [_symptomView addSubview:_symptomShowScroll];
    for (int i = 0; i < 10; i++)
    {
        UILabel *symptomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (2 + i*38)*Rate_NAV_H, 58*Rate_NAV_W, 20*Rate_NAV_H)];
        symptomLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        symptomLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        symptomLabel.textAlignment = NSTextAlignmentLeft;
        symptomLabel.text = [labelTextArray objectAtIndex:i];
        
        [_symptomShowScroll addSubview:symptomLabel];
    }
    
    //症状数据ScrollView
    _dataShowScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(86*Rate_NAV_W, 161*Rate_NAV_H, 267*Rate_NAV_W, 222*Rate_NAV_H)];
    _dataShowScroll.showsHorizontalScrollIndicator = NO;
    _dataShowScroll.showsVerticalScrollIndicator = NO;
    _dataShowScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, (96*_quarterFragmentArray.count - 29)*Rate_NAV_W);
    _dataShowScroll.tag = 1;
    _dataShowScroll.delegate = self;
    [_symptomView addSubview:_dataShowScroll];
    //添加症状滑动数据点
    for (int i = 0; i < _quarterFragmentArray.count; i++)
    {
        NSArray *numArray = [[_quarterFragmentArray objectAtIndex:i] allValues][0];
        for (int j = 0; j < 10; j++)
        {
            UIButton *circleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22*Rate_NAV_H, 22*Rate_NAV_H)];
            circleBtn.center = CGPointMake(11*Rate_NAV_W + (15 + 96*i)*Rate_NAV_W, (12 + 38*j)*Rate_NAV_H);
            circleBtn.layer.cornerRadius = 11*Rate_NAV_H;
            circleBtn.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
            circleBtn.titleLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
            NSString *numStr = [numArray objectAtIndex:j];
            if ([numStr intValue] == 0)
            {
                [circleBtn setBackgroundColor:[UIColor whiteColor]];
                [circleBtn setTitleColor:[UIColor colorWithRed:0x33/255.0 green:0xC5/255.0 blue:0xDF/255.0 alpha:1] forState:UIControlStateNormal];
                circleBtn.layer.borderWidth = 1;
                circleBtn.layer.borderColor = [UIColor colorWithRed:0x33/255.0 green:0xC5/255.0 blue:0xDF/255.0 alpha:1].CGColor;
            }
            else if ([numStr intValue] >= 1 && [numStr intValue] <= 2)
            {
                [circleBtn setBackgroundColor:[UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1]];
                [circleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else if ([numStr intValue] >= 3 && [numStr intValue] <= 4)
            {
                [circleBtn setBackgroundColor:[UIColor colorWithRed:0xFF/255.0 green:0xB8/255.0 blue:0x5A/255.0 alpha:1]];
                [circleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else if ([numStr intValue] >= 5 && [numStr intValue] <= 7)
            {
                [circleBtn setBackgroundColor:[UIColor colorWithRed:0xFF/255.0 green:0xB8/255.0 blue:0x5A/255.0 alpha:1]];
                [circleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            [circleBtn setTitle:numStr forState:UIControlStateNormal];
            [_dataShowScroll addSubview:circleBtn];
        }
    }
    //症状第一部分视图最下方更多展开按钮
    _moreSymptomBtn = [[UIButton alloc] initWithFrame:CGRectMake(174.5*Rate_NAV_W, 424*Rate_NAV_H, 26*Rate_NAV_W, 14*Rate_NAV_H)];
    [_moreSymptomBtn setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
    [_moreSymptomBtn addTarget:self action:@selector(moreSymptomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_symptomView addSubview:_moreSymptomBtn];
}

#pragma UIScrollViewDelegate代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (scrollView.tag == 0)
    {
        //滑动_dateShowScroll并让_dataShowScroll同步滑动
        _dataShowScroll.contentOffset = scrollView.contentOffset;
    }
    else if (scrollView.tag == 1)
    {
        //滑动_dataShowScroll并让_dateShowScroll同步滑动
        _dateShowScroll.contentOffset = scrollView.contentOffset;
    }
}

- (void)statusViewSelectIndex:(NSInteger)index
{
    //选择周、月、季度时数据变更
    if (index == 0)
    {
        _dateType = 0;
        //去掉之前的视图
        [self removeViewFromSuperView];
        
        [self handleFragmentDataByWeek:_fragmentArray];
        //添加周显示视图
        [self createSymptomDataViewByWeek];
    }
    else if (index == 1)
    {
        _dateType = 1;
        //去掉之前的视图
        [self removeViewFromSuperView];
        
        [self handleFragmentDataByMonth:_fragmentArray];
        //添加月显示视图
        [self createSymptomDataViewByMonth];
    }
    else if (index == 2)
    {
        _dateType = 2;
        //去掉之前的视图
        [self removeViewFromSuperView];
        
        [self handleFragmentDataByQuarter:_fragmentArray];
        //添加季度显示视图
        [self createSymptomDataViewByQuarter];
    }
}
//将View的全局变量的子View移除并置空
- (void)removeViewFromSuperView
{
    if (_symptomChildView != nil)
    {
        [_symptomChildView removeFromSuperview];
        _symptomChildView = nil;
    }
    if (_dateShowScroll != nil)
    {
        [_dateShowScroll removeFromSuperview];
        _dateShowScroll = nil;
    }
    if (_symptomShowScroll != nil)
    {
        [_symptomShowScroll removeFromSuperview];
        _symptomShowScroll = nil;
    }
    if (_dataShowScroll != nil)
    {
        [_dataShowScroll removeFromSuperview];
        _dataShowScroll = nil;
    }
    if (_leftBtn != nil)
    {
        [_leftBtn removeFromSuperview];
        _leftBtn = nil;
    }
    if (_rightBtn != nil)
    {
        [_rightBtn removeFromSuperview];
        _rightBtn = nil;
    }
    if (_moreSymptomBtn != nil)
    {
        [_moreSymptomBtn removeFromSuperview];
        _moreSymptomBtn = nil;
    }
}

//症状第一部分视图最下方更多按钮点击事件
- (void)moreSymptomBtnClick:(UIButton *)sender
{
    if (sender.selected == NO)
    {
        _symptomAssessmentView.hidden = YES;
        _symptomView.frame = CGRectMake(0, 0, 375*Rate_NAV_W, 562*Rate_NAV_H);
        
        if (_dateType == 0)
        {
            _symptomShowScroll.frame = CGRectMake(21*Rate_NAV_W, 152*Rate_NAV_H, 56*Rate_NAV_W, 365*Rate_NAV_H);
            _dataShowScroll.frame = CGRectMake(98*Rate_NAV_W, 155*Rate_NAV_H, 255*Rate_NAV_W, 365*Rate_NAV_H);
        }
        else
        {
            _symptomShowScroll.frame = CGRectMake(21*Rate_NAV_W, 161*Rate_NAV_H, 56*Rate_NAV_W, 365*Rate_NAV_H);
            _dataShowScroll.frame = CGRectMake(86*Rate_NAV_W, 161*Rate_NAV_H, 267*Rate_NAV_W, 365*Rate_NAV_H);
        }
        
        sender.frame = CGRectMake(174.5*Rate_NAV_W, 538*Rate_NAV_H, 26*Rate_NAV_W, 14*Rate_NAV_H);
        [sender setImage:[UIImage imageNamed:@"icon_arrow_up"] forState:UIControlStateNormal];
        sender.selected = YES;
    }
    else
    {
        _symptomView.frame = CGRectMake(0, 0, 375*Rate_NAV_W, 453*Rate_NAV_H);
        _symptomAssessmentView.hidden = NO;
        
        
        if (_dateType == 0)
        {
            _symptomShowScroll.frame = CGRectMake(21*Rate_NAV_W, 152*Rate_NAV_H, 56*Rate_NAV_W, 222*Rate_NAV_H);
            _dataShowScroll.frame = CGRectMake(98*Rate_NAV_W, 155*Rate_NAV_H, 255*Rate_NAV_W, 222*Rate_NAV_H);
        }
        else
        {
            _symptomShowScroll.frame = CGRectMake(21*Rate_NAV_W, 161*Rate_NAV_H, 56*Rate_NAV_W, 222*Rate_NAV_H);
            _dataShowScroll.frame = CGRectMake(86*Rate_NAV_W, 161*Rate_NAV_H, 267*Rate_NAV_W, 222*Rate_NAV_H);
        }
        
        sender.frame = CGRectMake(174.5*Rate_NAV_W, 424*Rate_NAV_H, 26*Rate_NAV_W, 14*Rate_NAV_H);
        [sender setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
        sender.selected = NO;
    }
}

//创建症状评估View
- (void)createSymptomAssessmentView
{
    _symptomAssessmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 463*Rate_NAV_H, 375*Rate_NAV_W, 100*Rate_NAV_H)];
    _symptomAssessmentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_symptomAssessmentView];
    
    UILabel *symptomAssessmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 11*Rate_NAV_H, 80*Rate_NAV_W, 22*Rate_NAV_H)];
    symptomAssessmentLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0xB9/255.0 blue:0xD1/255.0 alpha:1];
    symptomAssessmentLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    symptomAssessmentLabel.textAlignment = NSTextAlignmentLeft;
    symptomAssessmentLabel.text = @"症状评估";
    [_symptomAssessmentView addSubview:symptomAssessmentLabel];
    
    UILabel *symptomLabel = [[UILabel alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 40*Rate_NAV_H, 331*Rate_NAV_W, 44*Rate_NAV_H)];
    symptomLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    symptomLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    symptomLabel.textAlignment = NSTextAlignmentLeft;
    symptomLabel.numberOfLines = 2;
    NSString *str_Text;
    for (int i = 0; i < 3; i++)
    {
        NSString *strTmp;
        if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"0"])
        {
            strTmp = @"做噩梦";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"1"])
        {
            strTmp = @"入睡困难";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"2"])
        {
            strTmp = @"易醒早醒";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"3"])
        {
            strTmp = @"呼吸不畅";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"4"])
        {
            strTmp = @"感觉冷";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"5"])
        {
            strTmp = @"咳嗽打鼾";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"6"])
        {
            strTmp = @"起夜";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"7"])
        {
            strTmp = @"疼痛不适";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"8"])
        {
            strTmp = @"感觉热";
        }
        else if ([[[_descArray objectAtIndex:i] allKeys][0] isEqualToString:@"9"])
        {
            strTmp = @"其他";
        }
        if (i == 0)
        {
            str_Text = strTmp;
        }
        else
        {
            str_Text = [str_Text stringByAppendingString:[NSString stringWithFormat:@"、%@",strTmp]];
        }
    }
    NSString *symptomLabelText = [NSString stringWithFormat:@"您的失眠症状主要表现为%@",str_Text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:symptomLabelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [symptomLabelText length])];
    symptomLabel.attributedText = attributedString;
    [_symptomAssessmentView addSubview:symptomLabel];
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
