//
//  HistoryTableViewCell.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/1/15.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *courseLabel;
@property (strong, nonatomic) IBOutlet UILabel *symptomLabel;

@end
