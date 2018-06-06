//
//  InstructionView.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "InstructionView.h"
#import "Define.h"
@implementation InstructionView

- (instancetype)initWithFrame:(CGRect)frame andImageList:(NSArray *)imageList andInfoList:(NSArray *)infoList
{
    if (self == [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0.21 green:0.76 blue:0.87 alpha:1.00];
        self.imageList = [[NSArray alloc]initWithArray:imageList];
        self.userInteractionEnabled = YES;
        [self customerViewWithFrame:frame andImageList:imageList andInfoList:infoList];
    }
    
    return self;
}

- (void)customerViewWithFrame:(CGRect)frame andImageList:(NSArray *)imageList andInfoList:(NSArray *)infoList
{
    self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-107*Ratio)/2, 10*Ratio, 107*Ratio, 182*Ratio)];
    _imageV.image = [UIImage imageNamed:imageList[0]];
    [self addSubview:_imageV];
    
    self.scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 147*Ratio, frame.size.width, 90)];
    self.scrollV.delegate = self;
    self.scrollV.scrollEnabled = YES;
    self.scrollV.pagingEnabled = NO;
    self.scrollV.showsHorizontalScrollIndicator = NO;
    self.scrollV.showsVerticalScrollIndicator = NO;
    self.scrollV.contentSize = CGSizeMake(15+15+8*(infoList.count-1)+(frame.size.width-30)*infoList.count, 90);
    for (int i = 0; i <infoList.count; i++)
    {
        UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(15+(frame.size.width-30+8)*i, 0, frame.size.width-30, 90)];
        bottomView.layer.cornerRadius = 5;
        bottomView.clipsToBounds = YES;
        bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bottomView.layer.borderWidth = 0.5;
        bottomView.backgroundColor = [UIColor whiteColor];
        [self.scrollV addSubview:bottomView];
        
        UIImageView * littleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        littleImage.image = [UIImage imageNamed:@"使用说明 icon.png"];
        [bottomView addSubview:littleImage];
        
        UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(littleImage.frame)+8, 10, bottomView.frame.size.width-38, 20)];
        lable.text = @"使用说明";
        lable.textColor = [UIColor cyanColor];
        lable.adjustsFontSizeToFitWidth = YES;
        [bottomView addSubview:lable];
        
        UILabel * index = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lable.frame)+10, 30, 30)];
        index.layer.cornerRadius = 15;
        index.layer.borderColor = [UIColor lightGrayColor].CGColor;
        index.layer.borderWidth = 0.5;
        index.text = [NSString stringWithFormat:@"%i",i+1];
        index.adjustsFontSizeToFitWidth = YES;
        index.textAlignment = NSTextAlignmentCenter;
        [bottomView addSubview:index];
        
        UILabel * content = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(index.frame)+8, CGRectGetMaxY(lable.frame), bottomView.frame.size.width-10-(CGRectGetMaxX(index.frame)+8), 45)];
        content.numberOfLines = 0;
        content.text = infoList[i];
        content.adjustsFontSizeToFitWidth = YES;
        [bottomView addSubview:content];
    }
    
    [self addSubview:self.scrollV];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end
