//
//  RecordMessageModel.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/29.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "RecordMessageModel.h"

@implementation RecordMessageModel

- (instancetype)init
{
    if (self == [super init])
    {
        _questionID = @"";
        _message = @"";
        _messageType = Message_Text;
        _isSender = NO;
        _nickName = @"";
        _headerImage = @"";
        _size = @"";
        _thumbnailSize = @"";
        _image = @"";
        _thumbnailImage = @"";
        _localPath = @"";
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self == [super init])
    {
        //问题信息
        _questionID = [self getValueWithString:[dic objectForKey:@"QuestionID"]];
        _message = [self getValueWithString:[dic objectForKey:@"Message"]];
        if ([[dic objectForKey:@"MessageType"] intValue] == 0)
        {
            _messageType = Message_Text ;
        }
        else if ([[dic objectForKey:@"MessageType"] intValue] == 1)
        {
            _messageType = Message_Image;
        }
        else if ([[dic objectForKey:@"MessageType"] intValue] == 2)
        {
            _messageType = Message_Time;
        }
        else if ([[dic objectForKey:@"MessageType"] intValue] == 3)
        {
            _messageType = Message_Scale;
        }
        
        if ([[dic objectForKey:@"IsSender"] intValue] == 0)
        {
            _isSender = NO;
        }
        else
        {
            _isSender = YES;
        }
//        _nickName = [self getValueWithString:[dic objectForKey:@"NickName"]];
//        _headerImage = [self getValueWithString:[dic objectForKey:@"HeaderImage"]];
        _size = [self getValueWithString:[dic objectForKey:@"ImageSize"]];
        _thumbnailSize = [self getValueWithString:[dic objectForKey:@"ThumbnailImageSize"]];
        if ([dic objectForKey:@"ImageURLPath"])
        {
            _image = [dic objectForKey:@"ImageURLPath"];
        }
        else
        {
            _image = @"";
        }
        
        if ([dic objectForKey:@"ThumbnailImageURLPath"])
        {
            _thumbnailImage = [dic objectForKey:@"ThumbnailImageURLPath"];
        }
        else
        {
            _thumbnailImage = @"";
        }
        _localPath = [self getValueWithString:[dic objectForKey:@"LocalPath"]];
    }
    
    return self;
}

- (NSString *)getValueWithString:(NSString *)str
{
    if (str)
    {
        return str;
    }
    else
    {
        return @"";
    }
}

@end
