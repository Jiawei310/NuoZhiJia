//
//  BindViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "BindViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

#import "StartLiaoLiaoViewController.h"

@interface BindViewController ()

@property (strong, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) UITableView *scanResultTableView;

@end

@implementation BindViewController
{
    NSArray *recipes;
    NSInteger num;
    
    UILabel *nameLabel;
    
    DataBaseOpration *dbOpration;
}
@synthesize centralMgr,arrayBLE;

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"蓝牙搜索"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"蓝牙搜索"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    _tempLabel.hidden = YES;
    //1.创建CBCentralManager
    self.centralMgr=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.arrayBLE=[[NSMutableArray alloc] init];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scanClick:) userInfo:nil repeats:NO];
}

//2.点击按钮 寻找CBPeripheral(扫描外设)
- (IBAction)scanClick:(id)sender
{
    [arrayBLE removeAllObjects];
    if (self.centralMgr.state==CBCentralManagerStatePoweredOn)
    {
        [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
    }
    [self.scanResultTableView reloadData];
}

#pragma mark -CBCentralManagerDelegate方法(required)
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSLog(@"name:%@ localName:%@", peripheral.name, [advertisementData objectForKey:CBAdvertisementDataLocalNameKey]);
    BLEInfo *discoveredBLEInfo=[[BLEInfo alloc] init];
    discoveredBLEInfo.discoveredPeripheral=peripheral;
    discoveredBLEInfo.rssi=RSSI;
    discoveredBLEInfo.localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    //搜索到设备，隐藏“搜索疗疗”按钮，添加tableview显示搜索到的设备
    if (_scanResultTableView == nil)
    {
        _bindImageView.image = [UIImage imageNamed:@"img_equipbox"];
        _tempLabel.hidden = NO;
        _alertLabel.text = @"已搜索到以下设备，点击设备名称即可连接";
        //1.修改“搜索疗疗”按钮Title
        [_scanButton setTitle:@"重新搜索" forState:UIControlStateNormal];
        //2.添加tableview显示搜索到的设备
        _scanResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(40, _scanButton.frame.origin.y + 40 + 10*Ratio, SCREENWIDTH-80*Ratio, SCREENHEIGHT - 40 - _scanButton.frame.origin.y - 10*Ratio)];
        _scanResultTableView.showsVerticalScrollIndicator = NO;
        _scanResultTableView.tableFooterView = [UIView new];
        [_scanResultTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        _scanResultTableView.delegate=self;
        _scanResultTableView.dataSource=self;
        
        [self.view addSubview:_scanResultTableView];
    }
    
    [self saveBLE:discoveredBLEInfo];
}

#pragma mark -更新tableview的数据源
-(BOOL)saveBLE:(BLEInfo *)discoveredBLEInfo
{
    for (BLEInfo *info in self.arrayBLE)
    {
        if ([info.discoveredPeripheral.identifier.UUIDString isEqualToString:discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString])
        {
            return NO;
        }
    }
    if ([discoveredBLEInfo.localName isEqualToString:@"NZJ-iHappySleep"] || [discoveredBLEInfo.localName containsString:@"Sleep4U"])
    {
        [self.arrayBLE addObject:discoveredBLEInfo];
    }
    [self.scanResultTableView reloadData];
    return YES;
}

#pragma mark -tableview的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayBLE.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *Identifier = @"BLEcell";
    
    UITableViewCell *BLEcell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    if (BLEcell==nil)
    {
        BLEcell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blecell"];
    }
    
    BLEInfo *discoveredBLEInfo=[BLEInfo new];
    discoveredBLEInfo=[arrayBLE objectAtIndex:indexPath.row];
    
    nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH/2, 40)];
    nameLabel.font=[UIFont systemFontOfSize:16];
    
    NSString* uuid = [NSString stringWithFormat:@"%@",[discoveredBLEInfo.discoveredPeripheral identifier]];
    uuid = [uuid substringFromIndex:[uuid length] - 13];
    
    nameLabel.text=discoveredBLEInfo.localName;
    
    [BLEcell.contentView addSubview:nameLabel];
    
    return BLEcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLEInfo *bleInfo=[arrayBLE objectAtIndex:indexPath.row];
    //1.将选择的外设存储到数据库并关闭数据库
    dbOpration=[[DataBaseOpration alloc] init];
    NSArray *tmpArr = [dbOpration getBluetoothDataFromDataBase];
    if (tmpArr.count > 0)
    {
        [dbOpration deletePeripheralInfo];
    }
    BluetoothInfo *bluetoothInfo=[[BluetoothInfo alloc] init];
    bluetoothInfo.saveId=@"1";
    bluetoothInfo.peripheralIdentify=bleInfo.discoveredPeripheral.identifier.UUIDString;
    bluetoothInfo.deviceName = bleInfo.localName;
    bluetoothInfo.deviceCode = nil;
    bluetoothInfo.deviceElectric = nil;
    [dbOpration insertPeripheralInfo:bluetoothInfo];
    //2.代理传值，将bluetoothInfo传回开始疗疗界面
    [self.blueDelegate sendBluetoothValueToStartLiaoLiao:bleInfo andBluetooth:bluetoothInfo];
    
    //绑定成功之后界面回跳至开始疗疗
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
