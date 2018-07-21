//
//  Bluetooth.m
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/20.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import "Bluetooth.h"
#import "Tool.h"
#import "CommandManager.h"

@interface Bluetooth () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    NSString *_order;                   //记录发送命令
    
    NSTimer *_checkElectricTimer;       //设置阻抗检测的NSTimer对象
    NSTimer *_readBatteryTimer;         //设置读取电量的NSTimer对象
    BOOL _isConnect;                    //判断是否后连接成功
    Byte chOUTFinal[8];                 //用于存储设备序列号的16进制数的char类型数组
    NSMutableArray *_valueStrs;         //存储应答数据的字符串数组
    
    NSTimer *_scanTimer;                //搜索设备60秒限制

}

//手机为蓝牙中心
@property (nonatomic, strong) CBCentralManager *centralManager;

//发现的所有设备
@property (nonatomic, strong) NSMutableArray *equipments;
//命令
@property (nonatomic, strong) CommandManager *commandManger;

@end

@implementation Bluetooth
//单例模式
+ (instancetype)shareBluetooth {
    static Bluetooth *bluetooth = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetooth = [[Bluetooth alloc] init];
    });
    return bluetooth;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

//搜索设备
- (void)scanEquipment {
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        [self cleanData];
        [self stopTimer];
        
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        _scanTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(scanTimerAction) userInfo:nil repeats:NO];

    }
}

//停止扫描 移除所有搜索到的设备
- (void)stopScanEquipment {
    [self.centralManager stopScan];
    
    [self cleanData];
    [self stopTimer];
}

//连接设备
- (void)connectEquipment:(Equipment *)equipment {
    [self cleanData];
    [self stopTimer];
    
    self.equipment = equipment;
    [self.centralManager connectPeripheral:self.equipment.peripheral options:nil];
}

//断开设备
- (void)stopConnectEquipment:(Equipment *)equipment {
    [self.centralManager cancelPeripheralConnection:self.equipment.peripheral];
}

//开始工作
- (void)startWork {
    //工作状态设为：调节状态
    [self changeChannel:EquipmentWorkChannelStateRegulation];
}
//结束工作
- (void)endWork {
    [self changeChannel:EquipmentWorkChannelStateStop];
    [self stopTimer];
}


- (void)scanTimerAction {
    [self stopTimer];
    NSError *error = [[NSError alloc] initWithDomain:@"connect fail"
                                                code:999
                                            userInfo:@{NSLocalizedDescriptionKey:@"Make sure Cervella unit is nearby and is sufficiently charged."}];
    
    if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
        _connectSate = ConnectStateNone;
        [self.delegate connectState:self.connectSate Error:error];
    }
}
//清除缓存数据
- (void)cleanData {
    self.equipment = nil;
    self.commandManger = nil;
    _order = nil;
    [self cleanEquipments];
    
}
//清除搜索到的设备
- (void)cleanEquipments {
    [self.equipments removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(scanedEquipments:)] ) {
        [self.delegate scanedEquipments:self.equipments];
    }
}
//停止所有的定时器
- (void)stopTimer {
    [self.checkElectricTimer invalidate];
    _checkElectricTimer = nil;
    
    [self.readBatteryTimer invalidate];
    _readBatteryTimer = nil;
    
    [_scanTimer invalidate];
    _scanTimer = nil;
}

#pragma mark -- 命令
//读取设备序列号借口调用方法
- (void)readAndSendDeviceInfo
{
    [self.commandManger sendGetDeviceInfo:self.equipment.peripheral characteristics:self.equipment.characteristics];
}

//阻抗检测 获取刺激时间
- (void)detectionPersecondsForImpedance
{
    [self.commandManger sendImpedanceDetectionOrder:self.equipment.peripheral characteristics:self.equipment.characteristics];
}

//读取电量
- (void)readBattery
{
    [self.commandManger sendElectricQuantity:self.equipment.peripheral characteristics:self.equipment.characteristics];
}

//发送切换通道状态命令，设置通道参数为正常工作
- (void)changeChannel:(EquipmentWorkChannelState )equipmentWorkChannelState {
    self.equipment.equipmentWorkChannelState = equipmentWorkChannelState;
    
    _order = [self.commandManger sendSwitchChannelStateOrder:self.equipment.peripheral
                                             characteristics:self.equipment.characteristics
                                                       state:equipmentWorkChannelState];
    
    if (equipmentWorkChannelState != EquipmentWorkChannelStateRegulation) {
        _order = nil;//流程走完，开始正常工作
    }
}

