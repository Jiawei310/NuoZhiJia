//
//  BindViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEInfo.h"
#import "DataBaseOpration.h"
#import "BluetoothInfo.h"

@protocol sendBluetoothValue <NSObject>

- (void)sendBluetoothValueToStartLiaoLiao:(BLEInfo *)bleInfo andBluetooth:(BluetoothInfo *)bluetoothInfo;

@end

@interface BindViewController : UIViewController<CBCentralManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property NSString *bindFlag;

@property (nonatomic, weak) id<sendBluetoothValue>blueDelegate;

@property (nonatomic,strong) CBCentralManager *centralMgr;
@property (nonatomic,strong) NSMutableArray *arrayBLE;

@property NSMutableArray *peripheralsArray;


@property (strong, nonatomic) IBOutlet UIImageView *bindImageView;
@property (strong, nonatomic) IBOutlet UILabel *alertLabel;
@property (strong, nonatomic) IBOutlet UIButton *scanButton;

@end
