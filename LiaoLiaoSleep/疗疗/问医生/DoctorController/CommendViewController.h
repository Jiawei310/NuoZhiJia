//
//  CommendViewController.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/7.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommentModel.h"

@interface CommendViewController : UIViewController

@property (copy, nonatomic) NSString *doctorID;
@property (copy, nonatomic) NSString *patientID;
@property (copy, nonatomic) CommentModel *comment;
@property (nonatomic)BOOL isJump;

@end
