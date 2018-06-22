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

@interface BindViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property NSString *bindFlag;

@property (nonatomic,strong) NSMutableArray *arrayBLE;

@property (strong, nonatomic) IBOutlet UIButton *scanButton;
@property (strong, nonatomic) IBOutlet UITableView *scanResultTableView;
@property (strong, nonatomic) IBOutlet UILabel *alertLabel;

@end
