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

#import "BindViewController.h"

@protocol sendElectricQuality <NSObject>

-(void)sendElectricQualityValue:(NSString *)string;

@end

@interface StartsViewController : UIViewController

@property (nonatomic, strong) PatientInfo *patientInfo;
@property BluetoothInfo *bluetoothInfo;
@property id<sendElectricQuality>delegate;






@end
