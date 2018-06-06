//
//  TimeLine.m
//  TestProject
//
//  Created by 甘伟 on 16/10/19.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "TimeLine.h"
#import "Define.h"

@implementation TimeLine
{
    int currentIndex;   //标志当前日期在疗程当中第几天
}

- (instancetype)initWithFrame:(CGRect)frame andData:(NSArray *)dataSource
{
    if (self == [super initWithFrame:frame])
    {
        [self createViewWithFrame:frame andData:dataSource];
    }
    return self;
}

- (void)createViewWithFrame:(CGRect)frame andData:(NSArray *)dataSource
{
    
    UILabel *dayLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10*Rate_NAV_H, frame.size.width, 30*Rate_NAV_H)];
    
    for (int i = 0; i < dataSource.count; i++)
    {
        if ([self isPast:[dataSource[i] allKeys][0]] == 2)
        {
            dayLable.text = [NSString stringWithFormat:@"第%d天",i+1];
            currentIndex = i + 1;
        }
    }
    
    dayLable.textColor = [UIColor whiteColor];
    dayLable.adjustsFontSizeToFitWidth = YES;
    dayLable.font = [UIFont systemFontOfSize:22*Rate_NAV_H];
    dayLable.textAlignment =NSTextAlignmentCenter;
    [self addSubview:dayLable];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(0, 41*Rate_NAV_H, frame.size.width, 20*Rate_NAV_H)];
    notice.text = @"\"宁可早起，不要晚睡\"";
    notice.textColor = [UIColor whiteColor];
    notice.textAlignment = NSTextAlignmentCenter;
    notice.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    notice.adjustsFontSizeToFitWidth = YES;
    [self addSubview:notice];
    
    self.userInteractionEnabled = YES;
    _scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 71*Rate_NAV_H, frame.size.width, 60*Rate_NAV_H)];
    _scrollV.delegate = self;
    _scrollV.scrollEnabled = YES;
    _scrollV.pagingEnabled = NO;
    _scrollV.showsHorizontalScrollIndicator = NO;
    _scrollV.showsVerticalScrollIndicator = NO;
    _scrollV.contentSize = CGSizeMake((60*dataSource.count + 6)*Rate_NAV_W, 60*Rate_NAV_H);
    for (int i = 0; i < dataSource.count*2-1; i++)
    {
        //偶数表示
        if (i%2 == 0)
        {
            if (i == 0)
            {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29*Rate_NAV_H, 23*Rate_NAV_W, 2*Rate_NAV_H)];
                lineView.backgroundColor = [UIColor whiteColor];
                [_scrollV addSubview:lineView];
            }
            UIImageView *circleView = [[UIImageView alloc] initWithFrame:CGRectMake((23+60*(i/2))*Rate_NAV_W, 20*Rate_NAV_H, 20*Rate_NAV_H, 20*Rate_NAV_H)];
            circleView.layer.cornerRadius = 10*Rate_NAV_H;
            circleView.clipsToBounds = YES;
            
            [_scrollV addSubview:circleView];
            
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake((23+60*(i/2))*Rate_NAV_W, CGRectGetMaxY(circleView.frame), 20*Rate_NAV_H, 20*Rate_NAV_H)];
            NSString *date = [dataSource[i/2] allKeys][0];
            NSArray *temp = [date componentsSeparatedByString:@"-"];
            lable.text = [NSString stringWithFormat:@"%@.%@",temp[1],temp[2]];
            NSLog(@"%@",[dataSource[i/2] allKeys][0]);
            lable.textAlignment = NSTextAlignmentCenter;
            lable.adjustsFontSizeToFitWidth = YES;
            [_scrollV addSubview:lable];
            
            if ([self isPast:[dataSource[i/2] allKeys][0]] != 0)
            {
                if ([[dataSource[i/2] allValues][0] integerValue] == 0)
                {
                    circleView.image = [UIImage imageNamed:@"icon_unchecked.png"];
                }
                else
                {
                    circleView.image = [UIImage imageNamed:@"icon_checked.png"];
                }
                lable.textColor = [UIColor whiteColor];
            }
            else
            {
                circleView.backgroundColor = [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:0.2];
                lable.textColor = [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:0.7];
            }
        }
        else
        {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20*Rate_NAV_H+(23+60*(i/2))*Rate_NAV_W, 29*Rate_NAV_H, 60*Rate_NAV_W - 20*Rate_NAV_H, 2*Rate_NAV_H)];
            lineView.backgroundColor = [UIColor whiteColor];
            [_scrollV addSubview:lineView];
        }
    }
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((60*dataSource.count-17)*Rate_NAV_W, 29*Rate_NAV_H, 23*Rate_NAV_W, 2*Rate_NAV_H)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.scrollV addSubview:lineView];
    if (currentIndex > 4)
    {
        _scrollV.contentOffset = CGPointMake((currentIndex - 3)*60*Rate_NAV_W, 0);
    }
    //添加当前显示界面
    [self addSubview:_scrollV];
}

