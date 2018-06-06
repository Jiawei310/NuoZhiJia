//
//  PhotoAndNicknameViewController.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/23.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReturnInfoBlock)(PatientInfo *_tempInfo);

@interface PhotoAndNicknameViewController : UIViewController

@property (nonatomic, copy) ReturnInfoBlock returnInfoBlock;

- (void)returnInfoBlock:(ReturnInfoBlock)myBlock;

@end
