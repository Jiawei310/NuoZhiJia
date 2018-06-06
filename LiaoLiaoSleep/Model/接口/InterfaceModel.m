//
//  InterfaceModel.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "InterfaceModel.h"
#import "Define.h"
#import "FunctionHelper.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "DataBaseOpration.h"

#import "JXTAlertManagerHeader.h"

@interface InterfaceModel()

/*
 *用来接用户ID的全局变量
 */
@property (strong,nonatomic) NSString *userId;
/*
 *用来接用户ID对应密码的全局变量
 */
@property (strong,nonatomic) NSString *pwd;
/*
 *用来接用户注册手机号的全局变量
 */
@property (strong,nonatomic) NSString *phoneNum;
/*
 *用来接用户对象的全局变量
 */
@property (strong,nonatomic) PatientInfo *patientInfo;
/*
 *用来判断调用登录接口做什么的
 *1.点击登录调用登录接口登录
 *2.点击忘记密码调用登录接口进入密码修改界面
 */
@property (nonatomic) BOOL isLogin;
/*
 *此次修改当中包不包括头像修改
 */
@property (nonatomic) BOOL isPhotoAlert;

//网络接口解析所需的全局变量
@property (strong,nonatomic)        NSString *soapMsg;
@property (strong,nonatomic)   NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic)     NSXMLParser *xmlParser;
@property (nonatomic)                   BOOL  elementFound;
@property (strong,nonatomic)        NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end

@implementation InterfaceModel

@synthesize soapMsg,webData,soapResults,xmlParser,elementFound,matchingElement,conn;

