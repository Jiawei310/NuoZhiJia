//
//  AudioPlayer.m
//  SleepMusic
//
//  Created by 诺之嘉 on 2017/4/11.
//  Copyright © 2017年 诺之嘉. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer ()
{
    BOOL _isPrepare;//播放是否准备成功
    BOOL _isPlaying;//播放器是否正在播放
    
    CAShapeLayer *layer;
}

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSString *musicName;

@end

@implementation AudioPlayer

+ (AudioPlayer*)sharePlayer
{
    
    static AudioPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [AudioPlayer new];
    });
    
    return  player;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //通知中心
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (NSDirectoryEnumerator *)getMusicCache
{
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Music/"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:DocumentsPath];
    
    return enumerator;
}

- (void)setPrepareMusicUrl:(NSString*)urlStr
{
    NSString *musicFileName;
    //获取沙盒本地缓存
    NSDirectoryEnumerator *enumerator = [self getMusicCache];
    for (NSString *fileName in enumerator)
    {
        if ([urlStr containsString:fileName])
        {
            musicFileName = fileName;
        }
    }
    
    //从沙盒中取音乐
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Music/%@",musicFileName]];
    NSURL *musicUrl = [NSURL fileURLWithPath:DocumentsPath];
    if (_musicName == nil)
    {
        _musicName = musicFileName;
        //item资源的观察者
        if (self.player.currentItem)
        {
            [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        }
        //创建一个item资源
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:musicUrl];
        [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
        [self.player replaceCurrentItemWithPlayerItem:item];
    }
    else
    {
        if ([_musicName isEqualToString:musicFileName])
        {
            [self play];
        }
        else
        {
            _musicName = musicFileName;
            //item资源的观察者
            if (self.player.currentItem)
            {
                [self.player.currentItem removeObserver:self forKeyPath:@"status"];
            }
            //创建一个item资源
            AVPlayerItem *item = [AVPlayerItem playerItemWithURL:musicUrl];
            [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
            [self.player replaceCurrentItemWithPlayerItem:item];
        }
    }
}

- (void)play
{
    //判断资源是否准备成功
    if (!_isPrepare)
    {
        return;
    }
    
    [self.player play];
    _isPlaying = YES;
}

- (void)pause
{
    if (!_isPlaying)
    {
        return;
    }
    
    [self.player pause];
    _isPlaying = NO;
}

- (void)seekToTime:(float)time
{
    //当音乐播放器时间改变时,先暂停后播放
    [self pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished)
        {
            [self play];
        }
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerStatus staute = [change[@"new"] integerValue];
    switch (staute)
    {
        case AVPlayerStatusReadyToPlay:
            NSLog(@"加载成功,可以播放了");
            _isPrepare = YES;
            [self play];
            break;
        case AVPlayerStatusFailed:
            NSLog(@"加载失败");
            break;
        case AVPlayerStatusUnknown:
            NSLog(@"资源找不到");
            break;
            
        default:
            break;
    }
    
    NSLog(@"change:%@",change);
}

//当一首歌播放结束时会执行下面的方法
- (void)endAction:(NSNotification *)notificarion
{
    [self seekToTime:0];
}


- (AVPlayer*)player
{
    if (_player == nil)
    {
        _player = [AVPlayer new];
    }
    
    return _player;
}

- (BOOL)isPlaying
{
    return _isPlaying;
}

@end
