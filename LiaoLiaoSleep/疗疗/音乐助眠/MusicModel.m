//
//  MusicModel.m
//  SleepMusic
//
//  Created by Justin on 2017/4/18.
//  Copyright © 2017年 诺之嘉. All rights reserved.
//

#import "MusicModel.h"

@implementation MusicModel

@synthesize musicID,state,musicName,musicUrl;
@synthesize btnBgUrl_Gray,btnBgUrl_White,btnBgUrl_Colour;
@synthesize playBgBottom,playBgTop;
@synthesize updateDate,visible;

- (id)copyWithZone:(NSZone *)zone
{
    MusicModel *newModel = [[[self class] allocWithZone:zone] init];
    
    [newModel setMusicID:self.musicID];
    [newModel setState:self.state];
    [newModel setMusicName:self.musicName];
    [newModel setMusicUrl:self.musicUrl];
    [newModel setBtnBgUrl_Gray:self.btnBgUrl_Gray];
    [newModel setBtnBgUrl_White:self.btnBgUrl_White];
    [newModel setBtnBgUrl_Colour:self.btnBgUrl_Colour];
    [newModel setPlayBgBottom:self.playBgBottom];
    [newModel setPlayBgTop:self.playBgTop];
    [newModel setUpdateDate:self.updateDate];
    [newModel setVisible:self.visible];
    
    return newModel;
}

@end
