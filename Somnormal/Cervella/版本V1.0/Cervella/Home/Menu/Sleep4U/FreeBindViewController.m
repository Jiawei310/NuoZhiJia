//
//  FreeBindViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/8.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "FreeBindViewController.h"

@interface FreeBindViewController ()

@end

@implementation FreeBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.title = @"Unpair Cervella";
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.frame = CGRectMake(0, 0, 44.0, 100);
    titleLab.text = @"Unpair Cervella";
    titleLab.textColor = [UIColor whiteColor];
    UIBarButtonItem *titleBtnItem = [[UIBarButtonItem alloc] initWithCustomView:titleLab];

    
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
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem, titleBtnItem];
    
    UIImageView *device = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_device"]];
    UIImageView *phone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_phone"]];
    UIImageView *unbind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_unbind"]];
    if (SCREENHEIGHT == 568) {
        device.frame = CGRectMake(15, 100, 90, 90);
        unbind.frame = CGRectMake((SCREENWIDTH - 40)/2.0, 125, 40, 40);
        phone.frame = CGRectMake(SCREENWIDTH - 105, 100, 90, 90);
        _Label_One.frame = CGRectMake(15, 220, SCREENWIDTH - 30, 120);

    } else if (SCREENHEIGHT == 667) {
        device.frame = CGRectMake(15, 120, 110, 110);
        unbind.frame = CGRectMake((SCREENWIDTH - 40)/2.0, 150, 40, 40);
        phone.frame = CGRectMake(SCREENWIDTH - 135, 120, 110, 110);
        _Label_One.frame = CGRectMake(15, 240, SCREENWIDTH - 30, 120);

    } else if (SCREENHEIGHT == 736) {
        device.frame = CGRectMake(15, 120, 110, 110);
        unbind.frame = CGRectMake((SCREENWIDTH - 40)/2.0, 145, 40, 40);
        phone.frame = CGRectMake(SCREENWIDTH - 135, 120, 110, 110);
        _Label_One.frame = CGRectMake(15, 240, SCREENWIDTH - 30, 120);

    }
    else if (SCREENHEIGHT == 812) {
        device.frame = CGRectMake(15, 120, 110, 110);
        unbind.frame = CGRectMake((SCREENWIDTH - 40)/2.0, 145, 40, 40);
        phone.frame = CGRectMake(SCREENWIDTH - 135, 120, 110, 110);
        _Label_One.frame = CGRectMake(15, 240, SCREENWIDTH - 30, 120);

    }
    
    [self.view addSubview:device];
    [self.view addSubview:phone];
    [self.view addSubview:unbind];
    
    [_FreeBindButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    [_FreeBindButton setTitle:@"Unpair Cervella" forState:UIControlStateNormal];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)FreeBindButtonClick:(UIButton *)sender
{
    //1.删除数据库中的蓝牙绑定数据
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    [dbOpration deletePeripheralInfo];
    [dbOpration closeDataBase];
    
    
    NSNotification *notification = [NSNotification notificationWithName:@"Free" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    //2.跳转界面
    NSArray *arr = self.navigationController.viewControllers;
    [self.navigationController popToViewController:[arr objectAtIndex:arr.count - 3] animated:YES];
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
