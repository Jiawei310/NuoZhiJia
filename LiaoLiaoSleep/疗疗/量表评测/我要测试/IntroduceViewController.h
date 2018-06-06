//
//  IntroduceViewController.h
//  Assessment
//
//  Created by 诺之家 on 16/10/20.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroduceViewController : UIViewController

@property (nonatomic,strong)  NSArray *questionArray;
@property (nonatomic, strong) NSString *typeFlag; //标志从哪里跳转（SucceedRegister表示从注册成功跳转过来，ScaleTest表示从量表评测界面的我要测试入口进入，Doctor表示从问医生跳转过来）
@property (nonatomic,strong) NSString *typeStr;//标识量表类型
@property (nonatomic,strong) NSString *introductionTextViewText;//对应量表的“简介”
@property (nonatomic,strong) NSString *whyDoTextViewText;//对应量表“我为什么要去做这个”

@end
