//
//  ViewController.m
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/20.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import "ViewController.h"
#import "DataTableView.h"
#import "Bluetooth.h"

@interface ViewController () <DataTableViewDelegate, BluetoothDelegate> {
    UIButton *_scanBtn;
    DataTableView *_dataTableView;
    
    UIButton *_normalBtn;
    UIButton *_simulateBtn;
    UIButton *_highBtn;
    
    UIButton *_addBtn;
    UITextField *_levelField;
    UIButton *_minusBtn;
    
    UIButton *_startBtn;
    UIButton *_endBtn;
 }

@property (nonatomic, strong) Bluetooth *bluetooth;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scanBtn.frame = CGRectMake(15.0f, 20.0f, 60.0f, 44.0f);
    self.dataTableView.frame = CGRectMake(0, 70.0f, self.view.frame.size.width, 500.0f);
    
    self.normalBtn.frame = CGRectMake(15, 70.0f, 60.0f, 44.0f);
    self.simulateBtn.frame = CGRectMake(90, 70.0, 60, 44);
    self.highBtn.frame = CGRectMake(160, 70.0, 60, 44);
    
    self.addBtn.frame = CGRectMake(15.0f, 200.0f, 60, 44);
    self.levelField.frame = CGRectMake(90, 200.0f, 60.0f, 44);
    self.minusBtn.frame = CGRectMake(160, 200.0f, 60, 44);
    
    self.startBtn.frame = CGRectMake(15.0f, 260, 60, 44);
    self.endBtn.frame = CGRectMake(150.0f, 260, 60, 44);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.scanBtn];
    
    [self.view addSubview:self.normalBtn];
    [self.view addSubview:self.simulateBtn];
    [self.view addSubview:self.highBtn];
    
    [self.view addSubview:self.addBtn];
    [self.view addSubview:self.levelField];
    [self.view addSubview:self.minusBtn];
    
    [self.view addSubview:self.startBtn];
    [self.view addSubview:self.endBtn];
    
    [self.view addSubview:self.dataTableView];

}

- (void)scanEquipment {
    if (self.bluetooth.connectSate == ConnectStateNormal) {
        //断开设备
        [self.bluetooth stopConnectEquipment:self.bluetooth.equipment];
    }
    else {
        [self.bluetooth scanEquipment];
        [self.dataTableView showViewInView:self.view];
    }
}

- (void)changeModel:(UIButton *)btn {
    if (btn == self.normalBtn) {
        self.bluetooth.equipment.workModel = WorkModelNormal;
    }
    else if (btn == self.simulateBtn) {
        self.bluetooth.equipment.workModel = WorkModelStimulate;
    }
    else if (btn == self.highBtn) {
        self.bluetooth.equipment.workModel = WorkModelHighIntensity;
    }
    [self.bluetooth changeWorkModel:self.bluetooth.equipment.workModel];
}

- (void)changeLevel:(UIButton *)btn {
    if (btn == self.addBtn) {
        if (self.bluetooth.equipment.level < 12) {
            self.bluetooth.equipment.level++;
        }
    }
    else if (btn == self.minusBtn) {
        if (self.bluetooth.equipment.level > 1) {
            self.bluetooth.equipment.level--;
        }
    }
    self.levelField.text = [NSString stringWithFormat:@"%ld", self.bluetooth.equipment.level];
    [self.bluetooth changeLevel:self.bluetooth.equipment.level];
}

- (void)startBtnAction:(UIButton *)btn {
    [self.bluetooth startWork];
}


- (void)endBtnAction:(UIButton *)btn {
    [self.bluetooth endWork];
}

#pragma mark -- DataTableViewDelegate
- (void)dataTableView:(DataTableView *)dataTableView selectRowObject:(id)object {
    [self.bluetooth connectEquipment:object];
}

#pragma mark -- BluetoothDelegate
- (void)scanedEquipments:(NSArray *)equipments {
    self.dataTableView.dataArr = equipments;
}

