//
//  SquareCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SquareModel.h"
#import "Define.h"

@interface SquareCell : UITableViewCell

@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic)     UILabel *nameLable;
@property (strong, nonatomic)     UILabel *timeLable;
@property (strong, nonatomic)     UILabel *titleLable;
@property (strong, nonatomic)     UILabel *contentLable;
@property (strong, nonatomic)     UILabel *browserLable;
@property (strong, nonatomic)     UILabel *favorLable;
@property (strong, nonatomic)     UILabel *commentLable;
@property (strong, nonatomic) UIImageView *topImageView;
@property (copy, nonatomic)      NSString *chooseImage;

@property (copy, nonatomic) SquareModel *model;

@end
