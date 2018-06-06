//
//  SleepCircleModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SleepCircleModel.h"

@implementation SleepCircleModel

- (instancetype)init
{
    if (self == [super init])
    {
        _PostID = @"";
        _Title = @"";
        _Time = @"";
        _ImageUrl = @"";
        _Content = @"";
        _FavorCount = @"";
        _CommentCount = @"";
        
        _ImageName = @"";
        _PostUrl = @"";
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self == [super init])
    {
        _PostID = [self getValueWithString:[dict objectForKey:@"PostID"]];
        _Title = [self getValueWithString:[dict objectForKey:@"Title"]];
        _Time = [self getValueWithString:[dict objectForKey:@"Time"]];
        _ImageUrl = [self getValueWithString:[dict objectForKey:@"ImageUrl"]];
        _Content = [self getValueWithString:[dict objectForKey:@"Content"]];
        _FavorCount = [self getValueWithString:[dict objectForKey:@"FavorCount"]];
        _CommentCount = [self getValueWithString:[dict objectForKey:@"CommentCount"]];
        
        _ImageName = [self getValueWithString:[dict objectForKey:@"ImageName"]];
        _PostUrl = [self getValueWithString:[dict objectForKey:@"PostUrl"]];
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
