//
//  StartLiaoLiaoViewController.h
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/7.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEInfo.h"
#import "TreatInfo.h"
#import "BluetoothInfo.h"
#import "TreatmentInfo.h"
#import "FragmentInfo.h"

@interface StartLiaoLiaoViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, assign)             BOOL isScan;

@property (nonatomic, strong)          BLEInfo *BLEinfo;
@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong)     CBPeripheral *discoveredPeripheral;
// tableview sections，保存蓝牙设备里面的services字典，字典第一个为service，剩下是特性与值
@property (nonatomic, strong)   NSMutableArray *arrayServices;
// 用来记录有多少特性，当全部特性保存完毕，刷新列表
@property (atomic, assign)                 int characteristicNum;

@property (nonatomic, strong)        TreatInfo *treatInfo;
@property(nonatomic, strong)     BluetoothInfo *bluetoothInfo;

@property (nonatomic, strong)          NSArray *BluetoothInfoArray;
@property (nonatomic, assign)             BOOL isInCourse;
//当前疗程信息
@property (nonatomic, strong) TreatmentInfo *treatmentDic;

+ (id)sharedStartLiaoLiaoViewController;

@end
