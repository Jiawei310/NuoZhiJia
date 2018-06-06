//
//  ChatImageTableViewCell.m
//  ChatDemo
//
//  Created by 甘伟 on 16/11/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "ChatImageTableViewCell.h"
#import "EaseMessageReadManager.h"
#import "Auxiliary.h"
#import "UIImageView+EMWebCache.h"
#import "Define.h"

@implementation ChatImageTableViewCell

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        //头像
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [_photoImageView.layer setCornerRadius:15.0];
        [_photoImageView.layer setMasksToBounds:YES];
        [self.contentView addSubview:_photoImageView];
        
        //背景图
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, SCREENWIDTH-50, 30)];
        _backgroundImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_backgroundImageView];
        
        //图片框
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, _backgroundImageView.frame.size.width-10, _backgroundImageView.frame.size.height-10)];
        _contentImageView.userInteractionEnabled = YES;
        [_backgroundImageView addSubview:_contentImageView];
        
        //加载
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_backgroundImageView.frame)+5, CGRectGetMinY(_backgroundImageView.frame)+5, 15, 15)];
        _activity.hidden = YES;
        [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
        [self.contentView addSubview:_activity];
        
        //重发按钮
        _repeatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_repeatBtn setBackgroundImage:[UIImage imageNamed:@"messageSendFail"] forState:UIControlStateNormal];
        [_repeatBtn addTarget:self action:@selector(RepeatBtn:) forControlEvents:UIControlEventTouchUpInside];
        _repeatBtn.hidden = YES;
        [self.contentView addSubview:_repeatBtn];
        
        UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(originalImage:)];
        [_contentImageView addGestureRecognizer:tapImageView];
    }
    
    return self;
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    if(model.isSender)
    {
        [self setImageStrY];
    }
    else
    {
        [self setImageStrZ];
    }
}

- (void)setRecodeMessage:(RecordMessageModel *)record
{
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(originalImage:)];
    [_contentImageView addGestureRecognizer:tapImageView];
    _record = record;
    if(record.isSender)
    {
        [self setRecordImageStrY];
    }
    else
    {
        [self setRecordImageStrZ];
    }
}

- (void)setImageStrZ
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(5, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_left_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    
    NSArray *ary = [self getImageScale:_model.imageSize];
    _backgroundImageView.frame = CGRectMake(40, 5, [ary[0] floatValue]+15, [ary[1] floatValue]+10);
    _contentImageView.frame = CGRectMake(10, 5, [ary[0] floatValue], [ary[1] floatValue]);
    [_contentImageView sd_setImageWithURL:[NSURL URLWithString:_model.fileURLPath] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    CGRect rect = self.frame;
    rect.size.height = [ary[1] floatValue] + 20;
    self.frame = rect;
}

- (void)setImageStrY
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(SCREENWIDTH - 35, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_right_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    NSArray *ary = [self getImageScale:_model.imageSize];
    
    _backgroundImageView.frame = CGRectMake(SCREENWIDTH - [ary[0] floatValue] - 15 - 40, 5, [ary[0] floatValue]+15, [ary[1] floatValue]+10);
    _contentImageView.frame = CGRectMake(5, 5, [ary[0] floatValue], [ary[1] floatValue]);
    _contentImageView.image = [UIImage imageWithContentsOfFile:_model.fileLocalPath];
    
    if ([_model.askCount intValue] > 0)
    {
        CGSize countSize = [Auxiliary CalculationHeightWidth:[NSString stringWithFormat:@"追问(%@)",_model.askCount] andSize:12 andCGSize:CGSizeMake(SCREENWIDTH - 105, MAXFLOAT)];
        _askCountLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - countSize.width - 45, [ary[1] floatValue]+20, countSize.width, countSize.height)];
        _askCountLable.text = [NSString stringWithFormat:@"追问(%@)",_model.askCount];
        _askCountLable.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_askCountLable];
    }
    
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

- (void)setRecordImageStrZ
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(5, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_left_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    
    NSArray *temp = [_record.size componentsSeparatedByString:@"_"];
    CGSize size = CGSizeMake([temp[0] floatValue], [temp[1] floatValue]);
    NSArray *ary = [self getImageScale:size];
    _backgroundImageView.frame = CGRectMake(40, 5, [ary[0] floatValue]+15, [ary[1] floatValue]+10);
    _contentImageView.frame = CGRectMake(10, 5, [ary[0] floatValue], [ary[1] floatValue]);
    NSString * photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_record.thumbnailImage];
    [_contentImageView sd_setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:nil];
    CGRect rect = self.frame;
    rect.size.height = [ary[1] floatValue] + 20;
    self.frame = rect;
}

- (void)setRecordImageStrY
{
    _photoImageView.image = _model.avatarImage;
    _photoImageView.frame = CGRectMake(SCREENWIDTH - 35, 5, 30, 30);
    
    UIImage *image = [UIImage imageNamed:@"balloon_right_blue.png"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    
    NSArray * temp = [_record.size componentsSeparatedByString:@"_"];
    CGSize size = CGSizeMake([temp[0] floatValue], [temp[1] floatValue]);
    NSArray *ary = [self getImageScale:size];
    
    _backgroundImageView.frame = CGRectMake(SCREENWIDTH - [ary[0] floatValue] - 15 - 40, 5, [ary[0] floatValue]+15, [ary[1] floatValue]+10);
    _contentImageView.frame = CGRectMake(5, 5, [ary[0] floatValue], [ary[1] floatValue]);
    NSString * photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_record.thumbnailImage];
    [_contentImageView sd_setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:nil];
    CGRect rect = self.frame;
    rect.size.height = [ary[1] floatValue] + 20;
    self.frame = rect;
}

- (NSArray *)getImageScale:(CGSize)size
{
    float Jchang;
    float Jkuan;
    if(size.width > 100 || size.height > 100)
    {
        if(size.width > size.height)
        {
            float bili = 100/size.width;
            Jkuan = size.height * bili;
            Jchang = 100;
        }
        else
        {
            float bili = 100/size.height;
            Jchang = size.width * bili;
            Jkuan = 100;
        }
    }
    else
    {
        Jchang = size.width;
        Jkuan = size.height;
    }
    NSString *JJchang = [NSString stringWithFormat:@"%f",Jchang];
    NSString *JJkuan = [NSString stringWithFormat:@"%f",Jkuan];
    NSArray *ary = [[NSArray alloc] initWithObjects:JJchang,JJkuan, nil];
    
    return ary;
}

- (void)originalImage:(UITapGestureRecognizer *)tap
{
    if (_model.isSender && _model.image)
    {
        [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[_model.image]];
    }
    else if (_model.fileURLPath)
    {
        UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_model.fileURLPath]]];
        if (image)
        {
            [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
        }
        else
        {
            UIAlertView * alterV = [[UIAlertView alloc]initWithTitle:@"出错" message:@"获取图片出错" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alterV show];
        }
    }
    else
    {
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_record.image]);
        UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_record.image]]]];
        if(image)
        {
            [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
        }
        else
        {
            UIAlertView * alterV = [[UIAlertView alloc]initWithTitle:@"出错" message:@"获取图片出错" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alterV show];
        }
    }
}

- (void)RepeatBtn:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(statusButtonSelcted:withImageMessageCell:)])
    {
        [_delegate statusButtonSelcted:_model withImageMessageCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
