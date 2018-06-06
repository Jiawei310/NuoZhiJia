//
//  BluetoothStateView.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/2.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "BluetoothStateView.h"
#import "Define.h"

@interface BluetoothStateView()

/* 已连接设备界面 */
@property (strong, nonatomic) UIImageView *percentImageView;
@property (strong, nonatomic) UILabel *percentLabel;
/* 未找到设备界面 */
@property (strong, nonatomic) IBOutlet UIButton *changeDevice;
@property (strong, nonatomic) IBOutlet UIButton *tryAgain;

@end

@implementation BluetoothStateView

- (instancetype)initWithState:(NSString *)stateString andDevice:(NSString *)name andSerialNumber:(NSString *)serialNumber andPercent:(int)percent
{
    self = [super init];
    if (self)
    {
        if ([stateString isEqualToString:@"未绑定"])
        {
            self = [[[NSBundle mainBundle] loadNibNamed:@"UnboundStateView" owner:self options:nil] lastObject];
            self.frame = CGRectMake(30*Rate_NAV_W, 249.5*Rate_NAV_H, 315*Rate_NAV_W, 168*Rate_NAV_H);
            
            [self createUnboundView];
            
        }
        else if ([stateString isEqualToString:@"未连接"])
        {
            self = [[[NSBundle mainBundle] loadNibNamed:@"UnconnectedStateView" owner:self options:nil] lastObject];
            self.frame = CGRectMake(30*Rate_NAV_W, 249.5*Rate_NAV_H, 315*Rate_NAV_W, 168*Rate_NAV_H);
            
            [self createUnconnectedView];
        }
        else if([stateString isEqualToString:@"连接中"])
        {
            self = [[[NSBundle mainBundle] loadNibNamed:@"BluetoothStateView" owner:self options:nil] lastObject];
            self.frame = CGRectMake(30*Rate_NAV_W, 213*Rate_NAV_H, 315*Rate_NAV_W, 241*Rate_NAV_H);
            
            [self createConnectingView:name];
        }
        else if([stateString isEqualToString:@"已连接"])
        {
            self = [[[NSBundle mainBundle] loadNibNamed:@"ConnectedStateView" owner:self options:nil] lastObject];
            self.frame = CGRectMake(30*Rate_NAV_W, 213*Rate_NAV_H, 315*Rate_NAV_W, 241*Rate_NAV_H);
            
            [self createConnectedView:name];
            self.percent = percent;
        }
        else if ([stateString isEqualToString:@"未找到"])
        {
            self = [[[NSBundle mainBundle] loadNibNamed:@"UnFoundStateView" owner:self options:nil] lastObject];
            self.frame = CGRectMake(30*Rate_NAV_W, 213*Rate_NAV_H, 315*Rate_NAV_W, 241*Rate_NAV_H);
            
            [self createUnfoundView:name];
        }
        
        self.layer.cornerRadius = 10;
    }
    
    return self;
}

/*
 * 创建未绑定状态视图
 */
