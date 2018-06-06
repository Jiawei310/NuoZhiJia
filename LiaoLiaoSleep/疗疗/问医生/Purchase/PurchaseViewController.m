//
//  PurchaseViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PurchaseViewController.h"
#import "PayResultViewController.h"
#import "AlixPayOrder.h"
#import "Order.h"
#import "DataSigner.h"
#import "XMLDictionary.h"
#import <AlipaySDK/AlipaySDK.h>
#import <CommonCrypto/CommonDigest.h>
#import "WXApi.h"  // 微信支付头文件
#import "WXApiObject.h" // 回调头文件
#import "payRequsestHandler.h" // 签名相关头文件
#import "DataMD5.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface PurchaseViewController ()<UITableViewDelegate,UITableViewDataSource,WXApiDelegate>

@property(strong, nonatomic) UITableView * tableV;
@property(strong, nonatomic) UIView * headerView;
//预支付网关url地址-------微信
@property (nonatomic,strong) NSString* payUrl;

//debug信息
@property (nonatomic,strong) NSMutableString *debugInfo;
@property (nonatomic,assign) NSInteger lastErrCode;//返回的错误码

//商品信息
@property(copy, nonatomic)NSString * orderName;
@property(copy, nonatomic)NSString * orderID;
@property(copy, nonatomic)NSString * orderPrice;

@end

@implementation PurchaseViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"支付方式"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeiXinPay" object:nil];
    
    [MobClick endLogPageView:@"支付方式"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    self.navigationItem.title = @"支付方式";
    
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
    
    _payUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorde";
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AliPayOrWeiXinPay:) name:@"AliPayOrWeiXinPay" object:nil];
    [self createTableView];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeiXinPay" object:nil];
}

- (void)createTableView
{
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _tableV.backgroundColor = [UIColor whiteColor];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self createHeaderView];
    _tableV.tableHeaderView = _headerView;
    [self.view addSubview:_tableV];
}

- (void)createHeaderView
{
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 70*Rate_NAV_H)];
    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 15*Rate_NAV_H, 60*Rate_NAV_W, 20*Rate_NAV_H)];
    total.text = @"支付:";
    total.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    total.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_headerView addSubview:total];
    
    UILabel *totalPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(total.frame), 15*Rate_NAV_H, 68*Rate_NAV_W, 20*Rate_NAV_H)];
    totalPrice.text = _totalPrice;
    totalPrice.tag = 100;
    totalPrice.textColor = [UIColor redColor];
    totalPrice.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    totalPrice.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:totalPrice];
    
    UILabel *unit = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(totalPrice.frame), 15*Rate_NAV_H, 20*Rate_NAV_H, 20*Rate_NAV_H)];
    unit.text = @"元";
    unit.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    unit.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_headerView addSubview:unit];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 50*Rate_NAV_H, SCREENWIDTH, 20*Rate_NAV_H)];
    line.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_headerView addSubview:line];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Rate_NAV_H;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str  = @"payChooseCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:str];
    }
    if (indexPath.section == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_zhifubao.png"];
        cell.textLabel.text = @"支付宝";
    }
    else if (indexPath.section == 1)
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_weixin.png"];
        cell.textLabel.text = @"微信支付";
    }
    else if (indexPath.section == 2)
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_yinlian.png"];
        cell.textLabel.text = @"银联快捷支付";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //支付宝支付
    if (indexPath.section == 0)
    {
        [self doAliPay];
    }
    //微信支付
    else if (indexPath.section == 1)
    {
        //判断是否安装了微信
        if([WXApi isWXAppInstalled])
        {
            [self sendPay];
        }
        else
        {
            UIAlertView * alerV = [[UIAlertView alloc] initWithTitle:@"微信支付" message:@"未检测到微信" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alerV show];
        }
    }
    //银联支付
    else if (indexPath.section == 2)
    {
        UIAlertView * alerV = [[UIAlertView alloc] initWithTitle:@"银联支付" message:@"暂未开放" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alerV show];
    }
}

#pragma mark -- 获取商品编号
- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

/**
 *  微信支付
 */
- (void)sendPay
{
    //创建一次支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] init];
    req.name = _name;
    req.totoalPrice = [NSString stringWithFormat:@"%.0f",[_totalPrice floatValue]*100];
//    req.totoalPrice = @"1";
    req.orderID = [self generateTradeNO];
    _orderID = req.orderID;
    //初始化支付签名对象
    [req init:WX_AppID mch_id:WX_MCH_ID];
    //设置密钥
    [req setKey:WX_PartnerKey];
    //获取到实际调起微信支付的参数后，在app端调起支付，即下单并获得二次签名
    NSMutableDictionary *dict = [req sendPay_demo];
    if(dict == nil)
    {
        //错误提示
        NSString *debug = [req getDebugifo];
        NSLog(@"%@\n\n",debug);
    }
    else
    {
        NSLog(@"%@\n\n",[req getDebugifo]);
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        //调起微信支付
        PayReq* req  = [[PayReq alloc] init];
        req.openID  = [dict objectForKey:@"appid"];
        req.partnerId = [dict objectForKey:@"partnerid"];
        req.prepayId = [dict objectForKey:@"prepayid"];
        req.nonceStr = [dict objectForKey:@"noncestr"];
        req.timeStamp = stamp.intValue;
        req.package = [dict objectForKey:@"package"];
        req.sign = [dict objectForKey:@"sign"];
        [WXApi sendReq:req];    // 发起支付
    }
}

#pragma mark -- 支付宝支付
-(void)doAliPay
{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    NSString *partner = PartnerID;
    NSString *seller = SellerID;
    NSString *privateKey = PartnerRSAPrivKey;
    //partner和seller获取失败,提示
    if ([partner length] == 0 || [seller length] == 0 || [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    _orderID = order.outTradeNO;
    order.subject = _name; //商品标题
    order.body = @"上海诺之嘉医疗器械有限公司"; //商品描述
    order.totalFee = _totalPrice; //商品价格
//    order.totalFee = @"0.01";
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alisdkPaydemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil)
    {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
    
}

#pragma mark -- 微信支付结果通知
-(void)AliPayOrWeiXinPay:(NSNotification *)text
{
    NSString * dec = text.userInfo[@"resultDec"];
    NSString * state = text.userInfo[@"state"];
    PayResultViewController * result = [[PayResultViewController alloc]init];
    result.orderResult = dec;
    result.orderState = state;
    result.orderName = _name;
    result.orderID = _orderID;
    result.orderPrice = _totalPrice;
    result.orderCount = _count;
    result.patientID = _patientID;
    [self.navigationController pushViewController:result animated:YES];
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
