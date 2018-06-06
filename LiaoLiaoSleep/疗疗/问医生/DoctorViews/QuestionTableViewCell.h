//
//  QuestionTableViewCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/1.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConsultQuestionModel.h"

@interface QuestionTableViewCell : UITableViewCell

@property (nonatomic, strong)     UILabel *contentLable;
@property (nonatomic, strong) UIImageView *iconV;
@property (nonatomic, strong)     UILabel *nameLable;
@property (nonatomic, strong)     UILabel *sexAgeLable;
@property (nonatomic, strong)     UILabel *timeLbale;
@property (nonatomic, strong)      UIView *lineView;
@property (nonatomic, copy)   ConsultQuestionModel * model;

- (CGFloat)getCellHeight:(NSString *)text;

@end
