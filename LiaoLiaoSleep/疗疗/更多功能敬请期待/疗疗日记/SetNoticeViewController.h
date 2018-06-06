//
//  SetNoticeViewController.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/20.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TreatmentInfo.h"

@interface SetNoticeViewController : UIViewController

@property (nonatomic, strong) NSString *VCType;//push到这个界面的上层界面标记

@property (nonatomic, strong) TreatmentInfo *treatmentInfo;

@end
