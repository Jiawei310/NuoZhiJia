//
//  YBLoopBanner.h
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/8/15.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YBLoopBanner : UIView

// click action
@property (nonatomic, copy) void (^clickAction) (NSInteger curIndex) ;

// data source
@property (nonatomic, copy) NSArray *imageURLStrings;

- (instancetype)initWithFrame:(CGRect)frame scrollDuration:(NSTimeInterval)duration;

@end
