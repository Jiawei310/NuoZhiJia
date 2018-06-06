//
//  GaugeTestViewController.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/10.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GaugeTestViewController : UIViewController

@property (nonatomic, strong) NSString *typeFlag; //标志从哪里跳转（SucceedRegister表示从注册成功跳转过来，ScaleTest表示从量表评测界面的我要测试入口进入，Doctor表示从问医生跳转过来）
@property (nonatomic, strong) NSString *typeStr;
@property (nonatomic, strong)  NSArray *questionArray;

@end
