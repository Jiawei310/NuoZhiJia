//
//  BluetoothStatusView.m
//  Cervella
//
//  Created by 一磊 on 2018/6/14.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "BluetoothStatusView.h"
#import <QuartzCore/QuartzCore.h>
#define line_W 4
@interface BluetoothStatusView ()
{
    UIView *_backView;
    CAShapeLayer *_backLayer;
    CAShapeLayer *_progressLayer;
    
    UITapGestureRecognizer *_tapGesture;
    BluetoothInfo *_bluetoothInfo;
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
        
        [self updateProgressWithPercent:0.001];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


- (void)updateProgressWithPercent:(CGFloat )percent {
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:0.5];
    self.progressLayer.strokeEnd = percent;
    [CATransaction commit];
}

- (void)tapGestureAction {
    if (self.isCanTap) {
        if (self.bluetoothStatusViewBlock) {
            self.bluetoothStatusViewBlock(self.statusType);
        }
    } else {
        jxt_showTextHUDTitleMessage(@"", @"Connecting");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
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
        CGRect rect = CGRectMake(line_W * 2, line_W * 2, self.frame.size.width - line_W * 4, self.frame.size.height - line_W * 4);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        _backLayer.strokeColor = [UIColor colorWithRed:30/255.0 green:128/255.0 blue:211/255.0 alpha:1.0].CGColor;
        _backLayer.lineWidth = line_W;
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
        _progressLayer.lineWidth = line_W;
        _progressLayer.lineCap = kCALineCapRound;
        CGRect rect = CGRectMake(line_W * 2, line_W * 2, self.frame.size.width - line_W * 4, self.frame.size.height - line_W * 4);
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
        _timeLab.font = [UIFont systemFontOfSize:20];
    }
    return _timeLab;
}

- (UILabel *)startLab {
    if (!_startLab) {
        _startLab = [[UILabel alloc] init];
        _startLab.textAlignment = NSTextAlignmentCenter;
        _startLab.textColor = [UIColor grayColor];
        _startLab.font = [UIFont systemFontOfSize:20];
    }
    return _startLab;
}

- (void)setStatusType:(StatusType)statusType {
    _statusType = statusType;
    
    self.timeLab.frame = CGRectMake(5, (self.frame.size.height - 40)/2.0, self.frame.size.width - 10, 40);
    self.timeLab.font = [UIFont systemFontOfSize:34];
    self.startLab.font = [UIFont systemFontOfSize:30];

    if (statusType == StatusTypeNone) {
        self.timeLab.font = [UIFont systemFontOfSize:20];
        self.startLab.font = [UIFont systemFontOfSize:20];
        //Touch to Pair
        if (self.bluetoothInfo) {
            self.timeLab.text = @"Touch to Connect";
        }
        else {
            self.timeLab.text = @"Touch to Pair";
        }
        self.startLab.hidden = YES;
    }
    else if (statusType == StatusTypeStart) {
        self.startLab.hidden = NO;
        self.timeLab.frame = CGRectMake(5, (self.frame.size.height - 40)/2.0 - 10, self.frame.size.width - 10, 40);

        self.startLab.frame = CGRectMake(24,
                                         self.timeLab.frame.size.height + self.timeLab.frame.origin.y - 5,
                                         self.frame.size.width - 48,
                                         30);
        self.startLab.text = @"Start";
        self.timeLab.text = [NSString stringWithFormat:@"%.2ld:%.2ld", self.timers/60, self.timers%60];
    }
    else if (statusType == StatusTypeStop) {
        self.startLab.hidden = NO;
        self.timeLab.frame = CGRectMake(5, (self.frame.size.height - 40)/2.0 - 10, self.frame.size.width - 10, 40);
        self.startLab.frame = CGRectMake(5,
                                         self.timeLab.frame.size.height + self.timeLab.frame.origin.y - 5,
                                         self.frame.size.width - 10,
                                         30);
        self.startLab.text = @"Stop";
        self.timeLab.text = [NSString stringWithFormat:@"%.2ld:%.2ld", self.timers/60, self.timers%60];

    }
}

- (void)setTimers:(NSUInteger)timers {
    _timers = timers;
    self.timeLab.text = [NSString stringWithFormat:@"%.2ld:%.2ld", _timers/60, _timers%60];
}

- (BluetoothInfo *)bluetoothInfo {
    //从数据库读取之前绑定设备
    _bluetoothInfo = nil;
    DataBaseOpration *dataBaseOpration = [[DataBaseOpration alloc] init];
    NSArray *bluetoothInfoArray=[dataBaseOpration getBluetoothDataFromDataBase];
    
    if (bluetoothInfoArray.count>0)
    {
        _bluetoothInfo = [bluetoothInfoArray objectAtIndex:0];
    }
    [dataBaseOpration closeDataBase];
    return _bluetoothInfo;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
