//
//  DoctorInfoModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DoctorInfoModel : NSObject

//医生信息
@property (copy, nonatomic) NSString * doctorID;
@property (copy, nonatomic) NSString * doctorName;
@property (copy, nonatomic) NSString * doctorHospital;
@property (copy, nonatomic) NSString * doctorDepartment;
@property (copy, nonatomic) NSString * doctorLoction;
@property (copy, nonatomic) NSString * doctorStar;
@property (copy, nonatomic) NSString * doctorIcon;
@property (copy, nonatomic) NSString * doctorTap;
@property (copy, nonatomic) NSString * doctorBrief;
@property (copy, nonatomic) NSString * questionCount;
@property (copy, nonatomic) NSString * fullStarCount;
@property (copy, nonatomic) NSString * commentCount;

- (instancetype)init;
- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
