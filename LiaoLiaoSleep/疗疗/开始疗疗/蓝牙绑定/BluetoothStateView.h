//
//  BluetoothStateView.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/2.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClickEventDelegate <NSObject>

//BluetoothStateView中的按钮点击事件
- (void)doClickEvent:(UIButton *)sender andType:(NSString *)btnType;
- (void)tryAgainClickEvent:(UIButton *)sender;

@end

@interface BluetoothStateView : UIView

@property (nonatomic, weak) id<ClickEventDelegate>clickDelegate;

@property (nonatomic, assign) int percent;

- (instancetype)initWithState:(NSString *)stateString andDevice:(NSString *)name andSerialNumber:(NSString *)serialNumber andPercent:(int)percent ;

@end
