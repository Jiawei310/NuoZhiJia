//
//  PostCommentCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/12.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PostCommentCell.h"
#import "UIImageView+EMWebCache.h"
#import "Define.h"

@implementation PostCommentCell

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
    _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(10*Rate_W, 17*Rate_H, 36*Rate_H, 36*Rate_H)];
    _headerView.layer.cornerRadius = 18*Rate_H;
    _headerView.clipsToBounds = YES;
    _headerView.backgroundColor = [UIColor cyanColor];
    [self addSubview:_headerView];
    
    _nameLable = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, 16*Rate_H, 257*Rate_W, 19*Rate_H)];
    _nameLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _nameLable.font = [UIFont systemFontOfSize:13];
    [self addSubview:_nameLable];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, 36*Rate_H, 257*Rate_W, 19*Rate_H)];
    _timeLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _timeLable.font = [UIFont systemFontOfSize:14];
    [self addSubview:_timeLable];
    
    _contentLable = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, 60*Rate_H, 304*Rate_W, 60*Rate_H)];
    _contentLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _contentLable.font = [UIFont systemFontOfSize:14];
    _contentLable.numberOfLines = 0;
    [self addSubview:_contentLable];
}

- (void)setModel:(PostCommentModel *)model
{
    [_headerView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,model.HeaderImageUrl]] placeholderImage:[UIImage imageNamed:@""]];
    _nameLable.text = model.Name;
    _timeLable.text = model.CommentTime;
    _contentLable.text = model.CommentContent;
    CGSize titleSize = [model.CommentContent boundingRectWithSize:CGSizeMake(304*Rate_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _contentLable.frame = CGRectMake(50*Rate_W, 60*Rate_H, 304*Rate_W, titleSize.height);
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, titleSize.height + 70*Rate_H - 1, SCREENWIDTH - 50*Rate_W, 1)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [self addSubview:line];
    //获得当前cell高度
    CGRect frame = [self frame];
    //计算出自适应的高度
    frame.size.height = titleSize.height + 70*Rate_H;
    self.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
