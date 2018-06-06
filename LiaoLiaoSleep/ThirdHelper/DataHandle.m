//
//  DataHandle.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/6.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "DataHandle.h"
#import "Define.h"
#import "PatientInfo.h"

@implementation DataHandle

#pragma mark -- 上传问题信息
- (NSString *)UploadProblemWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadProblemResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadProblem xmlns=\"MeetingOnline\">"
                "<JsonProblemInfo>%@</JsonProblemInfo>"
                "</APP_UploadProblem>"
                "</soap:Body>"
                "</soap:Envelope>", jsonString,nil];
    return soapMsg;
}
#pragma mark -- 获取热门信息
-(NSString *)GetHotQuestion{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetHotQuestionResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_GetHotQuestion xmlns=\"MeetingOnline\">"
                "</APP_GetHotQuestion>"
                "</soap:Body>"
                "</soap:Envelope>",nil];
    return soapMsg;
}
#pragma mark -- 获取正在问答的问题
-(NSString *)GetAnsweringQuestionWithPatientID:(NSString *)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetAnsweringQuestionResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_GetAnsweringQuestion xmlns=\"MeetingOnline\">"
                "<JsonPatientID>%@</JsonPatientID>"
                "</APP_GetAnsweringQuestion>"
                "</soap:Body>"
                "</soap:Envelope>", patientID,nil];
    return soapMsg;
}
#pragma mark -- 获取关闭的问题
-(NSString *)GetClosedQuestionWithPatientID:(NSString*)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetClosedQuestionResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_GetClosedQuestion xmlns=\"MeetingOnline\">"
                "<JsonPatientID>%@</JsonPatientID>"
                "</APP_GetClosedQuestion>"
                "</soap:Body>"
                "</soap:Envelope>",patientID,nil];
    return soapMsg;
}
#pragma mark -- 更新已关闭的问题
-(NSString *)UpdateQuestionStateWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UpdateQuestionStateResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UpdateQuestionState xmlns=\"MeetingOnline\">"
                "<JsonQuestionStateInfo>%@</JsonQuestionStateInfo>"
                "</APP_UpdateQuestionState>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 上传医生信息
-(NSString *)UploadDoctorInfoWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadDoctorInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadDoctorInfo xmlns=\"MeetingOnline\">"
                "<JsonDoctorInfo>%@</JsonDoctorInfo>"
                "</APP_UploadDoctorInfo>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 获取医生详情
-(NSString *)GetDoctorInfoWithDoctorID:(NSString *)doctorID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetDoctorInfoByGanResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_GetDoctorInfoByGan xmlns=\"MeetingOnline\">"
                "<JsonDoctorInfo>%@</JsonDoctorInfo>"
                "</APP_GetDoctorInfoByGan>"
                "</soap:Body>"
                "</soap:Envelope>",doctorID,nil];
    return soapMsg;
}
#pragma mark -- 上传对医生的评论
-(NSString *)UploadCommentInfoWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadCommentResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadComment xmlns=\"MeetingOnline\">"
                "<JsonCommentInfo>%@</JsonCommentInfo>"
                "</APP_UploadComment>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 上传聊天记录
-(NSString *)UploadChatMessageWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadChatMessageResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadChatMessage xmlns=\"MeetingOnline\">"
                "<JsonMessageInfo>%@</JsonMessageInfo>"
                "</APP_UploadChatMessage>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 上传接诊时间
-(NSString *)UploadTimeAndDoctorWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadTimeAndDoctorResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadTimeAndDoctor xmlns=\"MeetingOnline\">"
                "<JsonTimeAndDoctorInfo>%@</JsonTimeAndDoctorInfo>"
                "</APP_UploadTimeAndDoctor>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 更新接诊医生
-(NSString *)UploadTimeAndDoctor2WithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadTimeAndDoctor2Response";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadTimeAndDoctor2 xmlns=\"MeetingOnline\">"
                "<JsonTimeAndDoctorInfo>%@</JsonTimeAndDoctorInfo>"
                "</APP_UploadTimeAndDoctor2>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 判断是否问过问题