- (void)connectState:(ConnectState)connectState Error:(NSError *)error {
    if (connectState == ConnectStateNormal) {
        [self.scanBtn setTitle:@"断开" forState:UIControlStateNormal];
    }
    else {
        [self.scanBtn setTitle:@"scan" forState:UIControlStateNormal];

        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"有错误，连接失败" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *  action) {
            
        }];
        [alertC addAction:alert];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

- (void)wearState:(WearState)wearState Error:(NSError *)error {
    if (wearState == WearStateNormal) {
        NSLog(@"WearStateNormal");
    }
    else {
        NSLog(@"WearStateError");
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

- (UIButton *)scanBtn {
    if (!_scanBtn) {
        _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scanBtn.layer.borderColor = [[UIColor blueColor] CGColor];
        _scanBtn.layer.borderWidth = 1.0;
        [_scanBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
        [_scanBtn setTitle:@"scan" forState:(UIControlStateNormal)];
        [_scanBtn addTarget:self
                     action:@selector(scanEquipment)
           forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _scanBtn;
}

- (DataTableView *)dataTableView {
    if (!_dataTableView) {
        _dataTableView = [[DataTableView alloc] init];
        _dataTableView.layer.borderColor = [[UIColor greenColor] CGColor];
        _dataTableView.layer.borderWidth = 1.0;
        
        _dataTableView.dataType = DataTypeBluetooth;
        _dataTableView.delegate = self;
    }
    return _dataTableView;
}

- (UIButton *)normalBtn {
    if (!_normalBtn) {
        _normalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _normalBtn.backgroundColor = [UIColor blueColor];
        [_normalBtn setTitle:@"normal" forState:(UIControlStateNormal)];

        [_normalBtn addTarget:self
                       action:@selector(changeModel:)
           forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _normalBtn;
}

- (UIButton *)simulateBtn {
    if (!_simulateBtn) {
        _simulateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _simulateBtn.backgroundColor = [UIColor purpleColor];
        [_simulateBtn setTitle:@"simulate" forState:(UIControlStateNormal)];

        [_simulateBtn addTarget:self
                         action:@selector(changeModel:)
           forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _simulateBtn;
}

- (UIButton *)highBtn {
    if (!_highBtn) {
        _highBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _highBtn.backgroundColor = [UIColor redColor];
        [_highBtn setTitle:@"high" forState:(UIControlStateNormal)];
        [_highBtn addTarget:self
                     action:@selector(changeModel:)
           forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _highBtn;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.backgroundColor = [UIColor redColor];
        [_addBtn setTitle:@"加" forState:(UIControlStateNormal)];
        [_addBtn addTarget:self
                    action:@selector(changeLevel:)
           forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _addBtn;
}

- (UITextField *)levelField {
    if (!_levelField) {
        _levelField = [[UITextField alloc] init];
        _levelField.enabled = NO;
        _levelField.borderStyle = UITextBorderStyleLine;
        _levelField.text = @"1";
    }
    return _levelField;
}

- (UIButton *)minusBtn {
    if (!_minusBtn) {
        _minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _minusBtn.backgroundColor = [UIColor greenColor];
        
        [_minusBtn setTitle:@"减" forState:(UIControlStateNormal)];
        [_minusBtn addTarget:self
                      action:@selector(changeLevel:)
           forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _minusBtn;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.backgroundColor = [UIColor greenColor];

        [_startBtn setTitle:@"开始" forState:(UIControlStateNormal)];
        [_startBtn addTarget:self
                      action:@selector(startBtnAction:)
            forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _startBtn;
}

- (UIButton *)endBtn {
    if (!_endBtn) {
        _endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _endBtn.backgroundColor = [UIColor redColor];
        [_endBtn setTitle:@"结束" forState:(UIControlStateNormal)];
        [_endBtn addTarget:self
                      action:@selector(endBtnAction:)
            forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _endBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
