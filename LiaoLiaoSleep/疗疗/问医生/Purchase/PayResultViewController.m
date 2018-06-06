//
//  PayResultViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PayResultViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UIViewController+HUD.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

#import "DataHandle.h"

#import "EMClient.h"
#import "Order.h"
#import "DataSigner.h"

#import "DoctorHomeViewController.h"
#import "ConsultRuleViewController.h"
#import "SymptomDescViewController.h"
#import "PurchaseRecordViewController.h"

@interface PayResultViewController ()

@property(strong, nonatomic) UIView * resultView;
@property(strong, nonatomic) UIView * orderView;
@property(copy, nonatomic) DataHandle * handle;

@end

@implementation PayResultViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"支付结果"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"支付结果"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    
    //添加返回按钮
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    backLogin.frame = CGRectMake(12, 30, 23, 23);
    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    
    UIBarButtonItem *completeButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(complete)];
    self.navigationItem.rightBarButtonItem = completeButton;
    _handle = [[DataHandle alloc] init];
    
    if ([_orderState isEqualToString:@"success"])
    {
        [self uploadPurchaseRecord];
        [self createSuccessView];
        self.navigationItem.title = @"支付成功";
    }
    else
    {
        [self createFailureView];
        self.navigationItem.title = @"支付失败";
    }
}

#pragma mark -- 完成支付
- (void)complete
{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[DoctorHomeViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)createSuccessView
{
    [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadLeaveNumber) andDictionary:@{@"LeaveNumber":_orderCount,@"PatientID":_patientID}];
    
    _resultView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 122*Rate_NAV_H)];
    _resultView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_resultView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(52*Rate_NAV_W, 40*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    imageView.image = [UIImage imageNamed:@"icon_cehnggong.png"];
    imageView.layer.cornerRadius = 25*Rate_NAV_H;
    imageView.clipsToBounds = YES;
    [_resultView addSubview:imageView];
    
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(132*Rate_NAV_W, 39*Rate_NAV_H, 83*Rate_NAV_W, 28*Rate_NAV_H)];
    lable1.text = @"恭喜您";
    lable1.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    lable1.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    lable1.adjustsFontSizeToFitWidth = YES;
    [_resultView addSubview:lable1];
    
    UILabel *lable2 = [[UILabel alloc] init];
    lable2.text = @"已成功购买";
    lable2.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    lable2.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    NSDictionary *attrs2 = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14*Rate_NAV_H]};
    CGSize size2 = [lable2.text sizeWithAttributes:attrs2];
    [lable2 setFrame:CGRectMake(132*Rate_NAV_W, 72*Rate_NAV_H, size2.width, 20*Rate_NAV_H)];
    [_resultView addSubview:lable2];
    
    UILabel *lable3 = [[UILabel alloc] init];
    lable3.text = _orderCount;
    lable3.textColor = [UIColor redColor];
    lable3.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    NSDictionary *attrs3 = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14*Rate_NAV_H]};
    CGSize size3 = [lable3.text sizeWithAttributes:attrs3];
    [lable3 setFrame:CGRectMake(CGRectGetMaxX(lable2.frame), 72*Rate_NAV_H, size3.width, 20*Rate_NAV_H)];
    [_resultView addSubview:lable3];
    
    UILabel *lable4 = [[UILabel alloc] init];
    lable4.text = _orderName;
    lable4.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    lable4.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    NSDictionary *attrs4 = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14*Rate_NAV_H]};
    CGSize size4 = [lable4.text sizeWithAttributes:attrs4];
    [lable4 setFrame:CGRectMake(CGRectGetMaxX(lable3.frame), 72*Rate_NAV_H, size4.width, 20*Rate_NAV_H)];
    [_resultView addSubview:lable4];
    
    _orderView = [[UIView alloc] initWithFrame:CGRectMake(0, 124*Rate_NAV_H, SCREENWIDTH, 136*Rate_NAV_H)];
    _orderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_orderView];
    
    UILabel *orderInfo = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 10*Rate_NAV_H, 67*Rate_NAV_W, 22*Rate_NAV_H)];
    orderInfo.text = @"订单详情";
    orderInfo.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.41 alpha:1.0];
    orderInfo.font = [UIFont boldSystemFontOfSize:16*Rate_NAV_H];
    [_orderView addSubview:orderInfo];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 41*Rate_NAV_H, 355*Rate_NAV_W, Rate_NAV_H)];
    line.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_orderView addSubview:line];
    
    UILabel *orderName = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 54*Rate_NAV_H, 200*Rate_NAV_W, 20*Rate_NAV_H)];
    orderName.text = [NSString stringWithFormat:@"订单名称：%@",_orderName];
    orderName.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.41 alpha:1.0];
    orderName.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    orderName.adjustsFontSizeToFitWidth = YES;
    [_orderView addSubview:orderName];
    
    UILabel *orderCode = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 80*Rate_NAV_H, 200*Rate_NAV_W, 20*Rate_NAV_H)];
    orderCode.text = [NSString stringWithFormat:@"订单编号：%@",_orderID];
    orderCode.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.41 alpha:1.0];
    orderCode.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    orderCode.adjustsFontSizeToFitWidth = YES;
    [_orderView addSubview:orderCode];
    
    UILabel *orderPrice = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 106*Rate_NAV_H, 200*Rate_NAV_W, 20*Rate_NAV_H)];
    orderPrice.text = [NSString stringWithFormat:@"订单支付：%@元",_orderPrice];
    orderPrice.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.41 alpha:1.0];
    orderPrice.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    orderPrice.adjustsFontSizeToFitWidth = YES;
    [_orderView addSubview:orderPrice];
    
    UIButton *recoder = [[UIButton alloc] initWithFrame:CGRectMake(271*Rate_NAV_W, 270*Rate_NAV_H, 100*Rate_NAV_W, 22*Rate_NAV_H)];
    [recoder setTitle:@"查看购买记录" forState:(UIControlStateNormal)];
    recoder.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [recoder setTitleColor:[UIColor colorWithRed:0.30 green:0.57 blue:0.89 alpha:1.0] forState:(UIControlStateNormal)];
    [recoder addTarget:self action:@selector(lookRecoder) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:recoder];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(0, 492*Rate_NAV_H, SCREENWIDTH, 20*Rate_NAV_H)];
    notice.text = @"现在，您可以向医生提问了！";
    notice.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    notice.font =[UIFont systemFontOfSize:14*Rate_NAV_H];
    notice.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:notice];
    
    UIButton *ask = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 523*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [ask setTitle:@"我要提问" forState:(UIControlStateNormal)];
    ask.layer.cornerRadius = 25;
    ask.clipsToBounds = YES;
    [ask setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
    [ask addTarget:self action:@selector(ask) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:ask];
}