- (void)createUnboundView
{
    UIImageView *stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((315*Rate_NAV_W - 50*Rate_NAV_H)/2, 20*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    [stateImageView setImage:[UIImage imageNamed:@"unbound.jpg"]];
    [self addSubview:stateImageView];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(128*Rate_NAV_W, 80*Rate_NAV_H, 60*Rate_NAV_W, 28*Rate_NAV_H)];
    stateLabel.text = @"未绑定";
    stateLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    stateLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:stateLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 118*Rate_NAV_H, 315*Rate_NAV_W, 2*Rate_NAV_H)];
    lineView.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
    [self addSubview:lineView];
    
    UIButton *searchLiaoLiao = [UIButton buttonWithType:UIButtonTypeSystem];
    searchLiaoLiao.frame = CGRectMake(118*Rate_NAV_W, 130*Rate_NAV_H, 80*Rate_NAV_W, 28*Rate_NAV_H);
    [searchLiaoLiao setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    [searchLiaoLiao setTitle:@"搜索疗疗" forState:UIControlStateNormal];
    searchLiaoLiao.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [searchLiaoLiao addTarget:self action:@selector(searchLiaoLiaoClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:searchLiaoLiao];
}

//未绑定 “搜索疗疗” 按钮
- (void)searchLiaoLiaoClick:(UIButton *)sender
{
    [self.clickDelegate doClickEvent:sender andType:@"搜索"];
}

/*
 * 创建未连接状态视图
 */
- (void)createUnconnectedView
{
    UIImageView *stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((315*Rate_NAV_W - 50*Rate_NAV_H)/2, 20*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    [stateImageView setImage:[UIImage imageNamed:@"icon_unconnected"]];
    [self addSubview:stateImageView];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(128*Rate_NAV_W, 80*Rate_NAV_H, 60*Rate_NAV_W, 28*Rate_NAV_H)];
    stateLabel.text = @"未连接";
    stateLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    stateLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:stateLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 118*Rate_NAV_H, 315*Rate_NAV_W, 2*Rate_NAV_H)];
    lineView.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
    [self addSubview:lineView];
    
    UIButton *changeDevice = [UIButton buttonWithType:UIButtonTypeSystem];
    changeDevice.frame = CGRectMake(118*Rate_NAV_W, 130*Rate_NAV_H, 80*Rate_NAV_W, 28*Rate_NAV_H);
    [changeDevice setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    [changeDevice setTitle:@"更换设备" forState:UIControlStateNormal];
    changeDevice.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [changeDevice addTarget:self action:@selector(changeDeviceUnconnected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:changeDevice];
}

//未连接 “更换设备” 按钮
- (void)changeDeviceUnconnected:(UIButton *)sender
{
    [self.clickDelegate doClickEvent:sender andType:@"更换设备"];
}

/*
 * 创建连接中状态视图
 */
- (void)createConnectingView:(NSString *)name
{
    UIImageView *stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((315*Rate_NAV_W - 50*Rate_NAV_H)/2, 30*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    [stateImageView setImage:[UIImage imageNamed:@"icon_connect"]];
    [self addSubview:stateImageView];
    
    UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 95*Rate_NAV_H, 215*Rate_NAV_W, 17*Rate_NAV_H)];
    deviceLabel.text = name;
    deviceLabel.textColor = [UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6B/255.0 alpha:1];
    deviceLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    deviceLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:deviceLabel];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(125*Rate_NAV_W, 112*Rate_NAV_H, 65*Rate_NAV_W, 28*Rate_NAV_H)];
    stateLabel.text = @"未连接";
    stateLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    stateLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:stateLabel];
    
    UIImageView *loadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((315*Rate_NAV_W - 35*Rate_NAV_H)/2, 170*Rate_NAV_H, 35*Rate_NAV_H, 35*Rate_NAV_H)];
    [self addSubview:loadImageView];
    loadImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"load11"],
                                                              [UIImage imageNamed:@"load10"],
                                                              [UIImage imageNamed:@"load9"],
                                                              [UIImage imageNamed:@"load8"],
                                                              [UIImage imageNamed:@"load7"],
                                                              [UIImage imageNamed:@"load6"],
                                                              [UIImage imageNamed:@"load5"],
                                                              [UIImage imageNamed:@"load4"],
                                                              [UIImage imageNamed:@"load3"],
                                                              [UIImage imageNamed:@"load2"],
                                                              [UIImage imageNamed:@"load1"],nil];
    loadImageView.animationDuration = 1.5;
    loadImageView.animationRepeatCount = MAXFLOAT;
    [loadImageView startAnimating];
}

/*
 * 创建已连接状态视图
 */
