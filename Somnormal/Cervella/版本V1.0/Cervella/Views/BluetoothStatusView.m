//
//  BluetoothStatusView.m
//  Cervella
//
//  Created by 一磊 on 2018/6/14.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "BluetoothStatusView.h"
#import <QuartzCore/QuartzCore.h>

@interface BluetoothStatusView ()
{
    UIView *_backView;
    CAShapeLayer *_backLayer;
    CAShapeLayer *_progressLayer;
    
    UITapGestureRecognizer *_tapGesture;
}
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UILabel *startLab;

@end

@implementation BluetoothStatusView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        frame.size.height = frame.size.width;
        self.frame = frame;
        
        self.layer.cornerRadius = frame.size.width/2;
        self.layer.masksToBounds = YES;
        [self addGestureRecognizer:self.tapGesture];
        
        [self addSubview:self.backView];
        
        [self addSubview:self.timeLab];
        [self addSubview:self.startLab];
        
        [self updateProgressWithNumber:1.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


- (void)updateProgressWithNumber:(NSUInteger)number {
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:0.5];
    self.progressLayer.strokeEnd = number/100.0;
    [CATransaction commit];
}

- (void)tapGestureAction {
    if (self.bluetoothStatusViewBlock) {
        self.bluetoothStatusViewBlock();
    }
}

#pragma mark - get
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _backView.transform = CGAffineTransformMakeRotation(-M_PI_2);

        [_backView.layer addSublayer:self.backLayer];
        [_backView.layer addSublayer:self.progressLayer];
    }
    return _backView;
}

- (CAShapeLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAShapeLayer layer];
        CGRect rect = CGRectMake(2.5, 2.5, self.frame.size.width - 5, self.frame.size.height - 5);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        _backLayer.strokeColor = [UIColor blueColor].CGColor;
        _backLayer.lineWidth = 1;
        _backLayer.fillColor = [UIColor clearColor].CGColor;
        _backLayer.lineCap = kCALineCapRound;
        _backLayer.path = path.CGPath;
    }
    return _backLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor greenColor].CGColor;
        _progressLayer.lineWidth = 5;
        _progressLayer.lineCap = kCALineCapRound;
        CGRect rect = CGRectMake(2.5, 2.5, self.frame.size.width - 5, self.frame.size.height - 5);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        _progressLayer.path = path.CGPath;
    }
    return _progressLayer;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    }
    return _tapGesture;
}



- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.textColor = [UIColor grayColor];
    }
    return _timeLab;
}

- (UILabel *)startLab {
    if (!_startLab) {
        _startLab = [[UILabel alloc] init];
        _startLab.textAlignment = NSTextAlignmentCenter;
        _startLab.textColor = [UIColor grayColor];
    }
    return _startLab;
}

- (void)setStatusType:(StatusType)statusType {
    _statusType = statusType;
    
    self.timeLab.frame = CGRectMake(5, (self.frame.size.height - 30)/2.0, self.frame.size.width - 10, 30);
    if (statusType == StatusTypeNone) {
        //Unpaired
        self.timeLab.text = @"Unpaired";
        self.startLab.hidden = YES;
    }
    else if (statusType == StatusTypeStart) {
        self.timeLab.text = @"10:00";

        self.startLab.hidden = NO;
        self.startLab.frame = CGRectMake(24,
                                         self.timeLab.frame.size.height + self.timeLab.frame.origin.y,
                                         self.frame.size.width - 48,
                                         30);
        self.startLab.text = @"Start";
    }
    else if (statusType == StatusTypeStop) {
        self.timeLab.text = @"10:00";

        self.startLab.hidden = NO;
        self.startLab.frame = CGRectMake(5,
                                         self.timeLab.frame.size.height + self.timeLab.frame.origin.y,
                                         self.frame.size.width - 10,
                                         30);
        self.startLab.text = @"Stop";
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
