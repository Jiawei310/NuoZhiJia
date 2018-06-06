//
//  SetTreamentView.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/23.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetTreamentView : UIView<UIScrollViewDelegate>

@property(nonatomic, strong)    UIScrollView *scrollV;
@property(nonatomic, copy)           NSArray *imageList;
@property(nonatomic, strong)UIViewController *superVC;

- (instancetype)initWithFrame:(CGRect)frame andInfoList:(NSArray *)infoList;

@end
