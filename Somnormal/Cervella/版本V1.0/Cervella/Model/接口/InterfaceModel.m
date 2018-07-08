//
//  InterfaceModel.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "InterfaceModel.h"
#import "TypeDefine.h"

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
    NSDictionary *jsonRegisterPatient = [NSDictionary dictionaryWithObjectsAndKeys:_patientInfo.PatientID,@"PatientID",_patientInfo.PatientID,@"PatientName",_patientInfo.PatientPwd,@"PatientPwd",_patientInfo.PatientSex,@"PatientSex",patientInfo.Birthday,@"Birthday",_patientInfo.Email,@"Email",_patientInfo.CellPhone,@"CellPhone",_patientInfo.Birthday,@"Birthday",@"2",@"PatientType",@"",@"IDCard",patientInfo.Address,@"Address",@"0",@"Age",patientInfo.BloodModel,@"BloodModel",_patientInfo.FamilyPhone,@"FamilyPhone",_patientInfo.Marriage,@"Marriage",_patientInfo.NativePlace,@"NativePlace",_patientInfo.PatientHeight,@"PatientHeight",_patientInfo.PatientRemarks,@"PatientRemarks",_patientInfo.PatientWeight,@"PatientWeight",_patientInfo.Picture,@"Picture",_patientInfo.Vocation,@"Vocation",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonRegisterPatient,nil];
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
    NSLog(@"%@",soapMsg);
    //打印soapMsg信息
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
- (void)insertTreatInfoToServer:(TreatInfo *)treatInfo
{
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:treatInfo.PatientID,@"PatientID",treatInfo.Strength,@"Strength",treatInfo.Frequency,@"Freq",treatInfo.BeginTime ,@"BeginTime",treatInfo.EndTime,@"EndTime",treatInfo.CureTime,@"CureTime",nil];
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
                         "<APP_InsertCureData xmlns=\"MeetingOnline\">"
                         "<JsonCureData>%@</JsonCureData>"
                         "</APP_InsertCureData>"
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
                        [JXTAlertView showToastViewWithTitle:@"" message:@"username error!" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                            NSLog(@"OK");
                        }];
                    }
                    else if ([state isEqualToString:@"NO"] && [description isEqualToString:@"密码错误！"])
                    {
                        [JXTAlertView showToastViewWithTitle:@"" message:@"password error!" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                            NSLog(@"OK");
                        }];
                    }
                }
            }
            else
            {
                if ([description isEqualToString:@"账号不存在！"])
                {
                    [JXTAlertView showToastViewWithTitle:@"" message:@"username error!" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                        NSLog(@"OK");
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
                [JXTAlertView showToastViewWithTitle:@"" message:verifyDescription duration:2 dismissCompletion:^(NSInteger buttonIndex) {
                    NSLog(@"OK");
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
            else {
                [self.delegate sendValueBackToController:resultDic type:InterfaceModelBackTypeLogin];
            }
        }
        else if ([matchingElement isEqualToString:@"APP_GetEvaluateDataResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            //将用户所有评估数据持久化
            [self assessmentPersistence:resultArray];
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
        else if ([matchingElement isEqualToString:@"APP_SavePatientInfoResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            
            [self.delegate sendValueBackToController:resultDic type:InterfaceModelBackTypeAlertPatientInfo];
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
    _patientInfo.PatientWeight = [patientDic objectForKey:@"PatientWeight"];
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
            //判断数据库是否存在这个patientInfo，存在则更新数据库，不存在插入数据库
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            NSArray *patientInfoArray = [dbOpration getPatientDataFromDataBase];
            PatientInfo *temp = [[PatientInfo alloc] init];
            
            //图片下载完成  在这里进行相关操作，如加到数组里 或者显示在imageView上
            NSData *imageData = UIImagePNGRepresentation(image);
            _patientInfo.Picture = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            if (patientInfoArray.count == 0)
            {
                [dbOpration insertUserInfo:_patientInfo];
            }
            else
            {
                for (PatientInfo *tmp in patientInfoArray)
                {
                    if ([tmp.PatientID isEqualToString:_patientInfo.PatientID])
                    {
                        //更新数据库中的信息
                        temp = tmp;
                        [dbOpration updataUserInfo:_patientInfo];
                    }
                }
                if (temp.PatientID == nil)
                {
                    [dbOpration insertUserInfo:_patientInfo];
                }
            }
            [dbOpration closeDataBase];
        }
    }];
    
    if (_pwd.length > 0)
    {
        [self.delegate sendValueBackToController:_patientInfo type:InterfaceModelBackTypeLogin];
    }
    else
    {
        [self.delegate sendValueBackToController:_patientInfo type:InterfaceModelBackTypeGetPatientInfo];
    }
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

@end
