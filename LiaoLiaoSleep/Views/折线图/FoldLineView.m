//
//  FoldLineView.m
//  ChartDemo
//
//  Created by 诺之家 on 16/11/15.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "FoldLineView.h"
#import "YBPlot.h"
#import <math.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark -
#pragma mark MACRO

#define POINT_CIRCLE  5.0f              //圆点大小

#define NUMBER_VERTICAL_ELEMENTS (7)    //折线图有几行
//#define HORIZONTAL_LINE_SPACES (30)     //虚线之间的行高
#define HORIZONTAL_LINE_SPACES ((self.frame.size.height - 42 - AXIS_BOTTOM_LINE_HEIGHT)/6)     //虚线之间的行高
#define HORIZONTAL_LINE_HEIGHT (1)       //水平虚线的高度
#define POINTER_WIDTH_INTERVAL  ((self.frame.size.width - AXIS_LEFT_LINE_WIDTH*2)/3)    //两个点之间间隔
#define AXIS_FONT_SIZE    (12)          //x，y轴上的字体大小

#define AXIS_BOTTOM_LINE_HEIGHT (30)    //距离FoldLineView底部的距离
#define AXIS_LEFT_LINE_WIDTH (25)       //距离FoldLineView左侧的距离

#define FLOAT_NUMBER_FORMATTER_STRING  @"%.0f"

#define DEVICE_WIDTH   (320)

#define AXIX_LINE_WIDTH (1)            //x、y轴线的粗细

@interface FoldLineView()

@property (nonatomic, strong) NSString* fontName;     //字体名称
@property (nonatomic, assign) CGPoint contentScroll;
@property (nonatomic, assign) CGPoint touchBegainLocation;//开始触摸时的点位置
@property (nonatomic, assign) CGPoint touchEndLocation;//结束触摸时的点位置

@end

@implementation FoldLineView

#pragma mark -
#pragma mark init

-(void)commonInitWithFrame:(CGRect)frame
{
    self.fontName = @"Helvetica";
    self.numberOfDashLines = NUMBER_VERTICAL_ELEMENTS;
    self.axisFontColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    self.axisFontSize = AXIS_FONT_SIZE;
    self.horizontalLinesColor = [UIColor lightGrayColor];
    
    self.horizontalLineInterval = HORIZONTAL_LINE_SPACES;
//    self.verticalLineInterval = POINTER_WIDTH_INTERVAL;
    self.horizontalLineHeight = HORIZONTAL_LINE_HEIGHT;
    
    self.verticalLineInterval = POINTER_WIDTH_INTERVAL;
    
    self.axisBottomLinetHeight = AXIS_BOTTOM_LINE_HEIGHT;
    self.axisLeftLineWidth = AXIS_LEFT_LINE_WIDTH;
    self.axisLineWidth = AXIX_LINE_WIDTH;
    
    self.floatNumberFormatterString = FLOAT_NUMBER_FORMATTER_STRING;
    
    UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    labelOne.font = [UIFont systemFontOfSize:12];
    labelOne.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    labelOne.numberOfLines = 0;
    labelOne.text = @"障碍指数";
    [self addSubview:labelOne];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInitWithFrame:frame];
    }
    return self;
}

#pragma mark -
#pragma mark Plots

- (void)addPlot:(YBPlot *)newPlot;
{
    if(nil == newPlot)
    {
        return;
    }
    
    if (newPlot.plottingYValues.count == 0)
    {
        return;
    }
    
    
    if(self.plots == nil)
    {
        _plots = [NSMutableArray array];
    }
    
    [self.plots addObject:newPlot];
    
    [self layoutIfNeeded];
}

-(void)clearPlot
{
    if (self.plots)
    {
        [self.plots removeAllObjects];
    }
}

#pragma mark -
#pragma mark Draw the lineChart

