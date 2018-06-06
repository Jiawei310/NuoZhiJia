//
//  PayResultViewController.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayResultViewController : UIViewController

@property(copy, nonatomic) NSString * patientID;
@property(copy, nonatomic) NSString * orderResult;
@property(copy, nonatomic) NSString * orderState;
@property(copy, nonatomic) NSString * orderName;
@property(copy, nonatomic) NSString * orderCount;
@property(copy, nonatomic) NSString * orderID;
@property(copy, nonatomic) NSString * orderPrice;
@property(nonatomic) float totalPrice;

@end
