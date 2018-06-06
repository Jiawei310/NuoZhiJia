//
//  DownloadOpration.h
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/4/27.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MusicButton;

@protocol DownloadOprationDelegate <NSObject>

//下载完成
- (void)musicDownloadProgress:(float)progress typeNum:(NSInteger)num;

@end

@interface DownloadOpration : NSObject

@property (nonatomic, weak) id<DownloadOprationDelegate>delegate;


- (instancetype)initWithUrl:(NSString *)urlStr typeNum:(NSUInteger)typeNum;

@end
