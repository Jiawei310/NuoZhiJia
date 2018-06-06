//
//  Bluetooth.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/20.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "Equipment.h"
#import "CommandManager.h"
typedef NS_OPTIONS(NSUInteger, ConnectState) {
    ConnectStateNone       = 0,//没有连接
    ConnectStateNormal     = 1,//正常连接
    ConnectStateError      = 2,//连接问题
};

//协议
@protocol BluetoothDelegate <NSObject>

@optional
//搜索到的设备
- (void)scanedEquipments:(NSArray *)equipments;
//连接状态
- (void)connectState:(ConnectState )connectState Error:(NSError *)error;
@end


@interface Bluetooth : NSObject
#pragma mark -- 属性
//协议
@property (nonatomic, weak) id <BluetoothDelegate> delegate;
//连接的设备
@property (nonatomic, strong) Equipment *equipment;

//连接状态
@property (nonatomic, assign) ConnectState connectSate;

#pragma mark -- 方法
//单例模式
+ (instancetype)shareBluetooth;
//向蓝牙设备中，写入数据，下达命令
- (void)writeValue:(NSData *)dataToWrite forCharacteristic:(CBCharacteristic *)characteristicUUID;

//搜索设备
- (void)scanEquipment;
//停止扫描 移除所有搜索到的设备
- (void)stopScanEquipment;

//连接设备
- (void)connectEquipment:(Equipment *)equipment;
//断开设备
- (void)stopConnectEquipment:(Equipment *)equipment;

@end

