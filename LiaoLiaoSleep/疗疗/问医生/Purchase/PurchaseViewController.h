//
//  PurchaseViewController.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseViewController : UIViewController

//@property(nonatomic) float totalPrice;
@property(copy, nonatomic) NSString * totalPrice;
@property(copy, nonatomic) NSString * count;
@property(copy, nonatomic) NSString * name;
@property(copy, nonatomic) NSString * patientID;

@end
