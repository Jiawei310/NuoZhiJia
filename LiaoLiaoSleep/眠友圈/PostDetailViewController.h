//
//  PostDetailViewController.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/12.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SquareModel.h"

@interface PostDetailViewController : UIViewController

@property (nonatomic, strong) SquareModel *postModel;
@property (nonatomic, assign) NSInteger index;

@end
