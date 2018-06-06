//
//  FootPrintModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/15.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "FootPrintModel.h"
#import "DataHandle.h"

@implementation FootPrintModel

- (instancetype)init
{
    if (self == [super init])
    {
        _PostID = @"";
        _PostTitle = @"";
        _PublicTime = @"";
        _HeaderImage = @"";
        _PatientName = @"";
        _PatientID = @"";
        _isReplay = NO;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self == [super init])
    {
        _PostID = [self getValueWithString:[dic objectForKey:@"PostID"]];
        _PatientID = [self getValueWithString:[dic objectForKey:@"PatientID"]];
        //通过PostID获取帖子的model
        DataHandle *handle = [[DataHandle alloc]init];
        NSData *data = [handle getDataFromNetWorkWithJsonType:(DataModelBackTypeGetPostDetail) andDictionary:@{@"patientID":_PatientID,@"postID":_PostID}];
        NSArray *temp = [handle objectFromeResponseString:data andType:DataModelBackTypeGetCollectedPost];
        for (NSDictionary *dic in temp)
        {
            SquareModel *model = [[SquareModel alloc] initWithDictionary:dic];
            _postModel = model;
        }
        
        int type = [[self getValueWithString:[dic objectForKey:@"PostType"]] intValue];
        NSString *title = [self getValueWithString:[dic objectForKey:@"PostTitle"]];
        if (type == 1)
        {
            _PostTitle = [NSString stringWithFormat:@"【助眠干货】%@",title];
        }
        else if (type == 2)
        {
            _PostTitle = [NSString stringWithFormat:@"【讨论疗疗】%@",title];
        }
        else if (type == 3)
        {
            _PostTitle = [NSString stringWithFormat:@"【压力树洞】%@",title];
        }
        else if (type == 4)
        {
            _PostTitle = [NSString stringWithFormat:@"【其它】%@",title];
        }
        _PublicTime = [self getValueWithString:[dic objectForKey:@"PostDate"]];
        _HeaderImage = [self getValueWithString:[dic objectForKey:@"HeaderImage"]];
        _PatientName = [self getValueWithString:[dic objectForKey:@"PatientName"]];
        
        if([[dic objectForKey:@"IsReply"] intValue] == 0)
        {
            _isReplay = YES;
        }
        else
        {
            _isReplay = NO;
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
