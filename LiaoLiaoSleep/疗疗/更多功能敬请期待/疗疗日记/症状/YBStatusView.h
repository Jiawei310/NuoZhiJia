//
//  YBStatusView.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/12/13.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YBStatusViewDelegate <NSObject>

- (void)statusViewSelectIndex:(NSInteger)index;

@end

@interface YBStatusView : UIView

@property (nonatomic,strong)NSMutableArray *buttonArray;
@property (nonatomic,assign) id <YBStatusViewDelegate>delegate;
//横线
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic, assign) NSInteger currentIndex;

//初始化方法
- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray;

@end
