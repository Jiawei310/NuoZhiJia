//
//  ChatTextTableViewCell.h
//  ChatDemo
//
//  Created by 甘伟 on 16/11/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "RecordMessageModel.h"

@protocol ChatTextCellDelegate;

@interface ChatTextTableViewCell : UITableViewCell

@property (nonatomic, weak) id<ChatTextCellDelegate> delegate;

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *askCountLable;//追问次数
@property (nonatomic, strong) UILabel *contentLabel;//内容
@property (nonatomic, strong) UIActivityIndicatorView *activity; //进度显示
@property (nonatomic, strong) UIButton *repeatBtn;//重发按钮
@property (nonatomic, strong) MessageModel * model;//消息Model
@property (nonatomic, strong) RecordMessageModel * record;//消息Model
@property (nonatomic, copy) NSString * askCount;

-(void)setRecodeMessage:(RecordMessageModel *)record;

@end

@protocol ChatTextCellDelegate <NSObject>

@optional

- (void)messageTextCellSelected:(MessageModel *)model;

- (void)statusButtonSelcted:(MessageModel *)model
        withTextMessageCell:(ChatTextTableViewCell*)messageCell;

@end
