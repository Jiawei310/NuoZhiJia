//
//  MessageModel.h
//  Chat
//
//  Created by 甘伟 on 16/12/16.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EMSDK.h"

@interface MessageModel : NSObject

@property (nonatomic) CGFloat cellHeight;   //cell的高度
@property (strong, nonatomic, readonly) EMMessage *message; //消息
@property (strong, nonatomic, readonly) EMMessageBody *firstMessageBody;
@property (strong, nonatomic, readonly) NSString *messageId; //消息ID
@property (nonatomic, readonly) EMMessageStatus messageStatus; //消息发送状态
@property (nonatomic, readonly) EMMessageBodyType bodyType; //消息体类型
@property (nonatomic) BOOL isMessageRead; //是否被读
@property (strong, nonatomic) NSString *askCount;
// if the current login user is message sender
@property (nonatomic) BOOL isSender;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *avatarURLPath;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSAttributedString *attrBody;
//Placeholder image when download fails
@property (strong, nonatomic) NSString *failImageName;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGSize thumbnailImageSize;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) BOOL isMediaPlaying;
@property (nonatomic) BOOL isMediaPlayed;
@property (nonatomic) CGFloat mediaDuration;
@property (strong, nonatomic) NSString *fileIconName;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileSizeDes;
@property (nonatomic) CGFloat fileSize;
//progress of uploading or downloading the attachment message
@property (nonatomic) float progress;
@property (strong, nonatomic, readonly) NSString *fileLocalPath;
@property (strong, nonatomic) NSString *thumbnailFileLocalPath;
@property (strong, nonatomic) NSString *fileURLPath;
@property (strong, nonatomic) NSString *thumbnailFileURLPath;

//- (instancetype)initWithMessage:(EMMessage *)message;
- (instancetype)initWithMessage:(EMMessage *)message
                          photo:(UIImage *)userPhoto;

@end
