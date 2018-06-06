//
//  Equipment.m
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//
#import "Equipment.h"

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

@end
