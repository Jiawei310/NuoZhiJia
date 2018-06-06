//
//  PointDetailViewController.h
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/8/24.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointDetailViewController : UIViewController

@property (copy, nonatomic) NSString *page;//数据分页显示的页数
@property (nonatomic, copy) NSMutableArray *pointDataSource;

@end
