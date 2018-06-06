//
//  Treat.m
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import "Treat.h"
#import "CommandManager.h"
@interface Treat ()

//命令
@property (nonatomic, strong) CommandManager *commandManger;

@end

@implementation Treat

#pragma mark -- treat
//开始治疗
- (void)startTreat {
    if (self.commandManger.bluetooth.connectSate == ConnectStateNormal) {
        //工作状态设为：调节状态
        [self.commandManger changeChannel:EquipmentWorkChannelStateRegulation];
        //接下来的几步在didWriteValueForCharacteristic
    }
    else {
        //开始扫描设备
        [self.commandManger.bluetooth scanEquipment];
    }
}

//暂停治疗
- (void)suspendTreat {
    
}
//结束治疗
- (void)endTreat {
    
}

#pragma mark -- 命令
//修改工作模式
- (void)changeWorkModel:(WorkModel) workModel {
    [self.commandManger changeWorkModel:workModel];
}

//修改刺激强度
- (void)changeLevel:(NSUInteger)level {
    [self.commandManger changeLevel:level];
}

#pragma mark -- seter and geter
- (CommandManager *)commandManger {
    if (!_commandManger) {
        _commandManger = [[CommandManager alloc] init];
    }
    return _commandManger;
}

- (Equipment *)equipment {
    return self.commandManger.equipment;
}

@end
