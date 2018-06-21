//
//  StartsViewController.h
//  Cervella
//
//  Created by Justin on 2017/6/29.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEInfo.h"
#import "TreatInfo.h"
#import "BluetoothInfo.h"
#import "Bluetooth.h"

#import "BindViewController.h"

@interface StartsViewController : UIViewController
@property (nonatomic, strong) PatientInfo *patientInfo;

@property (nonatomic, strong) Bluetooth *bluetooth;
@property (strong,nonatomic) BluetoothInfo *bluetoothInfo;





@end