-(void)drawRect:(CGRect)rect
{
    CGFloat startHeight = self.axisBottomLinetHeight;
    CGFloat startWidth = self.axisLeftLineWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f , self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    // set text size and font
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextSelectFont(context, [self.fontName UTF8String], self.axisFontSize, kCGEncodingMacRoman);
    
    CGContextAddRect(context, CGRectMake(39, 30, POINTER_WIDTH_INTERVAL, HORIZONTAL_LINE_SPACES*6));
    [[UIColor colorWithRed:0xF4/255.0 green:0xFD/255.0 blue:0xFF/255.0 alpha:1] set];
    CGContextFillPath(context);
    CGContextAddRect(context, CGRectMake(39+POINTER_WIDTH_INTERVAL, 30, POINTER_WIDTH_INTERVAL, HORIZONTAL_LINE_SPACES*6));
    [[UIColor colorWithRed:0xE4/255.0 green:0xFB/255.0 blue:0xFF/255.0 alpha:1] set];
    CGContextFillPath(context);
    CGContextAddRect(context, CGRectMake(39+2*POINTER_WIDTH_INTERVAL, 30, POINTER_WIDTH_INTERVAL, HORIZONTAL_LINE_SPACES*6));
    [[UIColor colorWithRed:0xCD/255.0 green:0xF7/255.0 blue:0xFF/255.0 alpha:1] set];
    CGContextFillPath(context);
    
    // draw lines
    for (int i=0; i<self.plots.count; i++)
    {
        YBPlot* plot = [self.plots objectAtIndex:i];
        
        [plot.lineColor set];
        CGContextSetLineWidth(context, plot.lineWidth);
        
        
        NSArray* pointYArray = plot.plottingYValues;
        NSArray* pointXArray = plot.plottingXValues;
        
        // draw lines
        for (int i=0; i<pointYArray.count; i++)
        {
            NSNumber* valueY = [pointYArray objectAtIndex:i];
            NSNumber* valueX = [pointXArray objectAtIndex:i];
            
            float floatYValue = valueY.floatValue;
            
            NSDateFormatter *df = [[NSDateFormatter alloc]init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            
            NSDate *dateFirst = [[NSDate alloc] init];
            dateFirst = [df dateFromString:[NSString stringWithFormat:@"%d",(int)valueX.intValue]];
            NSDate *dateSecond = [[NSDate alloc] init];
            dateSecond =[df dateFromString:[NSString stringWithFormat:@"%d",(int)self.x_min]];
            
            NSTimeInterval intervalFirst = [dateFirst timeIntervalSince1970];
            int daySeconds = 24 * 60 * 60;
            NSInteger theDaysFirst = intervalFirst / daySeconds;
            NSTimeInterval intervalSecond = [dateSecond timeIntervalSince1970];
            NSInteger theDaysSecond = intervalSecond / daySeconds;
            
            float height = (floatYValue - self.y_min)/self.y_interval*self.horizontalLineInterval-self.contentScroll.y + startHeight;
            float width = (theDaysFirst - theDaysSecond)/self.x_interval*self.verticalLineInterval + self.contentScroll.x + startWidth;
            
            if (width < startWidth)
            {
                NSNumber *nextValue;
                if (i == pointYArray.count -1)
                {
                    nextValue = [pointYArray objectAtIndex:i];
                }
                else
                {
                    nextValue = [pointYArray objectAtIndex:i+1];
                }
                float nextFloatValue = nextValue.floatValue;
                float nextHeight = (nextFloatValue-self.y_min)/self.y_interval*self.horizontalLineInterval+startHeight;
                
                CGContextMoveToPoint(context, startWidth, nextHeight);
                
                continue;
            }
            
            if (i==0)
            {
                CGContextMoveToPoint(context,  width, height);
            }
            else
            {
                CGContextAddLineToPoint(context, width, height);
            }
        }
        
        CGContextStrokePath(context);
        
        
        // 画数据圆点
        for (int i = 0; i<pointYArray.count; i++)
        {
            NSNumber* valueY = [pointYArray objectAtIndex:i];
            NSNumber* valueX = [pointXArray objectAtIndex:i];
            
            float floatYValue = valueY.floatValue;
            
            NSDateFormatter*df = [[NSDateFormatter alloc]init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            
            NSDate *dateFirst = [[NSDate alloc]init];
            dateFirst =[df dateFromString:[NSString stringWithFormat:@"%d",(int)valueX.intValue]];
            NSDate *dateSecond = [[NSDate alloc]init];
            dateSecond =[df dateFromString:[NSString stringWithFormat:@"%d",(int)self.x_min]];
            
            NSTimeInterval intervalFirst = [dateFirst timeIntervalSince1970];
            int daySeconds = 24 * 60 * 60;
            NSInteger theDaysFirst = intervalFirst / daySeconds;
            NSTimeInterval intervalSecond = [dateSecond timeIntervalSince1970];
            NSInteger theDaysSecond = intervalSecond / daySeconds;
            
            float height = (floatYValue - self.y_min)/self.y_interval*self.horizontalLineInterval - self.contentScroll.y+startHeight;
            float width = (theDaysFirst - theDaysSecond)/self.x_interval*self.verticalLineInterval + self.contentScroll.x + startWidth;
            
            if (width >= startWidth)
            {
                CGContextFillEllipseInRect(context, CGRectMake(width-POINT_CIRCLE/2, height-POINT_CIRCLE/2, POINT_CIRCLE, POINT_CIRCLE));
            }
        }
        CGContextStrokePath(context);
    }
    
    [self.axisFontColor set];
    CGContextSetLineWidth(context, self.axisLineWidth);
    CGContextMoveToPoint(context, startWidth, startHeight);
    
    CGContextAddLineToPoint(context, startWidth, self.bounds.size.height - 32);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, startWidth, startHeight);
    CGContextAddLineToPoint(context, self.bounds.size.width, startHeight);
    CGContextStrokePath(context);
    
    // x axis text
    for (int i = 0; i< self.xAxisValues.count; i++)
    {
        float width = self.verticalLineInterval*i + startWidth;//( + self.contentScroll.x)
        float height = self.axisFontSize;
        
        //画x轴垂直实线
        CGContextMoveToPoint(context, width, startHeight);
        CGContextAddLineToPoint(context, width , self.frame.size.height - 32);
        CGContextStrokePath(context);
        
        if (width + self.contentScroll.x < startWidth)
        {
            continue;
        }
        //x轴上字体显示
        NSString *dateStr = [self.xAxisValues objectAtIndex:i];
        NSString *str_1 = [dateStr substringWithRange:NSMakeRange(4, 2)];
        NSString *str_2 = [dateStr substringWithRange:NSMakeRange(6, 2)];
        NSString *str = [NSString stringWithFormat:@"%@.%@",str_1,str_2];
        NSInteger count = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        CGContextShowTextAtPoint(context, width - 15 + self.contentScroll.x, height, [str UTF8String], count);
    }
    
    //画y轴水平虚线
    for (int i = 0; i < self.numberOfDashLines; i++)
    {
        int height = self.horizontalLineInterval*i;
        float verticalLine = height + startHeight - self.contentScroll.y;
        
        CGContextSetLineWidth(context, self.horizontalLineHeight);
        
        [self.horizontalLinesColor set];
        
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, self.horizontalLineHeight);//水平虚线高度
        CGFloat lengths[] = {4, 2};//先画4个点再画2个点
        CGContextSetLineDash(context, 0, lengths,2);//注意2(count)的值等于lengths数组的长度
        CGContextMoveToPoint(context, startWidth, verticalLine);
        CGContextAddLineToPoint(context, self.bounds.size.width, verticalLine);
        CGContextStrokePath(context);
        
        //y轴上字体显示
        NSNumber* yAxisVlue = [self.yAxisValues objectAtIndex:i];
        NSString* numberString = [NSString stringWithFormat:self.floatNumberFormatterString, yAxisVlue.floatValue];
        NSInteger count = [numberString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        CGContextShowTextAtPoint(context, 10, verticalLine - self.axisFontSize/2, [numberString UTF8String], count);
    }
    
}

#pragma mark -
#pragma mark touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"触摸开始");
//    _touchBegainLocation = [[touches anyObject] locationInView:self];
//    NSLog(@"touchLocation_x:%f,touchLocation_y:%f",_touchBegainLocation.x,_touchBegainLocation.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"触摸结束");
//    _touchEndLocation = [[touches anyObject] locationInView:self];
//    NSLog(@"touchLocation_x:%f,touchLocation_y:%f",_touchEndLocation.x,_touchEndLocation.y);
//    float xDiffrance=_touchBegainLocation.x - _touchEndLocation.x;
//    float yDiffrance=_touchBegainLocation.y - _touchEndLocation.y;
//    
//    if (xDiffrance < 0)
//    {
//        _contentScroll.x += POINTER_WIDTH_INTERVAL;
//    }
//    else if (xDiffrance > 0)
//    {
//        _contentScroll.x -= POINTER_WIDTH_INTERVAL;
//    }
//    _contentScroll.y+=yDiffrance;
//    
//    if (_contentScroll.x > 0)
//    {
//        _contentScroll.x = 0;
//    }
//    
//    if (_contentScroll.y < 0)
//    {
//        _contentScroll.y = 0;
//    }
//    
//    if (_contentScroll.y > self.frame.size.height/2)
//    {
//        _contentScroll.y = self.frame.size.height/2;
//    }
//    
//    
//    _contentScroll.y =0;// close the move up
//    
//    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation=[[touches anyObject] locationInView:self];
    CGPoint previouseLocation=[[touches anyObject] previousLocationInView:self];
    float xDiffrance=touchLocation.x-previouseLocation.x;
    float yDiffrance=touchLocation.y-previouseLocation.y;
    
    _contentScroll.x+=xDiffrance;
    _contentScroll.y+=yDiffrance;
    NSLog(@"%f--%f",_contentScroll.x,POINTER_WIDTH_INTERVAL);
    
    if (_contentScroll.x >0)
    {
        _contentScroll.x=0;
    }
    
    if (_contentScroll.y<0)
    {
        _contentScroll.y=0;
    }
    
    if (-_contentScroll.x>(self.verticalLineInterval*(self.xAxisValues.count +3)-DEVICE_WIDTH))
    {
        _contentScroll.x=-(self.verticalLineInterval*(self.xAxisValues.count +3)-DEVICE_WIDTH);
    }
    
    if (_contentScroll.y>self.frame.size.height/2)
    {
        _contentScroll.y=self.frame.size.height/2;
    }
    
    
    _contentScroll.y =0;// close the move up
    
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
