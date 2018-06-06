//
//  ModelView.h
//  TestProject
//
//  Created by 甘伟 on 16/10/20.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ModelValue)(NSString *modelSelectTitle);

@interface ModelView : UIView

@property (nonatomic, strong)UIVisualEffectView *modelView;//模式选择界面
@property (nonatomic, strong)          UIButton *btnNormal;
@property (nonatomic, strong)          UIButton *btnStimulate;
@property (nonatomic, strong)          UIButton *btnStrength;
@property (nonatomic, strong)           UILabel *contentNormal;
@property (nonatomic, strong)           UILabel *contentStimulate;
@property (nonatomic, strong)           UILabel *contentStrength;
@property (nonatomic, strong)           UILabel *titleLable;
@property (nonatomic, strong)           UILabel *infoLable;

@property (nonatomic, copy) ModelValue modelBlock;


- (instancetype)initWithFrame:(CGRect)frame ModelTitle:(NSString *)titleLableText;

- (void)sendModelValue:(ModelValue)modelBlock;

@end
