//
//  HistoryQuestionViewController.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/23.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryQuestionViewController : UIViewController

@property (copy, nonatomic) NSString *questionID; //问题编号
@property (copy, nonatomic) NSString *patientID; //患者编号
@property (nonatomic) BOOL isCommend; //是否可以评价医生
@property (nonatomic) BOOL isNotice; //是否提醒用户该问题已关闭；

@end
