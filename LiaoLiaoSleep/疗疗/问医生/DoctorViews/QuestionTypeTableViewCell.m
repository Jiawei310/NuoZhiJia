//
//  QuestionTypeTableViewCell.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/6/7.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "QuestionTypeTableViewCell.h"

@interface QuestionTypeTableViewCell()

@property (nonatomic, strong) UIImageView *typeImageView;
@property (nonatomic, strong)     UILabel *typeLabel;
@property (nonatomic, strong)     UILabel *typeIntroduceLabel;

@end

@implementation QuestionTypeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        //获得当前cell高度
        CGRect frame = [self frame];
        //计算出自适应的高度
        frame.size.height = 151*Rate_NAV_H;
        self.frame = frame;
        [self createContentView];
    }
    return self;
}

- (void)createContentView
{
    _typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 30*Rate_NAV_H, 60*Rate_NAV_H, 60*Rate_NAV_H)];
    [self.contentView addSubview:_typeImageView];
    
    _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 91*Rate_NAV_H, 60*Rate_NAV_H, 30*Rate_NAV_H)];
    _typeLabel.textAlignment = NSTextAlignmentCenter;
    _typeLabel.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    _typeLabel.numberOfLines = 0;
    [self.contentView addSubview:_typeLabel];
    
    _typeIntroduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W + 60*Rate_NAV_H, 60*Rate_NAV_H, SCREENWIDTH - 30*Rate_NAV_W - 60*Rate_NAV_H, 43*Rate_NAV_H)];
    _typeIntroduceLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    _typeIntroduceLabel.numberOfLines = 0;
    [self.contentView addSubview:_typeIntroduceLabel];
}

- (void)setModel:(QuestionTypeModel *)model
{
    _model = model;
    
    [_typeImageView setImage:[UIImage imageNamed:model.typeImageName]];
    _typeLabel.text = model.typeStr;
    _typeIntroduceLabel.text = model.typeIntroduceStr;
    CGSize contentSize = [model.typeIntroduceStr boundingRectWithSize:CGSizeMake(SCREENWIDTH - 30*Rate_NAV_W - 60*Rate_NAV_H, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14*Rate_NAV_H]} context:nil].size;
    _typeIntroduceLabel.frame = CGRectMake(20*Rate_NAV_W + 60*Rate_NAV_H, 65*Rate_NAV_H, SCREENWIDTH - 30*Rate_NAV_W - 60*Rate_NAV_H, contentSize.height);
}

@end
