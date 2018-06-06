//
//  InstructionView.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong)UIScrollView *scrollV;
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, copy)       NSArray *imageList;

- (instancetype)initWithFrame:(CGRect)frame andImageList:(NSArray *)imageList andInfoList:(NSArray *)infoList;

@end
