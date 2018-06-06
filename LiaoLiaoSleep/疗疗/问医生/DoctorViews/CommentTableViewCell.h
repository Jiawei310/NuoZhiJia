//
//  CommentTableViewCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"
@interface CommentTableViewCell : UITableViewCell


@property(nonatomic,strong)UIImageView * headerImage;
@property(nonatomic,strong)UILabel * nameLable;
@property(nonatomic,strong)UILabel * timeLbale;
@property(nonatomic,strong)UILabel * contentLable;
@property(nonatomic,copy)CommentModel * model;
-(CGFloat)getCellHeight:(NSString *)text;

@end
