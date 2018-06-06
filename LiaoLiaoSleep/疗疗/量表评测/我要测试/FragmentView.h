//
//  FragmentView.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/11.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnswerSelect)(NSString *selectStr);

@interface FragmentView : UIView

@property (nonatomic, copy) AnswerSelect answerSelect;

- (instancetype)initWithQuestion:(NSString *)questionText Selected:(NSString *)selectedString;

- (void)sendSelectValue:(AnswerSelect)answerSelect;

@end