- (void)createFailureView
{
    _resultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 122*Rate_NAV_H)];
    _resultView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_resultView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(90*Rate_NAV_W, 40*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    imageView.image = [UIImage imageNamed:@"icon_wrong.png"];
    imageView.layer.cornerRadius = 25*Rate_NAV_H;
    imageView.clipsToBounds = YES;
    [_resultView addSubview:imageView];
    
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(170*Rate_NAV_W, 39*Rate_NAV_H, 100*Rate_NAV_W, 20*Rate_NAV_H)];
    lable1.text = @"对不起";
    lable1.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    lable1.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_resultView addSubview:lable1];
    
    UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(170*Rate_NAV_W, 72*Rate_NAV_H, 116*Rate_NAV_W, 20*Rate_NAV_H)];
    lable2.text = @"个体账户支付失败";
    lable2.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    lable2.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_resultView addSubview:lable2];
    
    _orderView = [[UIView alloc] initWithFrame:CGRectMake(0, 124*Rate_NAV_H, SCREENWIDTH, 111*Rate_NAV_H)];
    _orderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_orderView];
    
    UILabel *orderInfo = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 10*Rate_NAV_H, 67*Rate_NAV_W, 22*Rate_NAV_H)];
    orderInfo.text = @"订单详情";
    orderInfo.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.41 alpha:1.0];
    orderInfo.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [_orderView addSubview:orderInfo];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 41*Rate_NAV_H, 355*Rate_NAV_W, Rate_NAV_H)];
    line.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_orderView addSubview:line];
    
    UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 53*Rate_NAV_H, 200*Rate_NAV_W, 20*Rate_NAV_H)];
    result.text = [NSString stringWithFormat:@"错误码：%@",_orderResult];
    result.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    result.font =[UIFont systemFontOfSize:14*Rate_NAV_H];
    [_orderView addSubview:result];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 80*Rate_NAV_H, 210*Rate_NAV_W, 20*Rate_NAV_H)];
    notice.text = @"如有疑问请咨询第三方支付平台";
    notice.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];;
    notice.font =[UIFont systemFontOfSize:14*Rate_NAV_H];
    [_orderView addSubview:notice];
    
    UIButton *repeate = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 523*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [repeate setTitle:@"重新支付" forState:(UIControlStateNormal)];
    repeate.layer.cornerRadius = 25*Rate_NAV_H;
    repeate.clipsToBounds = YES;
    [repeate setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
    [repeate addTarget:self action:@selector(complete) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:repeate];
}

#pragma mark -- 上传购买记录
- (void)uploadPurchaseRecord
{
    NSDictionary *dic = @{@"PatientID":_patientID,@"OrderID":_orderID,@"Count":_orderCount,@"TotalPrice":_orderPrice,@"OrderDate":[self getCurrentTime]};
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPurchaseRecord) andDictionary:dic];
    req.timeoutInterval = 5.0;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data)
        {
            if([[_handle objectFromeResponseString:data andType:(DataModelBackTypeUploadPurchaseRecord)] isEqualToString:@"OK"])
            {
                [self showHint:@"购买记录上传成功"];
            }
            else
            {
                [self showHint:@"购买记录上传失败"];
            }
        }
        else
        {
            [self showHint:@"购买记录上传失败"];
        }
    }];
}

#pragma mark -- 查看购买记录
- (void)lookRecoder
{
    PurchaseRecordViewController *record = [[PurchaseRecordViewController alloc] init];
    record.patientID = _patientID;
    [self.navigationController pushViewController:record animated:NO];
}

#pragma mark -- 提问
- (void)ask
{
    SymptomDescViewController *write = [[SymptomDescViewController alloc] init];
    [self.navigationController pushViewController:write animated:NO];
}

- (NSString *)getCurrentTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy.MM.dd HH:mm";
    return [dateFormatter stringFromDate:[NSDate date]];
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
