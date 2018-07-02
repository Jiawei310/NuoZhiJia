//
//  ColorsSliderView.m
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "ColorsSliderView.h"
@interface ColorsSliderView ()
@property (nonatomic, strong) NSArray *imgsArr;

@end

@implementation ColorsSliderView

- (id)init {
    self = [super init];
    if (self) {
        for (UIImageView *imgV in self.imgsArr) {
            [self addSubview:imgV];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIImageView *imgV in self.imgsArr) {
        imgV.frame = CGRectMake(colorSliderd_d * imgV.tag + colorSliderWidth * (imgV.tag-1),
                               0,
                               colorSliderWidth,
                               colorSliderHeight);
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    UIImageView *imageV = (UIImageView *)tap.view;
//    if (_level < imageV.tag) {
//        self.level = _level + 1;
//    }
//    else if (self.level > imageV.tag) {
//        self.level = _level - 1;
//    }
    if ([self.delegate respondsToSelector:@selector(selectIndex:)]) {
        [self.delegate selectIndex:imageV.tag];
    }
}


- (NSArray *)imgsArr {
    if (!_imgsArr) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
        for (NSInteger k = 1; k <= 10; k++) {
            UIImageView *imageV = [[UIImageView alloc] init];
            imageV.userInteractionEnabled = YES;
            imageV.image = [UIImage imageNamed:@"ces_ball_grey"];

            imageV.tag = k;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [imageV addGestureRecognizer:tap];
            [arr addObject:imageV];
        }
        _imgsArr = arr;
    }
    return _imgsArr;
}

- (void)setLevel:(NSInteger)level {
    _level = level;
//    UIButton *btn = self.btnsArr[level];
//    [self btnAction:btn];
    for (UIImageView *imgV in self.imgsArr) {
        if (imgV.tag <= _level) {
            if (imgV.tag <= 3) {
                imgV.image = [UIImage imageNamed:@"ces_ball_green"];
            } else if (imgV.tag <= 6) {
                imgV.image = [UIImage imageNamed:@"ces_ball_yellow"];
            } else if (imgV.tag <= 8) {
                imgV.image = [UIImage imageNamed:@"ces_ball_orange"];

            } else if (imgV.tag <= 10) {
                imgV.image = [UIImage imageNamed:@"ces_ball_red"];
            }
        }
        else {
            imgV.image = [UIImage imageNamed:@"ces_ball_grey"];
        }
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
