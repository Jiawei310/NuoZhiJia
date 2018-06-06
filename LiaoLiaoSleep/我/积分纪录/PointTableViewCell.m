//
//  PointTableViewCell.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/8/24.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "PointTableViewCell.h"

@interface PointTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointLabel;

@end

@implementation PointTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setPModel:(PointModel *)pModel
{
    _pModel = pModel;
    
    _typeLabel.text = _pModel.type;
    _dateLabel.text = _pModel.date;
    _pointLabel.text = [NSString stringWithFormat:@"+%@",_pModel.point];
}

@end
