//
//  ConsultQuestionModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "ConsultQuestionModel.h"

@implementation ConsultQuestionModel

-(instancetype)init{
    if (self == [super init]) {
        //问题信息
        _questionID = @"";//conversationId
        _question = @"";
        _startTime = @"";
        _answerTime = @"";
        _isClose = @"NO";
        _isHot = @"NO";
        _askCount = @"";
        
        //患者信息
        _patientID = @"";
        _name = @"";
        _sex = @"";
        _birth = @"";
        
        //医生信息
        _doctorID = @"";
        _doctorName = @"";
        _doctorHospital = @"";
        _doctorDepartment = @"";
        _doctorStar = @"";
        _doctorCommentCount = @"0";
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self == [super init]) {
        //问题信息
        _questionID = [self getValueWithString:[dic objectForKey:@"QuestionID"]];
        _question = [self getValueWithString:[dic objectForKey:@"Question"]];
        _answerTime = [self getValueWithString:[dic objectForKey:@"AnswerTime"]];
        _startTime = [self getValueWithString:[dic objectForKey:@"StartTime"]];
        _isClose = [self getValueWithString:[dic objectForKey:@"IsClose"]];
        _isHot = [self getValueWithString:[dic objectForKey:@"IsHot"]];
        _askCount = [self getValueWithString:[dic objectForKey:@"AskCount"]];
        _patientID = [self getValueWithString:[dic objectForKey:@"PatientID"]];
        _name = [self getValueWithString:[dic objectForKey:@"Name"]];
        _sex = [self getValueWithString:[dic objectForKey:@"Sex"]];
        _birth = [self getValueWithString:[dic objectForKey:@"Birth"]];
        _headerImage = [self getValueWithString:[dic objectForKey:@"HeaderImage"]];
        _doctorID = [self getValueWithString:[dic objectForKey:@"DoctorID"]];
        _doctorName = [self getValueWithString:[dic objectForKey:@"DoctorName"]];
        _doctorIcon = [self getValueWithString:[dic objectForKey:@"DoctorIcon"]];
        _doctorStar = [self getValueWithString:[dic objectForKey:@"DoctorStar"]];
        _doctorHospital = [self getValueWithString:[dic objectForKey:@"DoctorHospital"]];
        _doctorDepartment = [self getValueWithString:[dic objectForKey:@"DoctorDepartment"]];
        _doctorCommentCount = [self getValueWithString:[dic objectForKey:@"DoctorCommentCount"]];
    }
    return self;
}
-(NSString *)getValueWithString:(NSString *)str{
    if (str) {
        return str;
    }else{
        return @"";
    }
}
@end