-(NSString*)IsFirstUseDoctorWithPatientID:(NSString *)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_IsFirstUseDoctorResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
   NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_IsFirstUseDoctor xmlns=\"MeetingOnline\">"
                "<JsonPatientID>%@</JsonPatientID>"
                "</APP_IsFirstUseDoctor>"
                "</soap:Body>"
                "</soap:Envelope>",patientID,nil];
    NSLog(@"%@",soapMsg);
    return soapMsg;
}
#pragma mark -- 获取我的剩余问题数
-(NSString *)QuestionSurplusWithPatientID:(NSString *)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_QuestionSurplusResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_QuestionSurplus xmlns=\"MeetingOnline\">"
                "<JsonPatientID>%@</JsonPatientID>"
                "</APP_QuestionSurplus>"
                "</soap:Body>"
                "</soap:Envelope>",patientID,nil];
    return soapMsg;
}
#pragma mark -- 修改我的剩余问题数
-(NSString *)UploadSubLeaveNumberWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadSubLeaveNumberResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadSubLeaveNumber xmlns=\"MeetingOnline\">"
                "<JsonLeaveNumber>%@</JsonLeaveNumber>"
                "</APP_UploadSubLeaveNumber>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 更新医生回答的问题数或五星评价数
-(NSString *)UploadAnswerCountWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadAnswerCountResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadAnswerCount xmlns=\"MeetingOnline\">"
                "<JsonAnswerCountInfo>%@</JsonAnswerCountInfo>"
                "</APP_UploadAnswerCount>"
                "</soap:Body>"
                "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 获取医生评论
-(NSString *)GetDoctorCommentWithDoctorID:(NSString *)doctorID andPage:(NSString *)page{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetDoctorCommentResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_GetDoctorComment xmlns=\"MeetingOnline\">"
                "<pDoctorID>%@</pDoctorID>"
                "<pPage>%@</pPage>"
                "</APP_GetDoctorComment>"
                "</soap:Body>"
                "</soap:Envelope>",doctorID,page,nil];
    return soapMsg;
}
#pragma mark -- 获取问题追问个数
-(NSString *)QuestionAskCountWithQuestionID:(NSString *)questionID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_QuestionAskCountResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_QuestionAskCount xmlns=\"MeetingOnline\">"
                "<pQuestionID>%@</pQuestionID>"
                "</APP_QuestionAskCount>"
                "</soap:Body>"
                "</soap:Envelope>",questionID,nil];
    return soapMsg;
}
#pragma mark -- 更新追问次数
-(NSString *)UploadQuestionAskCountWithCount:(NSString *)count andQuestionID:(NSString *)questionID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadQuestionAskCountResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_UploadQuestionAskCount xmlns=\"MeetingOnline\">"
                "<pAskCount>%@</pAskCount>"
                "<pQuestionID>%@</pQuestionID>"
                "</APP_UploadQuestionAskCount>"
                "</soap:Body>"
                "</soap:Envelope>",count,questionID,nil];
    return soapMsg;
}
#pragma mark -- 获取问题详情
-(NSString *)GetDetailQuestionWithQuestionID:(NSString *)questionID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetDetailQuestionResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap12:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap12:Body>"
                "<APP_GetDetailQuestion xmlns=\"MeetingOnline\">"
                "<pQuestionID>%@</pQuestionID>"
                "</APP_GetDetailQuestion>"
                "</soap12:Body>"
                "</soap12:Envelope>",questionID,nil];
    return soapMsg;
}

#pragma mark -- 获取聊天记录
-(NSString *)GetChatMessageWithQuestionID:(NSString *)questionID andPage:(NSString *)page{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetChatMessageResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                "<soap:Envelope "
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                "<soap:Body>"
                "<APP_GetChatMessage xmlns=\"MeetingOnline\">"
                "<pQuestionID>%@</pQuestionID>"
                "<pPage>%@</pPage>"
                "</APP_GetChatMessage>"
                "</soap:Body>"
                "</soap:Envelope>",questionID,page,nil];
    return soapMsg;
}

#pragma mark -- 上传问医生购买记录
-(NSString *)UplaodOrderRecordWithDictionary:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UploadOrderRecordResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_UploadOrderRecord xmlns=\"MeetingOnline\">"
                          "<JsonOrderInfo>%@</JsonOrderInfo>"
                          "</APP_UploadOrderRecord>"
                          "</soap:Body>"
                          "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}
#pragma mark -- 获取聊天记录
-(NSString *)GetOrderRecordWithPatientID:(NSString *)patientID andPage:(NSString *)page{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetOrderRecordResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetOrderRecord xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "<pPage>%@</pPage>"
                          "</APP_GetOrderRecord>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,page,nil];
    return soapMsg;
}

#pragma mark -- 上传帖子
-(NSString *)UploadPostWithPostInfo:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_InsertPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_InsertPost xmlns=\"MeetingOnline\">"
                          "<JsonPost>%@</JsonPost>"
                          "</APP_InsertPost>"
                          "</soap:Body>"
                          "</soap:Envelope>",jsonString,nil];
    NSLog(@"%@",soapMsg);
    return soapMsg;
}
#pragma mark -- 上传帖子评论
-(NSString *)UploadPostCommentWithCommentInfo:(NSDictionary *)dic{
    NSArray *jsonArray=[NSArray arrayWithObjects:dic, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_InsertPostCommentResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_InsertPostComment xmlns=\"MeetingOnline\">"
                          "<JsonPostComment>%@</JsonPostComment>"
                          "</APP_InsertPostComment>"
                          "</soap:Body>"
                          "</soap:Envelope>",jsonString,nil];
    return soapMsg;
}

