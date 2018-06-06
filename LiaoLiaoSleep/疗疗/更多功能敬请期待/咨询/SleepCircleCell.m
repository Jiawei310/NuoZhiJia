//
//  SleepCircleCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SleepCircleCell.h"
#import "EaseMessageReadManager.h"
#import "UIImageView+EMWebCache.h"
#import "Define.h"

#import "PostWebViewController.h"

@implementation SleepCircleCell
{
    UIView *mainView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
        [self customerView];
    }
    
    return self;
}

- (void)customerView
{
    mainView = [[UIView alloc] init];
    mainView.backgroundColor = [UIColor whiteColor];
    [self addSubview:mainView];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(14*Rate_NAV_W, 6*Rate_NAV_H, 120*Rate_NAV_W, 14*Rate_NAV_H)];
    _timeLable.textAlignment = NSTextAlignmentRight;
    _timeLable.textColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    _timeLable.font = [UIFont systemFontOfSize:14];
    _timeLable.adjustsFontSizeToFitWidth = YES;
    [mainView addSubview:_timeLable];
    
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(14*Rate_NAV_W, 24*Rate_NAV_H, 300*Rate_NAV_W, 18*Rate_NAV_H)];
    _titleLable.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    _titleLable.font = [UIFont systemFontOfSize:18];
    _titleLable.adjustsFontSizeToFitWidth = YES;
    [mainView addSubview:_titleLable];
    
    _pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(11*Rate_NAV_W, 52*Rate_NAV_H, 325*Rate_NAV_W, 165*Rate_NAV_H)];
    _pictureView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushVC:)];
    [_pictureView addGestureRecognizer:tapImageView];
    [mainView addSubview:_pictureView];
    
    _contentLable = [[UILabel alloc] initWithFrame:CGRectMake(11*Rate_NAV_W, 229*Rate_NAV_H, 325*Rate_NAV_W, 66*Rate_NAV_H)];
    _contentLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _contentLable.font = [UIFont systemFontOfSize:14];
    _contentLable.numberOfLines = 0;
    [mainView addSubview:_contentLable];
}

- (void)setModel:(SleepCircleModel *)model
{
    _model = model;
    _titleLable.text = model.Title;
    _timeLable.text = model.Time;
    _pictureView.image = [self cutImage:[UIImage imageNamed:model.ImageName] andView:_pictureView];
    _contentLable.text = model.Content;
    CGSize titleSize = [model.Content boundingRectWithSize:CGSizeMake(325*Rate_NAV_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _contentLable.frame = CGRectMake(11*Rate_NAV_W, 229*Rate_NAV_H, 325*Rate_NAV_W, titleSize.height);
    _favorLable.text = model.FavorCount;
    _commentLable.text = model.CommentCount;
    
    //获得当前cell高度
    CGRect frame = [self frame];
    //计算出自适应的高度
    frame.size.height = titleSize.height + 260*Rate_NAV_H;
    self.frame = frame;
    
    CGRect viewFrame = [self frame];
    viewFrame.size.height = titleSize.height + 250*Rate_NAV_H;
    mainView.frame = CGRectMake(14*Rate_NAV_W, 5*Rate_NAV_H, 347*Rate_NAV_W, viewFrame.size.height);
    mainView.layer.cornerRadius = 5.0;
}

#pragma mark --- _pictureView点击触发的方法，完成跳转
- (void)pushVC:(UITapGestureRecognizer *)gesture
{
    NSNotification *notification = [[NSNotification alloc] initWithName:@"pushToPostWebVC" object:nil userInfo:@{@"modelURL":_model.PostUrl}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

/* 图片片处理的两种方式 */
//压缩图片
- (UIImage *)image:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
//裁剪图片
- (UIImage *)cutImage:(UIImage*)image andView:(UIView *)myView
{
    CGSize newSize;
    CGImageRef imageRef = nil;
    
    if ((image.size.width / image.size.height) < (myView.frame.size.width / myView.frame.size.height))
    {
        newSize.width = image.size.width;
        newSize.height = image.size.width * myView.frame.size.height / myView.frame.size.width;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, newSize.width, newSize.height));
    }
    else
    {
        newSize.height = image.size.height;
        newSize.width = image.size.height * myView.frame.size.width / myView.frame.size.height;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, newSize.width, newSize.height));
    }
    
    return [UIImage imageWithCGImage:imageRef];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
