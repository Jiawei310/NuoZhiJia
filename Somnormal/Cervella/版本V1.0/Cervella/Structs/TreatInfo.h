//
//  TreatInfo.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/21.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreatInfo : NSObject

@property (nonatomic, copy) NSString *PatientID;  //患者ID
@property (nonatomic, copy) NSString *Date;       //日期
@property (nonatomic, copy) NSString *Strength;   //强度
@property (nonatomic, copy) NSString *Frequency;  //频率
@property (nonatomic, copy) NSString *Time;       //总时长
@property (nonatomic, copy) NSString *BeginTime;  //开始时间
@property (nonatomic, copy) NSString *EndTime;    //结束时间
@property (nonatomic, copy) NSString *CureTime;   //治疗时间

@end
