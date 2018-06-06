//
//  ChatTimeTableViewCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/28.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTimeTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *title;

@property (nonatomic) UIFont *titleLabelFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:12]

@property (nonatomic) UIColor *titleLabelColor UI_APPEARANCE_SELECTOR; //default [UIColor grayColor]

+ (NSString *)cellIdentifier;

@end
