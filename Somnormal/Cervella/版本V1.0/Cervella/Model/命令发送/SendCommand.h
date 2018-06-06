//
//  SendCommand.h
//  SleepExpert
//
//  Created by 诺之家 on 16/7/4.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_OPTIONS(NSUInteger, DiscoveredPeripheralState) {
    discoveredPeripheralStateStop					= 1,
    discoveredPeripheralStateSuspend				= 2,
    discoveredPeripheralStateCurrentRegulation		= 3,
    discoveredPeripheralStateWork					= 4,
};

@interface SendCommand : NSObject

/*
 *发送'获取刺激时间'命令，检测是否连通
 *注：该命令格式为'55AA03086848C'；返回数据格式'55bb010b84xxxxxxxxxxxx'
 *
 * @param discoveredPeripheral 发送'获取刺激时间'命令的蓝牙外设
 * @param characteristicArray 发送'获取刺激时间'命令的蓝牙外设内部特征值
 */
- (void)sendImpedanceDetectionOrder:(CBPeripheral *)discoveredPeripheral
                   characteristics:(NSMutableArray *)characteristicArray;

/*
 *发送'设置刺激参数'命令，并返回发送命令的字符串
 *
 * @param discoveredPeripheral 发送'设置刺激参数'命令的蓝牙外设
 * @param characteristicArray 发送'设置刺激参数'命令的蓝牙外设内部特征值
 * @param indexFrequency 发送'设置刺激参数'命令的刺激频率参数
 *
 *注：该命令格式为'55AA030882xxxxxx'；返回数据格式'55bb010782xxxx'
 */
- (NSString *)sendSetTimeAndFrequencyOrder:(CBPeripheral *)discoveredPeripheral
                          characteristics:(NSMutableArray *)characteristicArray
                           indexFrequency:(NSInteger)modelIndex;

/*
 *发送'电流设定'命令，并返回发送命令的字符串
 *
 * @param discoveredPeripheral 发送'电流设定'命令的蓝牙外设
 * @param characteristicArray 发送'电流设定'命令的蓝牙外设内部特征值
 * @param currentnumOfElectric 发送'电流设定'命令的治疗时间参数
 *
 *注：该命令格式为'55AA030785xxxx'；返回数据格式'55bb010785xxxx'
 */
- (NSString *)sendElectricSetOrder:(CBPeripheral *)discoveredPeripheral
                  characteristics:(NSMutableArray *)characteristicArray
             currentnumOfElectric:(NSInteger)electricCurrentNum;

/*
 *发送'切换通道工作状态'命令（切换到电流调节通道状态）
 *注：该命令格式为'55AA030781xxxx'；返回数据格式'55bb010781xxxx'
 *
 * @param discoveredPeripheral 发送'切换通道工作状态'命令的蓝牙外设
 * @param characteristicArray 发送'切换通道工作状态'命令的蓝牙外设内部特征值
 * @param state 发送'切换通道工作状态'命令中需要切换到哪个通道下所设置的参数
 */
- (NSString *)sendSwitchChannelStateOrder:(CBPeripheral *)discoveredPeripheral
                         characteristics:(NSMutableArray *)characteristicArray
                                   state:(DiscoveredPeripheralState)state;
/*
 *发送'读取电量'命令
 *注：该命令格式为'55AA02060108'；返回数据格式'55bb010a00xxxxxxxx'
 *
 * @param discoveredPeripheral 发送'切换通道工作状态'命令的蓝牙外设
 * @param characteristicArray 发送'切换通道工作状态'命令的蓝牙外设内部特征值
 */
- (NSString *)sendElectricQuantity:(CBPeripheral *)discoveredPeripheral
                  characteristics:(NSMutableArray *)characteristicArray;

/*
 *发送'获取设备信息'命令
 *注：该命令格式为'55AA0306878F'；返回数据格式'55bb011987xxxxxxxx...'
 *
 * @param discoveredPeripheral 发送'切换通道工作状态'命令的蓝牙外设
 * @param characteristicArray 发送'切换通道工作状态'命令的蓝牙外设内部特征值
 */
- (void)sendGetDeviceInfo:(CBPeripheral *)discoveredPeripheral
         characteristics:(NSMutableArray *)characteristicArray;

@end
