//
//  ModelView.m
//  TestProject
//
//  Created by 甘伟 on 16/10/20.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "ModelView.h"
#import "Define.h"

@implementation ModelView

- (instancetype)initWithFrame:(CGRect)frame ModelTitle:(NSString *)titleLableText
{
    if(self == [super initWithFrame:frame])
    {
        [self creteViewWithFrame:frame ModelTitle:titleLableText];
    }
    
    return self;
}

- (void)creteViewWithFrame:(CGRect)frame ModelTitle:(NSString *)titleLableText
{
    self.layer.cornerRadius = 10*Rate_NAV_H;
    //毛玻璃效果
    _modelView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _modelView.frame = frame;
    [self addSubview:_modelView];
    
    //模式选择视图框架
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(33*Rate_NAV_W, 159*Rate_NAV_H, 310*Rate_NAV_W, 354*Rate_NAV_H)];
    bottomView.userInteractionEnabled = YES;
    bottomView.image = [UIImage imageNamed:@"bg_mode_select.png"];
    
    //模式的标题，默认普通模式
    self.titleLable  = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 20*Rate_NAV_H, 110*Rate_NAV_W, 28*Rate_NAV_H)];
    _titleLable.text = titleLableText;
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.textColor = [UIColor whiteColor];
    _titleLable.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    _titleLable.adjustsFontSizeToFitWidth = YES;
    [bottomView addSubview:_titleLable];
    
    //模式内容，默认普通模式
    self.infoLable  = [[UILabel alloc]initWithFrame:CGRectMake(22*Rate_NAV_W, 61*Rate_NAV_H, 264*Rate_NAV_W, 88*Rate_NAV_H)];
    self.infoLable.numberOfLines = 0;
    NSString *textStr;
    if ([titleLableText isEqualToString:@"刺激模式"])
    {
        textStr = @"        刺激模式是系统中的一种刺激频率较高的模式。刺激模式是针对用户在正常模式下效果不显著而设置的，更加有效的保持用户良好的体验，更加有助于缓解失眠状态。";
    }
    else if ([titleLableText isEqualToString:@"高强度模式"])
    {
        textStr = @"        高强度模式时系统中刺激频率最高的模式。该模式下，对于比较敏感的客户来说，长时间使用会有比较强烈的刺痛感，不建议持续长时间使用。";
    }
    else
    {
        textStr = @"        正常模式是系统中的一种普通模式。在正常模式下用户可以舒适地体验疗疗为您带来的良好体验，起到事半功倍的效果，有效缓解失眠状态。";
    }
    self.infoLable.textColor = [UIColor whiteColor];
    self.infoLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8.0*Rate_NAV_H];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textStr length])];
    self.infoLable.attributedText = attributedString;
    CGSize adviseContentLabelSize = [_infoLable sizeThatFits:CGSizeMake(264*Rate_NAV_W, MAXFLOAT)];
    _infoLable.frame = CGRectMake(22*Rate_NAV_W, 61*Rate_NAV_H, 264*Rate_NAV_W, adviseContentLabelSize.height);
    [bottomView addSubview:self.infoLable];
    
    //添加三个按钮之间的一条直线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(52*Rate_NAV_W, 226*Rate_NAV_H, 200*Rate_NAV_W, 2*Rate_NAV_H)];
    lineView.backgroundColor = [UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:0.26];
    [bottomView addSubview:lineView];
    
    self.btnNormal = [[UIButton alloc] initWithFrame:CGRectMake(32*Rate_NAV_W, 227*Rate_NAV_H - 20*Rate_NAV_W, 40*Rate_NAV_W, 40*Rate_NAV_W)];
    self.btnNormal.tag = 1;
    if ([titleLableText isEqualToString:@"正常模式"])
    {
        [self.btnNormal setImage:[UIImage imageNamed:@"icon_mode_1_select"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnNormal setImage:[UIImage imageNamed:@"icon_mode_1"] forState:UIControlStateNormal];
    }
    [self.btnNormal addTarget:self action:@selector(choose:) forControlEvents:(UIControlEventTouchUpInside)];
    [bottomView addSubview:self.btnNormal];
    
    self.btnStimulate = [[UIButton alloc] initWithFrame:CGRectMake(135*Rate_NAV_W, 227*Rate_NAV_H - 20*Rate_NAV_W, 40*Rate_NAV_W, 40*Rate_NAV_W)];
    self.btnStimulate.tag = 2;
    if ([titleLableText isEqualToString:@"刺激模式"])
    {
        [self.btnStimulate setImage:[UIImage imageNamed:@"icon_mode_2_select"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnStimulate setImage:[UIImage imageNamed:@"icon_mode_2"] forState:UIControlStateNormal];
    }
    [self.btnStimulate addTarget:self action:@selector(choose:) forControlEvents:(UIControlEventTouchUpInside)];
    [bottomView addSubview:self.btnStimulate];
    
    self.btnStrength = [[UIButton alloc] initWithFrame:CGRectMake(236*Rate_NAV_W, 227*Rate_NAV_H - 20*Rate_NAV_W, 40*Rate_NAV_W, 40*Rate_NAV_W)];
    self.btnStrength.tag = 3;
    if ([titleLableText isEqualToString:@"高强度模式"])
    {
        [self.btnStrength setImage:[UIImage imageNamed:@"icon_mode_3_select"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnStrength setImage:[UIImage imageNamed:@"icon_mode_3"] forState:UIControlStateNormal];
    }
    [self.btnStrength addTarget:self action:@selector(choose:) forControlEvents:(UIControlEventTouchUpInside)];
    [bottomView addSubview:self.btnStrength];
    
    self.contentNormal = [[UILabel alloc] initWithFrame:CGRectMake(17*Rate_NAV_W, 254*Rate_NAV_H, 70*Rate_NAV_W, 22*Rate_NAV_H)];
    self.contentNormal.text = @"正常模式";
    self.contentNormal.textAlignment = NSTextAlignmentCenter;
    if ([titleLableText isEqualToString:@"正常模式"])
    {
        self.contentNormal.textColor = [UIColor colorWithRed:0x51/255.0 green:0xCF/255.0 blue:0xBC/255.0 alpha:1];
    }
    else
    {
        self.contentNormal.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    }
    self.contentNormal.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [bottomView addSubview:self.contentNormal];
    
    self.contentStimulate = [[UILabel alloc] initWithFrame:CGRectMake(120*Rate_NAV_W, 254*Rate_NAV_H, 70*Rate_NAV_W, 22*Rate_NAV_H)];
    self.contentStimulate.text = @"刺激模式";
    self.contentStimulate.textAlignment = NSTextAlignmentCenter;
    if ([titleLableText isEqualToString:@"刺激模式"])
    {
        self.contentStimulate.textColor = [UIColor colorWithRed:0x51/255.0 green:0xCF/255.0 blue:0xBC/255.0 alpha:1];
    }
    else
    {
        self.contentStimulate.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    }
    
    self.contentStimulate.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [bottomView addSubview:self.contentStimulate];
    
    self.contentStrength = [[UILabel alloc] initWithFrame:CGRectMake(206*Rate_NAV_W, 254*Rate_NAV_H, 100*Rate_NAV_W, 22*Rate_NAV_H)];
    self.contentStrength.text = @"高强度模式";
    self.contentStrength.textAlignment = NSTextAlignmentCenter;
    if ([titleLableText isEqualToString:@"高强度模式"])
    {
        self.contentStrength.textColor = [UIColor colorWithRed:0x51/255.0 green:0xCF/255.0 blue:0xBC/255.0 alpha:1];
    }
    else
    {
        self.contentStrength.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    }
    
    self.contentStrength.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [bottomView addSubview:self.contentStrength];
    
    UIButton *chooseSure =[[UIButton alloc]initWithFrame:CGRectMake(0, 306*Rate_NAV_H, 310*Rate_NAV_W, 48*Rate_NAV_H)];
    [chooseSure setTitle:@"确定" forState:UIControlStateNormal];
    chooseSure.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [chooseSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    chooseSure.backgroundColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    [chooseSure addTarget:self action:@selector(chooseModelSure) forControlEvents:(UIControlEventTouchUpInside)];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:chooseSure.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10*Rate_NAV_H, 10*Rate_NAV_H)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = chooseSure.bounds;
    maskLayer.path = maskPath.CGPath;
    chooseSure.layer.mask = maskLayer;
    [bottomView addSubview:chooseSure];
    [self addSubview:bottomView];
}

- (void)choose:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        [self.btnNormal setImage:[UIImage imageNamed:@"icon_mode_1_select"] forState:UIControlStateNormal];
        [self.btnStimulate setImage:[UIImage imageNamed:@"icon_mode_2"] forState:UIControlStateNormal];
        [self.btnStrength setImage:[UIImage imageNamed:@"icon_mode_3"] forState:UIControlStateNormal];
        self.contentNormal.textColor = [UIColor colorWithRed:0x51/255.0 green:0xCF/255.0 blue:0xBC/255.0 alpha:1];
        self.contentStimulate.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        self.contentStrength.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        self.titleLable.text = @"正常模式";
        self.infoLable.text = @"        正常模式是系统中的一种普通模式。在正常模式下用户可以舒适地体验疗疗为您带来的良好体验，起到事半功倍的效果，有效缓解失眠状态。";
    }
    else if (sender.tag == 2)
    {
        [self.btnNormal setImage:[UIImage imageNamed:@"icon_mode_1"] forState:UIControlStateNormal];
        [self.btnStimulate setImage:[UIImage imageNamed:@"icon_mode_2_select"] forState:UIControlStateNormal];
        [self.btnStrength setImage:[UIImage imageNamed:@"icon_mode_3"] forState:UIControlStateNormal];
        self.contentNormal.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        self.contentStimulate.textColor = [UIColor colorWithRed:0x51/255.0 green:0xCF/255.0 blue:0xBC/255.0 alpha:1];
        self.contentStrength.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        self.titleLable.text = @"刺激模式";
        self.infoLable.text = @"        刺激模式是系统中的一种刺激频率较高的模式。刺激模式是针对用户在正常模式下效果不显著而设置的，更加有效的保持用户良好的体验，更加有助于缓解失眠状态。";
    }
    else if (sender.tag == 3)
    {
        [self.btnNormal setImage:[UIImage imageNamed:@"icon_mode_1"] forState:UIControlStateNormal];
        [self.btnStimulate setImage:[UIImage imageNamed:@"icon_mode_2"] forState:UIControlStateNormal];
        [self.btnStrength setImage:[UIImage imageNamed:@"icon_mode_3_select"] forState:UIControlStateNormal];
        self.contentNormal.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        self.contentStimulate.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
        self.contentStrength.textColor = [UIColor colorWithRed:0x51/255.0 green:0xCF/255.0 blue:0xBC/255.0 alpha:1];
        self.titleLable.text = @"高强度模式";
        self.infoLable.text = @"        高强度模式时系统中刺激频率最高的模式。该模式下，对于比较敏感的客户来说，长时间使用会有比较强烈的刺痛感，不建议持续长时间使用。";
    }
}

- (void)sendModelValue:(ModelValue)modelBlock
{
    self.modelBlock = modelBlock;
}

#pragma mark -- 模式选择确定
-(void)chooseModelSure
{
    //遮盖层除去
    [_modelView removeFromSuperview];
    //ModelValue这个block来传值
    self.modelBlock(self.titleLable.text);
}

@end
