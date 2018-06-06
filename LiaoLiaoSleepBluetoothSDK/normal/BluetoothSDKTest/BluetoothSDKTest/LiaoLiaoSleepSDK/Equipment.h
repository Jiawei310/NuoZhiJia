//
//  Equipment.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#pragma mark - 工作流程
/*
 当修改强度或者切换模式时
 * 将设备工作状态设为：调节状态
 * 调节工作模式：正常 刺激 高强度 （可单独调节，必须停止设备，计时从新开始）
 * 调节强度：1-12个档次         （可单独调节，不需要暂停设备，计时不需要停止）
 * 将设备工作状态设为：工作状态
 * 工作结束：将设备工作状态设为：停止状态
 */

//工作模式
typedef NS_OPTIONS(NSUInteger, WorkModel) {
    WorkModelNormal        = 0,//正常模式 默认
    WorkModelStimulate     = 1,//刺激模式
    WorkModelHighIntensity = 2,//高强度模式
};

//刺激仪的通道工作状态
typedef NS_OPTIONS(NSUInteger, EquipmentWorkChannelState) {
    EquipmentWorkChannelStateNone                   = 0,
    EquipmentWorkChannelStateStop                   = 1,//停止
    EquipmentWorkChannelStateSuspend                = 2,//暂停
    EquipmentWorkChannelStateRegulation             = 3,//电流调节 暂时不用
    EquipmentWorkChannelStateWork                   = 4,//正常工作
};


@interface Equipment : NSObject
//设备
@property (nonatomic, strong) CBPeripheral *peripheral;
//设备的ID    peripheral.identifier
@property (nonatomic, strong) NSString *identifier;
//信号强弱
@property (nonatomic, strong) NSNumber *RSSI;
//服务
@property (nonatomic, strong) NSMutableArray *services;
//属性
@property (nonatomic, strong) NSMutableArray *characteristics;
//电量百分比 1-100
@property (nonatomic, assign) NSUInteger battery;
//code
@property (nonatomic, strong) NSString *deviceCode;

//刺激仪的通道工作状态
@property (nonatomic, assign) EquipmentWorkChannelState equipmentWorkChannelState;
//工作模式
@property (nonatomic, assign) WorkModel workModel;
//刺激强度
@property (nonatomic, assign) NSUInteger level;


- (instancetype)initWithCBPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI;
@end
