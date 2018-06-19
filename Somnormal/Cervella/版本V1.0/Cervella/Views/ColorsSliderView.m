//
//  ColorsSliderView.m
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "ColorsSliderView.h"
@interface ColorsSliderView ()
@property (nonatomic, strong) NSArray *btnsArr;
@end

@implementation ColorsSliderView

- (id)init {
    self = [super init];
    if (self) {
        for (UIButton *btn in self.btnsArr) {
            [self addSubview:btn];
        }
    }
    return self;
}


- (void)btnAction:(UIButton *)button {
    for (UIButton *btn in self.btnsArr) {
        if (btn.tag <= button.tag) {
            btn.selected = YES;
        } else {
            btn.selected = NO;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(selectIndex:)]) {
        [self.delegate selectIndex:button.tag];
    }
}

- (NSArray *)btnsArr {
    if (!_btnsArr) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
        for (NSInteger k = 1; k <= 10; k++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = k;
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(colorSliderd_d * k + colorSliderWidth * (k-1), 0, colorSliderWidth, colorSliderHeight);
            [btn setBackgroundImage:[UIImage imageNamed:@"ces_ball_grey"] forState:UIControlStateNormal];
            if (k <= 3) {
                [btn setBackgroundImage:[UIImage imageNamed:@"ces_ball_green"] forState:UIControlStateSelected];
            } else if (k <= 6) {
                [btn setBackgroundImage:[UIImage imageNamed:@"ces_ball_yellow"] forState:UIControlStateSelected];
            } else if (k <= 8) {
                [btn setBackgroundImage:[UIImage imageNamed:@"ces_ball_orange"] forState:UIControlStateSelected];
            } else if (k <= 10) {
                [btn setBackgroundImage:[UIImage imageNamed:@"ces_ball_red"] forState:UIControlStateSelected];
            }
            [arr addObject:btn];
        }
        _btnsArr = arr;
    }
    return _btnsArr;
}

- (void)setLevel:(NSInteger)level {
    _level = level;
    UIButton *btn = self.btnsArr[level];
    [self btnAction:btn];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
