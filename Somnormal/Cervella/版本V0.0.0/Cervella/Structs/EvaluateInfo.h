//
//  SleepEvaluateInfo.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvaluateInfo : NSObject

@property (nonatomic, copy) NSString *PatientID;
@property (nonatomic, copy) NSString *ListFlag;
@property (nonatomic, copy) NSString *Date;
@property (nonatomic, copy) NSString *Time;
@property (nonatomic, copy) NSString *Score;
@property (nonatomic, copy) NSString *Quality;
@property (nonatomic, copy) NSString *AdviceFreq;
@property (nonatomic, copy) NSString *AdviceTime;
@property (nonatomic, copy) NSString *AdviceStrength;
@property (nonatomic, copy) NSString *AdviceNum;

@end
