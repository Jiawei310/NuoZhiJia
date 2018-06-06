//
//  InterfaceModel.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "EvaluateInfo.h"
#import "TreatInfo.h"
#import "FragmentInfo.h"
#import "TreatmentInfo.h"

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
    InterfaceModelBackTypeGetTreatmentSet                = 9,       //疗程设置数据
    InterfaceModelBackTypeGetAllTreatmentSet             = 10,      //所有疗程设置数据
    InterfaceModelBackTypeGetFragment                    = 11,      //碎片化搜集数据
    InterfaceModelBackTypeAlertPatientInfo               = 12,      //修改个人信息
    InterfaceModelBackTypeSetTreatment                   = 13,      //设置疗程
    InterfaceModelBackTypeAltTreatment                   = 14,      //修改疗程
    InterfaceModelBackTypePoint                          = 15,      //获取积分
    InterfaceModelBackTypeHomePicture                    = 16,      //获取主页图片
    InterfaceModelBackTypeHomePictureTwo                 = 17,      //获取主页图片2
    InterfaceModelBackTypeGetSoftVersion                 = 18,      //getSoftVersion

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
 *插入碎片化信息借口调用(用的是江浩的服务器)
 *fragmentInfo 是传入的搜集到的碎片化数据对象
 */
- (void)insertFragmentInfoToServer:(FragmentInfo *)fragmentInfo;

/*
 *获取碎片化信息借口调用(用的是江浩的服务器)
 *myUserId 是传入的用户ID（PatientID）
 *date
 */
- (void)getFragmentInfoFromServer:(NSString *)myUserId
                      collectDate:(NSString *)date;

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
- (void)insertTreatInfoToServer:(TreatInfo *)treatInfo DeviceCode:(NSString *)deviceCode;

/*
 *从后台数据库获取治疗数据
 *userId 是传入的用户ID
 *pwd 是传入的用户ID对应的密码
 *传入用户ID和密码便于存储到本地，密码在获取个人信息接口中获取不到，故此只能传
 */
- (void)getTreatInfoFromServer:(NSString *)patientID;

/*
 *插入疗程接口调用(用的是江浩的服务器)
 *fragmentInfo 是传入的搜集到的碎片化数据对象
 */
- (void)insertTreatmentSetInfoToServer:(TreatmentInfo *)treatmentInfo;

/*
 *更新疗程接口调用(用的是江浩的服务器)
 *fragmentInfo 是传入的搜集到的碎片化数据对象
 */
- (void)updateTreatmentSetInfoToServer:(TreatmentInfo *)treatmentInfo;

/*
 *获取疗程接口调用(用的是江浩的服务器)
 *myUserId 是传入的用户ID（PatientID）
 *treatmentID 是疗程ID
 */
- (void)getTreatmentSetInfoFromServer:(NSString *)myUserId
                           andTreatmentID:(NSString *)treatmentID;

/*
 *获取疗程接口调用(用的是江浩的服务器)
 *myUserId 是传入的用户ID（PatientID）
 */
- (void)getAllTreatmentSetInfoFromServer:(NSString *)myUserId;

/*
 *上传量表结果接口调用(用的是江浩的服务器)
 *myUserId 是传入的用户ID（PatientID）
 */
- (void)sendScaleResultToServerWithResultArray:(NSArray *)resultArray
                                       andType:(NSString *)typeStr
                                       andDate:(NSString *)recordDate
                                      andScore:(NSString *)score
                                     andResult:(NSString *)result
                                  andPatientID:(NSString *)patientID;

/*
 *积分获取
 *myUserId 用户ID（PatientID）
 */
- (void)getPointFromServer:(NSString *)myUserId
                 pointPage:(NSString *)page;

/*
 *积分上传
 *myUserId 用户ID（PatientID）
 *type 积分类型：1.治疗10分钟 +2分； 2.完成1/3疗程 +5分； 3.完成2/3疗程 +10分； 4.完成全部疗程 +20分
               5.发布帖子 +3分； 6.评论帖子 +1分； 7.量表评估 +3分； 8.助眠音乐 +5分
               9.评估报告分享 +8分； 10.眠友圈分享 +8分； 11.评价医生 +5分
 */
- (void)uploadPointToServer:(NSString *)myUserId
                  pointType:(NSString *)type;

/*
 *获取主页图片资源
 */
- (void)sendJsonPictureToServer;

/*
 *获取主页图片资源2
 */
- (void)sendJsonPictureTwoToServer;

/*
 *上传用户软件版本号、设备名称
 *myUserId 用户ID（PatientID）
 *appVersion app的版本号
 *device 使用的手机型号
 */
- (void)sendJsonDeviceValueToServer:(NSString *)myUserId
                            Version:(NSString *)appVersion
                              Model:(NSString *)device
                               Date:(NSString *)currentDate;
/*
 *获取软件版本号
 *phoneType:Ios 苹果APP
 */
- (void)getSoftVersion;
@end
