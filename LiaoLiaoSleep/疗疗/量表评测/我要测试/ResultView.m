//
//  ResultView.m
//  Assessment
//
//  Created by 诺之家 on 16/10/20.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "ResultView.h"

#import "Define.h"

#import "InterfaceModel.h"
#import "DataBaseOpration.h"

#import "GaugeTestViewController.h"
#import "CustomerChatViewController.h"
#import "DoctorHomeViewController.h"

@interface ResultView()

@property (nonatomic, strong) NSString *typeFlag;
@property (nonatomic, strong) NSString *typeString;
@property (nonatomic, strong) PatientInfo *patientInfo;
@property (nonatomic, copy) NSMutableArray *resultArray;

@property (nonatomic, copy)        NSArray *sleepTipsArray;           //存储睡眠贴士的23条建议
@property (nonatomic, copy) NSMutableArray *sleepTipsResultArray;//存储睡眠贴士结果包括哪几条
@property (nonatomic, copy)        NSArray *depressedTipsArray;           //存储抑郁的23条建议
@property (nonatomic, copy) NSMutableArray *depressedTipsResultArray;//存储抑郁结果包括哪几条
@property (nonatomic, copy)        NSArray *anxiousTipsArray;           //存储焦虑的23条建议
@property (nonatomic, copy) NSMutableArray *anxiousTipsResultArray;//存储焦虑结果包括哪几条
@property (nonatomic, copy)        NSArray *bodyTipsArray;           //存储躯体的23条建议
@property (nonatomic, copy) NSMutableArray *bodyTipsResultArray;//存储躯体结果包括哪几条

@property (nonatomic, strong) UIImageView *partOneView;
@property (nonatomic, strong) UIImageView *partTwoView;
@property (nonatomic, strong) UIImageView *partThreeView;
@property (nonatomic, strong) UIImageView *partFourView;

@end

@implementation ResultView
{
    NSInteger Mark;                        //记录测评的分数
    UILabel *markLabel;
    NSString *result;
    NSString *recordDate;
    
    NSInteger A_mark;   //睡眠质量分数
    NSInteger B_mark;   //入睡时间分数
    NSInteger C_mark;   //睡眠时间分数
    NSInteger D_mark;   //睡眠效率分数
    NSInteger E_mark;   //睡眠障碍分数
    NSInteger F_mark;   //催眠药物分数
    NSInteger G_mark;   //日间功能障碍分数
}

- (instancetype)initWithScaleData:(NSArray *)resultArray andType:(NSString *)typeStr andPatientInfo:(PatientInfo *)patientInfo andFlag:(NSString *)flagString
{
    self = [super init];
    if (self)
    {
        if ([typeStr isEqualToString:@"匹兹堡睡眠指数"])
        {
            _resultArray = [NSMutableArray array];
            for (int i = 0; i < resultArray.count; i++)
            {
                if ([[resultArray objectAtIndex:i] isEqualToString:@"4"] && i >= 4)
                {
                    [_resultArray addObject:@"0"];
                }
                else
                {
                    [_resultArray addObject:[resultArray objectAtIndex:i]];
                }
            }
        }
        else
        {
            _resultArray = [NSMutableArray arrayWithArray:resultArray];
        }
        _patientInfo = patientInfo;
        _typeFlag = flagString;
        _typeString = typeStr;
        _resultScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _resultScrollView.contentSize = CGSizeMake(375*Ratio_W,1393*Ratio_W);
        [self addSubview:_resultScrollView];
        _resultScrollView.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
        if ([typeStr isEqualToString:@"匹兹堡睡眠指数"])
        {
            NSString *sleepTipsPath = [[NSBundle mainBundle] pathForResource:@"SleepTipsList" ofType:@"plist"];
            _sleepTipsArray = [NSArray arrayWithContentsOfFile:sleepTipsPath];
            _sleepTipsResultArray = [NSMutableArray array];
            
            [self markForResult];
            //对应量表根据答题选项得出的建议
            [self addSleepTips];
            [self addPittsburghResultView];
            //数据持久化
            [self evaluateDatePersistence];
            //上传匹兹堡睡眠表的答案
            InterfaceModel *interfaceM = [[InterfaceModel alloc] init];
            [interfaceM sendScaleResultToServerWithResultArray:_resultArray andType:_typeString andDate:recordDate andScore:[NSString stringWithFormat:@"%ld",Mark] andResult:result andPatientID:patientInfo.PatientID];
        }
        else if ([typeStr isEqualToString:@"抑郁自评"])
        {
            NSString *sleepTipsPath = [[NSBundle mainBundle] pathForResource:@"DepressedTipsList" ofType:@"plist"];
            _depressedTipsArray = [NSArray arrayWithContentsOfFile:sleepTipsPath];
            _depressedTipsResultArray = [NSMutableArray array];
            
            [self markForResult];
            //对应量表根据答题选项得出的建议
            [self addDepressedTips];
            [self addDepressedResultView];
            //数据持久化
            [self evaluateDatePersistence];
        }
        else if ([typeStr isEqualToString:@"焦虑自评"])
        {
            NSString *sleepTipsPath = [[NSBundle mainBundle] pathForResource:@"AnxiousTipsList" ofType:@"plist"];
            _anxiousTipsArray = [NSArray arrayWithContentsOfFile:sleepTipsPath];
            _anxiousTipsResultArray = [NSMutableArray array];
            
            [self markForResult];
            //对应量表根据答题选项得出的建议
            [self addAnxiousTips];
            [self addAnxiousResultView];
            //数据持久化
            [self evaluateDatePersistence];
        }
        else if ([typeStr isEqualToString:@"躯体自评"])
        {
            NSString *sleepTipsPath = [[NSBundle mainBundle] pathForResource:@"BodyTipsList" ofType:@"plist"];
            _bodyTipsArray = [NSArray arrayWithContentsOfFile:sleepTipsPath];
            _bodyTipsResultArray = [NSMutableArray array];
            
            [self markForResult];
            //对应量表根据答题选项得出的建议
            [self addBodyTips];
            [self addBodyResultView];
            //数据持久化
            [self evaluateDatePersistence];
        }
    }
    
    return self;
}

//添加匹兹堡睡眠指数结果
- (void)addPittsburghResultView
{
    [self createPartOneView];
    [self createPartTwoView];
    [self createPartThreeView];
    [self createPartFourView];
}

//添加抑郁自评结果
- (void)addDepressedResultView
{
    [self createPartOneView];
    [self createPartFourView];
}

//添加焦虑自评结果
- (void)addAnxiousResultView
{
    [self createPartOneView];
    [self createPartFourView];
}

//添加躯体自评结果
- (void)addBodyResultView
{
    [self createPartOneView];
    [self createPartFourView];
}

