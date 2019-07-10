//
//  SendCommand.m
//  SleepExpert
//
//  Created by 诺之家 on 16/7/4.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "CommandManager.h"
#import "Tool.h"
@implementation CommandManager

- (void)sendImpedanceDetectionOrder:(CBPeripheral *)discoveredPeripheral
                    characteristics:(NSMutableArray *)characteristicArray
{
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            NSString *str=@"55AA0306848C";
            NSData *dataToWrite=[Tool dataWithHexstring:str];
            [discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (NSString *)sendSetTimeAndFrequencyOrder:(CBPeripheral *)discoveredPeripheral
                           characteristics:(NSMutableArray *)characteristicArray
                            indexFrequency:(WorkModel)workModel
                                 timeInedx:(NSInteger)timeIndex
{
    NSString *orderStr;
    NSString *strFrequency=[NSString string];
    NSString *strTime=[NSString string];
    NSString *strVerify=[NSString string];
    if (timeIndex == 0) {//@"10Min"
        if (workModel ==  WorkModelNormal)
        {
            strFrequency=@"00";
            strTime=@"0A";
            strVerify=@"96";
        }
        else if (workModel == WorkModelStimulate)
        {
            strFrequency=@"01";
            strTime=@"0A";
            strVerify=@"97";
            
        }
        else if (workModel == WorkModelHighIntensity)
        {
            strFrequency=@"02";
            strTime=@"0A";
            strVerify=@"98";
        }
    }
    if (timeIndex == 1) {//@"20Min"
        if (workModel ==  WorkModelNormal)
        {
            //14  A0
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
    }
    if (timeIndex == 2) {//@"30Min"
        if (workModel ==  WorkModelNormal)
        {
            strFrequency=@"00";
            strTime=@"1E";
            strVerify=@"AA";
        }
        else if (workModel == WorkModelStimulate)
        {
            strFrequency=@"01";
            strTime=@"1E";
            strVerify=@"AB";
            
        }
        else if (workModel == WorkModelHighIntensity)
        {
            strFrequency=@"02";
            strTime=@"1E";
            strVerify=@"AC";
        }
    }
    if (timeIndex == 3) {//@"40Min"
        if (workModel ==  WorkModelNormal)
        {
            strFrequency=@"00";
            strTime=@"28";
            strVerify=@"B4";
        }
        else if (workModel == WorkModelStimulate)
        {
            strFrequency=@"01";
            strTime=@"28";
            strVerify=@"B5";
            
        }
        else if (workModel == WorkModelHighIntensity)
        {
            strFrequency=@"02";
            strTime=@"28";
            strVerify=@"B6";
        }
    }
    if (timeIndex == 4) {//@"50Min"
        if (workModel ==  WorkModelNormal)
        {
            strFrequency=@"00";
            strTime=@"32";
            strVerify=@"BE";
        }
        else if (workModel == WorkModelStimulate)
        {
            strFrequency=@"01";
            strTime=@"32";
            strVerify=@"BF";
            
        }
        else if (workModel == WorkModelHighIntensity)
        {
            strFrequency=@"02";
            strTime=@"32";
            strVerify=@"C0";
        }
    }
    else if (timeIndex == 5) {//@"60Min"
        if (workModel ==  WorkModelNormal)
        {
            strFrequency=@"00";
            strTime=@"3C";
            strVerify=@"C8";
        }
        else if (workModel == WorkModelStimulate)
        {
            strFrequency=@"01";
            strTime=@"3C";
            strVerify=@"C9";
            
        }
        else if (workModel == WorkModelHighIntensity)
        {
            strFrequency=@"02";
            strTime=@"3C";
            strVerify=@"CA";
        }
    }
    
    
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            orderStr=[NSString stringWithFormat:@"55AA030882%@%@%@",strTime,strFrequency,strVerify];
            NSData *dataToWrite=[Tool dataWithHexstring:orderStr];
            [discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
    
    return orderStr;
}

//设置电流设定命令
- (NSString *)sendElectricSetOrder:(CBPeripheral *)discoveredPeripheral
                   characteristics:(NSMutableArray *)characteristicArray
              currentnumOfElectric:(NSInteger) electricCurrentNum
{
    NSString *orderStr;
    NSString *strElectric=[NSString string];
    NSString *strElectricVerify=[NSString string];
    if (electricCurrentNum==0)
    {
        strElectric=@"00";
        strElectricVerify=@"8E";
    }
    else if (electricCurrentNum==1)
    {
        strElectric=@"01";
        strElectricVerify=@"8F";
    }
    else if (electricCurrentNum==2)
    {
        strElectric=@"02";
        strElectricVerify=@"90";
    }
    else if (electricCurrentNum==3)
    {
        strElectric=@"03";
        strElectricVerify=@"91";
    }
    else if (electricCurrentNum==4)
    {
        strElectric=@"04";
        strElectricVerify=@"92";
    }
    else if (electricCurrentNum==5)
    {
        strElectric=@"05";
        strElectricVerify=@"93";
    }
    else if (electricCurrentNum==6)
    {
        strElectric=@"06";
        strElectricVerify=@"94";
    }
    else if (electricCurrentNum==7)
    {
        strElectric=@"07";
        strElectricVerify=@"95";
    }
    else if (electricCurrentNum==8)
    {
        strElectric=@"08";
        strElectricVerify=@"96";
    }
    else if (electricCurrentNum==9)
    {
        strElectric=@"09";
        strElectricVerify=@"97";
    }
    else if (electricCurrentNum==10)
    {
        strElectric=@"0A";
        strElectricVerify=@"98";
    }else if (electricCurrentNum==11)
    {
        strElectric=@"0B";
        strElectricVerify=@"99";
    }
    else if (electricCurrentNum==12)
    {
        strElectric=@"0C";
        strElectricVerify=@"9A";
    }
    
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            orderStr=[NSString stringWithFormat:@"55AA030785%@%@",strElectric,strElectricVerify];
            NSData *dataToWriteSet=[Tool dataWithHexstring:orderStr];
            [discoveredPeripheral writeValue:dataToWriteSet forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
    
    return orderStr;
}

//设置切换通道工作状态命令
- (NSString *)sendSwitchChannelStateOrder:(CBPeripheral *)discoveredPeripheral
                          characteristics:(NSMutableArray *)characteristicArray
                                    state:(EquipmentWorkChannelState)state
{
    NSString *orderStr;
    
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            if (state == EquipmentWorkChannelStateStop)
            {
                orderStr=@"55AA030781008A";
            }
            else if (state == EquipmentWorkChannelStateRegulation)
            {
                orderStr=@"55AA030781028C";
            }
            else if (state == EquipmentWorkChannelStateWork)
            {
                orderStr=@"55AA030781038D";
            }
            NSData *dataToWriteRegulate=[Tool dataWithHexstring:orderStr];
            [discoveredPeripheral writeValue:dataToWriteRegulate forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
    
    return orderStr;
}

//发送电量命令
- (NSString *)sendElectricQuantity:(CBPeripheral *)discoveredPeripheral
                   characteristics:(NSMutableArray *)characteristicArray
{
    NSString *orderStr;
    
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            CBCharacteristic *characteristicUUID=characteristic;
            orderStr=@"55AA02060108";
            NSData *dataToWrite=[Tool dataWithHexstring:orderStr];
            [discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
    
    return orderStr;
}

//获取设备序列号命令
- (void)sendGetDeviceInfo:(CBPeripheral *)discoveredPeripheral
          characteristics:(NSMutableArray *)characteristicArray
{
    for (int i=0; i<2; i++)
    {
        for (CBCharacteristic *characteristic in characteristicArray)
        {
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
            {
                CBCharacteristic *characteristicUUID=characteristic;
                NSString *str=@"55AA0306878F";
                NSData *dataToWrite=[Tool dataWithHexstring:str];
                [discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

@end
