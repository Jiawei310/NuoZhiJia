//
//  SquareCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SquareCell.h"
#import "Define.h"
#import "FunctionHelper.h"

#import "InterfaceModel.h"

#import "UIImageView+EMWebCache.h"

@implementation SquareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self customerView];
    }
    return self;
}

- (void)customerView
{
    _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(10*Rate_W, 10*Rate_H, 36*Rate_H, 36*Rate_H)];
    _headerView.layer.cornerRadius = 18*Rate_H;
    _headerView.clipsToBounds = YES;
    [self.contentView addSubview:_headerView];
    
    _nameLable = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, 10*Rate_H, 322*Rate_W, 18*Rate_H)];
    _nameLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _nameLable.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLable];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, 28*Rate_H, 322*Rate_W, 18*Rate_H)];
    _timeLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _timeLable.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_timeLable];
    
//    _topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(313*Rate_W, 10*Rate_H, 16*Rate_H, 16*Rate_H)];
//    _topImageView.image = [UIImage imageNamed:@"icon_top.png"];
//    _topImageView.hidden = YES;
//    [self.contentView addSubview:_topImageView];
    
//    UIButton *collecte = [[UIButton alloc] initWithFrame:CGRectMake(339*Rate_W, 10*Rate_H, 16*Rate_H, 16*Rate_H)];
//    [collecte setBackgroundImage:[UIImage imageNamed:@"icon_fine.png"] forState:(UIControlStateNormal)];
//    [self.contentView addSubview:collecte];
    
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_W, 56*Rate_H, 355*Rate_W, 25*Rate_H)];
    _titleLable.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    _titleLable.font = [UIFont systemFontOfSize:18];
    _titleLable.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_titleLable];
    
    _contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_W, 86*Rate_H, 355*Rate_W, 70*Rate_H)];
    _contentLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    _contentLable.font = [UIFont systemFontOfSize:14];
    _contentLable.numberOfLines = 0;
    [self.contentView addSubview:_contentLable];
}

- (void)setModel:(SquareModel *)model
{
    _model = model;
    //头像显示(EMSDWebImageRefreshCached不本地缓存，每次按URL读取图片)
    [_headerView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,model.HeaderImageUrl]] placeholderImage:[UIImage imageNamed:@""] options:EMSDWebImageRefreshCached];
    
    //发帖人昵称显示
    _nameLable.text = model.Name;
    CGSize nameSize = [model.Name boundingRectWithSize:CGSizeMake(322*Rate_W, 18*Rate_H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _nameLable.frame = CGRectMake(53*Rate_W, 10*Rate_H, nameSize.width, 18*Rate_H);
    
    //发帖时间显示
    _timeLable.text = model.Time;
    CGSize timeSize = [model.Time boundingRectWithSize:CGSizeMake(322*Rate_W, 18*Rate_H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    _timeLable.frame = CGRectMake(53*Rate_W, 27*Rate_H, timeSize.width, 18*Rate_H);
    
    //帖子类型 + Title显示
    _titleLable.text = [NSString stringWithFormat:@"【%@】%@",model.Type,model.Title];
    
    //帖子是否置顶
    if (model.IsTop)
    {
        _topImageView.hidden = NO;
    }
    
    //帖子文字内容显示
    NSString *content = [model.Content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *contentLableText;
    if (content.length >= 50)
    {
        contentLableText = [content substringWithRange:NSMakeRange(0, 50)];
    }
    else
    {
        contentLableText = content;
    }
    _contentLable.text = contentLableText;
    CGSize contentSize = [contentLableText boundingRectWithSize:CGSizeMake(355*Rate_W, 70*Rate_H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14*Rate_NAV_H]} context:nil].size;
    _contentLable.frame = CGRectMake(10*Rate_W, 86*Rate_H, 355*Rate_W, contentSize.height);
    
    //帖子内容中图片显示
    int imagCount = [model.ImageCount intValue];
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    if (imagCount == 0)
    {
        height = 0;
    }
    else if (imagCount >= 3)
    {
        width = (SCREENWIDTH - 34*Rate_W)/3;
        height = 80*Rate_H;
    }
    else if (imagCount == 2)
    {
        width = (SCREENWIDTH - 27*Rate_W)/2;
        height = 100*Rate_H;
    }
    else
    {
        width = SCREENWIDTH - 20*Rate_W;
        height = 150*Rate_H;
    }
    
    __block CGFloat imageV_x = 15.0f;
    for(int i = 0; i < [model.ImageCount intValue]; i++)
    {
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10*Rate_W + (width + 7*Rate_W) * (i%3), CGRectGetMaxY(_contentLable.frame) + 5*Rate_H + (height + 7*Rate_H) * (i/3), width, height)];
        imageV.userInteractionEnabled = YES;
        NSString * imageUrl;
        if (i == 0)
        {
            imageUrl = model.Image1;
        }
        else if (i == 1)
        {
            imageUrl = model.Image2;
        }
        else if (i == 2)
        {
            imageUrl = model.Image3;
        }
        else if (i == 3)
        {
            imageUrl = model.Image4;
        }
        else if (i == 4)
        {
            imageUrl = model.Image5;
        }
        else if (i == 5)
        {
            imageUrl = model.Image6;
        }
        [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,imageUrl]] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                NSLog(@"获取帖子图片失败！");
            }
            else
            {
//                imageV.image = [self cutImage:image andView:imageV];
                
                CGFloat scaleH = image.size.height/height;
                
                imageV.image = [FunctionHelper scaleImage:image toScale:scaleH];
                
                CGRect frame = imageV.frame;
                frame.size.width = frame.size.width / scaleH;
                frame.origin.x = imageV_x;
                imageV.frame = frame;
                
                imageV_x = imageV_x + frame.size.width;
            }
        }];
        
        [self.contentView addSubview:imageV];
    }
    
    //查看次数按钮
    UIButton *browser = [[UIButton alloc]initWithFrame:CGRectMake(21*Rate_W, CGRectGetMaxY(_contentLable.frame) + 15*Rate_H + height*(((imagCount - 1)/3) + 1) + 7*(imagCount/3), 20*Rate_H, 13*Rate_H)];
    [browser setBackgroundImage:[UIImage imageNamed:@"icon_browse.png"] forState:(UIControlStateNormal)];
    [self.contentView addSubview:browser];
    
    _browserLable = [[UILabel alloc]initWithFrame:CGRectMake(43*Rate_W, CGRectGetMinY(browser.frame), 30*Rate_W, 13*Rate_H)];
    _browserLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _browserLable.font = [UIFont systemFontOfSize:13*Rate_H];
    _browserLable.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_browserLable];
    
    //评论次数按钮
    UIButton *comment = [[UIButton alloc]initWithFrame:CGRectMake(170*Rate_W, CGRectGetMinY(browser.frame) - Rate_H, 15*Rate_H, 15*Rate_H)];
    [comment setBackgroundImage:[UIImage imageNamed:@"icon_message.png"] forState:(UIControlStateNormal)];
    [self.contentView addSubview:comment];
    
    _commentLable = [[UILabel alloc]initWithFrame:CGRectMake(190*Rate_W, CGRectGetMinY(browser.frame) - Rate_H, 30*Rate_W, 15*Rate_H)];
    _commentLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _commentLable.font = [UIFont systemFontOfSize:13*Rate_H];
    _contentLable.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_commentLable];
    
    //点赞次数按钮
    UIButton *favor = [[UIButton alloc]initWithFrame:CGRectMake(318*Rate_W, CGRectGetMinY(browser.frame) - Rate_H, 14*Rate_H, 15*Rate_H)];
    [favor setBackgroundImage:[UIImage imageNamed:@"icon_fabulous.png"] forState:(UIControlStateNormal)];
    [self.contentView addSubview:favor];
    
    _favorLable = [[UILabel alloc]initWithFrame:CGRectMake(337*Rate_W, CGRectGetMinY(browser.frame) - Rate_H, 30*Rate_W, 15*Rate_H)];
    _favorLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _favorLable.font = [UIFont systemFontOfSize:13*Rate_H];
    _favorLable.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_favorLable];
    _browserLable.text = model.BrowserCount;
    _favorLable.text = model.FavorCount;
    _commentLable.text = model.CommentCount;

    //获得当前cell高度
    CGRect frame = [self frame];
    //计算出自适应的高度
    frame.size.height = contentSize.height + 125*Rate_H + ((imagCount -1 )/3 + 1)*height + 7*((imagCount - 1)/3)*Rate_H;
    self.frame = frame;
}

