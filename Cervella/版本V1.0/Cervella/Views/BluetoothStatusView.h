//
//  BluetoothStatusView.h
//  Cervella
//
//  Created by 一磊 on 2018/6/14.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, StatusType) {
    StatusTypeNone,
    StatusTypeStart,
    StatusTypeStop
};

@interface BluetoothStatusView : UIView {

}

@property (nonatomic, assign) StatusType statusType;
@property (nonatomic, assign) NSUInteger timers;//单位秒
@property (nonatomic, assign) BOOL isCanTap;
@property (nonatomic, assign) UIColor *textColor;

@property (copy) void (^bluetoothStatusViewBlock)(StatusType);

- (void)updateProgressWithPercent:(CGFloat )percent;
@end
