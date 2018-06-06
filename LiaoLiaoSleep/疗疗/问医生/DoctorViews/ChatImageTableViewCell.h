//
//  ChatImageTableViewCell.h
//  ChatDemo
//
//  Created by 甘伟 on 16/11/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "RecordMessageModel.h"

@protocol ChatImageCellDelegate;
@interface ChatImageTableViewCell : UITableViewCell

@property (weak, nonatomic) id<ChatImageCellDelegate> delegate;

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *askCountLable;//追问次数
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) UIButton *repeatBtn;
@property (nonatomic, copy) MessageModel * model;//消息Model
@property (nonatomic, copy) RecordMessageModel * record;//消息Model

-(void)setRecodeMessage:(RecordMessageModel *)record;

@end

@protocol ChatImageCellDelegate <NSObject>

@optional

- (void)messageImageCellSelected:(MessageModel *)model;

- (void)statusButtonSelcted:(MessageModel *)model
       withImageMessageCell:(ChatImageTableViewCell*)messageCell;

@end
