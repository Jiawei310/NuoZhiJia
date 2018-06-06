//
//  TreatmentInfo.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/12/19.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreatmentInfo : NSObject

@property (nonatomic, strong) NSString *PatientID;
@property (nonatomic, strong) NSString *TreatmentID;
@property (nonatomic, strong) NSString *StartDate;
@property (nonatomic, strong) NSString *EndDate;
@property (nonatomic, strong) NSString *GetUpTime;
@property (nonatomic, strong) NSString *TreatTimeOne;
@property (nonatomic, strong) NSString *TreatTimeTwo;
@property (nonatomic, strong) NSString *GoToBedTime;

@end
