//
//  PatientInfo.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientInfo : NSObject

/*
 *用户ID（登录时的用户名，唯一的）
 */
@property (strong,nonatomic) NSString *PatientID;
/*
 *用户密码
 */
@property (strong,nonatomic) NSString *PatientPwd;
/*
 *用户姓名（与PatientID用户ID不同，不唯一）
 */
@property (strong,nonatomic) NSString *PatientName;
/*
 *用户性别
 */
@property (strong,nonatomic) NSString *PatientSex;
/*
 *用户手机号码
 */
@property (strong,nonatomic) NSString *CellPhone;
/*
 *用户出生年月
 */
@property (strong,nonatomic) NSString *Birthday;
/*
 *用户年龄
 */
@property                    NSInteger Age;
/*
 *用户婚姻状况
 */
@property (strong,nonatomic) NSString *Marriage;
/*
 *用户籍贯
 */
@property (strong,nonatomic) NSString *NativePlace;
/*
 *用户血型
 */
@property (strong,nonatomic) NSString *BloodModel;
/*
 *用户联系方式
 */
@property (strong,nonatomic) NSString *PatientContactWay;
/*
 *用户联系电话
 */
@property (strong,nonatomic) NSString *FamilyPhone ;
/*
 *用户Email
 */
@property (strong,nonatomic) NSString *Email;
/*
 *用户职业
 */
@property (strong,nonatomic) NSString *Vocation;
/*
 *用户住址
 */
@property (strong,nonatomic) NSString *Address;
/*
 *备注信息
 */
@property (strong,nonatomic) NSString *PatientRemarks;
/*
 *用户身高
 */
@property (strong,nonatomic) NSString *PatientHeight;
/*
 *用户体重
 */
@property (strong,nonatomic) NSString *PatientWeight;
/*
 *用户头像（二进制转换成的NSString类型，转换成图片需要讲其转换成二进制之后再转成图片，提供图片上传时使用）
 */
@property (strong,nonatomic) NSString *Picture;
/*
 *用户头像URL（接口返回的头像图片在服务区上的地址，提供用户显示、缓存、下载头像时使用）
 */
@property (strong,nonatomic) NSString *PhotoUrl;


+ (instancetype)shareInstance;

@end