- (void)evaluateDatePersistence
{
    DataBaseOpration *opration = [[DataBaseOpration alloc] init];
    NSArray *evaluateInfoArray = [opration getEvaluateDataFromDataBase];
    
    //保存睡眠评估数据
    EvaluateInfo *tmpEvaluate = [[EvaluateInfo alloc] init];
    tmpEvaluate.PatientID = _patientInfo.PatientID;
    
    if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
    {
        tmpEvaluate.ListFlag = @"1";
    }
    else if ([_typeString isEqualToString:@"抑郁自评"])
    {
        tmpEvaluate.ListFlag = @"2";
    }
    else if ([_typeString isEqualToString:@"焦虑自评"])
    {
        tmpEvaluate.ListFlag = @"3";
    }
    else if ([_typeString isEqualToString:@"躯体自评"])
    {
        tmpEvaluate.ListFlag = @"4";
    }
    
    NSDateFormatter *dateFormatterDate = [[NSDateFormatter alloc] init];
    [dateFormatterDate setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatterDate stringFromDate:[NSDate date]];
    tmpEvaluate.Date = strDate;
    
    NSDateFormatter *dateFormatTime=[[NSDateFormatter alloc] init];
    [dateFormatTime setDateFormat:@"HH:mm:ss"];
    NSString *strTime = [dateFormatTime stringFromDate:[NSDate date]];
    tmpEvaluate.Time = strTime;
    
    tmpEvaluate.Score = [NSString stringWithFormat:@"%ld",(long)Mark];
    tmpEvaluate.Quality = result;
    
    EvaluateInfo *contain=[[EvaluateInfo alloc] init];
    for (EvaluateInfo *tmp in evaluateInfoArray)
    {
        if ([tmp.Date isEqualToString:tmpEvaluate.Date] && [tmp.ListFlag isEqualToString:tmpEvaluate.ListFlag] && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
        {
            contain = tmp;
        }
    }
    //初始化数据库，并打开数据库
    DataBaseOpration *dbOption = [[DataBaseOpration alloc] init];
    if (contain.Date != nil)
    {
        //更新睡眠评估数据库数据
        [dbOption updateEvaluateInfo:tmpEvaluate];
        [dbOption closeDataBase];
    }
    else
    {
        //插入睡眠评估数据库数据
        [dbOption insertEvaluateInfo:tmpEvaluate];
        [dbOption closeDataBase];
    }
    
    //将评估数据上传到服务器
    InterfaceModel *interfaceM = [[InterfaceModel alloc] init];
    [interfaceM insertEvaluateInfoToServer:tmpEvaluate];
}

//创建第一部分视图
- (void)createPartOneView
{
    //第一部分评分视图
    _partOneView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 348*Ratio_NAV_H)];
    [_partOneView setImage:[UIImage imageNamed:@"result_bg"]];
    [_resultScrollView addSubview:_partOneView];
    
    UIImageView *markBgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 184*Rate_NAV_H)/2, 42*Rate_NAV_H, 184*Rate_NAV_H, 184*Rate_NAV_H)];
    [markBgView setImage:[UIImage imageNamed:@"mark_bg"]];
    [_resultScrollView addSubview:markBgView];
    
    markLabel = [[UILabel alloc] initWithFrame:CGRectMake(75*Rate_NAV_H, 45*Rate_NAV_H, 34*Rate_NAV_H, 60*Rate_NAV_H)];
    markLabel.font = [UIFont systemFontOfSize:60*Rate_NAV_H];
    markLabel.textColor = [UIColor whiteColor];
    markLabel.textAlignment = NSTextAlignmentRight;
    markLabel.adjustsFontSizeToFitWidth = YES;
    markLabel.text = [NSString stringWithFormat:@"%ld",Mark];
    [markBgView addSubview:markLabel];
    
    UILabel *label_one = [[UILabel alloc] initWithFrame:CGRectMake(107*Rate_NAV_H, 86*Rate_NAV_H, 12*Rate_NAV_H, 12*Rate_NAV_H)];
    label_one.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    label_one.textColor = [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:0.7];
    label_one.textAlignment = NSTextAlignmentCenter;
    label_one.text = @"分";
    [markBgView addSubview:label_one];
    
    UILabel *label_two = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_NAV_H, 107*Rate_NAV_H, 84*Rate_NAV_H, 17*Rate_NAV_H)];
    label_two.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    label_two.adjustsFontSizeToFitWidth = YES;
    label_two.textColor = [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:0.7];
    label_two.textAlignment = NSTextAlignmentCenter;
    if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
    {
        label_two.text = @"您的睡眠指数";
    }
    else if ([_typeString isEqualToString:@"抑郁自评"])
    {
        label_two.text = @"您的抑郁症状指数";
    }
    else if ([_typeString isEqualToString:@"焦虑自评"])
    {
        label_two.text = @"您的焦虑症状指数";
    }
    else if ([_typeString isEqualToString:@"躯体自评"])
    {
        label_two.text = @"您的躯体症状指数";
    }
    
    [markBgView addSubview:label_two];
    
    UILabel *label_three = [[UILabel alloc] initWithFrame:CGRectMake(88*Rate_NAV_W, 242*Rate_NAV_H, 199*Rate_NAV_W, 27*Rate_NAV_H)];
    label_three.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    label_three.textColor = [UIColor whiteColor];
    label_three.textAlignment = NSTextAlignmentCenter;
    if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
    {
        if (Mark >= 0 && Mark <= 5)
        {
            label_three.text = @"睡眠质量很好";
            result = @"睡眠质量很好";
        }
        else if (Mark >= 6 && Mark <= 10)
        {
            label_three.text = @"睡眠质量一般";
            result = @"睡眠质量一般";
        }
        else if (Mark >= 11 && Mark <= 15)
        {
            label_three.text = @"睡眠质量较差";
            result = @"睡眠质量较差";
        }
        else if (Mark >= 16 && Mark <= 21)
        {
            label_three.text = @"睡眠质量很差";
            result = @"睡眠质量很差";
        }
    }
    else if ([_typeString isEqualToString:@"抑郁自评"])
    {
        if (Mark == 0)
        {
            label_three.text = @"没有抑郁";
            result = @"没有抑郁";
        }
        else if (Mark > 0 && Mark < 9)
        {
            label_three.text = @"轻度抑郁";
            result = @"轻度抑郁";
        }
        else if (Mark >= 9 && Mark < 18)
        {
            label_three.text = @"中度抑郁";
            result = @"中度抑郁";
        }
        else if (Mark >= 18 && Mark < 27)
        {
            label_three.text = @"重度抑郁";
            result = @"重度抑郁";
        }
    }
    else if ([_typeString isEqualToString:@"焦虑自评"])
    {
        if (Mark == 0)
        {
            label_three.text = @"没有焦虑";
            result = @"没有焦虑";
        }
        else if (Mark > 0 && Mark < 7)
        {
            label_three.text = @"轻度焦虑";
            result = @"轻度焦虑";
        }
        else if (Mark >= 7 && Mark < 14)
        {
            label_three.text = @"中度焦虑";
            result = @"中度焦虑";
        }
        else if (Mark >= 14 && Mark <= 21)
        {
            label_three.text = @"重度焦虑";
            result = @"重度焦虑";
        }
    }
    else if ([_typeString isEqualToString:@"躯体自评"])
    {
        if (Mark >= 0 && Mark <= 4)
        {
            label_three.text = @"没有躯体症状";
            result = @"没有躯体症状";
        }
        else if (Mark >= 5 && Mark <= 9)
        {
            label_three.text = @"轻度躯体症状";
            result = @"轻度躯体症状";
        }
        else if (Mark >= 9 && Mark <= 14)
        {
            label_three.text = @"中度躯体症状";
            result = @"中度躯体症状";
        }
        else if (Mark >= 15)
        {
            label_three.text = @"重度躯体症状";
            result = @"重度躯体症状";
        }
    }
    [_partOneView addSubview:label_three];
    
    UILabel *label_four = [[UILabel alloc] initWithFrame:CGRectMake(88*Rate_NAV_W, 269*Rate_NAV_H, 199*Rate_NAV_W, 27*Rate_NAV_H)];
    label_four.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    label_four.textColor = [UIColor whiteColor];
    label_four.textAlignment = NSTextAlignmentCenter;
    label_four.text = @"建议使用疗疗失眠进行治疗";
    if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
    {
        if ([result isEqualToString:@"睡眠质量很好"])
        {
            label_four.text = @"请继续保持";
        }
        else
        {
            label_four.text = @"建议使用疗疗失眠进行治疗";
        }
    }
    else if ([_typeString isEqualToString:@"抑郁自评"])
    {
        if ([result isEqualToString:@"没有抑郁"])
        {
            label_four.text = @"请继续保持";
        }
        else
        {
            label_four.text = @"建议引起关注并及时就医";
        }
    }
    else if ([_typeString isEqualToString:@"焦虑自评"])
    {
        if ([result isEqualToString:@"没有焦虑"])
        {
            label_four.text = @"请继续保持";
        }
        else
        {
            label_four.text = @"建议引起关注并及时就医";
        }
    }
    else if ([_typeString isEqualToString:@"躯体自评"])
    {
        if ([result isEqualToString:@"没有躯体症状"])
        {
            label_four.text = @"请继续保持";
        }
        else
        {
            label_four.text = @"建议引起关注并及时就医";
        }
    }
    [_partOneView addSubview:label_four];
    
    UILabel *label_date = [[UILabel alloc] initWithFrame:CGRectMake(140*Rate_NAV_W, 314*Rate_NAV_H, 95*Rate_NAV_W, 17*Rate_NAV_H)];
    label_date.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    label_date.textColor = [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:0.5];
    label_date.textAlignment = NSTextAlignmentCenter;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    label_date.text = [dateFormatter stringFromDate:[NSDate date]];
    [_partOneView addSubview:label_date];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    recordDate = [dateFormatter stringFromDate:[NSDate date]];
}

