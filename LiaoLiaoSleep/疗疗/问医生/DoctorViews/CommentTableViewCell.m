//
//  CommentTableViewCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "Define.h"
@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self customerView];
    }
    return self;
}
-(void)customerView{
    //头像
    _headerImage  = [[UIImageView alloc]initWithFrame:CGRectMake(16*Ratio, 7*Ratio, 38*Ratio, 38*Ratio)];
    _headerImage.layer.cornerRadius = 19*Ratio;
    _headerImage.clipsToBounds = YES;
    [self addSubview:_headerImage];
    
    _nameLable  = [[UILabel alloc]initWithFrame:CGRectMake(62*Ratio, 16*Ratio, 61*Ratio, 20*Ratio)];
    _nameLable.font = [UIFont systemFontOfSize:14];
    [self addSubview:_nameLable];
    
    _timeLbale = [[UILabel alloc]initWithFrame:CGRectMake(250*Ratio, 19*Ratio, (375-250)*Ratio, 14*Ratio)];
    _timeLbale.font = [UIFont systemFontOfSize:12];
    [self addSubview:_timeLbale];
    
    _contentLable = [[UILabel alloc]init];
    _contentLable.font = [UIFont systemFontOfSize:16];
    _contentLable.numberOfLines = 0;
    [self addSubview:_contentLable];
}
-(void)setModel:(CommentModel *)model{
    [_headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,model.patientIcon]] placeholderImage:[UIImage imageNamed:@"icon_headportrait.png"]];
    _nameLable.text = model.patientName;
    _timeLbale.text = model.commentTime;
    _contentLable.text = model.commentContent;
    CGSize size = [_contentLable.text boundingRectWithSize:CGSizeMake(SCREENWIDTH-30*Ratio, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16*Ratio]} context:nil].size;
    _contentLable.frame = CGRectMake(15*Ratio, 53*Ratio, SCREENWIDTH-30*Ratio, size.height);
    for(int i = 0; i < 5; i++){
        UIImageView * star = [[UIImageView alloc]initWithFrame:CGRectMake(15*Ratio+(21*Ratio)*i, CGRectGetMaxY(_contentLable.frame)+10*Ratio, 13*Ratio, 13*Ratio)];
        if (i < [model.commentStar intValue]) {
            star.image = [UIImage imageNamed:@"star_in.png"];
        }else{
            star.image = [UIImage imageNamed:@"star.png"];
        }
        [self addSubview:star];
    }
    //获得当前cell高度
    CGRect frame = [self frame];
    //    //计算出自适应的高度
    frame.size.height = size.height+94*Ratio;
    self.frame = frame;
}
-(CGFloat)getCellHeight:(NSString *)text{
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREENWIDTH-30*Ratio, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16*Ratio]} context:nil].size;
    return size.height+94*Ratio;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
