//
//  FootPrintCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/15.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "FootPrintCell.h"
#import "Define.h"

#import "UIImageView+WebCache.h"

@implementation FootPrintCell

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
    _headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(10*Rate_W, 10*Rate_H, 36*Rate_H, 36*Rate_H)];
    _headerImage.layer.cornerRadius = 18*Rate_H;
    _headerImage.clipsToBounds = YES;
    [self addSubview:_headerImage];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56*Rate_W, 10*Rate_H, 257*Rate_W, 18*Rate_H)];
    _nameLabel.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _nameLabel.font = [UIFont systemFontOfSize:14*Rate_H];
    [self addSubview:_nameLabel];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(56*Rate_W, 28*Rate_H, 257*Rate_W, 18*Rate_H)];
    _timeLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _timeLable.font = [UIFont systemFontOfSize:12*Rate_H];
    [self addSubview:_timeLable];
    
    _contentLable = [[UILabel alloc]initWithFrame:CGRectMake(10*Rate_W, 86*Rate_H, 341*Rate_W, 70*Rate_H)];
    _contentLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _contentLable.font = [UIFont systemFontOfSize:14*Rate_H];
    _contentLable.numberOfLines = 0;
    [self addSubview:_contentLable];
    
    _replayPoint = [[UIView alloc]initWithFrame:CGRectMake(353*Rate_W, 25*Rate_H, 12*Rate_H, 12*Rate_H)];
    _replayPoint.layer.cornerRadius = 6*Rate_H;
    _replayPoint.clipsToBounds = YES;
    _replayPoint.backgroundColor = [UIColor redColor];
    _replayPoint.hidden = YES;
    [self addSubview:_replayPoint];
}

- (void)setModel:(FootPrintModel *)model
{
    [_headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,model.HeaderImage]] placeholderImage:[UIImage imageNamed:@""]];
    _nameLabel.text = model.PatientName;
    CGSize nameSize = [model.PatientName boundingRectWithSize:CGSizeMake(257*Rate_W, 18*Rate_H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(56*Rate_W, 10*Rate_H, nameSize.width, 18*Rate_H)];
    _timeLable.text = model.PublicTime;
    _contentLable.text = model.PostTitle;
    CGSize contentSize = [model.PostTitle boundingRectWithSize:CGSizeMake(341*Rate_W, 70*Rate_H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _contentLable.frame = CGRectMake(16*Rate_W, 58*Rate_H, 341*Rate_W, contentSize.height);
    if (model.isReplay && model.isPublic) {
        _replayPoint.hidden = NO;
    }
    //获得当前cell高度
    CGRect frame = [self frame];
    //计算出自适应的高度
    frame.size.height = contentSize.height + 75*Rate_H;
    self.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
