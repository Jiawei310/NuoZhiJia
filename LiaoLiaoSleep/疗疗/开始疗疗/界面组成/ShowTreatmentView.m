//
//  ShowTreatmentView.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "ShowTreatmentView.h"

@implementation ShowTreatmentView

- (instancetype)initWithFrame:(CGRect)frame andImageList:(NSArray *)imageList andInfoList:(NSArray *)infoList
{
    if (self == [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0.21 green:0.76 blue:0.87 alpha:1.00];
        self.imageList = [[NSArray alloc]initWithArray:imageList];
        self.userInteractionEnabled = YES;
        [self customerViewWithFrame:frame andImageList:imageList andInfoList:infoList];
    }
    return self;
}

- (void)customerViewWithFrame:(CGRect)frame andImageList:(NSArray *)imageList andInfoList:(NSArray *)infoList
{
    self.timeLineV = [[TimeLine alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 180) andData:@[@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"},@{@"2016-09-18":@"0"}]];
    [self addSubview:_timeLineV];
    
    self.scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.timeLineV.frame), frame.size.width, 90)];
    self.scrollV.delegate = self;
    self.scrollV.scrollEnabled = YES;
    self.scrollV.pagingEnabled = NO;
    self.scrollV.showsHorizontalScrollIndicator = NO;
    self.scrollV.showsVerticalScrollIndicator = NO;
    self.scrollV.contentSize = CGSizeMake(15+15+8*(infoList.count-1)+(frame.size.width-30)*infoList.count, 90);
    for (int i = 0; i <infoList.count; i++)
    {
        UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(15+(frame.size.width-30+8)*i, 0, frame.size.width-30, 90)];
        bottomView.layer.cornerRadius = 5;
        bottomView.clipsToBounds = YES;
        bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bottomView.layer.borderWidth = 0.5;
        bottomView.backgroundColor = [UIColor whiteColor];
        [self.scrollV addSubview:bottomView];
        
        UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, bottomView.frame.size.width-38, 20)];
        lable.text = @"睡觉的时候应该想些什么？";
        lable.textColor = [UIColor cyanColor];
        lable.adjustsFontSizeToFitWidth = YES;
        [bottomView addSubview:lable];
        
        UILabel * content = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lable.frame), bottomView.frame.size.width-20, 45)];
        content.numberOfLines = 0;
        content.text = infoList[i];
        content.adjustsFontSizeToFitWidth = YES;
        [bottomView addSubview:content];
    }
}


@end