//创建第二部分视图
- (void)createPartTwoView
{
    //第二部分睡眠质量评估条形图表
    _partTwoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 340*Rate_NAV_H, 375*Rate_NAV_W, 248*Rate_NAV_H)];
    _partTwoView.image = [UIImage imageNamed:@"mark_panel"];
    [_resultScrollView addSubview:_partTwoView];
    
    //设置字间距
    NSDictionary *dicTwo = @{NSKernAttributeName:@1.0f};
    
    UILabel *sleepQualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(47*Rate_NAV_W, 26*Rate_NAV_H, 104*Rate_NAV_W, 28*Rate_NAV_H)];
    sleepQualityLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    sleepQualityLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    sleepQualityLabel.textAlignment = NSTextAlignmentRight;
    sleepQualityLabel.attributedText = [[NSAttributedString alloc] initWithString:@"睡眠质量：" attributes:dicTwo];
    [_partTwoView addSubview:sleepQualityLabel];
    UIView *sleepQualityViewOne = [[UIView alloc] initWithFrame:CGRectMake(163*Rate_NAV_W, 35*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepQualityViewTwo = [[UIView alloc] initWithFrame:CGRectMake(199*Rate_NAV_W, 35*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepQualityViewThree = [[UIView alloc] initWithFrame:CGRectMake(235*Rate_NAV_W, 35*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepQualityViewFour = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 35*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    if (A_mark == 0)
    {
        sleepQualityViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepQualityViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.4];
        sleepQualityViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepQualityViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (A_mark == 1)
    {
        sleepQualityViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepQualityViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepQualityViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepQualityViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (A_mark == 2)
    {
        sleepQualityViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepQualityViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepQualityViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepQualityViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (A_mark == 3)
    {
        sleepQualityViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepQualityViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepQualityViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepQualityViewFour.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x56/255.0 blue:0x65/255.0 alpha:1];
    }
    [_partTwoView addSubview:sleepQualityViewOne];
    [_partTwoView addSubview:sleepQualityViewTwo];
    [_partTwoView addSubview:sleepQualityViewThree];
    [_partTwoView addSubview:sleepQualityViewFour];
    
    
    UILabel *fallAsleepTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(47*Rate_NAV_W, 54*Rate_NAV_H, 104*Rate_NAV_W, 28*Rate_NAV_H)];
    fallAsleepTimeLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    fallAsleepTimeLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    fallAsleepTimeLabel.textAlignment = NSTextAlignmentRight;
    fallAsleepTimeLabel.attributedText = [[NSAttributedString alloc] initWithString:@"入睡时间：" attributes:dicTwo];
    [_partTwoView addSubview:fallAsleepTimeLabel];
    UIView *fallAsleepTimeViewOne = [[UIView alloc] initWithFrame:CGRectMake(163*Rate_NAV_W, 63*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *fallAsleepTimeViewTwo = [[UIView alloc] initWithFrame:CGRectMake(199*Rate_NAV_W, 63*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *fallAsleepTimeViewThree = [[UIView alloc] initWithFrame:CGRectMake(235*Rate_NAV_W, 63*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *fallAsleepTimeViewFour = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 63*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    if (B_mark == 0)
    {
        fallAsleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        fallAsleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.4];
        fallAsleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        fallAsleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (B_mark == 1)
    {
        fallAsleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        fallAsleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        fallAsleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        fallAsleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (B_mark == 2)
    {
        fallAsleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        fallAsleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        fallAsleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        fallAsleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (B_mark == 3)
    {
        fallAsleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        fallAsleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        fallAsleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        fallAsleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x56/255.0 blue:0x65/255.0 alpha:1];
    }
    [_partTwoView addSubview:fallAsleepTimeViewOne];
    [_partTwoView addSubview:fallAsleepTimeViewTwo];
    [_partTwoView addSubview:fallAsleepTimeViewThree];
    [_partTwoView addSubview:fallAsleepTimeViewFour];
    
    UILabel *sleepTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(47*Rate_NAV_W, 82*Rate_NAV_H, 104*Rate_NAV_W, 28*Rate_NAV_H)];
    sleepTimeLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    sleepTimeLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    sleepTimeLabel.textAlignment = NSTextAlignmentRight;
    sleepTimeLabel.attributedText = [[NSAttributedString alloc] initWithString:@"睡眠时间：" attributes:dicTwo];
    [_partTwoView addSubview:sleepTimeLabel];
    UIView *sleepTimeViewOne = [[UIView alloc] initWithFrame:CGRectMake(163*Rate_NAV_W, 90*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepTimeViewTwo = [[UIView alloc] initWithFrame:CGRectMake(199*Rate_NAV_W, 90*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepTimeViewThree = [[UIView alloc] initWithFrame:CGRectMake(235*Rate_NAV_W, 90*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepTimeViewFour = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 90*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    if (C_mark == 0)
    {
        sleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.4];
        sleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (C_mark == 1)
    {
        sleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (C_mark == 2)
    {
        sleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (C_mark == 3)
    {
        sleepTimeViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepTimeViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepTimeViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepTimeViewFour.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x56/255.0 blue:0x65/255.0 alpha:1];
    }
    [_partTwoView addSubview:sleepTimeViewOne];
    [_partTwoView addSubview:sleepTimeViewTwo];
    [_partTwoView addSubview:sleepTimeViewThree];
    [_partTwoView addSubview:sleepTimeViewFour];
    
    UILabel *sleepEfficiencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(47*Rate_NAV_W, 110*Rate_NAV_H, 104*Rate_NAV_W, 28*Rate_NAV_H)];
    sleepEfficiencyLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    sleepEfficiencyLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    sleepEfficiencyLabel.textAlignment = NSTextAlignmentRight;
    sleepEfficiencyLabel.attributedText = [[NSAttributedString alloc] initWithString:@"睡眠效率：" attributes:dicTwo];
    [_partTwoView addSubview:sleepEfficiencyLabel];
    UIView *sleepEfficiencyViewOne = [[UIView alloc] initWithFrame:CGRectMake(163*Rate_NAV_W, 118*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepEfficiencyViewTwo = [[UIView alloc] initWithFrame:CGRectMake(199*Rate_NAV_W, 118*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepEfficiencyViewThree = [[UIView alloc] initWithFrame:CGRectMake(235*Rate_NAV_W, 118*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepEfficiencyViewFour = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 118*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    if (D_mark == 0)
    {
        sleepEfficiencyViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepEfficiencyViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.4];
        sleepEfficiencyViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepEfficiencyViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (D_mark == 1)
    {
        sleepEfficiencyViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepEfficiencyViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepEfficiencyViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepEfficiencyViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (D_mark == 2)
    {
        sleepEfficiencyViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepEfficiencyViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepEfficiencyViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepEfficiencyViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (D_mark == 3)
    {
        sleepEfficiencyViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepEfficiencyViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepEfficiencyViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepEfficiencyViewFour.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x56/255.0 blue:0x65/255.0 alpha:1];
    }
    [_partTwoView addSubview:sleepEfficiencyViewOne];
    [_partTwoView addSubview:sleepEfficiencyViewTwo];
    [_partTwoView addSubview:sleepEfficiencyViewThree];
    [_partTwoView addSubview:sleepEfficiencyViewFour];
    
    UILabel *sleepObstacleLabel = [[UILabel alloc] initWithFrame:CGRectMake(47*Rate_NAV_W, 138*Rate_NAV_H, 104*Rate_NAV_W, 28*Rate_NAV_H)];
    sleepObstacleLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    sleepObstacleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    sleepObstacleLabel.textAlignment = NSTextAlignmentRight;
    sleepObstacleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"睡眠障碍：" attributes:dicTwo];
    [_partTwoView addSubview:sleepObstacleLabel];
    UIView *sleepObstacleViewOne = [[UIView alloc] initWithFrame:CGRectMake(163*Rate_NAV_W, 146*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepObstacleViewTwo = [[UIView alloc] initWithFrame:CGRectMake(199*Rate_NAV_W, 146*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepObstacleViewThree = [[UIView alloc] initWithFrame:CGRectMake(235*Rate_NAV_W, 146*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepObstacleViewFour = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 146*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    if (E_mark == 0)
    {
        sleepObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.4];
        sleepObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (E_mark == 1)
    {
        sleepObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (E_mark == 2)
    {
        sleepObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (E_mark == 3)
    {
        sleepObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x56/255.0 blue:0x65/255.0 alpha:1];
    }
    [_partTwoView addSubview:sleepObstacleViewOne];
    [_partTwoView addSubview:sleepObstacleViewTwo];
    [_partTwoView addSubview:sleepObstacleViewThree];
    [_partTwoView addSubview:sleepObstacleViewFour];
    
    UILabel *sleepMedicineLabel = [[UILabel alloc] initWithFrame:CGRectMake(47*Rate_NAV_W, 166*Rate_NAV_H, 104*Rate_NAV_W, 28*Rate_NAV_H)];
    sleepMedicineLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    sleepMedicineLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    sleepMedicineLabel.textAlignment = NSTextAlignmentRight;
    sleepMedicineLabel.attributedText = [[NSAttributedString alloc] initWithString:@"催眠药物：" attributes:dicTwo];
    [_partTwoView addSubview:sleepMedicineLabel];
    UIView *sleepMedicineViewOne = [[UIView alloc] initWithFrame:CGRectMake(163*Rate_NAV_W, 174*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepMedicineViewTwo = [[UIView alloc] initWithFrame:CGRectMake(199*Rate_NAV_W, 174*Rate_NAV_H, 36*Rate_W, 10*Rate_NAV_H)];
    UIView *sleepMedicineViewThree = [[UIView alloc] initWithFrame:CGRectMake(235*Rate_NAV_W, 174*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *sleepMedicineViewFour = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 174*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    if (F_mark == 0)
    {
        sleepMedicineViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepMedicineViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.4];
        sleepMedicineViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepMedicineViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (F_mark == 1)
    {
        sleepMedicineViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepMedicineViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepMedicineViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        sleepMedicineViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (F_mark == 2)
    {
        sleepMedicineViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepMedicineViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepMedicineViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepMedicineViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (F_mark == 3)
    {
        sleepMedicineViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        sleepMedicineViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        sleepMedicineViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        sleepMedicineViewFour.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x56/255.0 blue:0x65/255.0 alpha:1];
    }
    [_partTwoView addSubview:sleepMedicineViewOne];
    [_partTwoView addSubview:sleepMedicineViewTwo];
    [_partTwoView addSubview:sleepMedicineViewThree];
    [_partTwoView addSubview:sleepMedicineViewFour];
    
    UILabel *dayObstacleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40*Rate_NAV_W, 194*Rate_NAV_H, 111*Rate_NAV_W, 28*Rate_NAV_H)];
    dayObstacleLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    dayObstacleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    dayObstacleLabel.textAlignment = NSTextAlignmentRight;
    dayObstacleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"日间功能障碍：" attributes:dicTwo];
    [_partTwoView addSubview:dayObstacleLabel];
    UIView *dayObstacleViewOne = [[UIView alloc] initWithFrame:CGRectMake(163*Rate_NAV_W, 202*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *dayObstacleViewTwo = [[UIView alloc] initWithFrame:CGRectMake(199*Rate_NAV_W, 202*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *dayObstacleViewThree = [[UIView alloc] initWithFrame:CGRectMake(235*Rate_NAV_W, 202*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    UIView *dayObstacleViewFour = [[UIView alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 202*Rate_NAV_H, 36*Rate_NAV_W, 10*Rate_NAV_H)];
    if (G_mark == 0)
    {
        dayObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        dayObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.4];
        dayObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        dayObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (G_mark == 1)
    {
        dayObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        dayObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        dayObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.64];
        dayObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (G_mark == 2)
    {
        dayObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        dayObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        dayObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        dayObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:0.89];
    }
    else if (G_mark == 3)
    {
        dayObstacleViewOne.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:0.2];
        dayObstacleViewTwo.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
        dayObstacleViewThree.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xBC/255.0 blue:0x5B/255.0 alpha:1];
        dayObstacleViewFour.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0x56/255.0 blue:0x65/255.0 alpha:1];
    }
    [_partTwoView addSubview:dayObstacleViewOne];
    [_partTwoView addSubview:dayObstacleViewTwo];
    [_partTwoView addSubview:dayObstacleViewThree];
    [_partTwoView addSubview:dayObstacleViewFour];
}

//创建第三部分视图
- (void)createPartThreeView
{
    //第三部分与失眠人群数据比较柱状图
    _partThreeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 598*Rate_NAV_H, 375*Rate_NAV_W, 259*Rate_NAV_H)];
    _partThreeView.backgroundColor = [UIColor whiteColor];
    [_resultScrollView addSubview:_partThreeView];
    
    UILabel *compareLabel = [[UILabel alloc] initWithFrame:CGRectMake(19*Rate_NAV_W, 16*Rate_NAV_H, 166*Rate_NAV_W, 25*Rate_NAV_H)];
    compareLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    compareLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    compareLabel.text = @"与失眠人群数据比较";
    compareLabel.adjustsFontSizeToFitWidth = YES;
    [_partThreeView addSubview:compareLabel];
    
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(299*Rate_NAV_W, 14*Rate_NAV_H, 12*Rate_NAV_W, 7*Rate_NAV_H)];
    greenView.backgroundColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    [_partThreeView addSubview:greenView];
    UILabel *greenLabel = [[UILabel alloc] initWithFrame:CGRectMake(317*Rate_NAV_W, 10*Rate_NAV_H, 9*Rate_NAV_W, 13*Rate_NAV_H)];
    greenLabel.font = [UIFont systemFontOfSize:9*Rate_NAV_H];
    greenLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    greenLabel.text = @"你";
    [_partThreeView addSubview:greenLabel];
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(299*Rate_NAV_W, 27*Rate_NAV_H, 12*Rate_NAV_W, 7*Rate_NAV_H)];
    blueView.backgroundColor = [UIColor colorWithRed:0x11/255.0 green:0xA3/255.0 blue:0xFF/255.0 alpha:1];
    [_partThreeView addSubview:blueView];
    UILabel *blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(317*Rate_NAV_W, 24*Rate_NAV_H, 20*Rate_NAV_W, 13*Rate_NAV_H)];
    blueLabel.font = [UIFont systemFontOfSize:9*Rate_NAV_H];
    blueLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    blueLabel.text = @"男性";
    [_partThreeView addSubview:blueLabel];
    UIView *purpleView = [[UIView alloc] initWithFrame:CGRectMake(299*Rate_NAV_W, 40*Rate_NAV_H, 12*Rate_NAV_W, 7*Rate_NAV_H)];
    purpleView.backgroundColor = [UIColor colorWithRed:0x86/255.0 green:0x92/255.0 blue:0xFE/255.0 alpha:1];
    [_partThreeView addSubview:purpleView];
    UILabel *purpleLabel = [[UILabel alloc] initWithFrame:CGRectMake(317*Rate_NAV_W, 37*Rate_NAV_H, 37*Rate_NAV_W, 13*Rate_NAV_H)];
    purpleLabel.font = [UIFont systemFontOfSize:9*Rate_NAV_H];
    purpleLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    purpleLabel.text = @"35-40岁";
    [_partThreeView addSubview:purpleLabel];
    
    NSArray *numArr = @[@[[NSString stringWithFormat:@"%ld.0",(long)A_mark],@"1.8",@"2.0"],
                        @[[NSString stringWithFormat:@"%ld.0",(long)B_mark],@"2.5",@"1.5"],
                        @[[NSString stringWithFormat:@"%ld.0",(long)C_mark],@"2.0",@"1.0"],
                        @[[NSString stringWithFormat:@"%ld.0",(long)D_mark],@"1.3",@"3.0"],
                        @[[NSString stringWithFormat:@"%ld.0",(long)E_mark],@"1.5",@"2.3"],
                        @[[NSString stringWithFormat:@"%ld.0",(long)F_mark],@"0.8",@"1.5"],
                        @[[NSString stringWithFormat:@"%ld.0",(long)G_mark],@"1.0",@"1.2"]];
    [self drawHistogramWithData:numArr andFatherView:_partThreeView];
    
    UILabel *labe_five = [[UILabel alloc] initWithFrame:CGRectMake(70*Rate_NAV_W, 227*Rate_NAV_H, 235*Rate_NAV_W, 17*Rate_NAV_H)];
    labe_five.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    labe_five.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    labe_five.text = @"*统计数据来源于2015年失眠患者数据统计";
    labe_five.textAlignment = NSTextAlignmentCenter;
    [_partThreeView addSubview:labe_five];
}

//画柱状图
- (void)drawHistogramWithData:(NSArray *)dataArray andFatherView:(UIView *)fatherView
{
    UIScrollView *scrollerView = [[UIScrollView alloc]init];
    scrollerView.frame = CGRectMake(36*Rate_NAV_W, 73*Rate_NAV_H, 318*Rate_NAV_W, 85*Rate_NAV_H);
    [fatherView addSubview:scrollerView];
    
    CALayer *layer1 = [CALayer layer];
    layer1.backgroundColor = [[UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1] CGColor];
    layer1.frame = CGRectMake(35*Rate_NAV_W, 73*Rate_NAV_H, 1, 85*Rate_NAV_H);
    [fatherView.layer addSublayer:layer1];
    
    for (int i = 0; i < 4; i++) {
        
        if (i > 0)
        {
            CALayer *layer2 = [CALayer layer];
            layer2.frame = CGRectMake(0,(85-i*25)*Rate_NAV_H, 318*Rate_NAV_W, 0.5*Rate_NAV_H);
            layer2.backgroundColor = [[UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1] CGColor];
            [layer1 addSublayer:layer2];
        }
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, (158-i*25-6)*Rate_NAV_H, 14*Rate_NAV_W, 12*Rate_NAV_H)];
        textLabel.text = [NSString stringWithFormat:@"%d",i];
        textLabel.font = [UIFont systemFontOfSize:10*Rate_NAV_H];
        [fatherView addSubview:textLabel];
    }
    
    CALayer *layer2 = [CALayer layer];
    layer2.backgroundColor = [[UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1] CGColor];
    layer2.frame = CGRectMake(35*Rate_NAV_W, 158*Rate_NAV_H, 318*Rate_NAV_W, 1);
    [fatherView.layer addSublayer:layer2];
    
    
    NSArray *xStrArr = @[@"睡眠质量",@"入睡时间",@"睡眠时间",@"睡眠效率",@"睡眠障碍",@"催眠药物",@"日间功能障碍"];
    for (int i = 0; i < xStrArr.count; i++)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((49+44*i)*Rate_NAV_W, 164*Rate_NAV_H, 25*Rate_NAV_W, 30*Rate_NAV_H)];
        if (i == xStrArr.count - 1)
        {
            textLabel.frame = CGRectMake(301*Rate_NAV_W, 164*Rate_NAV_H, 50*Rate_NAV_W, 30*Rate_NAV_H);
        }
        textLabel.text = [xStrArr objectAtIndex:i];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
        textLabel.numberOfLines = 0;
        [fatherView addSubview:textLabel];
    }
    scrollerView.contentSize = CGSizeMake(15*25+25, 0);
    
    
    NSArray *numArr = dataArray;
    
    CGPoint point1;
    CGPoint point2;
    CGFloat height = 1.0;
    for (int i = 0; i < numArr.count; i++)
    {
        NSArray *tmpArr = [numArr objectAtIndex:i];
        for (int j = 0; j < tmpArr.count; j++)
        {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            
            shapeLayer.fillColor = [UIColor orangeColor].CGColor;
            shapeLayer.lineWidth = 10*Rate_NAV_W;
            shapeLayer.lineCap = kCALineCapButt;
            UIBezierPath *path = [UIBezierPath bezierPath];
            if (j == 0)
            {
                shapeLayer.strokeColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1].CGColor;
            }
            else if (j == 1)
            {
                shapeLayer.strokeColor = [UIColor colorWithRed:0x11/255.0 green:0xA3/255.0 blue:0xFF/255.0 alpha:1].CGColor;
            }
            else if (j == 2)
            {
                shapeLayer.strokeColor = [UIColor colorWithRed:0x86/255.0 green:0x92/255.0 blue:0xFE/255.0 alpha:1].CGColor;
            }
            point1 = CGPointMake((15 + j*11 + i*44)*Rate_NAV_W, 85*Rate_NAV_H);
            CGFloat floatOne = [tmpArr[j] floatValue];
            point2 = CGPointMake((15 + j*11 + i*44)*Rate_NAV_W, (85 - 25*height*floatOne)*Rate_NAV_H);
            
            [path moveToPoint:point1];
            [path addLineToPoint:point2];
            
            shapeLayer.path = path.CGPath;
            [scrollerView.layer addSublayer:shapeLayer];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = @(0.0); //开始动画位置
            animation.toValue = @(1.0); //结束动画位置
            animation.autoreverses = NO;
            animation.duration = 1.0;
            [shapeLayer addAnimation:animation forKey:nil];
        }
    }
}

//创建第四部分视图
- (void)createPartFourView
{
    NSString *strText;
    if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
    {
        strText = [self createSuggestString:_sleepTipsResultArray];
    }
    else if ([_typeString isEqualToString:@"抑郁自评"])
    {
        strText = [self createSuggestString:_depressedTipsResultArray];
    }
    else if ([_typeString isEqualToString:@"焦虑自评"])
    {
        strText = [self createSuggestString:_anxiousTipsResultArray];
    }
    else if ([_typeString isEqualToString:@"躯体自评"])
    {
        strText = [self createSuggestString:_bodyTipsResultArray];
    }
    
    if (strText == nil)
    {
        /* 第四部分省略 */
        //第五部分问医生label
        UILabel *label = [[UILabel alloc] init];
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            label.frame = CGRectMake(93*Rate_NAV_W, 881*Rate_NAV_H, 189*Rate_NAV_W, 20*Rate_NAV_H);
        }
        else
        {
            label.frame = CGRectMake(93*Rate_NAV_W, 500*Rate_NAV_H, 189*Rate_NAV_W, 20*Rate_NAV_H);
        }
        label.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        label.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        label.text = @"想了解更多？专家线上问诊！";
        [_resultScrollView addSubview:label];
        //第五部分问医生按钮
        UIButton *askDoc = [UIButton buttonWithType:UIButtonTypeSystem];
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            askDoc.frame = CGRectMake((SCREENWIDTH - 292)/2, 912*Rate_NAV_H, 292, 44);
        }
        else
        {
            askDoc.frame = CGRectMake((SCREENWIDTH - 292)/2, 531*Rate_NAV_H, 292, 44);
        }
        
        [askDoc setBackgroundImage:[UIImage imageNamed:@"signin_btn_bg1"] forState:UIControlStateNormal];
        [askDoc setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if ([_typeFlag isEqualToString:@"Doctor"])
        {
            [askDoc setTitle:@"完成" forState:UIControlStateNormal];
        }
        else
        {
            [askDoc setTitle:@"问医生" forState:UIControlStateNormal];
        }
        askDoc.titleLabel.font = [UIFont systemFontOfSize:18];
        [askDoc addTarget:self action:@selector(askDoctor) forControlEvents:(UIControlEventTouchUpInside)];
        [_resultScrollView addSubview:askDoc];
        
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            _resultScrollView.contentSize = CGSizeMake(375*Ratio_W, 934*Rate_NAV_H + 44);
        }
        else
        {
            _resultScrollView.contentSize = CGSizeMake(375*Ratio_W, SCREENHEIGHT);
        }
    }
    else
    {
        //第四部分睡眠建议视图
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            _partFourView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 867*Rate_NAV_H, 375*Rate_NAV_W, 335*Rate_NAV_H)];
        }
        else
        {
            _partFourView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 358*Rate_NAV_H, 375*Rate_NAV_W, 335*Rate_NAV_H)];
        }
        _partFourView.backgroundColor = [UIColor whiteColor];
        [_resultScrollView addSubview:_partFourView];
        
        UILabel *adviseLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 17*Rate_NAV_H, 37*Rate_NAV_W, 25*Rate_NAV_H)];
        adviseLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
        adviseLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
        adviseLabel.text = @"建议";
        [_partFourView addSubview:adviseLabel];
        UILabel *adviseContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 50*Rate_NAV_H, 345*Rate_NAV_W, 260*Rate_NAV_H)];
        adviseContentLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        adviseContentLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        adviseContentLabel.numberOfLines = 0;
        
        NSDictionary *dic = @{NSKernAttributeName:@1.5f};
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:strText attributes:dic];
        adviseContentLabel.attributedText = attributeStr;
        CGSize adviseContentLabelSize = [adviseContentLabel sizeThatFits:CGSizeMake(345*Rate_NAV_W, MAXFLOAT)];
        adviseContentLabel.frame = CGRectMake(15*Rate_NAV_W, 50*Rate_NAV_H, 345*Rate_NAV_W, adviseContentLabelSize.height);
        [_partFourView addSubview:adviseContentLabel];
        
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            _partFourView.frame = CGRectMake(0, 867*Rate_NAV_H, 375*Rate_NAV_W, 75*Rate_NAV_H + adviseContentLabelSize.height);
        }
        else
        {
            _partFourView.frame = CGRectMake(0, 358*Rate_NAV_H, 375*Rate_NAV_W, 75*Rate_NAV_H + adviseContentLabelSize.height);
        }
        
        //第五部分问医生label
        UILabel *label = [[UILabel alloc] init];
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            label.frame = CGRectMake(93*Rate_NAV_W, 966*Rate_NAV_H + adviseContentLabelSize.height, 189*Rate_NAV_W, 20*Rate_NAV_H);
        }
        else
        {
            label.frame = CGRectMake(93*Rate_NAV_W, 457*Rate_NAV_H + adviseContentLabelSize.height, 189*Rate_NAV_W, 20*Rate_NAV_H);
        }
        label.text = @"想了解更多？专家线上问诊！";
        label.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        label.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        [_resultScrollView addSubview:label];
        //第五部分问医生按钮
        UIButton *askDoc = [UIButton buttonWithType:UIButtonTypeSystem];
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            askDoc.frame = CGRectMake((SCREENWIDTH - 292)/2, 997*Rate_NAV_H + adviseContentLabelSize.height, 292, 44);
        }
        else
        {
            askDoc.frame = CGRectMake((SCREENWIDTH - 292)/2, 488*Rate_NAV_H + adviseContentLabelSize.height, 292, 44);
        }
        
        [askDoc setBackgroundImage:[UIImage imageNamed:@"signin_btn_bg1"] forState:UIControlStateNormal];
        [askDoc setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if ([_typeFlag isEqualToString:@"Doctor"])
        {
            [askDoc setTitle:@"完成" forState:UIControlStateNormal];
        }
        else
        {
            [askDoc setTitle:@"问医生" forState:UIControlStateNormal];
        }
        askDoc.titleLabel.font = [UIFont systemFontOfSize:18];
        [askDoc addTarget:self action:@selector(askDoctor) forControlEvents:(UIControlEventTouchUpInside)];
        [_resultScrollView addSubview:askDoc];
        
        if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
        {
            _resultScrollView.contentSize = CGSizeMake(375*Rate_NAV_W, 1019*Rate_NAV_H + adviseContentLabelSize.height + 44 +64);
        }
        else
        {
            _resultScrollView.contentSize = CGSizeMake(375*Rate_NAV_W, 510*Rate_NAV_H + adviseContentLabelSize.height + 44 + 64);
        }
    }
}

#pragma mark -- 返回问医生
- (void)askDoctor
{
    if ([_typeFlag isEqualToString:@"Doctor"])
    {
        UIViewController * controllerVC =  [self getCurrentViewController:self];
        for (UIViewController *controller in controllerVC.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[CustomerChatViewController class]])
            {
                //创建通知
                NSNotification *notification =[NSNotification notificationWithName:@"updateScaleTest" object:nil userInfo:nil];
                //通过通知中心发送通知
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                [controllerVC.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    else
    {
        //跳转到问医生界面
        UIViewController * controllerVC =  [self getCurrentViewController:self];
        for (UIViewController *controller in controllerVC.navigationController.viewControllers) {
            if ([controller isKindOfClass:[GaugeTestViewController class]])
            {
                DoctorHomeViewController *doctorVC = [[DoctorHomeViewController alloc] init];
                [controllerVC.navigationController pushViewController:doctorVC animated:YES];
            }
        }
    }
}

#pragma mark -- 获取当前view的viewcontroller
- (UIViewController *)getCurrentViewController:(UIView *) currentView
{
    for (UIView* next = [currentView superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

//给评估的选择进行评分
- (void)markForResult
{
    if ([_typeString isEqualToString:@"匹兹堡睡眠指数"])
    {
        [self sleepMark];
    }
    else if ([_typeString isEqualToString:@"抑郁自评"])
    {
        [self depressedMark];
    }
    else if ([_typeString isEqualToString:@"焦虑自评"])
    {
        [self worriedMark];
    }
    else if ([_typeString isEqualToString:@"躯体自评"])
    {
        [self bodyMark];
    }
}
//睡眠评估量表评分
- (void)sleepMark
{
    //睡眠量表评估结果评分
    int E_tmpmark=0;
    int G_tmpmark=0;
    for (int i=0; i<_resultArray.count; i++)
    {
        if (i==3)
        {
            NSInteger sleepTime = [[_resultArray objectAtIndex:3] integerValue];
            if (sleepTime >= 6 && sleepTime < 7)
            {
                C_mark = 1;
            }
            else if (sleepTime>=5 && sleepTime<6)
            {
                C_mark = 2;
            }
            else if (sleepTime<5)
            {
                C_mark = 3;
            }
            
            NSString *getUpTimeStr = [_resultArray objectAtIndex:2];
            int getUpHour = [[getUpTimeStr substringWithRange:NSMakeRange(0, 2)] intValue];
            int getUpMinute = [[getUpTimeStr substringWithRange:NSMakeRange(3, 2)] intValue];
            
            NSString *bedTimeStr = [_resultArray objectAtIndex:0];
            int bedHour = [[bedTimeStr substringWithRange:NSMakeRange(0, 2)] intValue];
            int bedMinute = [[bedTimeStr substringWithRange:NSMakeRange(3, 2)] intValue];
            
            float onBedTime=0;
            
            if (bedHour > getUpHour)
            {
                onBedTime=(getUpHour + 24 - bedHour) + (getUpMinute - bedMinute)/60;
            }
            else if (bedHour < getUpHour)
            {
                onBedTime = (getUpHour - bedMinute) + (getUpMinute - bedMinute)/60;
            }
            
            float efficiencyForSleep = 100*sleepTime/onBedTime;
            
            if (efficiencyForSleep > 85)
            {
                D_mark = 0;
            }
            else if (efficiencyForSleep >= 75 && efficiencyForSleep <= 84)
            {
                D_mark = 1;
            }
            else if (efficiencyForSleep >= 65 && efficiencyForSleep <= 74)
            {
                D_mark = 2;
            }
            else if (efficiencyForSleep < 65)
            {
                D_mark = 3;
            }
        }
        else if (i==4)
        {
            NSString *toSleepTimeMinute = [_resultArray objectAtIndex:1];
            int toSleepTime;
            if ([toSleepTimeMinute isEqualToString:@"1"])
            {
                toSleepTime = 60;
            }
            else
            {
                toSleepTime = [toSleepTimeMinute intValue];
            }
            
            int tmpMark = 0;
            if (toSleepTime >= 16 && toSleepTime <= 30)
            {
                tmpMark = 1;
            }
            else if (toSleepTime >= 31 && toSleepTime <= 60)
            {
                tmpMark = 2;
            }
            else if (toSleepTime > 60)
            {
                tmpMark = 3;
            }
            
            if ([[_resultArray objectAtIndex:4] intValue] == 0)
            {
                tmpMark += 0;
            }
            else if ([[_resultArray objectAtIndex:4] intValue]==1)
            {
                tmpMark += 1;
            }
            else if ([[_resultArray objectAtIndex:4] intValue]==2)
            {
                tmpMark += 2;
            }
            else if ([[_resultArray objectAtIndex:4] intValue]==3)
            {
                tmpMark += 3;
            }
            
            if (tmpMark == 0)
            {
                B_mark = 0;
            }
            else if (tmpMark == 1 || tmpMark == 2)
            {
                B_mark = 1;
            }
            else if (tmpMark == 3 || tmpMark == 4)
            {
                B_mark = 2;
            }
            else if (tmpMark == 5 || tmpMark == 6)
            {
                B_mark = 3;
            }
        }
        else if (i>=5 && i<=13)
        {
            int tmp = [[_resultArray objectAtIndex:i] intValue];
            if (tmp == 1)
            {
                E_tmpmark += 1;
            }
            else if (tmp == 2)
            {
                E_tmpmark += 2;
            }
            else if (tmp == 3)
            {
                E_tmpmark += 3;
            }
        }
        else if (i==14)
        {
            int tmp = [[_resultArray objectAtIndex:i] intValue];
            if (tmp == 0)
            {
                A_mark = 0;
            }
            else if (tmp == 1)
            {
                A_mark = 1;
            }
            else if (tmp == 2)
            {
                A_mark = 2;
            }
            else if (tmp == 3)
            {
                A_mark = 3;
            }
        }
        else if (i==15)
        {
            int tmp = [[_resultArray objectAtIndex:i] intValue];
            if (tmp == 0)
            {
                F_mark = 0;
            }
            else if (tmp == 1)
            {
                F_mark = 1;
            }
            else if (tmp == 2)
            {
                F_mark = 2;
            }
            else if (tmp == 3)
            {
                F_mark = 3;
            }
        }
        else if (i==16 || i==17)
        {
            int tmp = [[_resultArray objectAtIndex:i] intValue];
            if (tmp == 0)
            {
                G_tmpmark += 0;
            }
            else if (tmp == 1)
            {
                G_tmpmark += 1;
            }
            else if (tmp == 2)
            {
                G_tmpmark += 2;
            }
            else if (tmp == 3)
            {
                G_tmpmark += 3;
            }
        }
    }
    if (E_tmpmark == 0)
    {
        E_mark = 0;
    }
    else if (E_tmpmark >= 1 && E_tmpmark <= 9)
    {
        E_mark = 1;
    }
    else if (E_tmpmark >= 10 && E_tmpmark <= 18)
    {
        E_mark = 2;
    }
    else if (E_tmpmark >= 19 && E_tmpmark <= 27)
    {
        E_mark = 3;
    }
    if (G_tmpmark == 0)
    {
        G_mark = 0;
    }
    else if (G_tmpmark == 1 || G_tmpmark == 2)
    {
        G_mark = 1;
    }
    else if (G_tmpmark == 3 || G_tmpmark == 4)
    {
        G_mark = 2;
    }
    else if (G_tmpmark == 5 || G_tmpmark == 6)
    {
        G_mark = 3;
    }
    Mark = A_mark + B_mark + C_mark + D_mark + E_mark + F_mark + G_mark;
}
//评估抑郁量表评分
- (void)depressedMark
{
    for (int i = 0; i < _resultArray.count; i++)
    {
        int tmp = [[_resultArray objectAtIndex:i] intValue];
        if (tmp == 1)
        {
            Mark += 1;
        }
        else if (tmp == 2)
        {
            Mark += 2;
        }
        else if (tmp == 3)
        {
            Mark += 3;
        }
    }
}
//评估焦虑量表评分
- (void)worriedMark
{
    for (int i = 0; i < _resultArray.count; i++)
    {
        int tmp = [[_resultArray objectAtIndex:i] intValue];
        if (tmp == 1)
        {
            Mark += 1;
        }
        else if (tmp == 2)
        {
            Mark += 2;
        }
        else if (tmp == 3)
        {
            Mark += 3;
        }
    }
}
//评估躯体量表评分
- (void)bodyMark
{
    for (int i = 0; i < _resultArray.count; i++)
    {
        int tmp = [[_resultArray objectAtIndex:i] intValue];
        if (tmp == 1)
        {
            Mark += 1;
        }
        else if (tmp == 2)
        {
            Mark += 2;
        }
    }
}

//添加匹兹堡睡眠指数建议
- (void)addSleepTips
{
    NSString *strOne = [_resultArray objectAtIndex:0];
    CGFloat bedTime = [[strOne substringWithRange:NSMakeRange(0, 2)] intValue] + [[strOne substringWithRange:NSMakeRange(3, 2)] intValue]/60.0;
    if (bedTime >= 23)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:0]];
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:11]];
    }
    if ([[_resultArray objectAtIndex:1] intValue] > 30)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:1]];
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:3]];
    }
    if ([[_resultArray objectAtIndex:3] intValue] < 7)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:2]];
    }
    if ([[_resultArray objectAtIndex:4] intValue]==2 || [[_resultArray objectAtIndex:4] intValue]==3)
    {
        NSString *temp;
        for (NSString *tmp in _sleepTipsResultArray)
        {
            if ([tmp isEqualToString:[_sleepTipsArray objectAtIndex:3]])
            {
                temp=tmp;
            }
        }
        if (temp==nil)
        {
            [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:3]];
        }
        
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:4]];
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:5]];
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:8]];
    }
    if ([[_resultArray objectAtIndex:5] intValue]==2 || [[_resultArray objectAtIndex:5] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:7]];
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:14]];
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:16]];
    }
    if ([[_resultArray objectAtIndex:6] intValue]==2 || [[_resultArray objectAtIndex:6] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:10]];
    }
    if ([[_resultArray objectAtIndex:7] intValue]==2 || [[_resultArray objectAtIndex:7] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:19]];
    }
    if ([[_resultArray objectAtIndex:8] intValue]==2 || [[_resultArray objectAtIndex:8] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:15]];
    }
    if ([[_resultArray objectAtIndex:9] intValue]==2 || [[_resultArray objectAtIndex:9] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:17]];
    }
    if ([[_resultArray objectAtIndex:10] intValue]==2 || [[_resultArray objectAtIndex:10] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:12]];
    }
    if ([[_resultArray objectAtIndex:11] intValue]==2 || [[_resultArray objectAtIndex:11] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:6]];
        NSString *temp;
        for (NSString *tmp in _sleepTipsResultArray)
        {
            if ([tmp isEqualToString:[_sleepTipsArray objectAtIndex:7]])
            {
                temp=tmp;
            }
        }
        if (temp==nil)
        {
            [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:7]];
        }
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:8]];
    }
    if ([[_resultArray objectAtIndex:12] intValue]==2 || [[_resultArray objectAtIndex:12] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:20]];
    }
    if ([[_resultArray objectAtIndex:14] intValue]==2 || [[_resultArray objectAtIndex:14] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:9]];
    }
    if ([[_resultArray objectAtIndex:15] intValue]==1 || [[_resultArray objectAtIndex:15] intValue]==2 || [[_resultArray objectAtIndex:15] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:13]];
    }
    if ([[_resultArray objectAtIndex:16] intValue]==2 || [[_resultArray objectAtIndex:16] intValue]==3)
    {
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:21]];
        [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:22]];
    }
    if ([[_resultArray objectAtIndex:17] intValue]==2 || [[_resultArray objectAtIndex:17] intValue]==3)
    {
        NSString *temp;
        for (NSString *tmp in _sleepTipsResultArray)
        {
            if ([tmp isEqualToString:[_sleepTipsArray objectAtIndex:21]] || [tmp isEqualToString:[_sleepTipsArray objectAtIndex:22]])
            {
                temp=tmp;
            }
        }
        if (temp==nil)
        {
            [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:21]];
            [_sleepTipsResultArray addObject:[_sleepTipsArray objectAtIndex:22]];
        }
    }
}

