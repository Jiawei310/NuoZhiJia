//
//  PurchaseRecordCell.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 17/1/9.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "PurchaseRecordCell.h"
#import "Define.h"

@implementation PurchaseRecordCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self customerView];
    }
    
    return self;
}

- (void)customerView
{
    _countLable = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_W, 12*Rate_H, 130*Rate_W, 18*Rate_H)];
    _countLable.font = [UIFont boldSystemFontOfSize:18*Rate_H];
    [self addSubview:_countLable];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_W, 40*Rate_H, 130*Rate_W, 17*Rate_H)];
    _timeLable.font = [UIFont systemFontOfSize:14*Rate_H];
    _timeLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    [self addSubview:_timeLable];
    
    _orderIDLable = [[UILabel alloc] initWithFrame:CGRectMake(155*Rate_W, 13*Rate_H, 220*Rate_W, 17*Rate_H)];
    _orderIDLable.font = [UIFont systemFontOfSize:14*Rate_H];
    _orderIDLable.adjustsFontSizeToFitWidth = YES;
    _orderIDLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    [self addSubview:_orderIDLable];
    
    _priceLable = [[UILabel alloc] initWithFrame:CGRectMake(155*Rate_W, 40*Rate_H, 220*Rate_W, 17*Rate_H)];
    _priceLable.font = [UIFont systemFontOfSize:14*Rate_H];
    _priceLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    [self addSubview:_priceLable];
}

- (void)setWithDictionary:(NSDictionary *)dic
{
    _countLable.text = [NSString stringWithFormat:@"购买 %@ 题",[dic objectForKey:@"Count"]];
    _timeLable.text = [dic objectForKey:@"OrderDate"];
    _orderIDLable.text = [NSString stringWithFormat:@"订单编号：%@",[dic objectForKey:@"OrderID"]];
    _priceLable.text = [NSString stringWithFormat:@"订单支付：%@",[dic objectForKey:@"TotalPrice"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
