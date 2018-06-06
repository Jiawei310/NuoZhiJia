//
//  InstructionTableViewCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/4.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "InstructionTableViewCell.h"
#import "Define.h"

@implementation InstructionTableViewCell

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

-(void)customerView
{
    self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(21*Rate_W, 13*Rate_W, 333*Rate_W, 23*Rate_W)];
    [self addSubview:self.imageV];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_W, 50*Rate_W - 1, 356*Rate_W, 1)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
