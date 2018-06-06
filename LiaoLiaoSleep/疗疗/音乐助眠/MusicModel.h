//
//  MusicModel.h
//  SleepMusic
//
//  Created by Justin on 2017/4/18.
//  Copyright © 2017年 诺之嘉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *musicID;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *musicUrl;
@property (nonatomic, strong) NSString *btnBgUrl_Gray;
@property (nonatomic, strong) NSString *btnBgUrl_Colour;
@property (nonatomic, strong) NSString *btnBgUrl_White;
@property (nonatomic, strong) NSString *playBgBottom;
@property (nonatomic, strong) NSString *playBgTop;
@property (nonatomic, strong) NSString *updateDate;
@property (nonatomic, strong) NSString *visible;

@end