- (void)enLargePicture:(UIButton *)btn
{
    NSMutableArray *networkImages = [NSMutableArray array];
    for (int i = 0; i < [_model.ImageCount  intValue]; i++)
    {
        NSString * photoURL;
        if (i == 0)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image1];
            [networkImages addObject:photoURL];
        }
        else if (btn.tag == 1)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image2];
            [networkImages addObject:photoURL];
        }
        else if (btn.tag == 2)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image3];
            [networkImages addObject:photoURL];
        }
        else if (btn.tag == 3)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image4];
            [networkImages addObject:photoURL];
        }
        else if (btn.tag == 4)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image5];
            [networkImages addObject:photoURL];
        }
        else if (btn.tag == 5)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image6];
            [networkImages addObject:photoURL];
        }
    }
}

- (void)chaImage:(UIButton *)btn
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.userInteractionEnabled = YES;
    [self.window addSubview:imageView];
    
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseImage:)];
    [imageView addGestureRecognizer:tapImageView];
    NSString * photoURL;
    if (btn.tag == 1)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image1];
    }
    else if (btn.tag == 2)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image2];
    }
    else if (btn.tag == 3)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image3];
    }
    else if (btn.tag == 4)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image4];
    }
    else if (btn.tag == 5)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image5];
    }
    else if (btn.tag == 6)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image6];
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:nil];
}

- (void)CloseImage:(UITapGestureRecognizer *)tap
{
    [tap.view removeFromSuperview];
}

//裁剪图片
- (UIImage *)cutImage:(UIImage*)image andView:(UIView *)myView
{
    CGSize newSize;
    CGImageRef imageRef = nil;
    
    if ((image.size.width / image.size.height) < myView.frame.size.width / myView.frame.size.height)
    {
        newSize.height = image.size.height;
        newSize.width = image.size.height * myView.frame.size.width / myView.frame.size.height;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, (image.size.height - myView.frame.size.height)/2, newSize.width, newSize.height));
    }
    else if ((image.size.width / image.size.height) >= myView.frame.size.width / myView.frame.size.height)
    {
        newSize.width = image.size.width;
        newSize.height = image.size.width * myView.frame.size.height / myView.frame.size.width;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake((image.size.width - myView.frame.size.width)/2, 0, newSize.width, newSize.height));
    }
    
    return [UIImage imageWithCGImage:imageRef];
}

//- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
//{
//    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
//    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
//    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//                                UIGraphicsEndImageContext();
//    return scaledImage;
//}
                                
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
