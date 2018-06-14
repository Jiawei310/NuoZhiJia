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
@property (copy) void (^bluetoothStatusViewBlock)(void);

- (void)updateProgressWithNumber:(NSUInteger)number;
@end
