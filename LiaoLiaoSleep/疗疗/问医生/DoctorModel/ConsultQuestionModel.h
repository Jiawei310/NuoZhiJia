//
//  ConsultQuestionModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConsultQuestionModel : NSObject

//问题信息
@property(copy, nonatomic) NSString * questionID;//conversationId
@property(copy, nonatomic) NSString * question;
@property(copy, nonatomic) NSString * startTime;
@property(copy, nonatomic) NSString * answerTime;
@property(copy, nonatomic) NSString * isClose;
@property(copy, nonatomic) NSString * isHot;
@property(copy, nonatomic) NSString * askCount;

//患者信息
@property(copy, nonatomic) NSString * patientID;
@property(copy, nonatomic) NSString * name;
@property(copy, nonatomic) NSString * sex;
@property(copy, nonatomic) NSString * birth;
@property(copy, nonatomic) NSString * headerImage;

//医生信息
@property(copy, nonatomic) NSString * doctorID;
@property(copy, nonatomic) NSString * doctorName;
@property(copy, nonatomic) NSString * doctorHospital;
@property(copy, nonatomic) NSString * doctorDepartment;
@property(copy, nonatomic) NSString * doctorStar;
@property(copy, nonatomic) NSString * doctorIcon;
@property(copy, nonatomic) NSString * doctorCommentCount;

-(instancetype)init;
-(instancetype)initWithDictionary:(NSDictionary *)dic;

@end

