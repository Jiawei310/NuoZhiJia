//
//  DoctorInfoModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "DoctorInfoModel.h"

@implementation DoctorInfoModel

- (instancetype)init
{
    if (self == [super init])
    {
        _doctorID = @"";
        _doctorName = @"";
        _doctorHospital = @"";
        _doctorDepartment = @"";
        _doctorLoction = @"";
        _doctorStar = @"";
        _doctorIcon = @"";
        _doctorTap = @"";
        _doctorBrief = @"";
        _questionCount = @"";
        _fullStarCount = @"";
        _commentCount = @"";
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self == [super init])
    {
        //问题信息
        _doctorID = [self getValueWithString:[dic objectForKey:@"DoctorID"]];
        _doctorName = [self getValueWithString:[dic objectForKey:@"DoctorName"]];
        _doctorHospital = [self getValueWithString:[dic objectForKey:@"DoctorHospital"]];
        _doctorDepartment = [self getValueWithString:[dic objectForKey:@"DoctorDepartment"]];
        _doctorIcon = [self getValueWithString:[dic objectForKey:@"DoctorIcon"]];
        _doctorStar = [self getValueWithString:[dic objectForKey:@"DoctorStar"]];
        _doctorTap = [self getValueWithString:[dic objectForKey:@"DoctorTap"]];
        _doctorBrief = [self getValueWithString:[dic objectForKey:@"DoctorBrief"]];
        _doctorLoction = [self getValueWithString:[dic objectForKey:@"DoctorLoction"]];
        _questionCount = [self getValueWithString:[dic objectForKey:@"QuestionCount"]];
        _fullStarCount = [self getValueWithString:[dic objectForKey:@"FullStarCount"]];
        _commentCount = [self getValueWithString:[dic objectForKey:@"CommentCount"]];
    }
    
    return self;
}

- (NSString *)getValueWithString:(NSString *)str
{
    if (str)
    {
        return str;
    }
    else
    {
        return @"";
    }
}


@end
