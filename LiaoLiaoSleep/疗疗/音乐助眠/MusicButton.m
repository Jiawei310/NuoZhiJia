//
//  MusicButton.m
//  SleepMusic
//
//  Created by Justin on 2017/4/20.
//  Copyright © 2017年 诺之嘉. All rights reserved.
//

#import "MusicButton.h"
#import "UIButton+Common.h"
#import "Define.h"

@interface MusicButton ()
{
    CAShapeLayer *layer;
}

@end

@implementation MusicButton

- (instancetype)init
{
    if (self == [super init])
    {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    
    return self;
}

- (void)setAnimationBgView:(UIView *)animationBgView
{
    if (self.downLoad == NO)
    {
        _animationBgView = animationBgView;
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self addSubview:animationBgView];
            
        });
    }
}

- (void)setAnimationViewOne:(UIView *)animationViewOne
{
    if (self.downLoad == NO)
    {
        _animationViewOne = animationViewOne;
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self addSubview:animationViewOne];
            
        });
    }
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    [self addMaskWithProgress:progress];
}

- (void)addMaskWithProgress:(float)progress
{
    self.userInteractionEnabled = NO;
    if (self.animationBgView == nil)
    {
        UIView *animationBgView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 45*Rate_H)/2, 7*Rate_H, 45*Rate_H, 45*Rate_H)];
        animationBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        animationBgView.layer.cornerRadius = 5;
        self.animationBgView = animationBgView;
        
        //create path
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 45*Rate_H, 45*Rate_H)];
        // MARK: circlePath
        [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(45*Rate_H/2, 45*Rate_H/2) radius:(35*Rate_H)/2 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.animationBgView.layer setMask:shapeLayer];
        });
    }
    
    if (self.animationViewOne == nil)
    {
        UIView *animationViewOne = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 30*Rate_H)/2, 14.5*Rate_H, 30*Rate_H, 30*Rate_H)];
        animationViewOne.backgroundColor = [UIColor clearColor];
        animationViewOne.layer.cornerRadius = 15*Rate_H;
        self.animationViewOne = animationViewOne;
    }
    UIBezierPath *myPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(15*Rate_H, 15*Rate_H) radius:15*Rate_H startAngle:(-1 + 4*progress)*M_PI/2 endAngle:3*M_PI/2 clockwise:YES];
    [myPath addLineToPoint:CGPointMake(15*Rate_H, 15*Rate_H)];
    if (layer == nil)
    {
        layer = [CAShapeLayer layer];
        layer.frame = self.animationViewOne.bounds;
        layer.fillColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;//设置填充颜色
        layer.path = myPath.CGPath;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.animationViewOne.layer addSublayer:layer];
        });
    }
    else
    {
        [layer removeFromSuperlayer];
        
        layer = [CAShapeLayer layer];
        layer.frame = self.animationViewOne.bounds;
        layer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;//设置填充颜色
        layer.path = myPath.CGPath;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.animationViewOne.layer addSublayer:layer];
        });
    }
}

@end
