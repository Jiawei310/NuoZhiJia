//
//  CommandManager.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bluetooth.h"
#import "Equipment.h"

@interface CommandManager : NSObject
//蓝牙
@property (nonatomic, strong) Bluetooth *bluetooth;
//连接的设备
@property (nonatomic, strong, readonly) Equipment *equipment;


//修改工作模式
- (void)changeWorkModel:(WorkModel) workModel;
//修改刺激强度
- (void)changeLevel:(NSUInteger)level;
//修改工作状态
- (void)changeChannel:(EquipmentWorkChannelState )equipmentWorkChannelState;
@end
