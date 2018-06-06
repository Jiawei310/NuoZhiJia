//
//  PurchaseRecordCell.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 17/1/9.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseRecordCell : UITableViewCell

@property (nonatomic, strong) UILabel *countLable;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UILabel *orderIDLable;
@property (nonatomic, strong) UILabel *priceLable;

- (void)setWithDictionary:(NSDictionary *)dic;

@end