//设置工作模式 正常 刺激 高度刺激
- (void)changeWorkModel:(WorkModel )workModel {
    self.equipment.workModel = workModel;
    if (self.equipment.equipmentWorkChannelState == EquipmentWorkChannelStateWork) {
        //若果更改工作模式，必须停止现在的治疗重新开始设置
        [self endWork];
        
        //强度初始为1
        self.equipment.level = 1;
    }
    else {
        _order = [self.commandManger sendSetTimeAndFrequencyOrder:self.equipment.peripheral characteristics:self.equipment.characteristics indexFrequency:workModel];
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
        _order = [self.commandManger sendElectricSetOrder:self.equipment.peripheral characteristics:self.equipment.characteristics currentnumOfElectric:self.equipment.level];
    }
}


#pragma mark -CBCentralManagerDelegate方法(required)
//蓝牙状态检测
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            [self scanEquipment];
            break;
            
        default:
            break;
    }
    if (central.state != CBManagerStatePoweredOn) {
        NSError *error = [[NSError alloc] initWithDomain:@"searched fail"
                                                    code:999
                                                userInfo:@{NSLocalizedDescriptionKey:@"Make sure Cervella unit is nearby and is sufficiently charged."}];
        [self cleanData];
        [self stopTimer];
        if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
            _connectSate = ConnectStateNone;
            [self.delegate connectState:self.connectSate Error:error];
        }
    }
}

//搜索周围设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    /*
     * 将搜索到的所有蓝牙设备转换成设备model
     * 更具设备名称，筛选出疗疗失眠的设备
     * 将搜索到的设备，添加到数组保存
     * 经所有设备信息，通过协议给予UI展示
    */
    Equipment *equipment = [[Equipment alloc] initWithCBPeripheral:peripheral RSSI:RSSI];
    if (![self.equipments containsObject:equipment])
    {
        if ([equipment.peripheral.name isEqualToString:@"NZJ-iHappySleep"] || [equipment.peripheral.name containsString:@"Sleep4U"])
        {
            NSLog(@"peripheral:%@", peripheral.name);
            [self.equipments addObject:equipment];
            
            
            NSNotification *notification = [NSNotification notificationWithName:@"scanedEquipments" object:self.equipments userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            if ([self.delegate respondsToSelector:@selector(scanedEquipments:)] ) {
                [self.delegate scanedEquipments:self.equipments];
            }
            //停止搜索计时，搜索到设备
            [self stopTimer];
        }
    }
}

//连接设备成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //签订协议
    [self.equipment.peripheral setDelegate:self];
    //搜索服务
    [self.equipment.peripheral discoverServices:nil];
    //连接成功
    if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
        _connectSate = ConnectStateNormal;
        [self.delegate connectState:self.connectSate Error:nil];
    }
}

//连接设备失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
    NSLog(@"设备已被连接");
    //连接失败
    if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
        _connectSate = ConnectStateError;
        [self.delegate connectState:self.connectSate Error:error];
    }
}

//蓝牙断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    [self.centralManager cancelPeripheralConnection:self.equipment.peripheral];
    
    [self cleanData];
    [self stopTimer];
    //蓝牙断开
    if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
        _connectSate = ConnectStateError;
        [self.delegate connectState:self.connectSate Error:error];
    }
}

#pragma mark -- CBPeripheralDelegate
//获取服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServices : %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *s in peripheral.services)
    {
        //因为只有一个服务，所以使用peripheral.name 作为 KEY
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{peripheral.name:s.UUID.description}];
        [self.equipment.services addObject:dic];
        [s.peripheral discoverCharacteristics:nil forService:s];
    }
}

//获取服务中的属性
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *c in service.characteristics)
    {
        //读取属性中的值
        [peripheral readValueForCharacteristic:c];
        //接受属性通知设置
        [peripheral setNotifyValue:YES forCharacteristic:c];
        //保存属性
        [self.equipment.characteristics addObject:c];
    }
    
//    if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
//        _connectSate = ConnectStateNormal;
//        [self.delegate connectState:self.connectSate Error:nil];
//    }
}

