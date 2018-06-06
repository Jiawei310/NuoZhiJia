//
//  AutoSlider.m
//  Sleep4U
//
//  Created by 诺之家 on 16/5/19.
//  Copyright © 2016年 诺之家. All rights reserved.
//


#define SelectViewBgColor   [UIColor colorWithRed:9/255.0 green:170/255.0 blue:238/255.0 alpha:1]
#define DefaultViewBgColor  [UIColor lightGrayColor]

#define AutoSliderWidth      (self.bounds.size.width)
#define AutoSliderHight     (self.bounds.size.height)

#define CenterImage_W       AutoSliderWidth/13

#define AutoSliderLine_W    (AutoSliderWidth-CenterImage_W)
#define AutoSLiderLine_H    6.0
#define AutoSLiderLine_Y    ((AutoSliderHight-6.0)/2)

#define CenterImage_Y       (AutoSliderHight/2)

#import "AutoSlider.h"

@interface AutoSlider()
{
    
    CGFloat _pointX;        //
    NSInteger _sectionIndex;//当前选中的那个
    CGFloat _sectionLength; //根据数组分段后一段的长度
}

/**
 *  必传，范围（0到(array.count-1)）
 */
@property (nonatomic,assign)CGFloat defaultIndx;
/**
 *  必传，传入节点数组
 */
@property (nonatomic,strong)NSArray *titleArray;
/**
 *  传入图片
 */
@property (nonatomic,strong)UIImage *sliderImage;

@property (strong,nonatomic)UIView *selectView;
@property (strong,nonatomic)UIView *defaultView;
@property (strong,nonatomic)UIImageView *centerImage;

@end

@implementation AutoSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titleArray defaultIndex:(CGFloat)defaultIndex sliderImage:(UIImage *)sliderImage
{
    if (self  = [super initWithFrame:frame])
    {
        _pointX=0;
        _sectionIndex=0;
        
        self.backgroundColor=[UIColor clearColor];
        
        _defaultView=[[UIView alloc] initWithFrame:CGRectMake(CenterImage_W/2, AutoSLiderLine_Y, AutoSliderWidth-CenterImage_W, AutoSLiderLine_H)];
        _defaultView.backgroundColor=DefaultViewBgColor;
        _defaultView.layer.cornerRadius=AutoSLiderLine_H/2;
        _defaultView.userInteractionEnabled=NO;
        [self addSubview:_defaultView];
        
        _selectView=[[UIView alloc] initWithFrame:CGRectMake(CenterImage_W/2, AutoSLiderLine_Y, AutoSliderWidth-CenterImage_W, AutoSLiderLine_H)];
        _selectView.backgroundColor=SelectViewBgColor;
        _selectView.layer.cornerRadius=AutoSLiderLine_H/2;
        _selectView.userInteractionEnabled=NO;
        [self addSubview:_selectView];
        
        _centerImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CenterImage_W, CenterImage_W)];
        _centerImage.center=CGPointMake(0, CenterImage_Y);
        _centerImage.userInteractionEnabled=NO;
        [self addSubview:_centerImage];
        
        
        self.titleArray=titleArray;
        self.defaultIndx=defaultIndex;
        self.sliderImage=sliderImage;
    }
    return self;
}


-(void)setDefaultIndx:(CGFloat)defaultIndx
{
    CGFloat withPress=defaultIndx/_titleArray.count;
    //设置默认位置
    CGRect rect=[_selectView frame];
    rect.size.width = withPress*AutoSliderLine_W;
    _selectView.frame=rect;
    
    _pointX=withPress*AutoSliderLine_W;
    _sectionIndex=defaultIndx;
}

-(void)setLocationIndex:(CGFloat)locationIndex
{
    CGFloat withPress=locationIndex/_titleArray.count;
    //设置默认位置
    CGRect rect=[_selectView frame];
    rect.size.width = withPress*AutoSliderLine_W;
    _selectView.frame=rect;
    
    _pointX=withPress*AutoSliderLine_W;
    _sectionIndex=locationIndex;
    
    [self refreshSlider];
}

-(void)setTitleArray:(NSArray *)titleArray
{
    _titleArray=titleArray;
    _sectionLength=AutoSliderLine_W/titleArray.count;
}

-(void)setSliderImage:(UIImage *)sliderImage
{
    _centerImage.image=sliderImage;
    [self refreshSlider];
}


#pragma mark ---UIColor Touchu
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self changePointX:touch];
    if (self.block)
    {
        self.block((int)_sectionIndex);
    }
    [self refreshSlider];
}

-(void)changePointX:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    
    if (_pointX<=_sectionLength+CenterImage_W/2)
    {
        if (_pointX<point.x)
        {
            _pointX=_pointX+_sectionLength;
        }
        else if(_pointX>point.x)
        {
            _pointX=_sectionLength;
        }
    }
    else if (_pointX>=AutoSliderLine_W)
    {
        if (_pointX<=point.x)
        {
            _pointX=AutoSliderLine_W;
        }
        else if(_pointX>point.x)
        {
             _pointX=_pointX-_sectionLength;
        }
    }
    else
    {
        if (_pointX<point.x)
        {
            _pointX=_pointX+_sectionLength;
        }
        else if(_pointX>point.x)
        {
            _pointX=_pointX-_sectionLength;
        }
    }
    //四舍五入计算选择的节点
    _sectionIndex=(int)roundf(_pointX/_sectionLength);
}

-(void)refreshSlider
{
    _centerImage.center=CGPointMake(_pointX+CenterImage_W/2, CenterImage_Y);
    CGRect rect = [_selectView frame];
    rect.size.width=_pointX;
    _selectView.frame=rect;
}

@end