/*******验证手机号是否可以注册*******/
-(void)sendJsonPhoneToServer:(NSString *)phoneNum
{
    _phoneNum = phoneNum;
    NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:phoneNum,@"CellPhone",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_VerifyPhoneResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_VerifyPhone xmlns=\"MeetingOnline\">"
               "<JsonPhone>%@</JsonPhone>"
               "</APP_VerifyPhone>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******发送短信给用户接口*******/
-(void)sendSendShortMessageToUser:(NSString *)phoneNum
{
    NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:phoneNum,@"CellPhone",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_SendShortMessageResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_SendShortMessage xmlns=\"MeetingOnline\">"
               "<JsonPhoneInfo>%@</JsonPhoneInfo>"
               "</APP_SendShortMessage>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******调用注册接口*******/
-(void)sendJsonRegisterInfoToServer:(PatientInfo *)patientInfo
{
    _patientInfo = patientInfo;
    
    NSDictionary *jsonRegisterPatient = [NSDictionary dictionaryWithObjectsAndKeys:patientInfo.PatientID,@"PatientID",patientInfo.PatientID,@"PatientName",patientInfo.PatientPwd,@"PatientPwd",patientInfo.PatientSex,@"PatientSex",patientInfo.CellPhone,@"CellPhone",patientInfo.Birthday,@"Birthday",@"",@"IDCard",@"0",@"Age",@"",@"Marriage",@"",@"NativePlace",@"",@"BloodModel",@"",@"FamilyPhone",@"",@"Email",@"",@"Vocation",@"",@"Address",@"",@"PatientHeight",@"",@"PatientWeight",@"",@"PatientRemarks",@"",@"Picture",@"2",@"PatientType", nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonRegisterPatient, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_RegisterPatientResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_RegisterPatient xmlns=\"MeetingOnline\">"
               "<JsonRegisterInfo>%@</JsonRegisterInfo>"
               "</APP_RegisterPatient>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}


/*******调用登录借口*******/
-(void)sendJsonLoginInfoToServer:(NSString *)userId password:(NSString *)pwd isLogin:(BOOL)isLogin
{
    _userId = userId;
    _pwd = pwd;
    _isLogin = isLogin;
    
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"UserID",pwd,@"Upwd",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_LoginResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_Login xmlns=\"MeetingOnline\">"
               "<JsonLoginInfo>%@</JsonLoginInfo>"
               "</APP_Login>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}


/*******网络请求用户个人信息*******/
-(void)sendJsonPatientIDToServer:(NSString *)myUserId andPwd:(NSString *)myPwd
{
    _userId = myUserId;
    _pwd = myPwd;
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:_userId,@"PatientID",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetPatientInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_GetPatientInfo xmlns=\"MeetingOnline\">"
               "<JsonPatientID>%@</JsonPatientID>"
               "</APP_GetPatientInfo>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******修改个人信息借口方法*******/
-(void)sendJsonSaveInfoToServer:(PatientInfo *)patientInfo isPhotoAlter:(BOOL)photoAlter
{
    _patientInfo = patientInfo;
    _isPhotoAlert = photoAlter;
    
    NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:patientInfo.PatientID,@"PatientID",patientInfo.PatientName,@"PatientName",patientInfo.PatientPwd,@"PatientPwd",patientInfo.PatientSex,@"PatientSex",patientInfo.Birthday,@"Birthday",@"",@"IDCard",[NSString stringWithFormat:@"%ld",(long)patientInfo.Age],@"Age",@"",@"Marriage",@"",@"NativePlace",@"",@"BloodModel",patientInfo.FamilyPhone,@"FamilyPhone",patientInfo.CellPhone,@"CellPhone",patientInfo.Email,@"Email",@"",@"Vocation",patientInfo.Address,@"Address",@"",@"PatientHeight",@"",@"PatientWeight",patientInfo.PatientRemarks,@"PatientRemarks",_patientInfo.Picture,@"Picture",@"上海",@"City",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_SavePatientInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_SavePatientInfo xmlns=\"MeetingOnline\">"
               "<JsonSaveInfo>%@</JsonSaveInfo>"
               "</APP_SavePatientInfo>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******插入碎片化数据*******/
- (void)insertFragmentInfoToServer:(FragmentInfo *)fragmentInfo
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:fragmentInfo.PatientID,@"PatientID",fragmentInfo.CollectDate,@"CollectDate",fragmentInfo.BadDream,@"BadDream",fragmentInfo.SleepDifficult,@"SleepDifficult",fragmentInfo.EasyWakeUp,@"EasyWakeUp",fragmentInfo.BreathDifficult,@"BreathDifficult",fragmentInfo.Cold,@"Cold",fragmentInfo.Snore,@"Snore",fragmentInfo.NightUp,@"NightUp",fragmentInfo.Pain,@"Pain",fragmentInfo.Hot,@"Hot",fragmentInfo.Other,@"Other",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_InsertFragmentResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_InsertFragment xmlns=\"MeetingOnline\">"
               "<JsonFragmentInfo>%@</JsonFragmentInfo>"
               "</APP_InsertFragment>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******获取碎片化数据*******/
- (void)getFragmentInfoFromServer:(NSString *)myUserId collectDate:(NSString *)date
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:myUserId,@"PatientID",date,@"CollectDate",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetFragmentResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_GetFragment xmlns=\"MeetingOnline\">"
               "<JsonPatientInfo>%@</JsonPatientInfo>"
               "</APP_GetFragment>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******插入评估数据*******/
- (void)insertEvaluateInfoToServer:(EvaluateInfo *)evaluateInfo
{
    //循环调用插入评估数据接口
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:evaluateInfo.PatientID,@"PatientID",evaluateInfo.Time,@"SaveTime",evaluateInfo.Quality,@"Quality",evaluateInfo.Date,@"Date",evaluateInfo.Score,@"Score",evaluateInfo.ListFlag,@"Type",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_InsertAndUpdateEvaluateDataResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_InsertAndUpdateEvaluateData xmlns=\"MeetingOnline\">"
                         "<JsonEvaluateData>%@</JsonEvaluateData>"
                         "</APP_InsertAndUpdateEvaluateData>"
                         "</soap12:Body>"
                         "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******获取评估数据*******/
- (void)getEvaluateDataFromServer:(NSString *)patientID
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:patientID,@"PatientID",@"",@"Date",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetEvaluateDataResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_GetEvaluateData xmlns=\"MeetingOnline\">"
               "<JsonEvaluateData>%@</JsonEvaluateData>"
               "</APP_GetEvaluateData>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******插入治疗数据*******/
- (void)insertTreatInfoToServer:(TreatInfo *)treatInfo DeviceCode:(NSString *)deviceCode
{
    if(deviceCode==nil){
        deviceCode = @"";
    }
    NSString *version = [NSString stringWithFormat:@"%@ %@ %@", [FunctionHelper iPhoneMode],[FunctionHelper iPhoneVersion],[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:
                                treatInfo.PatientID,@"PatientID",
                                treatInfo.Strength,@"Strength",
                                treatInfo.Frequency,@"Freq",
                                treatInfo.BeginTime ,@"BeginTime",
                                deviceCode,@"EndTime",
                                treatInfo.CureTime,@"CureTime",
                                @"",@"Phone",
                                @"",@"PhoneDetail",
                                version,@"Version",
                                nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_InsertCureDataResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_InsertCureData3 xmlns=\"MeetingOnline\">"
                         "<JsonCureData>%@</JsonCureData>"
                         "</APP_InsertCureData3>"
                         "</soap12:Body>"
                         "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******获取治疗数据*******/
- (void)getTreatInfoFromServer:(NSString *)patientID
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:patientID,@"PatientID",@"",@"BeginTime",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetCureDataResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_GetCureData xmlns=\"MeetingOnline\">"
                         "<JsonCureData>%@</JsonCureData>"
                         "</APP_GetCureData>"
                         "</soap12:Body>"
                         "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******插入疗程数据*******/
- (void)insertTreatmentSetInfoToServer:(TreatmentInfo *)treatmentInfo
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:treatmentInfo.PatientID,@"PatientID",treatmentInfo.TreatmentID,@"TreatmentID",treatmentInfo.StartDate,@"StartDate",treatmentInfo.EndDate,@"EndDate",treatmentInfo.GetUpTime,@"GetUpTime",treatmentInfo.TreatTimeOne,@"TreatTimeOne",treatmentInfo.TreatTimeTwo,@"TreatTimeTwo",treatmentInfo.GoToBedTime,@"GoToBedTime",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_InsertTreatmentSetResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_InsertTreatmentSet xmlns=\"MeetingOnline\">"
               "<JsonTreatmentSetInfo>%@</JsonTreatmentSetInfo>"
               "</APP_InsertTreatmentSet>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******修改疗程数据*******/
- (void)updateTreatmentSetInfoToServer:(TreatmentInfo *)treatmentInfo
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:treatmentInfo.PatientID,@"PatientID",treatmentInfo.TreatmentID,@"TreatmentID",treatmentInfo.StartDate,@"StartDate",treatmentInfo.EndDate,@"EndDate",treatmentInfo.GetUpTime,@"GetUpTime",treatmentInfo.TreatTimeOne,@"TreatTimeOne",treatmentInfo.TreatTimeTwo,@"TreatTimeTwo",treatmentInfo.GoToBedTime,@"GoToBedTime",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_UpdateTreatmentSetResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_UpdateTreatmentSet xmlns=\"MeetingOnline\">"
               "<JsonTreatmentIInfo>%@</JsonTreatmentIInfo>"
               "</APP_UpdateTreatmentSet>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******获取疗程数据*******/
- (void)getTreatmentSetInfoFromServer:(NSString *)myUserId andTreatmentID:(NSString *)treatmentID
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:myUserId,@"PatientID",treatmentID,@"TreatmentID",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetTreatmentSetResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_GetTreatmentSet xmlns=\"MeetingOnline\">"
               "<JsonDateInfo>%@</JsonDateInfo>"
               "</APP_GetTreatmentSet>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******获取所有疗程数据*******/
- (void)getAllTreatmentSetInfoFromServer:(NSString *)myUserId
{
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetAllTreatmentSetResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_GetAllTreatmentSet xmlns=\"MeetingOnline\">"
               "<pPatientID>%@</pPatientID>"
               "</APP_GetAllTreatmentSet>"
               "</soap12:Body>"
               "</soap12:Envelope>", myUserId,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/*******上传量表结果*******/
- (void)sendScaleResultToServerWithResultArray:(NSArray *)resultArray andType:(NSString *)typeStr andDate:(NSString *)recordDate andScore:(NSString *)score andResult:(NSString *)result andPatientID:(NSString *)patientID
{
    NSString *answer_One;
    NSString *answer_Two;
    NSString *answer_Three;
    NSString *answer_Four;
    NSString *answer_Remain;
    NSString *type;
    if ([typeStr isEqualToString:@"匹兹堡睡眠指数"])
    {
        type = @"1";
        answer_One = [resultArray objectAtIndex:0];
        answer_Two = [resultArray objectAtIndex:1];
        answer_Three = [resultArray objectAtIndex:2];
        answer_Four = [resultArray objectAtIndex:3];
        for (int i = 4; i < resultArray.count; i++)
        {
            if (i == 4)
            {
                answer_Remain = [resultArray objectAtIndex:i];
            }
            else
            {
                answer_Remain = [answer_Remain stringByAppendingFormat:@"*%@",[resultArray objectAtIndex:i]];
            }
        }
    }
    else
    {
        if ([typeStr isEqualToString:@"抑郁自评"])
        {
            type = @"2";
        }
        else if ([typeStr isEqualToString:@"焦虑自评"])
        {
            type = @"3";
        }
        else if ([typeStr isEqualToString:@"躯体自评"])
        {
            type = @"4";
        }
        answer_One = @"";
        answer_Two = @"";
        answer_Three = @"";
        answer_Four = @"";
        for (int i = 0; i < resultArray.count; i++)
        {
            if (i == 0)
            {
                answer_Remain = [resultArray objectAtIndex:i];
            }
            else
            {
                answer_Remain = [answer_Remain stringByAppendingFormat:@"*%@",[resultArray objectAtIndex:i]];
            }
        }
    }
    
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:patientID,@"PatientID",recordDate,@"RecordDate",answer_One,@"Answer1",answer_Two,@"Answer2",answer_Three,@"Answer3",answer_Four,@"Answer4",answer_Remain,@"AnswerRemain",score,@"Score",result,@"Result",type,@"Type", nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_UploadPSQIResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_UploadPSQI xmlns=\"MeetingOnline\">"
               "<JsonPSQI>%@</JsonPSQI>"
               "</APP_UploadPSQI>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/* 获取积分 */
- (void)getPointFromServer:(NSString *)myUserId
                 pointPage:(NSString *)page
{
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"Wang_DownloadAllPointResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<Wang_DownloadAllPoint xmlns=\"MeetingOnline\">"
               "<pPatientID>%@</pPatientID>"
               "<pPage>%@</pPage>"
               "</Wang_DownloadAllPoint>"
               "</soap12:Body>"
               "</soap12:Envelope>", myUserId, page, nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/* 积分上传 */
- (void)uploadPointToServer:(NSString *)myUserId
                  pointType:(NSString *)type
{
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"Wang_UploadPointResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<Wang_UploadPoint xmlns=\"MeetingOnline\">"
               "<pPatientID>%@</pPatientID>"
               "<pType>%@</pType>"
               "</Wang_UploadPoint>"
               "</soap12:Body>"
               "</soap12:Envelope>", myUserId,type, nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/* 获取首页轮播图片资源 */
- (void)sendJsonPictureToServer
{
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"Wang_DownloadHolidayPictureResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<Wang_DownloadHolidayPicture xmlns=\"MeetingOnline\">"
               "</Wang_DownloadHolidayPicture>"
               "</soap12:Body>"
               "</soap12:Envelope>", nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/* 获取首页轮播图片资源2 */
- (void)sendJsonPictureTwoToServer
{
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"Wang_DownloadHolidayPicture2Response";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<Wang_DownloadHolidayPicture2 xmlns=\"MeetingOnline\">"
               "</Wang_DownloadHolidayPicture2>"
               "</soap12:Body>"
               "</soap12:Envelope>", nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}

/* 插入用户ID、app版本号、手机型号 */
- (void)sendJsonDeviceValueToServer:(NSString *)myUserId
                            Version:(NSString *)appVersion
                              Model:(NSString *)device
                               Date:(NSString *)currentDate
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:myUserId, @"PatientID", @"", @"DeviceID", appVersion, @"VersionID", device, @"PhoneSize", currentDate, @"Date", nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_InsertCellPhoneResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<APP_InsertCellPhone xmlns=\"MeetingOnline\">"
               "<JsonCellPhone>%@</JsonCellPhone>"
               "</APP_InsertCellPhone>"
               "</soap12:Body>"
               "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}
/* 获取app最新版本号 */
- (void)getSoftVersion {
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"Temp_GetSoftVersionResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    soapMsg = [NSString stringWithFormat:
               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
               "<soap12:Envelope "
               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
               "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
               "<soap12:Body>"
               "<Temp_GetSoftVersion xmlns=\"MeetingOnline\">"
               "<pPhoneSystem>Ios</pPhoneSystem>"
               "</Temp_GetSoftVersion>"
               "</soap12:Body>"
               "</soap12:Envelope>", nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    [self allNeedPartByJH];
}
/*******(江浩)接口调用网络请求公共部分*******/
- (void)allNeedPartByJH
{
    //设置网络连接的url
    NSString *urlStr = [NSString stringWithFormat:@"%@",JHADDRESS];
    NSURL *url = [NSURL URLWithString:urlStr];
    //设置request
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSString *msgLength=[NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [request setHTTPMethod:@"POST"];//默认是GET
    // 将SOAP消息加到请求中
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    // 创建连接
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        webData = [NSMutableData data];
    }
}

#pragma mark -
#pragma mark URL Connection Data Delegate Methods
// 刚开始接受响应时调用
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response
{
    [webData setLength: 0];
}

// 每接收到一部分数据就追加到webData中
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *) data
{
    [webData appendData:data];
}

// 出现错误时
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    NSLog(@"error:%@", error.description);
    conn = nil;
    webData = nil;
}

// 完成接收数据时调用
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes]
                                                length:[webData length]
                                              encoding:NSUTF8StringEncoding];
    
    // 打印出得到的XML
    NSLog(@"%@", theXML);
    // 使用NSXMLParser解析出我们想要的结果
    xmlParser = [[NSXMLParser alloc] initWithData: webData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
}


#pragma mark -
#pragma mark XML Parser Delegate Methods
// 开始解析一个元素名
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:matchingElement])
    {
        if (!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        elementFound = YES;
    }
}

// 追加找到的元素值，一个元素值可能要分几次追加
-(void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if (elementFound)
    {
        [soapResults appendString: string];
    }
}

// 结束解析这个元素名
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:matchingElement])
    {
        if ([matchingElement isEqualToString:@"APP_LoginResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *state=[resultDic objectForKey:@"state"];
            NSString *description=[resultDic objectForKey:@"description"];
            if (_isLogin)
            {
                if(_userId.length>0 && _pwd.length>0 && [state isEqualToString:@"OK"])
                {
                    //网络请求用户个人信息
                    [self sendJsonPatientIDToServer:_userId andPwd:_pwd];
                }
                else
                {
                    [self.delegate sendValueBackToController:nil type:InterfaceModelBackTypeLoginPasswordError];
                    
                    if ([description isEqualToString:@"账号不存在！"])
                    {
                        [JXTAlertView showToastViewWithTitle:@"温馨提示" message:@"账号不存在，请检查后重新输入" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                            NSLog(@"关闭");
                        }];
                    }
                    else if ([state isEqualToString:@"NO"] && [description isEqualToString:@"密码错误！"])
                    {
                        [JXTAlertView showToastViewWithTitle:@"温馨提示" message:@"密码错误！" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                            NSLog(@"关闭");
                        }];
                    }
                }
            }
            else
            {
                if ([description isEqualToString:@"账号不存在！"])
                {
                    [JXTAlertView showToastViewWithTitle:@"温馨提示" message:@"账号不存在，请检查后重新输入" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                        NSLog(@"关闭");
                    }];
                    
                    [self.delegate sendValueBackToController:nil type:InterfaceModelBackTypeAccountNotExist];
                }
                else if ([state isEqualToString:@"NO"] && [description isEqualToString:@"密码错误！"])
                {
                    [self.delegate sendValueBackToController:nil type:InterfaceModelBackTypeFindPassword];
                }
            }
        }
        else if ([matchingElement isEqualToString:@"APP_GetPatientInfoResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultDic=[resultArray objectAtIndex:0];
            
            [self patientInfoPersistence:resultDic];
        }
        else if ([matchingElement isEqualToString:@"APP_SendShortMessageResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *code=[resultDic objectForKey:@"Code"];
            NSLog(@"%@",code);
            [self.delegate sendValueBackToController:code type:InterfaceModelBackTypeMessage];
        }
        else if ([matchingElement isEqualToString:@"APP_VerifyPhoneResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *verifyState=[resultDic objectForKey:@"state"];
            NSString *verifyDescription=[resultDic objectForKey:@"description"];
            
            //判断输入的手机号是否可以注册
            if ([verifyState isEqualToString:@"OK"])
            {
                [self.delegate sendValueBackToController:nil type:InterfaceModelBackTypeVerifyAccount];
                
                [self sendSendShortMessageToUser:_phoneNum];
            }
            else if ([verifyState isEqualToString:@"NO"])
            {
                [JXTAlertView showToastViewWithTitle:@"温馨提示" message:verifyDescription duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                    NSLog(@"关闭");
                }];
            }
        }
        else if ([matchingElement isEqualToString:@"APP_RegisterPatientResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *state=[resultDic objectForKey:@"state"];
            if ([state isEqualToString:@"OK"])
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                [userDefault setObject:_patientInfo.PatientID forKey:@"PatientID"];
                [userDefault setObject:_patientInfo.PatientPwd forKey:@"PatientPwd"];
                //跳转到主界面（变更app的根视图控制器）
                [self.delegate sendValueBackToController:_patientInfo type:InterfaceModelBackTypeLogin];
                
                //将Patient对象存储到本地sqlite数据库
                DataBaseOpration *dbOpration=[[DataBaseOpration alloc] init];
                [dbOpration insertUserInfo:_patientInfo];
                [dbOpration closeDataBase];
            }
        }
        else if ([matchingElement isEqualToString:@"APP_GetFragmentResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            //将用户所有碎片化数据持久化
            [self fragmentPersistence:resultArray];
            //跳转到主界面（变更app的根视图控制器）
            [self.delegate sendValueBackToController:_patientInfo type:InterfaceModelBackTypeLogin];
            
            //这里记住的不是第三方注册账号的账号和密码，而是使用账户密码登陆方式的账号和密码
            if (_isLogin)
            {
                //记住密码
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                [userDefault setObject:_userId forKey:@"PatientID"];
                [userDefault setObject:_pwd forKey:@"PatientPwd"];
            }
        }
        else if ([matchingElement isEqualToString:@"APP_GetEvaluateDataResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            //将用户所有评估数据持久化
            [self assessmentPersistence:resultArray];
            //加载碎片化数据
            [self getFragmentInfoFromServer:_userId collectDate:@""];
        }
        else if ([matchingElement isEqualToString:@"APP_GetCureDataResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            //将用户所有治疗数据持久化
            [self treatPersistence:resultArray];
            //加载评估数据
            [self getEvaluateDataFromServer:_userId];
        }
        else if ([matchingElement isEqualToString:@"APP_GetTreatmentSetResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            [self.delegate sendValueBackToController:resultArray type:InterfaceModelBackTypeGetTreatmentSet];
        }
        else if ([matchingElement isEqualToString:@"APP_GetAllTreatmentSetResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            //将用户所有疗程数据持久化
            [self treatmentPersistence:resultArray];
            //加载治疗数据
            [self getTreatInfoFromServer:_userId];
        }
        else if ([matchingElement isEqualToString:@"APP_SavePatientInfoResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            [self.delegate sendValueBackToController:resultArray type:InterfaceModelBackTypeAlertPatientInfo];
        }
        else if ([matchingElement isEqualToString:@"APP_InsertTreatmentSetResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            [self.delegate sendValueBackToController:resultArray type:InterfaceModelBackTypeSetTreatment];
        }
        else if ([matchingElement isEqualToString:@"APP_UpdateTreatmentSetResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            [self.delegate sendValueBackToController:resultArray type:InterfaceModelBackTypeAltTreatment];
        }
        else if ([matchingElement isEqualToString:@"Wang_DownloadAllPointResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            [self.delegate sendValueBackToController:resultArray type:InterfaceModelBackTypePoint];
        }
        else if ([matchingElement isEqualToString:@"Wang_DownloadHolidayPictureResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            [self.delegate sendValueBackToController:resultArray type:InterfaceModelBackTypeHomePicture];
        }
        else if ([matchingElement isEqualToString:@"Wang_DownloadHolidayPicture2Response"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            [self.delegate sendValueBackToController:resultArray type:InterfaceModelBackTypeHomePictureTwo];
        }
        else if ([matchingElement isEqualToString:@"Temp_GetSoftVersionResponse"]){
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *state=[resultDic objectForKey:@"state"];
            NSLog(@"%@",state);
            [self.delegate sendValueBackToController:state type:InterfaceModelBackTypeGetSoftVersion];

        }
        
        elementFound = FALSE;
        // 强制放弃解析
        [xmlParser abortParsing];
    }
}

// 解析整个文件结束后
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

// 出错时，例如强制结束解析
- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

//个人信息持久化
- (void)patientInfoPersistence:(NSDictionary *)patientDic
{
    _patientInfo = [[PatientInfo alloc] init];
    _patientInfo.PatientID = _userId;
    _patientInfo.PatientPwd = _pwd;
    _patientInfo.PatientName = [patientDic objectForKey:@"PatientName"];
    _patientInfo.PatientSex = [patientDic objectForKey:@"PatientSex"];
    if ([[patientDic objectForKey:@"Birthday"] isEqual:[NSNull null]])
    {
        _patientInfo.Birthday = @"";
    }
    else
    {
        _patientInfo.Birthday = [patientDic objectForKey:@"Birthday"];
    }
    _patientInfo.Age = [[patientDic objectForKey:@"Age"] integerValue];
    _patientInfo.Marriage = [patientDic objectForKey:@"Marriage"];
    _patientInfo.NativePlace = [patientDic objectForKey:@"NativePlace"];
    _patientInfo.BloodModel = [patientDic objectForKey:@"BloodModel"];
    _patientInfo.CellPhone = [patientDic objectForKey:@"CellPhone"];
    _patientInfo.FamilyPhone = [patientDic objectForKey:@"FamilyPhone"];
    _patientInfo.Email = [patientDic objectForKey:@"Email"];
    _patientInfo.Vocation = [patientDic objectForKey:@"Vocation"];
    _patientInfo.Address = [patientDic objectForKey:@"Address"];
    _patientInfo.PhotoUrl = [patientDic objectForKey:@"PhotoUrl"];
    _patientInfo.PatientHeight = [patientDic objectForKey:@"PatientHeight"];
    _patientInfo.PatientWeight = @"";
    _patientInfo.PatientContactWay = @"";
    _patientInfo.PatientRemarks = @"";
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", ADDRESS, _patientInfo.PhotoUrl];
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:urlStr]  options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (error)
        {
            NSLog(@"error is %@",error);
        }
        if (image)
        {
            //图片下载完成  在这里进行相关操作，如加到数组里 或者显示在imageView上
            NSData *imageData = UIImagePNGRepresentation(image);
            _patientInfo.Picture = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            //判断数据库是否存在这个patientInfo，存在则更新数据库，不存在插入数据库
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            [dbOpration updataUserInfo:_patientInfo];
            [dbOpration closeDataBase];
            
            //加载疗程信息
            [self getAllTreatmentSetInfoFromServer:_userId];
        }
    }];
}

//疗程信息持久化
- (void)treatmentPersistence:(NSArray *)treatmentArr
{
    //判断数据库是否存在这个疗程信息，存在则更新数据库，不存在插入数据库
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSArray *treatmentInfoArray = [dbOpration getTreatmentDataFromDataBase];
    
    if (treatmentInfoArray.count == 0)
    {
        for (int i = 0; i < treatmentArr.count; i++)
        {
            TreatmentInfo *temp = [[TreatmentInfo alloc] init];
            NSDictionary *treatmentDic = [treatmentArr objectAtIndex:i];
            temp.PatientID = [treatmentDic objectForKey:@"PatientID"];
            temp.TreatmentID = [treatmentDic objectForKey:@"TreatmentID"];
            temp.StartDate = [treatmentDic objectForKey:@"StartDate"];
            temp.EndDate = [treatmentDic objectForKey:@"EndDate"];
            temp.GetUpTime = [treatmentDic objectForKey:@"GetUpTime"];
            temp.TreatTimeOne = [treatmentDic objectForKey:@"TreatTimeOne"];
            temp.TreatTimeTwo = [treatmentDic objectForKey:@"TreatTimeTwo"];
            temp.GoToBedTime = [treatmentDic objectForKey:@"GoToBedTime"];
            [dbOpration insertTreatmentInfo:temp];
        }
    }
    else
    {
        for (int i = 0; i < treatmentArr.count; i++)
        {
            TreatmentInfo *temp = [[TreatmentInfo alloc] init];
            NSDictionary *treatmentDic = [treatmentArr objectAtIndex:i];
            temp.PatientID = [treatmentDic objectForKey:@"PatientID"];
            temp.TreatmentID = [treatmentDic objectForKey:@"TreatmentID"];
            temp.StartDate = [treatmentDic objectForKey:@"StartDate"];
            temp.EndDate = [treatmentDic objectForKey:@"EndDate"];
            temp.GetUpTime = [treatmentDic objectForKey:@"GetUpTime"];
            temp.TreatTimeOne = [treatmentDic objectForKey:@"TreatTimeOne"];
            temp.TreatTimeTwo = [treatmentDic objectForKey:@"TreatTimeTwo"];
            temp.GoToBedTime = [treatmentDic objectForKey:@"GoToBedTime"];
            
            BOOL isHave = NO;
            
            for (TreatmentInfo *tmp in treatmentInfoArray)
            {
                if ([tmp.StartDate isEqualToString:temp.StartDate])
                {
                    isHave = YES;
                }
            }
            if (isHave == NO)
            {
                [dbOpration insertTreatmentInfo:temp];
            }
        }
        
    }
    [dbOpration closeDataBase];
}

//治疗数据持久化
- (void)treatPersistence:(NSArray *)treatArr
{
    //判断数据库是否存在这个治疗数据，存在则更新数据库，不存在插入数据库
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSArray *treatInfoArray = [dbOpration getTreatDataFromDataBase];
    
    if (treatInfoArray.count == 0)
    {
        for (int i = 0; i < treatArr.count; i++)
        {
            TreatInfo *temp = [[TreatInfo alloc] init];
            NSDictionary *treatmentDic = [treatArr objectAtIndex:i];
            temp.PatientID = [treatmentDic objectForKey:@"PatientID"];
            temp.Date = [[treatmentDic objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(0, 10)];
            temp.Strength = [treatmentDic objectForKey:@"Strength"];
            temp.Frequency = [treatmentDic objectForKey:@"Freq"];
            temp.Time=@"1200";
            temp.BeginTime = [treatmentDic objectForKey:@"BeginTime"];
            temp.EndTime = [treatmentDic objectForKey:@"EndTime"];
            temp.CureTime = [treatmentDic objectForKey:@"CureTime"];
            [dbOpration insertTreatInfo:temp];
        }
    }
    else
    {
        for (int i = 0; i < treatArr.count; i++)
        {
            TreatInfo *temp = [[TreatInfo alloc] init];
            NSDictionary *treatmentDic = [treatArr objectAtIndex:i];
            temp.PatientID = [treatmentDic objectForKey:@"PatientID"];
            temp.Date = [[treatmentDic objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(0, 10)];
            temp.Strength = [treatmentDic objectForKey:@"Strength"];
            temp.Frequency=[treatmentDic objectForKey:@"Freq"];
            temp.Time=@"1200";
            temp.BeginTime = [treatmentDic objectForKey:@"BeginTime"];
            temp.EndTime = [treatmentDic objectForKey:@"EndTime"];
            temp.CureTime = [treatmentDic objectForKey:@"CureTime"];
            
            BOOL isHave = NO;
            
            for (TreatInfo *tmp in treatInfoArray)
            {
                if ([tmp.BeginTime isEqualToString:temp.BeginTime])
                {
                    isHave = YES;
                }
            }
            if (isHave == NO)
            {
                [dbOpration insertTreatInfo:temp];
            }
        }
        
    }
    [dbOpration closeDataBase];
}

//评估数据持久化
- (void)assessmentPersistence:(NSArray *)assessmentArr
{
    //判断数据库是否存在这个治疗数据，存在则更新数据库，不存在插入数据库
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSArray *assessmentArray = [dbOpration getEvaluateDataFromDataBase];
    
    if (assessmentArray.count == 0)
    {
        for (int i = 0; i < assessmentArr.count; i++)
        {
            EvaluateInfo *temp = [[EvaluateInfo alloc] init];
            NSDictionary *treatmentDic = [assessmentArr objectAtIndex:i];
            temp.PatientID = _userId;
            temp.ListFlag = [treatmentDic objectForKey:@"Type"];
            temp.Date = [treatmentDic objectForKey:@"Date"];
            temp.Time = [treatmentDic objectForKey:@"SaveTime"];
            temp.Score = [treatmentDic objectForKey:@"Score"];
            temp.Quality = [treatmentDic objectForKey:@"Quality"];
            [dbOpration insertEvaluateInfo:temp];
        }
    }
    else
    {
        for (int i = 0; i < assessmentArr.count; i++)
        {
            EvaluateInfo *temp = [[EvaluateInfo alloc] init];
            NSDictionary *treatmentDic = [assessmentArr objectAtIndex:i];
            temp.PatientID = _userId;
            temp.ListFlag = [treatmentDic objectForKey:@"Type"];
            temp.Date = [treatmentDic objectForKey:@"Date"];
            temp.Time = [treatmentDic objectForKey:@"SaveTime"];
            temp.Score = [treatmentDic objectForKey:@"Score"];
            temp.Quality = [treatmentDic objectForKey:@"Quality"];
            
            BOOL isHave = NO;
            
            for (EvaluateInfo *tmp in assessmentArray)
            {
                if ([tmp.Date isEqualToString:temp.Date] && [tmp.ListFlag isEqualToString:temp.ListFlag] && [tmp.PatientID isEqualToString:_userId])
                {
                    isHave = YES;
                }
            }
            if (isHave == NO)
            {
                [dbOpration insertEvaluateInfo:temp];
            }
        }
        
    }
    [dbOpration closeDataBase];
}

//碎片化数据持久化
- (void)fragmentPersistence:(NSArray *)fragmentArr
{
    //判断数据库是否存在这个治疗数据，存在则更新数据库，不存在插入数据库
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    NSArray *fragmentArray = [dbOpration getFragmentDataFromDataBase];
    
    if (fragmentArray.count == 0)
    {
        for (int i = 0; i < fragmentArr.count; i++)
        {
            FragmentInfo *temp = [[FragmentInfo alloc] init];
            NSDictionary *treatmentDic = [fragmentArr objectAtIndex:i];
            temp.PatientID = [treatmentDic objectForKey:@"PatientID"];
            temp.CollectDate = [treatmentDic objectForKey:@"CollectDate"];
            temp.BadDream = [treatmentDic objectForKey:@"BadDream"];
            temp.SleepDifficult = [treatmentDic objectForKey:@"SleepDifficult"];
            temp.EasyWakeUp = [treatmentDic objectForKey:@"EasyWakeUp"];
            temp.BreathDifficult = [treatmentDic objectForKey:@"BreathDifficult"];
            temp.Cold = [treatmentDic objectForKey:@"Cold"];
            temp.Snore = [treatmentDic objectForKey:@"Snore"];
            temp.NightUp = [treatmentDic objectForKey:@"NightUp"];
            temp.Pain = [treatmentDic objectForKey:@"Pain"];
            temp.Hot = [treatmentDic objectForKey:@"Hot"];
            temp.Other = [treatmentDic objectForKey:@"Other"];
            [dbOpration insertFragmentInfo:temp];
        }
    }
    else
    {
        for (int i = 0; i < fragmentArr.count; i++)
        {
            FragmentInfo *temp = [[FragmentInfo alloc] init];
            NSDictionary *treatmentDic = [fragmentArr objectAtIndex:i];
            temp.PatientID = [treatmentDic objectForKey:@"PatientID"];
            temp.CollectDate = [treatmentDic objectForKey:@"CollectDate"];
            temp.BadDream = [treatmentDic objectForKey:@"BadDream"];
            temp.SleepDifficult = [treatmentDic objectForKey:@"SleepDifficult"];
            temp.EasyWakeUp = [treatmentDic objectForKey:@"EasyWakeUp"];
            temp.BreathDifficult = [treatmentDic objectForKey:@"BreathDifficult"];
            temp.Cold = [treatmentDic objectForKey:@"Cold"];
            temp.Snore = [treatmentDic objectForKey:@"Snore"];
            temp.NightUp = [treatmentDic objectForKey:@"NightUp"];
            temp.Pain = [treatmentDic objectForKey:@"Pain"];
            temp.Hot = [treatmentDic objectForKey:@"Hot"];
            temp.Other = [treatmentDic objectForKey:@"Other"];
            
            BOOL isHave = NO;
            
            for (FragmentInfo *tmp in fragmentArray)
            {
                if ([tmp.CollectDate isEqualToString:temp.CollectDate])
                {
                    isHave = YES;
                }
            }
            if (isHave == NO)
            {
                [dbOpration insertFragmentInfo:temp];
            }
        }
        
    }
    [dbOpration closeDataBase];
}

@end
