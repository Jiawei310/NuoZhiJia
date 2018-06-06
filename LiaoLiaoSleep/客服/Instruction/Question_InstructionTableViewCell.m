//
//  Question_InstructionTableViewCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/4.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "Question_InstructionTableViewCell.h"

#import "Define.h"

@implementation Question_InstructionTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self customerView];
    }
    return self;
}

- (void)customerView
{
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_W, 15.5*Rate_H, 69*Rate_W, 19*Rate_H)];
    self.title.font = [UIFont systemFontOfSize:16*Rate_H];
    self.title.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    [self addSubview:self.title];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(337*Rate_W, 16.5*Rate_H, 9*Rate_H, 17*Rate_H)];
    arrow.image = [UIImage imageNamed:@"question_arrow_right.png"];
    [self addSubview:arrow];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_W, 50*Rate_H - 1, SCREENWIDTH - 20*Rate_W, 1)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
