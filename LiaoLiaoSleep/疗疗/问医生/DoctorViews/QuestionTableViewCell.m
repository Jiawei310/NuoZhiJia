//
//  QuestionTableViewCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/1.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "QuestionTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "Define.h"

@implementation QuestionTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
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
    _contentLable = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 10*Rate_NAV_H, 345*Rate_NAV_W, 22*Rate_NAV_H)];
    _contentLable.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    _contentLable.numberOfLines = 0;
    [self.contentView addSubview:_contentLable];
    
    _iconV = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 46*Rate_NAV_H, 38*Rate_NAV_H, 38*Rate_NAV_H)];
    _iconV.layer.cornerRadius = 19*Rate_NAV_H;
    _iconV.clipsToBounds = YES;
    [self.contentView addSubview:_iconV];
    
    _nameLable = [[UILabel alloc] initWithFrame:CGRectMake(63*Rate_NAV_W, 46*Rate_NAV_H, 47*Rate_NAV_W, 19*Rate_NAV_H)];
    _nameLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    _nameLable.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_nameLable];
    
    _sexAgeLable  = [[UILabel alloc] initWithFrame:CGRectMake(63*Rate_NAV_W, 65*Rate_NAV_H, 47*Rate_NAV_W, 19*Rate_NAV_H)];
    _sexAgeLable.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    _sexAgeLable.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_sexAgeLable];
    
    _timeLbale = [[UILabel alloc] initWithFrame:CGRectMake(260*Rate_NAV_W, 65*Rate_NAV_H, 101*Rate_NAV_W, 19*Rate_NAV_H)];
    _timeLbale.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    _timeLbale.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_timeLbale];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 99*Rate_NAV_H, SCREENWIDTH, 5*Rate_NAV_H)];
    _lineView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    [self.contentView addSubview:_lineView];
}

- (void)setModel:(ConsultQuestionModel *)model
{
    _contentLable.text = model.question;
    CGSize size = [_contentLable.text boundingRectWithSize:CGSizeMake(345*Rate_NAV_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16*Rate_NAV_H]} context:nil].size;
    _contentLable.frame = CGRectMake(15*Rate_NAV_W, 10*Rate_NAV_H, 345*Rate_NAV_W, size.height);
    
    [_iconV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,model.headerImage]] placeholderImage:[UIImage imageNamed:@"icon_me_in"]];
    _iconV.frame = CGRectMake(15*Rate_NAV_W, size.height + 24*Rate_NAV_H, 38*Rate_NAV_H, 38*Rate_NAV_H);
    
    _nameLable.text = model.name;
    _nameLable.frame = CGRectMake(63*Rate_NAV_W, size.height + 24*Rate_NAV_H, 47*Rate_NAV_W, 19*Rate_NAV_H);
    
    _sexAgeLable.text = [NSString stringWithFormat:@"%@  %@",model.sex,[self getAgeWithBirth:model.birth]];
    _sexAgeLable.frame = CGRectMake(63*Rate_NAV_W, size.height + 43*Rate_NAV_H, 47*Rate_NAV_W, 19*Rate_NAV_H);
    
    _timeLbale.text = model.startTime;
    _timeLbale.frame = CGRectMake(260*Rate_NAV_W, size.height + 43*Rate_NAV_H, 101*Rate_NAV_W, 19*Rate_NAV_H);
    
    _lineView.frame = CGRectMake(0, size.height + 72*Rate_NAV_H, SCREENWIDTH, 5*Rate_NAV_H);
    
    //获得当前cell高度
    CGRect frame = [self frame];
    //计算出自适应的高度
    frame.size.height = size.height + 77*Rate_NAV_H;
    self.frame = frame;
}

- (CGFloat)getCellHeight:(NSString *)text
{
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREENWIDTH - 30*Rate_NAV_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16*Rate_NAV_H]} context:nil].size;
    return size.height + 72*Rate_NAV_H + 5;
}

- (NSString *)getAgeWithBirth:(NSString *)birth
{
    //计算年龄
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //生日
    NSDate *birthDay = [dateFormatter dateFromString:birth];
    //当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
    NSLog(@"currentDate %@ birthDay %@",currentDateStr,birth);
    NSTimeInterval time=[currentDate timeIntervalSinceDate:birthDay];
    int age = ((int)time)/(3600*24*365);
    return [NSString stringWithFormat:@"%i",age];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
