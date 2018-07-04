//
//  Equipment.m
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/20.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import "Equipment.h"
#import "Tool.h"
@implementation Equipment
- (instancetype)initWithCBPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _identifier = peripheral.identifier.UUIDString;
        _RSSI = RSSI;
    }
    return self;
}

//设备信息解析
- (void)deviceInfo:(NSString *)valueStr {
    Byte myChar[8];
    for (int i=0; i<8; i++)
    {
        NSString *tmp = [valueStr substringWithRange:NSMakeRange(18+2*i, 2)];
        unsigned int anInt;
        NSScanner * scanner = [[NSScanner alloc] initWithString:tmp];
        [scanner scanHexInt:&anInt];
        myChar[i] = anInt;
    }
    Byte *chOUTFinal = (Byte *)[[Tool Deciphering:myChar] bytes];
    //发送序列号接口
    NSMutableArray *deviceIDArray = [NSMutableArray array];
    NSString *hexStr = @"";
    for(int i = 0; i < 6; i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",chOUTFinal[i]&0xff];///16进制数
        if([newHexStr length] == 1)
        {
            hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
        }
        else
        {
            hexStr = [NSString stringWithFormat:@"%@",newHexStr];
        }
        [deviceIDArray addObject:hexStr];
    }
    NSLog(@"%@",deviceIDArray);
    self.deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@%@",[deviceIDArray objectAtIndex:0],[deviceIDArray objectAtIndex:1],[deviceIDArray objectAtIndex:2],[deviceIDArray objectAtIndex:3],[deviceIDArray objectAtIndex:4],[deviceIDArray objectAtIndex:5]];
}

- (BOOL)isWearOK:(NSString *)valueStr {
    NSMutableArray *valueStrs = [NSMutableArray array];
    for (int i=1; i<= valueStr.length/2; i++)
    {
        NSString *str= [valueStr substringWithRange:NSMakeRange(2*(i-1), 2)];
        [valueStrs addObject:str];
    }
    
    //0x00：未接通，0x01：接通
    if([[valueStrs objectAtIndex:8] isEqualToString:@"01"])
    {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)battery:(NSString *)valueStr {
    //55bb010a0100 02(0:充满电 1:在充电 2:没有充电) 0e(电量百分比) 09(版本号) 3500000000000000000000
    NSString *batteryStr_One = [valueStr substringWithRange:NSMakeRange(14, 1)];
    NSString *batteryStr_Two = [valueStr substringWithRange:NSMakeRange(15, 1)];
    unichar batteryStr = [valueStr characterAtIndex:15];
    if (batteryStr >= 'a' && batteryStr <= 'f')
    {
        batteryStr_Two = [NSString stringWithFormat:@"%d",batteryStr-87];
    }
    self.battery = [batteryStr_One intValue]*16+[batteryStr_Two intValue];
    self.chargeStatus = [[valueStr substringWithRange:NSMakeRange(13, 1)] integerValue];
}

#pragma mark -- setter and getter
- (NSMutableArray *)services {
    if (!_services) {
        _services = [NSMutableArray array];
    }
    return _services;
}

- (NSMutableArray *)characteristics {
    if (!_characteristics) {
        _characteristics = [NSMutableArray array];
    }
    return _characteristics;
}

- (NSUInteger )level {
    if (_level <= 0) {
        _level = 1;
    }
    else if (_level >= 12){
        _level = 12;
    }
    return _level;
}

@end