//添加抑郁自评建议
- (void)addDepressedTips
{
    for (int i = 0; i < _resultArray.count; i++)
    {
        if (i == 4)
        {
            NSArray *tmpArr = [_depressedTipsArray objectAtIndex:4];
            if ([[_resultArray objectAtIndex:4] intValue] == 1)
            {
                [_depressedTipsResultArray addObject:[tmpArr objectAtIndex:0]];
            }
            else if ([[_resultArray objectAtIndex:4] intValue] == 2)
            {
                [_depressedTipsResultArray addObject:[tmpArr objectAtIndex:1]];
            }
            else if ([[_resultArray objectAtIndex:4] intValue] == 3)
            {
                [_depressedTipsResultArray addObject:[tmpArr objectAtIndex:2]];
            }
        }
        else
        {
            if ([[_resultArray objectAtIndex:i] intValue] == 3)
            {
                [_depressedTipsResultArray addObject:[_depressedTipsArray objectAtIndex:i]];
            }
        }
    }
}

//添加焦虑自评建议
- (void)addAnxiousTips
{
    for (int i = 0; i < _resultArray.count; i++)
    {
        if ([[_resultArray objectAtIndex:i] intValue] == 3)
        {
            NSString *tmpStr = [_anxiousTipsArray objectAtIndex:i];
            if (tmpStr.length > 1)
            {
                [_anxiousTipsResultArray addObject:[_anxiousTipsArray objectAtIndex:i]];
            }
        }
    }
}

//添加躯体自评建议
- (void)addBodyTips
{
    for (int i = 0; i < _resultArray.count; i++)
    {
        if ([[_resultArray objectAtIndex:i] intValue] == 2)
        {
            NSString *tmpStr = [_bodyTipsArray objectAtIndex:i];
            if (tmpStr.length > 1)
            {
                [_bodyTipsResultArray addObject:[_bodyTipsArray objectAtIndex:i]];
            }
        }
    }
}

//将建议结果数组拼接成数组
- (NSString *)createSuggestString:(NSArray *)suggestArray
{
    NSString *str;
    for (int i = 0; i < suggestArray.count; i++)
    {
        if (i == 0)
        {
            str = [NSString stringWithFormat:@"1、%@",[suggestArray objectAtIndex:0]];
        }
        else
        {
            str = [NSString stringWithFormat:@"%@\n%d、%@",str,i+1,[suggestArray objectAtIndex:i]];
        }
    }
    
    return str;
}

@end
