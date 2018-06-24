//
//  BindViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "BindViewController.h"
#import "BluetoothInfo.h"
#import "StartsViewController.h"

@interface BindViewController ()<BluetoothDelegate>
@property (nonatomic, strong) Bluetooth *bluetooth;

@end

@implementation BindViewController
{
    NSArray *recipes;
    NSInteger num;
    
    UILabel *nameLabel;
    UILabel *UUIDLabel;
}
@synthesize arrayBLE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Search for Cervella";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent=YES;
    
    //添加返回按钮
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    backLogin.frame = CGRectMake(12, 30, 23, 23);
    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    
    [_scanButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    [self.scanButton setTitle:@"Search Again" forState:UIControlStateNormal];
    if (SCREENHEIGHT == 667)
    {
        _scanButton.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    else if (SCREENWIDTH == 736)
    {
        _scanButton.titleLabel.font = [UIFont systemFontOfSize:22.5];
    }
    
    _scanResultTableView.delegate = self;
    _scanResultTableView.dataSource = self;

    UIImageView *device = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_device"]];
    UIImageView *phone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_phone"]];
    UIImageView *bind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_bind"]];
    if (SCREENHEIGHT == 480)
    {
        device.frame = CGRectMake(SCREENWIDTH/20, SCREENHEIGHT/30+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        phone.frame = CGRectMake(SCREENWIDTH*12/20, SCREENHEIGHT/30+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        bind.frame = CGRectMake(SCREENWIDTH*9/20, SCREENHEIGHT/9+65, SCREENWIDTH*2/20, SCREENWIDTH*3/20);
    }
    else
    {
        device.frame = CGRectMake(SCREENWIDTH/20, SCREENHEIGHT/10+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        phone.frame = CGRectMake(SCREENWIDTH*12/20, SCREENHEIGHT/10+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        bind.frame = CGRectMake(SCREENWIDTH*9/20, SCREENHEIGHT/6+65, SCREENWIDTH*2/20, SCREENWIDTH*3/20);
    }
    
    [self.view addSubview:device];
    [self.view addSubview:phone];
    [self.view addSubview:bind];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scanClick:) userInfo:nil repeats:NO];
    
    self.arrayBLE = [[NSMutableArray alloc] init];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//2.点击按钮 寻找CBPeripheral(扫描外设)
- (IBAction)scanClick:(id)sender
{
    [arrayBLE removeAllObjects];
    [self.bluetooth scanEquipment];
    [self.scanResultTableView reloadData];
}

#pragma mark -- BluetoothDelegate
- (void)scanedEquipments:(NSArray *)equipments {
    //搜索到设备
    arrayBLE = [equipments mutableCopy];
    [self.scanResultTableView reloadData];
}

#pragma mark -tableview的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayBLE.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *Identifier = @"BLEcell";
    
    UITableViewCell *BLEcell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (BLEcell == nil)
    {
        BLEcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blecell"];
    }
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/30, 0, SCREENWIDTH/2, 40)];
    nameLabel.font = [UIFont systemFontOfSize:16];
    UUIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2 + SCREENWIDTH/30, 0, SCREENWIDTH/2-SCREENWIDTH/15, 40)];
    UUIDLabel.font = [UIFont systemFontOfSize:16];
    UUIDLabel.textAlignment = NSTextAlignmentRight;
    
    
    Equipment *eq = [arrayBLE objectAtIndex:indexPath.row];
    nameLabel.text = eq.peripheral.name;
    
    NSString* uuid = [NSString stringWithFormat:@"%@",[eq.peripheral identifier]];
    uuid = [uuid substringFromIndex:[uuid length] - 13];
    UUIDLabel.text = uuid;
    
    [BLEcell.contentView addSubview:nameLabel];
    [BLEcell.contentView addSubview:UUIDLabel];
    
    return BLEcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Equipment *eq = [arrayBLE objectAtIndex:indexPath.row];
    if (self.bindViewControllerSelectEquiment) {
        self.bindViewControllerSelectEquiment(eq);
    }
    
    NSArray *arr = self.navigationController.viewControllers;
    if ([_bindFlag isEqualToString:@"1"])
    {
        [self.navigationController popToViewController:[arr objectAtIndex:arr.count - 2] animated:YES];
    }
    else if ([_bindFlag isEqualToString:@"2"])
    {
        [self.navigationController popToViewController:[arr objectAtIndex:arr.count - 3] animated:YES];
    }
}

#pragma mark setter and getter
- (Bluetooth *)bluetooth {
    if (!_bluetooth) {
        _bluetooth = [Bluetooth shareBluetooth];
        _bluetooth.delegate = self;
    }
    return _bluetooth;
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
