//
//  PostCommentModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/12.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PostCommentModel.h"

@implementation PostCommentModel

- (instancetype)init
{
    if (self == [super init])
    {
        _PostID = @"";
        _PatientID = @"";
        _HeaderImageUrl = @"";
        _Name = @"";
        _CommentTime = @"";
        _CommentContent = @"";
        _FavorCount = @"0";
        _IsHot = NO;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self == [super init])
    {
        _PostID = [self getValueWithString:[dict objectForKey:@"PostID"]];
        _PatientID = [self getValueWithString:[dict objectForKey:@"PatientID"]];
        _HeaderImageUrl = [self getValueWithString:[dict objectForKey:@"HeaderImage"]];
        _Name = [self getValueWithString:[dict objectForKey:@"PatientName"]];
        _CommentTime = [self getValueWithString:[dict objectForKey:@"CommentTime"]];
        _CommentContent = [self getValueWithString:[dict objectForKey:@"CommentContent"]];
        _CommentContent = [_CommentContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _FavorCount = [self getValueWithString:[dict objectForKey:@"FavorCount"]];
        _IsHot = [self getValueWithString:@"IsHot"];
    }
    
    return self;
}

- (NSString *)getValueWithString:(NSString *)str
{
    if (![str isEqual:@""])
    {
        return str;
    }
    else
    {
        return @"";
    }
}


@end
