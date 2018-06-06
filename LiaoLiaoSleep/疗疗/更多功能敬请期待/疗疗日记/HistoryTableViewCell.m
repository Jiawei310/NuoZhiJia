//
//  HistoryTableViewCell.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/1/15.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "HistoryTableViewCell.h"

@implementation HistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
