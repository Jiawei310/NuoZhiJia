//
//  AudioPlayer.h
//  SleepMusic
//
//  Created by 诺之嘉 on 2017/4/11.
//  Copyright © 2017年 诺之嘉. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AudioPlayer;

@interface AudioPlayer : NSObject

@property (nonatomic, assign) BOOL isPlaying;


+ (AudioPlayer*)sharePlayer;
- (void)play;
- (void)pause;
- (void)seekToTime:(float)time;
- (void)setPrepareMusicUrl:(NSString*)urlStr;

@end
