//
//  SendCommand.m
//  SleepExpert
//
//  Created by 诺之家 on 16/7/4.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "CommandManager.h"
#import "Tool.h"
@interface CommandManager () {
    NSString *_order;
    NSTimer  *_checkElectricTimer;       //设置阻抗检测的NSTimer对象
    NSTimer  *_readBatteryTimer;         //设置读取电量的NSTimer对象
}
@end

@implementation CommandManager

//设置工作模式
- (void)changeWorkModel:(WorkModel )workModel {
    self.equipment.workModel = workModel;
    if (self.equipment.equipmentWorkChannelState == EquipmentWorkChannelStateWork) {
        //若果更改工作模式，必须停止现在的治疗重新开始设置
        [self changeChannel:EquipmentWorkChannelStateStop];
        //接下来的几步在didWriteValueForCharacteristic
    }
    else {
        _order = [self sendSetTimeAndFrequencyOrder:workModel];
    }
}

//调整强度 //硬件数值改动
- (void)changeLevel:(NSUInteger )level {
    /*
     *放大信号，当前强度频道必须小于12
     *缩小信号，当前强度频道必须大于1
     *符合以上两个条件，信号调整，否则信号不变
     */
    if (level>= 1 && level <= 12) {
        self.equipment.level = level;
        //硬件数值改动
        _order = [self sendElectricSetOrder:self.equipment.level];
    }
}

//发送切换通道状态命令，设置通道参数为正常工作
- (void)changeChannel:(EquipmentWorkChannelState )equipmentWorkChannelState {
    self.equipment.equipmentWorkChannelState = equipmentWorkChannelState;
    
    _order = [self sendSwitchChannelStateOrder:equipmentWorkChannelState];
    if (equipmentWorkChannelState == EquipmentWorkChannelStateWork) {
        _order = nil;//流程走完，开始正常工作
    }
}


//停止所有的定时器
- (void)stopTimer {
    [self.checkElectricTimer invalidate];
    _checkElectricTimer = nil;
    
    [self.readBatteryTimer invalidate];
    _readBatteryTimer = nil;
}

#pragma mark -- 命令
/*
 *发送'获取刺激时间'命令，检测是否连通
 *注：该命令格式为'55AA03086848C'；返回数据格式'55bb010b84xxxxxxxxxxxx'
 *
 * @param discoveredPeripheral 发送'获取刺激时间'命令的蓝牙外设
 * @param characteristicArray 发送'获取刺激时间'命令的蓝牙外设内部特征值
 */
- (void)sendImpedanceDetectionOrder
{
    for (CBCharacteristic *characteristic in self.equipment.characteristics)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            NSString *str=@"55AA0306848C";
            NSData *dataToWrite=[Tool dataWithHexstring:str];
            [self.bluetooth writeValue:dataToWrite forCharacteristic:characteristicUUID];
        }
    }
}

/*
 *发送'设置刺激参数'命令，并返回发送命令的字符串
 *
 * @param discoveredPeripheral 发送'设置刺激参数'命令的蓝牙外设
 * @param characteristicArray 发送'设置刺激参数'命令的蓝牙外设内部特征值
 * @param indexFrequency 发送'设置刺激参数'命令的刺激频率参数
 *
 *注：该命令格式为'55AA030882xxxxxx'；返回数据格式'55bb010782xxxx'
 */
- (NSString *)sendSetTimeAndFrequencyOrder:(WorkModel)workModel
{
    NSString *orderStr;
    NSString *strFrequency=[NSString string];
    NSString *strTime=[NSString string];
    NSString *strVerify=[NSString string];
    if (workModel ==  WorkModelNormal)
    {
        strFrequency=@"00";
        strTime=@"14";
        strVerify=@"A0";
    }
    else if (workModel == WorkModelStimulate)
    {
        strFrequency=@"01";
        strTime=@"14";
        strVerify=@"A1";
    }
    else if (workModel == WorkModelHighIntensity)
    {
        strFrequency=@"02";
        strTime=@"14";
        strVerify=@"A2";
    }
    
    for (CBCharacteristic *characteristic in self.equipment.characteristics)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            orderStr=[NSString stringWithFormat:@"55AA030882%@%@%@",strTime,strFrequency,strVerify];
            NSData *dataToWrite=[Tool dataWithHexstring:orderStr];
            [self.bluetooth writeValue:dataToWrite forCharacteristic:characteristicUUID];
        }
    }
    return orderStr;
}

/*
 *发送'电流设定'命令，并返回发送命令的字符串
 *
 * @param discoveredPeripheral 发送'电流设定'命令的蓝牙外设
 * @param characteristicArray 发送'电流设定'命令的蓝牙外设内部特征值
 * @param currentnumOfElectric 发送'电流设定'命令的治疗时间参数
 *
 *注：该命令格式为'55AA030785xxxx'；返回数据格式'55bb010785xxxx'
 */
