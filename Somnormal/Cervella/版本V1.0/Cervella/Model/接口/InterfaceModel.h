//
//  InterfaceModel.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PatientInfo.h"
#import "EvaluateInfo.h"
#import "TreatInfo.h"

#import "InterfaceModel.h"

typedef NS_OPTIONS(NSUInteger, InterfaceModelBackType) {
    InterfaceModelBackTypeLogin					         = 1,       //登录主界面跳转主界面
    InterfaceModelBackTypeLoginPasswordError		     = 2,       //登录密码错误
    InterfaceModelBackTypeFindPassword                   = 3,       //忘记密码界面
    InterfaceModelBackTypeAccountNotExist                = 4,       //忘记密码界面，账号不存在
    InterfaceModelBackTypeVerifyAccount					 = 5,       //非第三方登录下，验证账号是否存在
    InterfaceModelBackTypeMessage					     = 6,       //短信发送
    InterfaceModelBackTypeGetTreatData 					 = 7,       //获取治疗数据
    InterfaceModelBackTypeGetEvaluateData                = 8,       //获取评估数据
    InterfaceModelBackTypeGetPatientInfo                 = 9,       //获取个人信息
    InterfaceModelBackTypeAlertPatientInfo               = 12,      //修改个人信息
};

@protocol  InterfaceModelDelegate <NSObject>

- (void)sendValueBackToController:(id)value
                             type:(InterfaceModelBackType)interfaceModelBackType;

@end

@interface InterfaceModel : NSObject <NSXMLParserDelegate,NSURLConnectionDelegate>

@property (nonatomic,weak) id<InterfaceModelDelegate>delegate;


/*
 *验证手机号是否可以注册
 *@param phoneNum 传入用户ID输入的手机号
 */
- (void)sendJsonPhoneToServer:(NSString *)phoneNum;

/*
 *发送短信验证码接口
 *@param phoneNum 传入用户ID输入的手机号
 */
- (void)sendSendShortMessageToUser:(NSString *)phoneNum;

/*
 *注册接口调用
 *@param patientInfo 传入注册用户对象信息
 */
- (void)sendJsonRegisterInfoToServer:(PatientInfo *)patientInfo;

/*
 *登录接口调用
 *@param userId 传入用户的PatientID
 *@param pwd 传入用户对应的密码PatientPwd
 *@param isLogin为YES时表示点击登录按钮时调用，为NO时表示点击忘记密码按钮时调用
 */
- (void)sendJsonLoginInfoToServer:(NSString *)userId
                         password:(NSString *)pwd
                          isLogin:(BOOL)isLogin;

/*
 *获取个人信息接口调用
 *userId 是传入的用户ID
 *pwd 是传入的用户ID对应的密码
 *传入用户ID和密码便于存储到本地，密码在获取个人信息接口中获取不到，故此只能传
 */
- (void)sendJsonPatientIDToServer:(NSString *)myUserId
                           andPwd:(NSString *)myPwd;

/*
 *修改个人信息接口调用
 *patientInfo 是传入的用户修改后的信息
 *photoAlter 是此次传递的patientInfo是否包含头像的修改
 */
- (void)sendJsonSaveInfoToServer:(PatientInfo *)patientInfo
                   isPhotoAlter:(BOOL)photoAlter;

/*
 *上传评估数据到后台数据库
 *evaluateInfo 是传入的治疗数据
 */
- (void)insertEvaluateInfoToServer:(EvaluateInfo *)evaluateInfo;

/*
 *从后台数据库获取评估数据
 *userId 是传入的用户ID
 *pwd 是传入的用户ID对应的密码
 *传入用户ID和密码便于存储到本地，密码在获取个人信息接口中获取不到，故此只能传
 */
- (void)getEvaluateDataFromServer:(NSString *)patientID;

/*
 *上传治疗数据到后台数据库
 *userId 是传入的用户ID
 *pwd 是传入的用户ID对应的密码
 *传入用户ID和密码便于存储到本地，密码在获取个人信息接口中获取不到，故此只能传
 */
- (void)insertTreatInfoToServer:(TreatInfo *)treatInfo;

/*
 *从后台数据库获取治疗数据
 *userId 是传入的用户ID
 *pwd 是传入的用户ID对应的密码
 *传入用户ID和密码便于存储到本地，密码在获取个人信息接口中获取不到，故此只能传
 */
- (void)getTreatInfoFromServer:(NSString *)patientID;

@end
