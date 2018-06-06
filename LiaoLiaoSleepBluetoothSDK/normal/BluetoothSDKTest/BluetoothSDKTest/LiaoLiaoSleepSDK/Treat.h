//
//  Treat.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipment.h"
@interface Treat : NSObject

//设备
@property (nonatomic, strong, readonly) Equipment *equipment;

#pragma mark -- treat
//开始治疗
- (void)startTreat;
//暂停治疗
- (void)suspendTreat;
//结束治疗
- (void)endTreat;

#pragma mark - 命令
//设置工作模式
- (void)changeWorkModel:(WorkModel )workModel;
//调整强度 0-12
- (void)changeLevel:(NSUInteger )level;

@end
