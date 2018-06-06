//
//  ShowTreatmentView.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLine.h"

@interface ShowTreatmentView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollV;
@property (nonatomic, strong)  UIImageView *imageV;
@property (nonatomic, copy)        NSArray *imageList;
@property (nonatomic, strong)     TimeLine *timeLineV;

- (instancetype)initWithFrame:(CGRect)frame andImageList:(NSArray *)imageList andInfoList:(NSArray *)infoList;

@end
