//
//  YBStatusView.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/12/13.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "YBStatusView.h"
#import "Define.h"

@implementation YBStatusView

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray
{
    if (self == [super initWithFrame:frame])
    {
        [self setUpStatusButtonWithTitlt:titleArray];
    }
    
    return self;
}

//界面搭建
- (void)setUpStatusButtonWithTitlt:(NSArray *)titleArray
{
    //按钮创建
    float width = self.frame.size.width/titleArray.count;
    
    for (int i = 0; i < titleArray.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(width*i, 0, width, 20*Rate_NAV_H);
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        [button addTarget:self action:@selector(buttonTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttonArray addObject:button];
        
        if (i == 0)
        {
            button.selected = YES;
        }
    }
    
    //线条
    UIView *lineBG = [[UIView alloc] initWithFrame:CGRectMake(0, 25*Rate_NAV_H, self.frame.size.width, 2*Rate_NAV_H)];
    lineBG.backgroundColor = [UIColor colorWithRed:0xEA/255.0 green:0xEA/255.0 blue:0xEA/255.0 alpha:1];
    [self addSubview:lineBG];
    self.lineView.frame = CGRectMake(0, 25*Rate_NAV_H, width, 2*Rate_NAV_H);
    self.lineView.backgroundColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    
    self.currentIndex = 0;
}

//状态切换
- (void)buttonTouchEvent:(UIButton *)sender
{
    if (sender.tag == _currentIndex)
    {
        return;
    }
    self.currentIndex = sender.tag;
    for (UIButton *tmp in _buttonArray)
    {
        if (tmp.tag == sender.tag)
        {
            [tmp setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
        }
        else
        {
            [tmp setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        }
    }
    //移动横线到对应的状态
    if (self.lineView)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect frame = self.lineView.frame;
            float origin = (self.frame.size.width/self.buttonArray.count)*sender.tag;
            frame.origin.x = origin;
            self.lineView.frame = frame;
        }];
    }
    //代理方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(statusViewSelectIndex:)])
    {
        [self.delegate statusViewSelectIndex:sender.tag];
    }
}

//- (void)

#pragma 懒加载
- (NSMutableArray *)buttonArray
{
    
    if (!_buttonArray)
    {
        _buttonArray = [NSMutableArray array];
    }
    
    return _buttonArray;
}

//下面滑动的横线
- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        [self addSubview:self.lineView];
    }
    return _lineView;
}

@end
