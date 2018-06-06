//
//  FoldLineView.h
//  ChartDemo
//
//  Created by 诺之家 on 16/11/15.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YBPlot;

@interface FoldLineView : UIView

@property (nonatomic, assign) NSInteger axisFontSize;            //x、y轴字体大小
@property (nonatomic, strong)   UIColor *axisFontColor;          //x、y轴字体颜色

@property (nonatomic, strong)   NSArray *xAxisValues;             //x轴数据数组
@property (nonatomic, assign) NSInteger numberOfVerticalLines;        //折线图上有虚线的条数
@property (nonatomic, assign) float  x_max; // x轴上的最大值
@property (nonatomic, assign) float  x_min; // x轴上的最小值
@property (nonatomic, assign) float  x_interval; // x轴上每条垂直线之间的距离


@property (nonatomic, strong) UIColor * horizontalLinesColor;     //水平线颜色




@property (nonatomic, assign) float  pointerInterval; // the x interval width between pointers

@property (nonatomic, assign) float  axisLineWidth; // x、y轴线的宽度
@property (nonatomic, assign) float  horizontalLineInterval; // 水平虚线之间的距离
@property (nonatomic, assign) float  verticalLineInterval; // 垂直线之间的距离
@property (nonatomic, assign) float  horizontalLineHeight; //水平虚线的高度
@property (nonatomic, assign) float  axisBottomLinetHeight;  //x轴到视图地步的距离
@property (nonatomic, assign) float  axisLeftLineWidth;   //y轴到视图左侧的距离

@property (nonatomic, strong) NSString *floatNumberFormatterString; // the yAxis label text should be formatted with


@property (nonatomic, strong)   NSArray *yAxisValues; // y轴数据数组
@property (nonatomic, assign) NSInteger numberOfDashLines;        //折线图上有虚线的条数

@property (nonatomic, assign) float  y_max; // y轴上的最大值
@property (nonatomic, assign) float  y_min; // y轴上的最小值
@property (nonatomic, assign) float  y_interval; // y轴上每条垂直线之间的距离

/**
 *  readyonly dictionary that stores all the plots in the graph.
 */
@property (nonatomic, readonly, strong) NSMutableArray *plots;



/**
 *  this method will add a Plot to the graph.
 *
 *  @param newPlot the Plot that you want to draw on the Graph.
 */
- (void)addPlot:(YBPlot *)newPlot;

@end
