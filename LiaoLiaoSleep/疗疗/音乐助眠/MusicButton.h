//
//  MusicButton.h
//  SleepMusic
//
//  Created by Justin on 2017/4/20.
//  Copyright © 2017年 诺之嘉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicButton : UIButton

//@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) float progress;

@property (nonatomic, strong) UIView *animationBgView;
@property (nonatomic, strong) UIView *animationViewOne;


- (instancetype)initWithFrame:(CGRect)frame;

@end