//获取服务中的属性值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    for (NSMutableDictionary *dic in self.equipment.services)
    {
        NSString *description = [dic valueForKey:peripheral.name];
        if ([description isEqual:characteristic.service.UUID.description])
        {
            [dic setValue:characteristic.value forKey:characteristic.UUID.description];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }

    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

//Notification 通知监听
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData* data = characteristic.value;
    NSString *valueStr =[Tool hexadecimalString:data];
    NSLog(@"valueAnswer: %@",valueStr);
    
    #pragma mark 整个流程
    //开始整个流程
    if (self.equipment.equipmentWorkChannelState == EquipmentWorkChannelStateRegulation && _order) {
        //切换通道工作状态 成功
        if ([valueStr containsString:@"55bb010781"]) {
            if ([_order containsString:@"55AA030781028C"])
            {
                //发送设置刺激参数命令，设置治疗时间和刺激频率
                [self changeWorkModel:self.equipment.workModel];
            }
        }
        //设置工作模式 成功
        else if ([valueStr containsString:@"55bb010782"]) {
            if ([_order containsString:@"55AA030882"])
            {
                //发送电流设定命令，设置电流强度
                [self changeLevel:self.equipment.level];
            }
        }
        //设置电流强度
        else if ([valueStr containsString:@"55bb010785"]) {
            if ([_order containsString:@"55AA030785"])
            {
                //发送开始命令，即疗疗正常工作命令
                [self changeChannel:EquipmentWorkChannelStateWork];
            }
        }
    }
    //开始定时器
    if (self.equipment.equipmentWorkChannelState == EquipmentWorkChannelStateWork &&
        !_readBatteryTimer &&
        [valueStr containsString:@"55bb010781"]) {
        //读取设备信息
        [self readAndSendDeviceInfo];
        
        //检测阻抗，时候正确佩戴
        [self.checkElectricTimer fire];
        //检测电量
        [self.readBatteryTimer fire];
    }
    #pragma mark 设备信息 阻抗 电量
    //设备信息
    if ([valueStr containsString:@"55bb011387"] && [[valueStr substringWithRange:NSMakeRange(34, 2)] isEqualToString:@"00"])
    {
        [self.equipment deviceInfo:valueStr];
    }
    //阻抗
    else if ([valueStr containsString:@"55bb010b84"])
    {
        WearState wearState = WearStateNone;
        NSError *errorE = nil;
        
        if ([self.equipment isWearOK:valueStr]) {
            wearState = WearStateNormal;
        }
        else {
            wearState = WearStateError;
            errorE = [[NSError alloc] initWithDomain:@"wear not ok"
                                                code:930
                                            userInfo:@{NSLocalizedDescriptionKey:@"wear not ok,try again"}];
        }
        if ([self.delegate respondsToSelector:@selector(wearState:Error:)]) {
            [self.delegate wearState:wearState Error:errorE];
        }
    }
    //电量提示
    else if ([valueStr containsString:@"55bb010a"])
    {
        [self.equipment battery:valueStr];
        
        if (self.equipment.battery > 5 && self.equipment.battery <= 20)
        {
            //NSLog(@"电池电量小于百分之20，请及时给设备充电");

            NSError *errorE = [[NSError alloc] initWithDomain:@"less than 20%"
                                                        code:920
                                                     userInfo:@{NSLocalizedDescriptionKey:@"Battery power is less than 20%. Please charge device promptly."}];
            if ([self.delegate respondsToSelector:@selector(battery:Error:)]) {
                [self.delegate battery:self.equipment.battery Error:errorE];
            }
        }
        else if(self.equipment.battery <= 5)
        {
            //NSLog(@"电池电量小于百分之5，设备无法正常工作，请先充电");
            NSError *errorE = [[NSError alloc] initWithDomain:@"less than 5%"
                                                         code:920
                                                     userInfo:@{NSLocalizedDescriptionKey:@"Battery power is less than 5%. Device unable to function, please charge device first."}];
            if ([self.delegate respondsToSelector:@selector(battery:Error:)]) {
                [self.delegate battery:self.equipment.battery Error:errorE];
            }
        }
        //
        if (self.equipment.isCharge) {
            NSError *errorE = [[NSError alloc] initWithDomain:@"Charging"
                                                         code:920
                                                     userInfo:@{NSLocalizedDescriptionKey:@"sorry, it is charging"}];
            if ([self.delegate respondsToSelector:@selector(chargeStatus:Error:)]) {
                [self.delegate chargeStatus:self.equipment.battery Error:errorE];
            }
        }
    }
}

//向设备中写入成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData* data = characteristic.value;
    NSString *valueStr =[Tool hexadecimalString:data];
    NSLog(@"valueAnswer: %@",valueStr);
    if (error)
    {
        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }
}

#pragma mark set and get
- (NSMutableArray *)equipments {
    if (!_equipments) {
        _equipments = [NSMutableArray array];
    }
    return _equipments;
}

- (CommandManager *)commandManger {
    if (!_commandManger) {
        _commandManger = [[CommandManager alloc] init];
    }
    return _commandManger;
}

- (NSMutableArray *)valueStrs {
    if (!_valueStrs) {
        _valueStrs = [NSMutableArray array];
    }
    return _valueStrs;
}

- (NSTimer *)checkElectricTimer {
    if (!_checkElectricTimer) {
        _checkElectricTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(detectionPersecondsForImpedance) userInfo:nil repeats:YES];
    }
    return _checkElectricTimer;
}

- (NSTimer *)readBatteryTimer {
    if (!_readBatteryTimer) {
        _readBatteryTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(readBattery) userInfo:nil repeats:YES];
    }
    return _readBatteryTimer;
}

@end