#pragma mark -- 获取全部帖子
-(NSString *)GetAllPostWithPage:(NSString *)page{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetPostAllResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    PatientInfo *patient = [PatientInfo shareInstance];
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetPostAllByPatientID2 xmlns=\"MeetingOnline\">"
                          "<pPage>%@</pPage>"
                          "<pPatientID>%@</pPatientID>"
                          "</APP_GetPostAllByPatientID2>"
                          "</soap:Body>"
                          "</soap:Envelope>",page, patient.PatientID,nil];
    NSLog(@"%@",soapMsg);
    return soapMsg;
}
#pragma mark -- 获取精华帖子
-(NSString *)GetCreamPost{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetPostCreamResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetPostCream xmlns=\"MeetingOnline\">"
                          "</APP_GetPostCream>"
                          "</soap:Body>"
                          "</soap:Envelope>",nil];
    return soapMsg;
}
#pragma mark -- 获取帖子详情
-(NSString *)GetPostDetailWithPostID:(NSString *)postID patientID:(NSString *)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetPost2 xmlns=\"MeetingOnline\">"
                          "<pPostID>%@</pPostID>"
                          "<pPatientID>%@</pPatientID>"
                          "</APP_GetPost2>"
                          "</soap:Body>"
                          "</soap:Envelope>",postID,patientID,nil];
    return soapMsg;
}
#pragma mark -- 获取评论详情
-(NSString *)GetPostCommentWithPostID:(NSString *)postID andPage:(NSString *)page{
    PatientInfo *patient = [PatientInfo shareInstance];
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetPostCommentByPatientIDResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetPostCommentByPatientID xmlns=\"MeetingOnline\">"
                          "<pPostID>%@</pPostID>"
                          "<pPage>%@</pPage>"
                          "<pPatientID>%@</pPatientID>"
                          "</APP_GetPostCommentByPatientID>"
                          "</soap:Body>"
                          "</soap:Envelope>",postID,page,patient.PatientID,nil];
    return soapMsg;
}
#pragma mark -- 更新帖子数据
-(NSString *)UploadPostCountWithPostID:(NSString *)postID andType:(NSString *)type{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UpdatePostCountInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_UpdatePostCountInfo xmlns=\"MeetingOnline\">"
                          "<pPostID>%@</pPostID>"
                          "<pType>%@</pType>"
                          "</APP_UpdatePostCountInfo>"
                          "</soap:Body>"
                          "</soap:Envelope>",postID,type,nil];
    return soapMsg;
}
#pragma mark -- 更新帖子数据
-(NSString *)UploadPatientCountWithPatientID:(NSString *)patientID andType:(NSString *)type{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UpdatePatientCountInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_UpdatePatientCountInfo xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "<pType>%@</pType>"
                          "</APP_UpdatePatientCountInfo>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,type,nil];
    return soapMsg;
}
#pragma mark -- 获取用户详情
-(NSString *)GetCommunityPatientInfoWithPatientID:(NSString *)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetCommunityPatientInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetCommunityPatientInfo xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "</APP_GetCommunityPatientInfo>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,nil];
    return soapMsg;
}
#pragma mark -- 获取广场信息
-(NSString *)GetSquareInfoWithDate:(NSString *)date{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetSquareInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    PatientInfo *patient = [PatientInfo shareInstance];
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetSquareInfoByPatientID xmlns=\"MeetingOnline\">"
                          "<pDate>%@</pDate>"
                          "<pPatientID>%@</pPatientID>"
                          "</APP_GetSquareInfoByPatientID>"
                          "</soap:Body>"
                          "</soap:Envelope>",date, patient.PatientID,nil];
    return soapMsg;
}
#pragma mark -- 获取广场信息(修改版)
-(NSString *)GetSquareInfo11WithDate:(NSString *)date{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetSquareInfo11Response";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetSquareInfo11 xmlns=\"MeetingOnline\">"
                          "<pDate>%@</pDate>"
                          "</APP_GetSquareInfo11>"
                          "</soap:Body>"
                          "</soap:Envelope>",nil];
    return soapMsg;
}
#pragma mark -- 收藏帖子
-(NSString *)CollectPostWithPostID:(NSString *)postID andPatientID:(NSString *)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_CollectPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_CollectPost xmlns=\"MeetingOnline\">"
                          "<pCollectorID>%@</pCollectorID>"
                          "<pPostID>%@</pPostID>"
                          "</APP_CollectPost>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,postID,nil];
    return soapMsg;
}
#pragma mark -- 获取收藏的帖子
-(NSString *)GetCollectedPostWithPatientID:(NSString *)patientID andPage:(NSString *)page{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetCollectedPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetCollectedPost xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "<pPage>%@</pPage>"
                          "</APP_GetCollectedPost>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,page,nil];
    return soapMsg;
}

