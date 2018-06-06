//
//  CommentModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel

-(instancetype)init{
    if (self == [super init]) {
        _doctorID = @"";
        _commentID = @"";
        _patientID = @"";
        _patientName = @"";
        _patientIcon = @"";
        _commentContent = @"";
        _commentStar = @"";
        _commentTime = @"";
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self == [super init]) {
        //评论信息
        _doctorID = [self getValueWithString:[dic objectForKey:@"DoctorID"]];
        _commentID = [self getValueWithString:[dic objectForKey:@"CommentID"]];
        _patientID = [self getValueWithString:[dic objectForKey:@"PatientID"]];
        _patientName = [self getValueWithString:[dic objectForKey:@"PatientName"]];
        _patientIcon = [self getValueWithString:[dic objectForKey:@"PatientIcon"]];
        _commentTime = [self getValueWithString:[dic objectForKey:@"CommentTime"]];
        _commentContent = [self getValueWithString:[dic objectForKey:@"CommentContent"]];
        _commentStar = [self getValueWithString:[dic objectForKey:@"CommentStar"]];
    }
    return self;
}
-(NSString *)getValueWithString:(NSString *)str{
    if (![str isEqual:@""]) {
        return str;
    }else{
        return @"";
    }
}


@end
