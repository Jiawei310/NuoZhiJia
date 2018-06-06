//
//  YBPlot.h
//  ChartDemo
//
//  Created by 诺之家 on 16/11/15.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YBPlot : NSObject

@property (nonatomic, strong) NSArray *plottingXValues;     //点的x轴值
@property (nonatomic, strong) NSArray *plottingYValues;     //点的y轴值
@property (nonatomic, strong) NSArray *plottingPointsLabels;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) float lineWidth;

@end
