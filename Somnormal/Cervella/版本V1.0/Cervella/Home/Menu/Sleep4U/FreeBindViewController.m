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
    
    self.title = @"Unpair Cervella";
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
    
    UIImageView *device = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_device"]];
    UIImageView *phone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_phone"]];
    UIImageView *unbind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_unbind"]];
    if (SCREENHEIGHT == 480)
    {
        device.frame=CGRectMake(SCREENWIDTH/20, SCREENHEIGHT/30+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        phone.frame=CGRectMake(SCREENWIDTH*12/20, SCREENHEIGHT/30+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        unbind.frame=CGRectMake(SCREENWIDTH*9/20, SCREENHEIGHT/8+65, SCREENWIDTH*2/20, SCREENWIDTH*3/20);
    }
    else
    {
        device.frame=CGRectMake(SCREENWIDTH/20, SCREENHEIGHT/10+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        phone.frame=CGRectMake(SCREENWIDTH*12/20, SCREENHEIGHT/10+65, SCREENWIDTH*7/20, SCREENWIDTH*7/20);
        unbind.frame=CGRectMake(SCREENWIDTH*9/20, SCREENHEIGHT/6+65, SCREENWIDTH*2/20, SCREENWIDTH*2/20);
    }
    
    [self.view addSubview:device];
    [self.view addSubview:phone];
    [self.view addSubview:unbind];
    
    [_FreeBindButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    [_FreeBindButton setTitle:@"Unpair Cervella" forState:UIControlStateNormal];
    if (SCREENHEIGHT == 667)
    {
        _FreeBindButton.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    else if (SCREENWIDTH == 736)
    {
        _FreeBindButton.titleLabel.font = [UIFont systemFontOfSize:22.5];
    }
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
    if (arr.count == 5)
    {
        [self.navigationController popToViewController:[arr objectAtIndex:2] animated:YES];
    }
    else if (arr.count == 4)
    {
        [self.navigationController popToViewController:[arr objectAtIndex:1] animated:YES];
    }
    else
    {
        [self.navigationController popToViewController:[arr objectAtIndex:0] animated:YES];
    }
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
