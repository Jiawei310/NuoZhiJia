//
//  TimeLine.h
//  TestProject
//
//  Created by 甘伟 on 16/10/19.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLine : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollV;

- (instancetype)initWithFrame:(CGRect)frame andData:(NSArray *)dataSource;

@end