//判断数据中的日期是否是过去
- (NSInteger)isPast:(NSString *)date
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString1 = [dateFormatter stringFromDate:currentDate];
    NSArray *arr1 = [dateString1 componentsSeparatedByString:@"-"];
    NSArray *arr2 = [date componentsSeparatedByString:@"-"];
    if ([arr2[0] integerValue] > [arr1[0] integerValue])
    {
        return 0;
    }
    else if([arr2[0] integerValue] < [arr1[0] integerValue])
    {
        return 1;
    }
    else
    {
        if ([arr2[1] integerValue] > [arr1[1] integerValue])
        {
            return 0;
        }
        else if([arr2[1] integerValue] < [arr1[1] integerValue])
        {
            return 1;
        }
        else
        {
            if ([arr2[2] integerValue] > [arr1[2] integerValue])
            {
                return 0;
            }
            else if ([arr2[2] integerValue] < [arr1[2] integerValue])
            {
                return 1;
            }
            else
            {
                return 2;
            }
        }
    }
}

//将阿拉伯数字换为中文数字
- (NSString *)translationArabicNum:(NSInteger)arabicNum
{
    NSString *arabicNumStr = [NSString stringWithFormat:@"%ld",(long)arabicNum];
    NSArray *arabicNumeralsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chineseNumeralsArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chineseNumeralsArray forKeys:arabicNumeralsArray];
    
    if (arabicNum < 20 && arabicNum > 9)
    {
        if (arabicNum == 10)
        {
            return @"十";
        }
        else
        {
            NSString *subStr1 = [arabicNumStr substringWithRange:NSMakeRange(1, 1)];
            NSString *a1 = [dictionary objectForKey:subStr1];
            NSString *chinese1 = [NSString stringWithFormat:@"十%@",a1];
            return chinese1;
        }
    }
    else
    {
        NSMutableArray *sums = [NSMutableArray array];
        for (int i = 0; i < arabicNumStr.length; i ++)
        {
            NSString *substr = [arabicNumStr substringWithRange:NSMakeRange(i, 1)];
            NSString *a = [dictionary objectForKey:substr];
            NSString *b = digits[arabicNumStr.length -i-1];
            NSString *sum = [a stringByAppendingString:b];
            if ([a isEqualToString:chineseNumeralsArray[9]])
            {
                if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
                {
                    sum = b;
                    if ([[sums lastObject] isEqualToString:chineseNumeralsArray[9]])
                    {
                        [sums removeLastObject];
                    }
                }
                else
                {
                    sum = chineseNumeralsArray[9];
                }
                
                if ([[sums lastObject] isEqualToString:sum])
                {
                    continue;
                }
            }
            
            [sums addObject:sum];
        }
        NSString *sumStr = [sums  componentsJoinedByString:@""];
        NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
        return chinese;
    }
}

@end