#pragma mark -- 删除收藏的帖子
-(NSString *)DeleteCollectedPostWithPatientID:(NSString *)patientID andPostID:(NSString *)postID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_DeleteCollectedPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_DeleteCollectedPost xmlns=\"MeetingOnline\">"
                          "<pCollectorID>%@</pCollectorID>"
                          "<pPostID>%@</pPostID>"
                          "</APP_DeleteCollectedPost>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,postID,nil];
    return soapMsg;
}
#pragma mark -- 获取发布的帖子
-(NSString *)GetMyPublicPostWithPatientID:(NSString *)patientID andPage:(NSString *)page{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetMyPublicPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetMyPublicPost xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "<pPage>%@</pPage>"
                          "</APP_GetMyPublicPost>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,page,nil];
    return soapMsg;
}
#pragma mark -- 获取我回复的帖子
-(NSString *)GetMyReplayPostWithPatientID:(NSString *)patientID andPage:(NSString *)page{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_GetMyReplayPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetMyReplayPost xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "<pPage>%@</pPage>"
                          "</APP_GetMyReplayPost>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,page,nil];
    return soapMsg;
}
#pragma mark -- 更新帖子的回复状态
-(NSString *)UpdatePostReplayStateWithPostID:(NSString *)postID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UpdatePostReplayResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_UpdatePostReplay xmlns=\"MeetingOnline\">"
                          "<pPostID>%@</pPostID>"
                          "</APP_UpdatePostReplay>"
                          "</soap:Body>"
                          "</soap:Envelope>",postID,nil];
    return soapMsg;
}
#pragma mark -- 更新帖子的点赞
-(NSString *)UpdatePostFavorCountWithPatientID:(NSString *)patientID andPostID:(NSString *)postID andState:(NSString *)state{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_InsertAndUpdateFavorPostResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_InsertAndUpdateFavorPost xmlns=\"MeetingOnline\">"
                          "<pFavorerID>%@</pFavorerID>"
                          "<pPostID>%@</pPostID>"
                          "<pState>%@</pState>"
                          "</APP_InsertAndUpdateFavorPost>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,postID,state,nil];
    return soapMsg;
}
#pragma mark -- 更新帖子的点赞
-(NSString *)GetPizzAndSelfTestValueWithPatientID:(NSString *)patientID{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @" APP_GetSleepResultResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_GetSleepResult xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "</APP_GetSleepResult>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,nil];
    return soapMsg;
}
#pragma mark -- 更新个人积分
-(NSString *)UpdateAccumlatePointWithPatientID:(NSString *)patientID andPoint:(NSString *)point{
    // 设置我们之后解析XML时用的关键字
    self.matchingElement = @"APP_UpdateAccumulatePointResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString * soapMsg = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap:Envelope "
                          "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                          "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                          "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                          "<soap:Body>"
                          "<APP_UpdateAccumulatePoint xmlns=\"MeetingOnline\">"
                          "<pPatientID>%@</pPatientID>"
                          "<pPoint>%@</pPoint>"
                          "</APP_UpdateAccumulatePoint>"
                          "</soap:Body>"
                          "</soap:Envelope>",patientID,point,nil];
    return soapMsg;
}