- (void)createConnectedView:(NSString *)name
{
    UIImageView *stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((315*Rate_NAV_W - 50*Rate_NAV_H)/2, 20*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    [stateImageView setImage:[UIImage imageNamed:@"connected.png"]];
    [self addSubview:stateImageView];
    
    UILabel *serialNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 85*Rate_NAV_H, 215*Rate_NAV_W, 17*Rate_NAV_H)];
    serialNumLabel.text = name;
    serialNumLabel.textColor = [UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6B/255.0 alpha:1];
    serialNumLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    serialNumLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:serialNumLabel];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(125*Rate_NAV_W, 103*Rate_NAV_H, 65*Rate_NAV_W, 28*Rate_NAV_H)];
    stateLabel.text = @"已连接";
    stateLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    stateLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:stateLabel];
    
    UILabel *staticLabelOne = [[UILabel alloc] initWithFrame:CGRectMake(84*Rate_NAV_W, 147*Rate_NAV_H, 82*Rate_NAV_W, 22*Rate_NAV_H)];
    staticLabelOne.text = @"设备电量：";
    staticLabelOne.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1];
    staticLabelOne.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [self addSubview:staticLabelOne];
    
    _percentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(166*Rate_NAV_W, 153*Rate_NAV_H, 23*Rate_NAV_W, 12*Rate_NAV_H)];
    [self addSubview:_percentImageView];
    
    _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(201*Rate_NAV_W, 149*Rate_NAV_H, 40*Rate_NAV_W, 20*Rate_NAV_H)];
    _percentLabel.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1];
    _percentLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [self addSubview:_percentLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 191*Rate_NAV_H, 315*Rate_NAV_W, 2*Rate_NAV_H)];
    lineView.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
    [self addSubview:lineView];
    
    UIButton *changeDevice = [UIButton buttonWithType:UIButtonTypeSystem];
    changeDevice.frame = CGRectMake(118*Rate_NAV_W, 203*Rate_NAV_H, 80*Rate_NAV_W, 28*Rate_NAV_H);
    [changeDevice setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    [changeDevice setTitle:@"更换设备" forState:UIControlStateNormal];
    changeDevice.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [changeDevice addTarget:self action:@selector(replaceEquipmentClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:changeDevice];
}

//已连接 “更换设备” 按钮
- (void)replaceEquipmentClick:(UIButton *)sender
{
    [self.clickDelegate doClickEvent:sender andType:@"更换设备"];
}

/*
 * 创建未找到状态视图
 */
- (void)createUnfoundView:(NSString *)name
{
    UIImageView *stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((315*Rate_NAV_W - 50*Rate_NAV_H)/2, 20*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    [stateImageView setImage:[UIImage imageNamed:@"icon_warning"]];
    [self addSubview:stateImageView];
    
    UILabel *serialNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 80*Rate_NAV_H, 215*Rate_NAV_W, 17*Rate_NAV_H)];
    serialNumLabel.text = name;
    serialNumLabel.textColor = [UIColor colorWithRed:0x61/255.0 green:0x69/255.0 blue:0x6B/255.0 alpha:1];
    serialNumLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    serialNumLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:serialNumLabel];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 98*Rate_NAV_H, 116*Rate_NAV_W, 28*Rate_NAV_H)];
    stateLabel.text = @"找不到设备";
    stateLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    stateLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:stateLabel];
    
    UILabel *staticLabel = [[UILabel alloc] initWithFrame:CGRectMake(36*Rate_NAV_W, 136*Rate_NAV_H, 243*Rate_NAV_W, 44*Rate_NAV_H)];
    staticLabel.text = @"请确认设备在附近且电量充足，手机请打开蓝牙";
    staticLabel.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x98/255.0 blue:0x9B/255.0 alpha:1];
    staticLabel.textAlignment = NSTextAlignmentCenter;
    staticLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    staticLabel.numberOfLines = 0;
    [self addSubview:staticLabel];
    
    UIView *lineViewTransverse = [[UIView alloc] initWithFrame:CGRectMake(0, 192*Rate_NAV_H, 315*Rate_NAV_W, Rate_NAV_H)];
    lineViewTransverse.backgroundColor = [UIColor colorWithRed:0xEC/255.0 green:0xF0/255.0 blue:0xF1/255.0 alpha:1];
    [self addSubview:lineViewTransverse];
    
    UIButton *changeDevice = [UIButton buttonWithType:UIButtonTypeSystem];
    changeDevice.frame = CGRectMake(28.5*Rate_NAV_W, 203*Rate_NAV_H, 100*Rate_NAV_W, 28*Rate_NAV_H);
    [changeDevice setTitle:@"更换设备" forState:UIControlStateNormal];
    [changeDevice setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    changeDevice.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [changeDevice addTarget:self action:@selector(changeDeviceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:changeDevice];
    
    UIView *lineViewPortrait = [[UIView alloc] initWithFrame:CGRectMake(157*Rate_NAV_W, 191*Rate_NAV_H, Rate_NAV_W, 50*Rate_NAV_H)];
    lineViewPortrait.backgroundColor = [UIColor colorWithRed:0xEC/255.0 green:0xF0/255.0 blue:0xF1/255.0 alpha:1];
    [self addSubview:lineViewPortrait];
    
    UIButton *retryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    retryBtn.frame = CGRectMake(186.5*Rate_NAV_W, 203*Rate_NAV_H, 100*Rate_NAV_W, 28*Rate_NAV_H);
    [retryBtn setTitle:@"重试" forState:UIControlStateNormal];
    [retryBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    retryBtn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [retryBtn addTarget:self action:@selector(tryAgainClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:retryBtn];
}

//未找到 “更换设备” 按钮
- (void)changeDeviceClick:(UIButton *)sender
{
    [self.clickDelegate doClickEvent:sender andType:@"更换设备"];
}

//未找到 “重试” 按钮
- (void)tryAgainClick:(UIButton *)sender
{
    [self.clickDelegate tryAgainClickEvent:sender];
}

- (void)setPercent:(int)percent
{
    _percent = percent;
    _percentLabel.text = [NSString stringWithFormat:@"%d%%",percent];
    if (percent == 0)
    {
        _percentImageView.hidden = YES;
        _percentLabel.hidden = YES;
    }
    else if (percent > 0 && percent < 34)
    {
        _percentImageView.hidden = NO;
        _percentLabel.hidden = NO;
        [_percentImageView setImage:[UIImage imageNamed:@"icon_electricity1"]];
    }
    else if (percent >= 34 && percent < 67)
    {
        _percentImageView.hidden = NO;
        _percentLabel.hidden = NO;
        [_percentImageView setImage:[UIImage imageNamed:@"icon_electricity2"]];
    }
    else if (percent >= 67 && percent <= 100)
    {
        _percentImageView.hidden = NO;
        _percentLabel.hidden = NO;
        [_percentImageView setImage:[UIImage imageNamed:@"icon_electricity3"]];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end
