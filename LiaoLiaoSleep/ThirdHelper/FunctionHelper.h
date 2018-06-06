//
//  FunctionHelper.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/5.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "EMClient.h"

@interface FunctionHelper : NSObject

- (NSString *)getAgeWithBirth:(NSString *)birth;
- (NSInteger)checkDate:(NSString *)endTime;
- (NSString *)getTimeIntervalWithEndTime:(NSString *)endTime;
+ (NSString *)getTimeIntervalWithStartTime:(NSString *)startTime;
+ (BOOL)checkDateWithEndTime:(NSString *)endTime;
+ (BOOL)isBlankString:(NSString *)string;


+ (BOOL)uploadLeaveNumber:(NSString *)count withQuestionID:(NSString *)patientID;
+ (BOOL)uploadAskCount:(NSString *)count withQuestionID:(NSString *)questionID;
+ (BOOL)uploadHistoryChatMessageWithMessage:(EMMessage *)message withQuestionID:(NSString *)questionID;
+ (NSString *)getImageName;
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

//时间戳
+ (NSString *)getNowTimeInterval;
#pragma mark -- 判断是否联网
+ (BOOL)isExistenceNetwork;
#pragma mark -- 推送本地通知2-----问医生和客服
+ (void)registerLocalNotificationWithalertBody:(NSString *)alertBody andalertTitle:(NSString *)alertTitle;
+ (void)registerLocalNotification:(NSString *)date alertBody:(NSString *)alertBody userDict:(NSDictionary *)userDict;
+ (void)cancelLocalNotificationWithKey:(NSString *)key;
+ (BOOL)updateAccumulatePointWithPatientID:(NSString *)patient andType:(NSInteger)type;

+ (NSString *)iPhoneVersion;
+ (NSString *)iPhoneMode;

@end
