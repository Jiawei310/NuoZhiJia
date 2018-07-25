//
//  Equipment.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/20.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
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
    EquipmentWorkChannelStateSuspend                = 2,//暂停 暂时不用
    EquipmentWorkChannelStateRegulation             = 3,//电流调节
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
//充电状态
@property (nonatomic, assign) BOOL isCharge;
//code
@property (nonatomic, strong) NSString *deviceCode;
//是否佩戴好
@property (nonatomic, assign) BOOL isWearOK;


//刺激仪的通道工作状态
@property (nonatomic, assign) EquipmentWorkChannelState equipmentWorkChannelState;
//工作模式
@property (nonatomic, assign) WorkModel workModel;
//刺激强度
@property (nonatomic, assign) NSUInteger level;
//时长
@property (nonatomic, assign) NSUInteger timeIndex;



- (instancetype)initWithCBPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI;

//设备信息
- (void)deviceInfo:(NSString *)valueStr;
//是否佩戴好
- (BOOL)isWearOK:(NSString *)valueStr;
//电量
- (void)battery:(NSString *)valueStr;
@end
