//
//  Bluetooth.m
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/20.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import "Bluetooth.h"
@interface Bluetooth () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    BOOL _isConnect;                    //判断是否后连接成功
    NSMutableArray *_valueStrs;         //存储应答数据的字符串数组
    NSTimer *_scanTimer;                //搜索设备60秒限制
}

//手机为蓝牙中心
@property (nonatomic, strong) CBCentralManager *centralManager;
//发现的所有设备
@property (nonatomic, strong) NSMutableArray *equipments;

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
    
}

- (void)scanTimerAction {
    [self stopTimer];
    NSError *error = [[NSError alloc] initWithDomain:@"连接时间超时"
                                                code:999
                                            userInfo:@{NSLocalizedDescriptionKey:@"连接时间超时",
                                                       NSLocalizedFailureReasonErrorKey:@"设备可能不在身边",
                                                       NSLocalizedRecoverySuggestionErrorKey:@"检查设备",
                                                       NSLocalizedRecoveryOptionsErrorKey:@[@"靠近自己",@"重启设备", @"蓝牙是否打开"]}];
    
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
    [_scanTimer invalidate];
    _scanTimer = nil;
}

#pragma mark --
- (void)writeValue:(NSData *)dataToWrite forCharacteristic:(CBCharacteristic *)characteristicUUID {
    [self.equipment.peripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
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
        NSError *error = [[NSError alloc] initWithDomain:@"搜索超时"
                                                    code:999
                                                userInfo:@{NSLocalizedDescriptionKey:@"搜索超时，检查蓝牙，靠近设备",
                                                           NSLocalizedFailureReasonErrorKey:@"蓝牙未开，设备不在身边",
                                                           NSLocalizedRecoverySuggestionErrorKey:@"检查设备蓝牙",
                                                           NSLocalizedRecoveryOptionsErrorKey:@[@"检查设备蓝牙",@"靠近设备"]}];
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
    
    
    //读取设备信息
    [self readAndSendDeviceInfo];
    //检测阻抗，时候正确佩戴
    [self.checkElectricTimer fire];
    //检测电量
    [self.readBatteryTimer fire];
}

//Notification 通知监听
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData* data = characteristic.value;
    NSString *valueStr =[self hexadecimalString:data];
    NSLog(@"valueAnswer: %@",valueStr);
    //设备信息
    if ([valueStr containsString:@"55bb011387"] && [[valueStr substringWithRange:NSMakeRange(34, 2)] isEqualToString:@"00"])
    {
        Byte myChar[8];
        for (int i=0; i<8; i++)
        {
            NSString *tmp = [valueStr substringWithRange:NSMakeRange(18+2*i, 2)];
            unsigned int anInt;
            NSScanner * scanner = [[NSScanner alloc] initWithString:tmp];
            [scanner scanHexInt:&anInt];
            myChar[i] = anInt;
        }
        [self Deciphering:myChar];
        
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
        self.equipment.deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@%@",[deviceIDArray objectAtIndex:0],[deviceIDArray objectAtIndex:1],[deviceIDArray objectAtIndex:2],[deviceIDArray objectAtIndex:3],[deviceIDArray objectAtIndex:4],[deviceIDArray objectAtIndex:5]];
    }
    //阻抗
    else if ([valueStr containsString:@"55bb010b84"])
    {
        
        [self.valueStrs removeAllObjects];
        for (int i=1; i<= valueStr.length/2; i++)
        {
            NSString *str= [valueStr substringWithRange:NSMakeRange(2*(i-1), 2)];
            [self.valueStrs addObject:str];
        }
        
        //0x00：未接通，0x01：接通
        if ([[self.valueStrs objectAtIndex:8] isEqualToString:@"00"])
        {
            _isConnect = NO;
        }
        else if([[self.valueStrs objectAtIndex:8] isEqualToString:@"01"])
        {
            _isConnect = YES;
        }
    }
    //电量提示
    else if ([valueStr containsString:@"55bb010a"])
    {
        NSString *numberStr_One = [valueStr substringWithRange:NSMakeRange(14, 1)];
        NSString *numberStr_Two = [valueStr substringWithRange:NSMakeRange(15, 1)];
        unichar numberStr = [valueStr characterAtIndex:15];
        if (numberStr >= 'a' && numberStr <= 'f')
        {
            numberStr_Two = [NSString stringWithFormat:@"%d",numberStr-87];
        }
        self.equipment.battery = [numberStr_One intValue]*16+[numberStr_Two intValue];
        
        if (self.equipment.battery > 5 && self.equipment.battery <= 20)
        {
            //NSLog(@"电池电量小于百分之20，请及时给设备充电");
            
            NSError *errorE = [[NSError alloc] initWithDomain:@"电量低于20%"
                                                         code:920
                                                     userInfo:@{NSLocalizedDescriptionKey:@"电量低于20%",
                                                                NSLocalizedFailureReasonErrorKey:@"电量低于20%",
                                                                NSLocalizedRecoverySuggestionErrorKey:@"及时给设备充电，以免影响您的使用",
                                                                NSLocalizedRecoveryOptionsErrorKey:@[@"及时给设备充电，以免影响您的使用"]}];
            if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
                _connectSate = ConnectStateNormal;
                [self.delegate connectState:self.connectSate Error:errorE];
            }
        }
        else if(self.equipment.battery <= 5)
        {
            //NSLog(@"电池电量小于百分之5，设备无法正常工作，请先充电");
            NSError *errorE = [[NSError alloc] initWithDomain:@"电量低于5%"
                                                         code:920
                                                     userInfo:@{NSLocalizedDescriptionKey:@"电量低于5%",
                                                                NSLocalizedFailureReasonErrorKey:@"电量低于5%",
                                                                NSLocalizedRecoverySuggestionErrorKey:@"尽快给设备充电，以免影响您的使用",
                                                                NSLocalizedRecoveryOptionsErrorKey:@[@"尽快给设备充电，以免影响您的使用"]}];
            if ([self.delegate respondsToSelector:@selector(connectState:Error:)]) {
                _connectSate = ConnectStateNormal;
                [self.delegate connectState:self.connectSate Error:errorE];
            }
        }
        else if (self.equipment.equipmentWorkChannelState == EquipmentWorkChannelStateNone) {
            [self startWork];
        }
    }
}

