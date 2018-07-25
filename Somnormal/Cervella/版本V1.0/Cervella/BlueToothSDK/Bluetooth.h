//
//  Bluetooth.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/20.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//


/*
 当修改强度或者切换模式时
 * 将设备工作状态设为：调节状态
 * 调节工作模式：正常 刺激 高强度 （可单独调节，必须停止设备，计时从新开始）
 * 调节强度：1-12个档次         （可单独调节，不需要暂停设备，计时不需要停止）
 * 将设备工作状态设为：工作状态
 * 工作结束：将设备工作状态设为：停止状态
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "Equipment.h"
typedef NS_OPTIONS(NSUInteger, ConnectState) {
    ConnectStateNone       = 0,//没有连接
    ConnectStateNormal     = 1,//正常连接
    ConnectStateError      = 2,//连接问题
};

typedef NS_OPTIONS(NSUInteger, WearState) {
    WearStateNone       = 0,//没有
    WearStateNormal     = 1,//正常
    WearStateError      = 2,//佩戴失败
};


//协议
@protocol BluetoothDelegate <NSObject>

@optional
//搜索到的设备
- (void)scanedEquipments:(NSArray *)equipments;
//连接状态
- (void)connectState:(ConnectState )connectState Error:(NSError *)error;
//佩戴状态
- (void)wearState:(WearState )wearState Error:(NSError *)error;

//电池状态
- (void)battery:(NSUInteger )battery Error:(NSError *)error;
//充电状态
- (void)chargeStatus:(NSUInteger )battery Error:(NSError *)error;

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

//搜索设备
- (void)scanEquipment;
//停止扫描 移除所有搜索到的设备
- (void)stopScanEquipment;

//连接设备
- (void)connectEquipment:(Equipment *)equipment;
//断开设备
- (void)stopConnectEquipment:(Equipment *)equipment;

#pragma mark - 命令
//设置工作模式 正常 刺激 高度刺激
- (void)changeWorkModel:(WorkModel )workModel timeIndex:(NSInteger )timeIndex;
//调整强度 //硬件数值改动
- (void)changeLevel:(NSUInteger )level;
//开始工作
- (void)startWork;
//结束工作
- (void)endWork;

























@end
