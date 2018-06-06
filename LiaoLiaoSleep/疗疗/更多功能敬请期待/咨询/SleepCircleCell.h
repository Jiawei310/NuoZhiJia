//
//  SleepCircleCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SleepCircleModel.h"

@interface SleepCircleCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLable;
@property (strong, nonatomic) UILabel *timeLable;
@property (strong, nonatomic) UIImageView *pictureView;
@property (strong, nonatomic) UILabel *contentLable;
@property (strong, nonatomic) UILabel *favorLable;
@property (strong, nonatomic) UILabel *commentLable;

@property (copy, nonatomic) SleepCircleModel *model;

@end