//网络请求数据
-(NSData *)uploadToNetWorkWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic{
    NSString * soapMsg = [NSString string];
    if (type == DataModelBackTypeUploadQuestionInfo) {
        soapMsg = [self UploadProblemWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionState) {
        soapMsg = [self UpdateQuestionStateWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionState) {
        soapMsg = [self UploadDoctorInfoWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadCommendInfo) {
        soapMsg = [self UploadCommentInfoWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadChatMessage) {
        soapMsg = [self UploadChatMessageWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionDeadline) {
        soapMsg = [self UploadTimeAndDoctorWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionDoctor) {
        soapMsg = [self UploadTimeAndDoctor2WithDictionary:dic];
    }else if(type == DataModelBackTypeUploadLeaveNumber) {
        soapMsg = [self UploadSubLeaveNumberWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadAnswerCountOrFullStar) {
        soapMsg = [self UploadAnswerCountWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionAskCount) {
        soapMsg = [self UploadQuestionAskCountWithCount:[dic objectForKey:@"count"] andQuestionID:[dic objectForKey:@"questionID"]];
    }else if(type == DataModelBackTypeUploadPost) {
        soapMsg = [self UploadPostWithPostInfo:dic];
    }else if(type == DataModelBackTypeUploadPostComment) {
        soapMsg = [self UploadPostCommentWithCommentInfo:dic];
    }else if(type == DataModelBackTypeUploadPostCount) {
        soapMsg = [self UploadPostCountWithPostID:[dic objectForKey:@"postID"] andType:[dic objectForKey:@"type"]];
    }else if(type == DataModelBackTypeUploadPatientCount) {
        soapMsg = [self UploadPatientCountWithPatientID:[dic objectForKey:@"patientID"] andType:[dic objectForKey:@"type"]];
    }else if(type == DataModelBackTypeCollectedPost) {
        soapMsg = [self CollectPostWithPostID:[dic objectForKey:@"postID"] andPatientID:[dic objectForKey:@"patientID"]];
    }else if(type == DataModelBackTypeDeleteCollectedPost) {
        soapMsg = [self DeleteCollectedPostWithPatientID:[dic objectForKey:@"patientID"] andPostID:[dic objectForKey:@"postID"]];
    }else if(type == DataModelBackTypeUpdatePostFavorCount) {
        soapMsg = [self UpdatePostFavorCountWithPatientID:[dic objectForKey:@"patientID"] andPostID:[dic objectForKey:@"postID"] andState:[dic objectForKey:@"state"]];
    }
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString: JHADDRESS];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    // 将SOAP消息加到请求中
    [req setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    return responseData;
}
//网络请求数据
-(NSData *)uploadToNetWorkWithStringType:(DataModelBackType)type andPrimaryKey:(NSString *)key{
    NSString * soapMsg = [NSString string];
    if (type == DataModelBackTypeUploadQuestionInfo) {
        soapMsg = [self UpdatePostReplayStateWithPostID:key];
    }
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString: JHADDRESS];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    // 将SOAP消息加到请求中
    [req setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    return responseData;
}
//网络请求数据
-(NSData *)getDataFromNetWorkWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic{
    NSString * soapMsg = [NSString string];
    if(type == DataModelBackTypeGetCommendInfo) {
        soapMsg = [self GetDoctorCommentWithDoctorID:[dic objectForKey:@"doctorID"] andPage:[dic objectForKey:@"page"]];
    }else if(type == DataModelBackTypeGetChatMessage) {
        soapMsg = [self GetChatMessageWithQuestionID:[dic objectForKey:@"questionID"] andPage:[dic objectForKey:@"page"]];
    }else if(type == DataModelBackTypeGetPostComment) {
        soapMsg = [self GetPostCommentWithPostID:[dic objectForKey:@"postID"] andPage:[dic objectForKey:@"page"]];
    }else if(type == DataModelBackTypeGetCollectedPost) {
        soapMsg = [self GetCollectedPostWithPatientID:[dic objectForKey:@"patientID"] andPage:[dic objectForKey:@"page"]];
    }else if(type == DataModelBackTypeGetMyPublicPost) {
        soapMsg = [self GetMyPublicPostWithPatientID:[dic objectForKey:@"patientID"] andPage:[dic objectForKey:@"page"]];
    }else if(type == DataModelBackTypeGetMyReplayPost) {
        soapMsg = [self GetMyReplayPostWithPatientID:[dic objectForKey:@"patientID"] andPage:[dic objectForKey:@"page"]];
    }else if(type == DataModelBackTypeGetPostDetail) {
        soapMsg = [self GetPostDetailWithPostID:[dic objectForKey:@"postID"] patientID:[dic objectForKey:@"patientID"]];
    }
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString: JHADDRESS];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    // 将SOAP消息加到请求中
    [req setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    return responseData;
}
-(NSData *)getDataFromNetWorkWithStringType:(DataModelBackType)type andPrimaryKey:(NSString *)key{
    NSString * soapMsg = [NSString string];
    if (type == DataModelBackTypeGetIsFirstAsk) {
        soapMsg = [self IsFirstUseDoctorWithPatientID:key];
    }else if (type == DataModelBackTypeGetLeaveNumber){
        soapMsg = [self QuestionSurplusWithPatientID:key];
    }else if (type == DataModelBackTypeGetAnsweringQuestions){
        soapMsg = [self GetAnsweringQuestionWithPatientID:key];
    }else if (type == DataModelBackTypeGetClosedQuestions){
        soapMsg = [self GetClosedQuestionWithPatientID:key];
    }else if (type == DataModelBackTypeGetHotQuestions) {
        soapMsg = [self GetHotQuestion];
    }else if(type == DataModelBackTypeGetQuestionAskCount) {
        soapMsg = [self QuestionAskCountWithQuestionID:key];
    }else if(type == DataModelBackTypeGetQuestionDetail) {
        soapMsg = [self GetDetailQuestionWithQuestionID:key];
    }else if(type == DataModelBackTypeGetDoctorInfo) {
        soapMsg = [self GetDoctorInfoWithDoctorID:key];
    }else if(type == DataModelBackTypeGetAllPost) {
        soapMsg = [self GetAllPostWithPage:key];
    }else if(type == DataModelBackTypeGetCreamPost) {
        soapMsg = [self GetCreamPost];
    }else if(type == DataModelBackTypeGetCommunityPatientInfo) {
        soapMsg = [self GetCommunityPatientInfoWithPatientID:key];
    }else if(type == DataModelBackTypeGetSquareInfo) {
        soapMsg = [self GetSquareInfo11WithDate:key];
    }else if(type == DataModelBackTypeGetPizzAndSelfTestValue) {
        soapMsg = [self GetPizzAndSelfTestValueWithPatientID:key];
    }
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString: JHADDRESS];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    // 将SOAP消息加到请求中
    [req setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    return responseData;
}
#pragma mark -- 解析服务器传来的数据
-(id)objectFromeResponseString:(NSData *)data andType:(DataModelBackType)type;
{
    id returnObj;
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *array = [xmlEle children];
    for (int i = 0; i < [array count]; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        NSError *error = nil;
        id object = [NSJSONSerialization JSONObjectWithData: [[ele stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &error];
        if (type == DataModelBackTypeGetIsFirstAsk) {
            returnObj = (NSString *)[(NSDictionary *)object objectForKey:@"description"];
            if ([returnObj isEqualToString:@"否"]) {
                returnObj = @"YES";
            }else{
                returnObj = @"NO";
            }
        }else if (type == DataModelBackTypeGetQuestionAskCount) {
            returnObj = (NSString *)[(NSDictionary *)object objectForKey:@"description"];
            if ([returnObj integerValue] == 0) {
                returnObj = @"0";
            }
        }else if (type == DataModelBackTypeGetLeaveNumber) {
            NSLog(@"%@",object);
            returnObj = (NSString *)[(NSDictionary *)object objectForKey:@"description"];
            if ([[(NSDictionary *)object objectForKey:@"state"] isEqualToString:@"OK"]) {
                if ([returnObj isEqual:@""]) {
                    returnObj = @"10";
                }
            }else{
                returnObj = @"0";
            }
        }else if (type == DataModelBackTypeGetHotQuestions || type == DataModelBackTypeGetAnsweringQuestions || type == DataModelBackTypeGetClosedQuestions || type == DataModelBackTypeGetDoctorInfo || type == DataModelBackTypeGetCommendInfo || type == DataModelBackTypeGetQuestionDetail || type == DataModelBackTypeGetChatMessage || type == DataModelBackTypeGetAllPost || type == DataModelBackTypeGetCreamPost || type == DataModelBackTypeGetPostDetail || type == DataModelBackTypeGetPostComment || type == DataModelBackTypeGetCommunityPatientInfo  || type == DataModelBackTypeGetCollectedPost || type == DataModelBackTypeGetMyPublicPost || type == DataModelBackTypeGetMyReplayPost || type == DataModelBackTypeGetPurchaseRecord) {
            returnObj = [NSArray arrayWithArray:object];
            if (type == DataModelBackTypeGetClosedQuestions) {
                NSLog(@"answerquestion = %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }else if (type == DataModelBackTypeUploadQuestionInfo || type == DataModelBackTypeUploadQuestionState || type == DataModelBackTypeUploadDoctorInfo || type == DataModelBackTypeUploadCommendInfo || type == DataModelBackTypeUploadChatMessage || type == DataModelBackTypeUploadQuestionDeadline || type == DataModelBackTypeUploadQuestionDoctor || type == DataModelBackTypeUploadLeaveNumber || type == DataModelBackTypeUploadAnswerCountOrFullStar || type == DataModelBackTypeUploadQuestionAskCount || type == DataModelBackTypeUploadPost || type == DataModelBackTypeUploadPostComment || type == DataModelBackTypeUploadPostCount || type == DataModelBackTypeUploadPatientCount  || type == DataModelBackTypeCollectedPost || type == DataModelBackTypeDeleteCollectedPost || type == DataModelBackTypeUpdatePostFavorCount || type == DataModelBackTypeUpdatePostReplayState || type == DataModelBackTypeUpdateAccumulatePoint || type == DataModelBackTypeUploadPurchaseRecord) {
            returnObj = (NSString *)[(NSDictionary *)object objectForKey:@"state"];
            if (type == DataModelBackTypeUploadQuestionState) {
                NSLog(@"update == %@",object);
                NSLog(@"answerquestion = %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }else if (type == DataModelBackTypeGetSquareInfo || type == DataModelBackTypeGetPizzAndSelfTestValue) {
            returnObj = [NSDictionary dictionaryWithDictionary:object];
        }
    }
    return returnObj;
}
//生成网络请求
-(NSMutableURLRequest *)GenerateRequestWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic{
    NSString * soapMsg = [NSString string];
    if (type == DataModelBackTypeUploadQuestionInfo) {
        soapMsg = [self UploadProblemWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionState) {
        soapMsg = [self UpdateQuestionStateWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionState) {
        soapMsg = [self UploadDoctorInfoWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadCommendInfo) {
        soapMsg = [self UploadCommentInfoWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadChatMessage) {
        soapMsg = [self UploadChatMessageWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionDeadline) {
        soapMsg = [self UploadTimeAndDoctorWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionDoctor) {
        soapMsg = [self UploadTimeAndDoctor2WithDictionary:dic];
    }else if(type == DataModelBackTypeUploadLeaveNumber) {
        soapMsg = [self UploadSubLeaveNumberWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadAnswerCountOrFullStar) {
        soapMsg = [self UploadAnswerCountWithDictionary:dic];
    }else if(type == DataModelBackTypeUploadQuestionAskCount) {
        soapMsg = [self UploadQuestionAskCountWithCount:[dic objectForKey:@"count"] andQuestionID:[dic objectForKey:@"questionID"]];
    }else if(type == DataModelBackTypeUploadPost) {
        soapMsg = [self UploadPostWithPostInfo:dic];
    }else if(type == DataModelBackTypeUploadPostComment) {
        soapMsg = [self UploadPostCommentWithCommentInfo:dic];
    }else if(type == DataModelBackTypeUploadPostCount) {
        soapMsg = [self UploadPostCountWithPostID:[dic objectForKey:@"postID"] andType:[dic objectForKey:@"type"]];
    }else if(type == DataModelBackTypeUploadPatientCount) {
        soapMsg = [self UploadPatientCountWithPatientID:[dic objectForKey:@"patientID"] andType:[dic objectForKey:@"type"]];
    }else if(type == DataModelBackTypeCollectedPost) {
        soapMsg = [self CollectPostWithPostID:[dic objectForKey:@"postID"] andPatientID:[dic objectForKey:@"patientID"]];
    }else if(type == DataModelBackTypeDeleteCollectedPost) {
        soapMsg = [self DeleteCollectedPostWithPatientID:[dic objectForKey:@"patientID"] andPostID:[dic objectForKey:@"postID"]];
    }else if(type == DataModelBackTypeUpdatePostFavorCount) {
        soapMsg = [self UpdatePostFavorCountWithPatientID:[dic objectForKey:@"patientID"] andPostID:[dic objectForKey:@"postID"] andState:[dic objectForKey:@"state"]];
    }
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString: JHADDRESS];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    // 将SOAP消息加到请求中
    [req setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    return req;
}
//生成网络请求
-(NSMutableURLRequest *)RequestForGetDataFromNetWorkWithStringType:(DataModelBackType)type andPrimaryKey:(NSString *)key{
    NSString * soapMsg = [NSString string];
    if (type == DataModelBackTypeGetIsFirstAsk) {
        soapMsg = [self IsFirstUseDoctorWithPatientID:key];
    }else if (type == DataModelBackTypeGetLeaveNumber){
        soapMsg = [self QuestionSurplusWithPatientID:key];
    }else if (type == DataModelBackTypeGetAnsweringQuestions){
        soapMsg = [self GetAnsweringQuestionWithPatientID:key];
    }else if (type == DataModelBackTypeGetClosedQuestions){
        soapMsg = [self GetClosedQuestionWithPatientID:key];
    }else if (type == DataModelBackTypeGetHotQuestions) {
        soapMsg = [self GetHotQuestion];
    }else if(type == DataModelBackTypeGetQuestionAskCount) {
        soapMsg = [self QuestionAskCountWithQuestionID:key];
    }else if(type == DataModelBackTypeGetQuestionDetail) {
        soapMsg = [self GetDetailQuestionWithQuestionID:key];
    }else if(type == DataModelBackTypeGetDoctorInfo) {
        soapMsg = [self GetDoctorInfoWithDoctorID:key];
    }else if(type == DataModelBackTypeGetAllPost) {
        soapMsg = [self GetAllPostWithPage:key];
    }else if(type == DataModelBackTypeGetCreamPost) {
        soapMsg = [self GetCreamPost];
    }else if(type == DataModelBackTypeGetCommunityPatientInfo) {
        soapMsg = [self GetCommunityPatientInfoWithPatientID:key];
    }else if(type == DataModelBackTypeGetSquareInfo) {
        soapMsg = [self GetSquareInfoWithDate:key];
        NSLog(@"%@",soapMsg);
    }else if(type == DataModelBackTypeGetPizzAndSelfTestValue) {
        soapMsg = [self GetPizzAndSelfTestValueWithPatientID:key];
    }else if(type == DataModelBackTypeUpdatePostReplayState) {
        soapMsg = [self UpdatePostReplayStateWithPostID:key];
    }
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString: JHADDRESS];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    // 将SOAP消息加到请求中
    [req setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    return req;
}
//生成网络请求
-(NSMutableURLRequest *)RequestForGetDataFromNetWorkWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic{
    NSString * soapMsg = [NSString string];
    if(type == DataModelBackTypeGetCommendInfo)
    {
        soapMsg = [self GetDoctorCommentWithDoctorID:[dic objectForKey:@"doctorID"] andPage:[dic objectForKey:@"page"]];
    }
    else if(type == DataModelBackTypeUploadPurchaseRecord)
    {
        soapMsg = [self UplaodOrderRecordWithDictionary:dic];
    }
    else if(type == DataModelBackTypeGetPurchaseRecord)
    {
        soapMsg = [self GetOrderRecordWithPatientID:dic[@"patientID"] andPage:dic[@"page"]];
    }
    else if(type == DataModelBackTypeGetChatMessage)
    {
        soapMsg = [self GetChatMessageWithQuestionID:[dic objectForKey:@"questionID"] andPage:[dic objectForKey:@"page"]];
    }
    else if(type == DataModelBackTypeGetPostComment)
    {
        soapMsg = [self GetPostCommentWithPostID:[dic objectForKey:@"postID"] andPage:[dic objectForKey:@"page"]];
    }
    else if(type == DataModelBackTypeGetCollectedPost)
    {
        soapMsg = [self GetCollectedPostWithPatientID:[dic objectForKey:@"patientID"] andPage:[dic objectForKey:@"page"]];
    }
    else if(type == DataModelBackTypeGetMyPublicPost)
    {
        soapMsg = [self GetMyPublicPostWithPatientID:[dic objectForKey:@"patientID"] andPage:[dic objectForKey:@"page"]];
    }
    else if(type == DataModelBackTypeGetMyReplayPost)
    {
        soapMsg = [self GetMyReplayPostWithPatientID:[dic objectForKey:@"patientID"] andPage:[dic objectForKey:@"page"]];
    }
    else if(type == DataModelBackTypeUploadPost)
    {
        soapMsg = [self UploadPostWithPostInfo:dic];
    }
    else if(type == DataModelBackTypeUploadPostComment)
    {
        soapMsg = [self UploadPostCommentWithCommentInfo:dic];
    }
    else if(type == DataModelBackTypeUploadPostCount)
    {
        soapMsg = [self UploadPostCountWithPostID:[dic objectForKey:@"postID"] andType:[dic objectForKey:@"type"]];
    }
    else if(type == DataModelBackTypeUploadPatientCount)
    {
        soapMsg = [self UploadPatientCountWithPatientID:[dic objectForKey:@"patientID"] andType:[dic objectForKey:@"type"]];
    }
    else if(type == DataModelBackTypeCollectedPost)
    {
        soapMsg = [self CollectPostWithPostID:[dic objectForKey:@"postID"] andPatientID:[dic objectForKey:@"patientID"]];
    }
    else if(type == DataModelBackTypeDeleteCollectedPost)
    {
        soapMsg = [self DeleteCollectedPostWithPatientID:[dic objectForKey:@"patientID"] andPostID:[dic objectForKey:@"postID"]];
    }
    else if(type == DataModelBackTypeUpdatePostFavorCount)
    {
        soapMsg = [self UpdatePostFavorCountWithPatientID:[dic objectForKey:@"patientID"] andPostID:[dic objectForKey:@"postID"] andState:[dic objectForKey:@"state"]];
    }
    else if(type == DataModelBackTypeUpdateAccumulatePoint)
    {
        soapMsg = [self UpdateAccumlatePointWithPatientID:[dic objectForKey:@"patientID"] andPoint:[dic objectForKey:@"point"]];
    }
    else if(type == DataModelBackTypeGetPostDetail)
    {
        soapMsg = [self GetPostDetailWithPostID:[dic objectForKey:@"postID"] patientID:[dic objectForKey:@"patientID"]];
    }else if(type == DataModelBackTypeUploadQuestionState)
    {
        soapMsg = [self UpdateQuestionStateWithDictionary:dic];
    }
    
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString: JHADDRESS];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    // 将SOAP消息加到请求中
    [req setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    return req;
}


@end