//设置电流设定命令
- (NSString *)sendElectricSetOrder:(NSUInteger) level
{
    NSString *orderStr;
    NSString *strElectric=[NSString string];
    NSString *strElectricVerify=[NSString string];
    if (level==0)
    {
        strElectric=@"00";
        strElectricVerify=@"8E";
    }
    else if (level==1)
    {
        strElectric=@"01";
        strElectricVerify=@"8F";
    }
    else if (level==2)
    {
        strElectric=@"02";
        strElectricVerify=@"90";
    }
    else if (level==3)
    {
        strElectric=@"03";
        strElectricVerify=@"91";
    }
    else if (level==4)
    {
        strElectric=@"04";
        strElectricVerify=@"92";
    }
    else if (level==5)
    {
        strElectric=@"05";
        strElectricVerify=@"93";
    }
    else if (level==6)
    {
        strElectric=@"06";
        strElectricVerify=@"94";
    }
    else if (level==7)
    {
        strElectric=@"07";
        strElectricVerify=@"95";
    }
    else if (level==8)
    {
        strElectric=@"08";
        strElectricVerify=@"96";
    }
    else if (level==9)
    {
        strElectric=@"09";
        strElectricVerify=@"97";
    }
    else if (level==10)
    {
        strElectric=@"0A";
        strElectricVerify=@"98";
    }else if (level==11)
    {
        strElectric=@"0B";
        strElectricVerify=@"99";
    }
    else if (level==12)
    {
        strElectric=@"0C";
        strElectricVerify=@"9A";
    }
    
    for (CBCharacteristic *characteristic in self.equipment.characteristics)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            orderStr=[NSString stringWithFormat:@"55AA030785%@%@",strElectric,strElectricVerify];
            NSData *dataToWrite = [Tool dataWithHexstring:orderStr];
            [self.bluetooth writeValue:dataToWrite forCharacteristic:characteristicUUID];
        }
    }
    
    return orderStr;
}

/*
 *发送'切换通道工作状态'命令（切换到电流调节通道状态）
 *注：该命令格式为'55AA030781xxxx'；返回数据格式'55bb010781xxxx'
 *
 * @param discoveredPeripheral 发送'切换通道工作状态'命令的蓝牙外设
 * @param characteristicArray 发送'切换通道工作状态'命令的蓝牙外设内部特征值
 * @param state 发送'切换通道工作状态'命令中需要切换到哪个通道下所设置的参数
 */
//设置切换通道工作状态命令
- (NSString *)sendSwitchChannelStateOrder:(EquipmentWorkChannelState)state
{
    NSString *orderStr;
    
    for (CBCharacteristic *characteristic in self.equipment.characteristics)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            if (state == EquipmentWorkChannelStateStop)
            {
                orderStr=@"55AA030781008A";
            }
            else if (state == EquipmentWorkChannelStateWork)
            {
                orderStr=@"55AA030781038D";
            }
            else if (state == EquipmentWorkChannelStateRegulation)
            {
                orderStr=@"55AA030781028C";
            }
            NSData *dataToWrite=[Tool dataWithHexstring:orderStr];
            [self.bluetooth writeValue:dataToWrite forCharacteristic:characteristicUUID];
        }
    }
    
    return orderStr;
}

/*
 *发送'读取电量'命令
 *注：该命令格式为'55AA02060108'；返回数据格式'55bb010a00xxxxxxxx'
 *
 * @param discoveredPeripheral 发送'切换通道工作状态'命令的蓝牙外设
 * @param characteristicArray 发送'切换通道工作状态'命令的蓝牙外设内部特征值
 */
//发送电量命令
- (NSString *)sendElectricQuantity
{
    NSString *orderStr;
    
    for (CBCharacteristic *characteristic in self.equipment.characteristics)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            orderStr=@"55AA02060108";
            NSData *dataToWrite=[Tool dataWithHexstring:orderStr];
            [self.bluetooth writeValue:dataToWrite forCharacteristic:characteristicUUID];
        }
    }
    
    return orderStr;
}
/*
 *发送'获取设备信息'命令
 *注：该命令格式为'55AA0306878F'；返回数据格式'55bb011987xxxxxxxx...'
 *
 * @param discoveredPeripheral 发送'切换通道工作状态'命令的蓝牙外设
 * @param characteristicArray 发送'切换通道工作状态'命令的蓝牙外设内部特征值
 */

//获取设备序列号命令
- (void)sendGetDeviceInfo
{
    for (int i=0; i<2; i++)
    {
        for (CBCharacteristic *characteristic in self.equipment.characteristics)
        {
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
            {
                CBCharacteristic *characteristicUUID=characteristic;
                NSString *str=@"55AA0306878F";
                NSData *dataToWrite=[Tool dataWithHexstring:str];
                
                [self.bluetooth writeValue:dataToWrite forCharacteristic:characteristicUUID];
            }
        }
    }
}

#pragma mark -- set and get
- (Bluetooth *)bluetooth {
    if (!_bluetooth) {
        _bluetooth = [Bluetooth shareBluetooth];
    }
    return _bluetooth;
}

- (Equipment *)equipment {
    return self.bluetooth.equipment;
}

- (NSTimer *)checkElectricTimer {
    if (!_checkElectricTimer) {
        //时时 阻抗检测 获取刺激时间
        _checkElectricTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendImpedanceDetectionOrder) userInfo:nil repeats:YES];
    }
    return _checkElectricTimer;
}

- (NSTimer *)readBatteryTimer {
    if (!_readBatteryTimer) {
        //时时 读取电量
        _readBatteryTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendElectricQuantity) userInfo:nil repeats:YES];
    }
    return _readBatteryTimer;
}

@end

