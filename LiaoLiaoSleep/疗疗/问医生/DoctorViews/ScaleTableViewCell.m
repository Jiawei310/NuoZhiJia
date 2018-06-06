//
//  ScaleTableViewCell.m
//  ChatDemo
//
//  Created by 甘伟 on 16/11/11.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "ScaleTableViewCell.h"
#import "Define.h"

@implementation ScaleTableViewCell

- (void)awakeFromNib {
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
    _lable = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/4, 0, SCREENWIDTH/2, 30)];
    _lable.textColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0];
    _lable.layer.cornerRadius = 5;
    _lable.font = [UIFont systemFontOfSize:13];
    _lable.clipsToBounds = YES;
    _lable.backgroundColor = [UIColor colorWithRed:0.85 green:0.96 blue:0.99 alpha:1.00];
    _lable.adjustsFontSizeToFitWidth = YES;
    _lable.textAlignment = NSTextAlignmentCenter;
    _lable.text = @"量表已更新";
    [self.contentView addSubview:_lable];
    
    CGRect rect = self.frame;
    rect.size.height = 30;
    self.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
