//
//  PostCommentCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/12.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCommentModel.h"

@interface PostCommentCell : UITableViewCell

@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic) UILabel *nameLable;
@property (strong, nonatomic) UILabel *timeLable;
@property (strong, nonatomic) UILabel *contentLable;
@property (strong, nonatomic) UILabel *favorLable;
@property (strong, nonatomic) UILabel *commentLable;

@property(copy, nonatomic) PostCommentModel *model;

@end
