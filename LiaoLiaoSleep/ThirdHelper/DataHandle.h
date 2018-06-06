//
//  DataHandle.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/6.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
typedef enum {
    DataModelBackTypeGetIsFirstAsk,           //是否第一次使用提问
    DataModelBackTypeGetLeaveNumber,       //获取剩余问题数
    DataModelBackTypeGetAnsweringQuestions, //获取正在问答问题
    DataModelBackTypeGetClosedQuestions,    //获取已关闭问题
    DataModelBackTypeGetHotQuestions,      //获取热门问题
    DataModelBackTypeUploadQuestionInfo,    //上传问题
    DataModelBackTypeUploadQuestionState,   //更新问题状态
    DataModelBackTypeUploadDoctorInfo,      //上传医生信息
    DataModelBackTypeGetDoctorInfo,         //获取医生信息
    DataModelBackTypeUploadCommendInfo,    //上传医生评论
    DataModelBackTypeUploadChatMessage,     //上传聊天记录
    DataModelBackTypeUploadQuestionDeadline,  //上传问题截止时间
    DataModelBackTypeUploadQuestionDoctor,   //更新问诊医生
    DataModelBackTypeUploadLeaveNumber,      //更新剩余问题数
    DataModelBackTypeUploadAnswerCountOrFullStar, //更新医生回答问题数和五星数
    DataModelBackTypeGetCommendInfo,        //获取评论
    DataModelBackTypeGetQuestionAskCount,      //获取问题追问次数
    DataModelBackTypeUploadQuestionAskCount,   //更新问题追问次数
    DataModelBackTypeGetQuestionDetail,         //获取问题详情
    DataModelBackTypeGetChatMessage,          //获取聊天记录
    DataModelBackTypeUploadPost,               //上传帖子
    DataModelBackTypeGetAllPost,               //获取所有帖子
    DataModelBackTypeGetCreamPost,            //获取精华帖子
    DataModelBackTypeGetPostDetail,            //获取帖子详情
    DataModelBackTypeUploadPostComment,      //上传帖子评论
    DataModelBackTypeGetPostComment,         //获取帖子评论
    DataModelBackTypeUploadPostCount,         //更新帖子数据
    DataModelBackTypeUploadPatientCount,      //更新用户数据
    DataModelBackTypeGetCommunityPatientInfo, //更新帖子数据
    DataModelBackTypeGetSquareInfo,           //更新用户数据
    DataModelBackTypeCollectedPost,            //收藏帖子
    DataModelBackTypeGetCollectedPost,         //获取收藏帖子
    DataModelBackTypeDeleteCollectedPost,      //删除收藏帖子
    DataModelBackTypeUpdatePostReplayState,   //更新帖子的回复状态
    DataModelBackTypeGetMyPublicPost,         //获取我发布的帖子
    DataModelBackTypeGetMyReplayPost,        //获取我评论的帖子
    DataModelBackTypeUpdatePostFavorCount,   //更新帖子点赞
    DataModelBackTypeGetPizzAndSelfTestValue,   //获取匹兹堡数据
    DataModelBackTypeUploadPurchaseRecord,   //上传问医生购买记录
    DataModelBackTypeGetPurchaseRecord,   //获取问医生购买记录
    DataModelBackTypeUpdateAccumulatePoint,   //更新积分
    DataModelBackTypeGetSoftVersion,   //获取软件版本号
    
}DataModelBackType;

@interface DataHandle : NSObject<NSXMLParserDelegate,NSURLConnectionDelegate>

@property(nonatomic,copy)NSString *matchingElement;

-(NSData *)uploadToNetWorkWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic;
-(NSData *)uploadToNetWorkWithStringType:(DataModelBackType)type andPrimaryKey:(NSString *)key;
-(NSData *)getDataFromNetWorkWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic;
-(NSData *)getDataFromNetWorkWithStringType:(DataModelBackType)type andPrimaryKey:(NSString *)key;
-(id)objectFromeResponseString:(NSData *)data andType:(DataModelBackType)type;
-(NSMutableURLRequest *)GenerateRequestWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic;
-(NSMutableURLRequest *)RequestForGetDataFromNetWorkWithStringType:(DataModelBackType)type andPrimaryKey:(NSString *)key;
-(NSMutableURLRequest *)RequestForGetDataFromNetWorkWithJsonType:(DataModelBackType)type andDictionary:(NSDictionary *)dic;

@end