//向设备中写入成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData* data = characteristic.value;
    NSString *valueStr =[self hexadecimalString:data];
    NSLog(@"valueAnswer: %@",valueStr);
    if (self.equipment.equipmentWorkChannelState == EquipmentWorkChannelStateRegulation) {
        if ([_order containsString:@"55AA030781028C"])
        {
            //发送设置刺激参数命令，设置治疗时间和刺激频率
            [self changeWorkModel:self.equipment.workModel];
            
        }
        else if ([_order containsString:@"55AA030882"])
        {
            //发送电流设定命令，设置电流强度
            [self changeLevel:self.equipment.level];
        }
        else if ([_order containsString:@"55AA030785"])
        {
            //发送开始命令，即疗疗正常工作命令
            [self changeChannel:EquipmentWorkChannelStateWork];
        }
    }
    else if (self.equipment.equipmentWorkChannelState == EquipmentWorkChannelStateStop) {
        [self startWork];
    }
    
    if (error)
    {
        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }
}


#pragma mark -- tool
-(void)Deciphering:(Byte *)chData
{
    Byte chKey[] = { 0x01, 0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05, 0x01,
        0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05 };
    Byte chOUT[16];
    Byte chC[16];
    
    for (int i = 0; i < 8; i++) {
        chC[2 * i] = (Byte) (chData[i] >> 4);
        chC[2 * i + 1] = (Byte) (chData[i] & 0x0f);
    }
    
    for (int k = 0; k < 16; k++) {
        for (int j = 0; j < 16; j++) {
            if ((((j * chKey[k]) - chC[k]) % 16) == 0) {
                chOUT[k] = (Byte) j;
                j = 15;
            }
        }
    }
    
    for (int g = 0; g < 8; g++)
    {
        chOUTFinal[g] = (Byte) (((chOUT[2 * g] << 4) & 0xf0) + (chOUT[2 * g + 1] & 0x0f));
    }
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data
{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

#pragma mark set and get
- (NSMutableArray *)equipments {
    if (!_equipments) {
        _equipments = [NSMutableArray array];
    }
    return _equipments;
}

- (NSMutableArray *)valueStrs {
    if (!_valueStrs) {
        _valueStrs = [NSMutableArray array];
    }
    return _valueStrs;
}


@end

