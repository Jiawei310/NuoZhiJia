//
//  CommentModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

//评论信息
@property(copy, nonatomic) NSString * doctorID;//conversationId
@property(copy, nonatomic) NSString * commentID;//conversationId
@property(copy, nonatomic) NSString * patientID;
@property(copy, nonatomic) NSString * patientName;
@property(copy, nonatomic) NSString * patientIcon;
@property(copy, nonatomic) NSString * commentTime;
@property(copy, nonatomic) NSString * commentContent;
@property(copy, nonatomic) NSString * commentStar;

-(instancetype)init;
-(instancetype)initWithDictionary:(NSDictionary *)dic;

@end
