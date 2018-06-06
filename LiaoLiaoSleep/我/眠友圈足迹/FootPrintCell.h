//
//  FootPrintCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/15.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FootPrintModel.h"

@interface FootPrintCell : UITableViewCell

@property (nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong)     UILabel *nameLabel;
@property (nonatomic, strong)     UILabel *timeLable;
@property (nonatomic, strong)     UILabel *contentLable;
@property (nonatomic, strong)      UIView *replayPoint;

@property (nonatomic, copy) FootPrintModel *model;

@end
