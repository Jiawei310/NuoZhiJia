//
//  FragmentView.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/11.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "FragmentView.h"
#import "Define.h"

@interface FragmentView()

@property (strong, nonatomic) IBOutlet UILabel *staticLabelOne;
@property (strong, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutlet UILabel *staticLabelTwo;

@property (nonatomic, strong) UIButton *noBtn;     //没有
@property (nonatomic, strong) UIButton *oneTimeBtn;//每周不到一次
@property (nonatomic, strong) UIButton *twiceBtn;  //每周一到两次
@property (nonatomic, strong) UIButton *moreBtn;   //每周三次或更多

@end

@implementation FragmentView

- (instancetype)initWithQuestion:(NSString *)questionText Selected:(NSString *)selectedString
{
    self = [super init];
    if (self)
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"FragmentView" owner:self options:nil] lastObject];
        self.frame = CGRectMake(38*Rate_NAV_W, 169*Rate_NAV_H, 300*Rate_NAV_W, 290*Rate_NAV_H);
        self.layer.cornerRadius = 4;
        
        _staticLabelOne = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 18*Rate_NAV_H, 100*Rate_NAV_W, 20*Rate_NAV_H)];
        _staticLabelOne.text = @"近一个月，因";
        _staticLabelOne.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
        _staticLabelOne.textAlignment = NSTextAlignmentCenter;
        _staticLabelOne.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        [self addSubview:_staticLabelOne];
        
        _questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 39*Rate_NAV_H, 100*Rate_NAV_W, 36*Rate_NAV_H)];
        _questionLabel.text = questionText;
        _questionLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
        _questionLabel.textAlignment = NSTextAlignmentCenter;
        _questionLabel.font = [UIFont systemFontOfSize:25*Rate_NAV_H];
        _questionLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_questionLabel];
        
        _staticLabelOne = [[UILabel alloc] initWithFrame:CGRectMake(58*Rate_NAV_W, 76*Rate_NAV_H, 187*Rate_NAV_W, 22*Rate_NAV_H)];
        _staticLabelOne.text = @"影响睡眠而烦恼的频率是";
        _staticLabelOne.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
        _staticLabelOne.textAlignment = NSTextAlignmentCenter;
        _staticLabelOne.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        [self addSubview:_staticLabelOne];
        
        _noBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _noBtn.frame = CGRectMake(20*Rate_NAV_W, 127*Rate_NAV_H, 125*Rate_NAV_W, 58*Rate_NAV_H);
        _noBtn.tag = 0;
        if ([selectedString isEqualToString:@"0"])
        {
            [_noBtn setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
            [_noBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [_noBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
            [_noBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
        }
        [_noBtn setTitle:@"没有" forState:UIControlStateNormal];
        _noBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        [_noBtn addTarget:self action:@selector(selectFragmentAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_noBtn];
        
        _oneTimeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _oneTimeBtn.frame = CGRectMake(155*Rate_NAV_W, 127*Rate_NAV_H, 125*Rate_NAV_W, 58*Rate_NAV_H);
        _oneTimeBtn.tag = 1;
        if ([selectedString isEqualToString:@"1"])
        {
            [_oneTimeBtn setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
            [_oneTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [_oneTimeBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
            [_oneTimeBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
        }
        [_oneTimeBtn setTitle:@"每周不到一次" forState:UIControlStateNormal];
        _oneTimeBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        [_oneTimeBtn addTarget:self action:@selector(selectFragmentAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_oneTimeBtn];

        _twiceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _twiceBtn.frame = CGRectMake(20*Rate_NAV_W, 195*Rate_NAV_H, 125*Rate_NAV_W, 58*Rate_NAV_H);
        _twiceBtn.tag = 2;
        if ([selectedString isEqualToString:@"2"])
        {
            [_twiceBtn setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
            [_twiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [_twiceBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
            [_twiceBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
        }
        [_twiceBtn setTitle:@"每周一到两次" forState:UIControlStateNormal];
        _twiceBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        [_twiceBtn addTarget:self action:@selector(selectFragmentAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_twiceBtn];

        _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _moreBtn.frame = CGRectMake(155*Rate_NAV_W, 195*Rate_NAV_H, 125*Rate_NAV_W, 58*Rate_NAV_H);
        _moreBtn.tag = 3;
        if ([selectedString isEqualToString:@"3"])
        {
            [_moreBtn setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
            [_moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [_moreBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
            [_moreBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
        }
        [_moreBtn setTitle:@"每周三次或更多" forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        [_moreBtn addTarget:self action:@selector(selectFragmentAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_moreBtn];
    }
    
    return self;
}

- (void)selectFragmentAnswer:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
        [_oneTimeBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [_twiceBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [_moreBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        
        //传递选项的值
        self.answerSelect(sender.titleLabel.text);
    }
    else if (sender.tag == 1)
    {
        [_noBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
        [_twiceBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [_moreBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        
        //传递选项的值
        self.answerSelect(sender.titleLabel.text);
    }
    else if (sender.tag == 2)
    {
        [_noBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [_oneTimeBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
        [_moreBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        
        //传递选项的值
        self.answerSelect(sender.titleLabel.text);
    }
    else if (sender.tag == 3)
    {
        [_noBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [_oneTimeBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [_twiceBtn setBackgroundImage:[UIImage imageNamed:@"gauge_win1_notselected_bg"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"screen_btn_bg"] forState:UIControlStateNormal];
        
        //传递选项的值
        self.answerSelect(sender.titleLabel.text);
    }
}

- (void)sendSelectValue:(AnswerSelect)answerSelect
{
    self.answerSelect = answerSelect;
}

@end
