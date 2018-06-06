//
//  SquareModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SquareModel.h"
#import "FunctionHelper.h"

@implementation SquareModel

- (instancetype)init
{
    if (self == [super init])
    {
        _PostID = @"";
        _PatientID = @"";
        _HeaderImageUrl = @"";
        _Name = @"";
        _Type = @"";
        _Title = @"";
        _Time = @"";
        _ImageUrl = @"";
        _Content = @"";
        _BrowserCount = @"0";
        _FavorCount = @"0";
        _CommentCount = @"0";
        _IsTop = NO;
        _IsHot = NO;
        _IsCollect = NO;
        _IsFavor = NO;
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
        if ([[dict objectForKey:@"PostType"] intValue] == 1)
        {
            _Type = @"助眠干货";
        }
        else if ([[dict objectForKey:@"PostType"] intValue] == 2)
        {
            _Type = @"讨论疗疗";
        }
        else if ([[dict objectForKey:@"PostType"] intValue] == 3)
        {
            _Type = @"压力树洞";
        }
        else
        {
            _Type = @"其它";
        }
        _Title = [self getValueWithString:[dict objectForKey:@"PostTitle"]];
        _Time = [self getValueWithString:[dict objectForKey:@"PostDate"]];
        _ImageUrl = [self getValueWithString:[dict objectForKey:@"ImageUrl"]];
        _Content = [self getValueWithString:[dict objectForKey:@"PostContent"]];
        _ImageCount = [self getValueWithString:[dict objectForKey:@"ImageCount"]];
        _Image1 = [self getValueWithString:[dict objectForKey:@"PostImage1"]];
        _Image2 = [self getValueWithString:[dict objectForKey:@"PostImage2"]];
        _Image3 = [self getValueWithString:[dict objectForKey:@"PostImage3"]];
        _Image4 = [self getValueWithString:[dict objectForKey:@"PostImage4"]];
        _Image5 = [self getValueWithString:[dict objectForKey:@"PostImage5"]];
        _Image6 = [self getValueWithString:[dict objectForKey:@"PostImage6"]];
        _BrowserCount = [NSString stringWithFormat:@"%i",[[dict objectForKey:@"BrowserCount"] intValue]];
        if([[dict objectForKey:@"BrowserCount"] intValue] >= 100){
            _CommentCount = @"99+";
        }
         _FavorCount = [NSString stringWithFormat:@"%i",[[dict objectForKey:@"FavorCount"] intValue]];
        if([[dict objectForKey:@"FavorCount"] intValue] >= 100){
             _FavorCount = @"99+";
        }
        _CommentCount = [NSString stringWithFormat:@"%i",[[dict objectForKey:@"CommentCount"] intValue]];
        if([[dict objectForKey:@"CommentCount"] intValue] >= 100){
            _CommentCount = @"99+";
        }
        _IsTop = [dict objectForKey:@"IsTop"];
        _IsHot = [dict objectForKey:@"IsHot"];
        if([[dict objectForKey:@"IsFavor"] intValue] == 1)
        {
            _IsFavor = YES;
        }
        else
        {
            _IsFavor = NO;
        }
        if([[dict objectForKey:@"IsCollect"] integerValue] == 0)
        {
            _IsCollect = NO;
        }
        else
        {
            _IsCollect = YES;
        }
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
