//
//  ChatTextTableViewCell.m
//  ChatDemo
//
//  Created by 甘伟 on 16/11/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "ChatTextTableViewCell.h"
#import "Define.h"
#import "Auxiliary.h"

@implementation ChatTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        //头像
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [_photoImageView.layer setCornerRadius:15.0];
        [_photoImageView.layer setMasksToBounds:YES];
        [self.contentView addSubview:_photoImageView];
        
        //背景图
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 5, SCREENWIDTH - 80, 30)];
        _backgroundImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_backgroundImageView];
        
        //文字内容框
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, _backgroundImageView.bounds.size.width-20, _backgroundImageView.bounds.size.height-20)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
        _contentLabel.userInteractionEnabled = YES;
        [_backgroundImageView addSubview:_contentLabel];
        
        //加载提示
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_backgroundImageView.frame)+5, CGRectGetMinY(_backgroundImageView.frame)+5, 15, 15)];
        _activity.hidden = YES;
        [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
        [self.contentView addSubview:_activity];
        
        //重新发送
        _repeatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_repeatBtn setBackgroundImage:[UIImage imageNamed:@"messageSendFail"] forState:UIControlStateNormal];
        [_repeatBtn addTarget:self action:@selector(RepeatBtn:) forControlEvents:UIControlEventTouchUpInside];
        _repeatBtn.hidden = YES;
        [self.contentView addSubview:_repeatBtn];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [_backgroundImageView addGestureRecognizer:tapRecognizer];
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    if(model.isSender)
    {
        //发送的消息
        [self setContentStrY];
    }
    else
    {
        //接收的消息
        [self setContentStrZ];
    }
}

- (void)setRecodeMessage:(RecordMessageModel *)record
{
    _record = record;
    if(record.isSender)
    {
        //发送的消息
        [self setRecordContentStrY];
    }
    else
    {
        //接收的消息
        [self setRecordContentStrZ];
    }
}

- (void)setContentStrZ
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(5, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_left_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    //计算文字所占空间大小
    CGSize size = [Auxiliary CalculationHeightWidth:_model.text andSize:15 andCGSize:CGSizeMake(SCREENWIDTH - 105, MAXFLOAT)];
    _backgroundImageView.frame = CGRectMake(40, 5, size.width + 25, size.height + 20);
    
    _contentLabel.frame = CGRectMake(15, 10, size.width, size.height);
    _contentLabel.text = _model.text;
    //cell自身的大小
    CGRect rect = self.frame;
    rect.size.height = size.height + 30;
    self.frame = rect;
}

- (void)setContentStrY
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(SCREENWIDTH - 35, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_right_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    CGSize size = [Auxiliary CalculationHeightWidth:_model.text andSize:15 andCGSize:CGSizeMake(SCREENWIDTH - 105, MAXFLOAT)];
    _backgroundImageView.frame = CGRectMake(SCREENWIDTH - size.width - 25 - 40, 5, size.width+25, size.height+20);
    if ([_model.askCount intValue] > 0)
    {
        CGSize countSize = [Auxiliary CalculationHeightWidth:[NSString stringWithFormat:@"追问(%@)",_model.askCount] andSize:12 andCGSize:CGSizeMake(SCREENWIDTH - 105, MAXFLOAT)];
        _askCountLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - countSize.width - 45, size.height+30, countSize.width, countSize.height)];
        _askCountLable.text = [NSString stringWithFormat:@"追问(%@)",_model.askCount];
        _askCountLable.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_askCountLable];
    }
    
    _contentLabel.frame = CGRectMake(10, 10, size.width, size.height);
    _contentLabel.text = _model.text;
    if(_model.isSender && (_model.message.status == 0 || _model.message.status == 1))
    {
        _repeatBtn.hidden = YES;
        _activity.hidden = NO;
        [_activity startAnimating];
        _activity.frame = CGRectMake(_backgroundImageView.frame.origin.x-20, _backgroundImageView.frame.origin.y+_backgroundImageView.frame.size.height/2-7.5, 15, 15);
    }
    else if(_model.isSender && _model.message.status == 3)
    {
        _repeatBtn.hidden = NO;
        _activity.hidden = YES;
        [_activity stopAnimating];
        _repeatBtn.frame = CGRectMake(_backgroundImageView.frame.origin.x-20, _backgroundImageView.frame.origin.y+_backgroundImageView.frame.size.height/2-7.5, 15, 15);
    }
    else
    {
        _repeatBtn.hidden = YES;
        _activity.hidden = YES;
        [_activity stopAnimating];
    }
    
    CGRect rect = self.frame;
    if ([_model.askCount intValue] > 0)
    {
        rect.size.height = CGRectGetMaxY(_askCountLable.frame) + 5;
    }
    else
    {
        rect.size.height = CGRectGetMaxY(_backgroundImageView.frame) + 5;
    }
    self.frame = rect;
}

- (void)setRecordContentStrZ
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(5, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_left_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    CGSize size = [self getCellHeight:_record.message];
    _backgroundImageView.frame = CGRectMake(40, 5, size.width+25, size.height+20);
    
    _contentLabel.frame = CGRectMake(15, 10, size.width, size.height);
    _contentLabel.text = _record.message;
    
    CGRect rect = self.frame;
    rect.size.height = size.height + 30;
    self.frame = rect;
}

- (void)setRecordContentStrY
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(SCREENWIDTH - 35, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_right_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    CGSize size = [self getCellHeight:_record.message];
    _backgroundImageView.frame = CGRectMake(SCREENWIDTH - size.width - 25 - 40, 5, size.width+25, size.height+20);
    
    _contentLabel.frame = CGRectMake(10, 10, size.width, size.height);
    _contentLabel.text = _record.message;
    
    CGRect rect = self.frame;
    rect.size.height = size.height + 30;
    self.frame = rect;
}

- (CGSize)getCellHeight:(NSString *)text
{
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREENWIDTH - 105, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
    return size;
}

- (void)bubbleViewTapAction:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (!_delegate)
        {
            return;
        }
        if ([_delegate respondsToSelector:@selector(messageTextCellSelected:)])
        {
            [_delegate messageTextCellSelected:_model];
        }
    }
}

- (void)RepeatBtn:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(statusButtonSelcted:withTextMessageCell:)])
    {
        [_delegate statusButtonSelcted:_model withTextMessageCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
