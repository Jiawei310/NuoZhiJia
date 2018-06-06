//
//  RecordMessageModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/29.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Message_Text=0,//文本
    Message_Image,//图片
    Message_Time,//时间
    Message_Scale//更新量表
}MessageType;

@interface RecordMessageModel : NSObject

@property(copy, nonatomic)NSString * questionID;
@property(copy, nonatomic)NSString * message;
@property(nonatomic)MessageType messageType;
@property(nonatomic)BOOL isSender;
@property(copy, nonatomic)NSString * nickName;
@property(copy, nonatomic)NSString * headerImage;
//image
@property (copy, nonatomic) NSString * size;
@property (copy, nonatomic) NSString * thumbnailSize;
@property (copy, nonatomic) NSString * image;
@property (copy, nonatomic) NSString * thumbnailImage;
@property (copy, nonatomic) NSString * localPath;

- (instancetype)init;
- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
