//
//  ConsultRuleViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/17.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "ConsultRuleViewController.h"
#import "PurchaseViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

@interface ConsultRuleViewController ()

@property(strong, nonatomic)UIView * ruleView;
@property(strong, nonatomic)UIView * priceView;
@property(strong, nonatomic)UIView * purchaseView;

@end

@implementation ConsultRuleViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"规则与购买"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick endLogPageView:@"规则与购买"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"规则与购买";
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    
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
    
    [self createRuleView];
    [self createPriceView];
    [self createPurchaseView];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createRuleView
{
    _ruleView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 253*Rate_NAV_H)];
    _ruleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_ruleView];
    
    UILabel *tittle = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 20*Rate_NAV_H, 200*Rate_NAV_W, 25*Rate_NAV_H)];
    tittle.text = @"问医生规则";
    tittle.textColor = [UIColor blackColor];
    tittle.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_ruleView addSubview:tittle];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 55*Rate_NAV_H, 335*Rate_NAV_W, 2*Rate_NAV_H)];
    line.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_ruleView addSubview:line];
    
    UILabel *rules = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 72*Rate_NAV_H, 335*Rate_NAV_W, 156*Rate_NAV_H)];
    rules.text = @"每个免费问题可以进行10次追问，不另外消耗问题，超过10次将另外消耗1个免费问题来再次获得10次追问机会。即每个免费问题可以在医生接诊后的48小时内问10个小问题，问题一旦关闭要重新激活则需要另外消耗一个免费问题。";
    rules.numberOfLines = 0;
    rules.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    rules.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [_ruleView addSubview:rules];
}

- (void)createPriceView
{
    _priceView = [[UIView alloc] initWithFrame:CGRectMake(0, 291*Rate_NAV_H, 375*Rate_NAV_W, 262*Rate_NAV_H)];
    _priceView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_priceView];
    
    UIImageView *askImage = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 10*Rate_NAV_H, 50*Rate_NAV_H, 50*Rate_NAV_H)];
    askImage.image = [UIImage imageNamed:@"buy_icon_question.png"];
    [_priceView addSubview:askImage];
    
    UILabel *singlePrice = [[UILabel alloc] initWithFrame:CGRectMake(90*Rate_NAV_W, 10*Rate_NAV_H, 20*Rate_NAV_W, 22*Rate_NAV_H)];
    singlePrice.text = @"20";
    singlePrice.textColor = [UIColor redColor];
    singlePrice.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [singlePrice sizeToFit];
    [_priceView addSubview:singlePrice];
    
    UILabel *singleUnit = [[UILabel alloc] initWithFrame:CGRectMake(109*Rate_NAV_W, 10*Rate_NAV_H, 40*Rate_NAV_W, 22*Rate_NAV_H)];
    singleUnit.text = @"元/题";
    singleUnit.textColor =[UIColor colorWithRed:0.62 green:0.64 blue:0.64 alpha:1.0];
    singleUnit.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    singleUnit.adjustsFontSizeToFitWidth = YES;
    [_priceView addSubview:singleUnit];
    
    UILabel *askNotie = [[UILabel alloc] initWithFrame:CGRectMake(90*Rate_NAV_W, 35*Rate_NAV_H, 80*Rate_NAV_W, 22*Rate_NAV_H)];
    askNotie.text = @"向医生提问";
    askNotie.textColor =[UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    askNotie.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    askNotie.adjustsFontSizeToFitWidth = YES;
    [_priceView addSubview:askNotie];
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 69*Rate_NAV_H, 355*Rate_NAV_W, 2*Rate_NAV_H)];
    line1.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_priceView addSubview:line1];
    
    UILabel *priceNotie = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 83*Rate_NAV_H, 81*Rate_NAV_W, 22*Rate_NAV_H)];
    priceNotie.text = @"套餐价格：";
    priceNotie.textColor =[UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    priceNotie.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    priceNotie.adjustsFontSizeToFitWidth = YES;
    [_priceView addSubview:priceNotie];
    
    for (int i = 0; i < 2; i++)
    {
        UIButton *price = [[UIButton alloc] initWithFrame:CGRectMake((20+140*i)*Rate_NAV_W, 115*Rate_NAV_H, 120*Rate_NAV_W, 30*Rate_NAV_H)];
        price.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
        if (i == 0)
        {
            [price setTitle:@"10题 / 180元" forState:(UIControlStateNormal)];
        }
        else
        {
            [price setTitle:@"20题 / 340元" forState:(UIControlStateNormal)];
        }
        price.tag = i+1;
        price.layer.cornerRadius = 15*Rate_NAV_H;
        price.clipsToBounds = YES;
        [price setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
        [price setTitleColor:[UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0] forState:(UIControlStateNormal)];
        [price addTarget:self action:@selector(choosePackage:) forControlEvents:(UIControlEventTouchUpInside)];
        [_priceView addSubview:price];
    }
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 157*Rate_NAV_H, 355*Rate_NAV_W, 2*Rate_NAV_H)];
    line2.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_priceView addSubview:line2];
    
    UILabel *purchaseNotie = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 172*Rate_NAV_H, 81*Rate_NAV_W, 22*Rate_NAV_H)];
    purchaseNotie.text = @"购买数量：";
    purchaseNotie.textColor =[UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    purchaseNotie.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    purchaseNotie.adjustsFontSizeToFitWidth = YES;
    [_priceView addSubview:purchaseNotie];
    
    for (int i = 0; i < 2; i++)
    {
        UIButton *change = [[UIButton alloc] initWithFrame:CGRectMake((256+73*i)*Rate_NAV_W, 171*Rate_NAV_H, 26*Rate_NAV_W, 26*Rate_NAV_H)];
        if (i == 0)
        {
            [change setTitle:@"-" forState:(UIControlStateNormal)];
        }
        else
        {
            [change setTitle:@"+" forState:(UIControlStateNormal)];
        }
        change.tag = i+11;
        [change setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
        [change setTitleColor:[UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0] forState:(UIControlStateNormal)];
        [change addTarget:self action:@selector(valueChange:) forControlEvents:(UIControlEventTouchUpInside)];
        [_priceView addSubview:change];
    }
    
    UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(292*Rate_NAV_W, 171*Rate_NAV_H, 27*Rate_NAV_W, 26*Rate_NAV_H)];
    value.tag = 100;
    value.text = @"1";
    value.textAlignment = NSTextAlignmentCenter;
    value.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    value.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_priceView addSubview:value];
    
    UILabel *line3 = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 209*Rate_NAV_H, 355*Rate_NAV_W, 2*Rate_NAV_H)];
    line3.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_priceView addSubview:line3];
    
    UILabel *line4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 260*Rate_NAV_H, 375*Rate_NAV_W, 2*Rate_NAV_H)];
    line4.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    [_priceView addSubview:line4];
}

- (void)createPurchaseView
{
    _purchaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 553*Rate_NAV_H, SCREENHEIGHT, 49*Rate_NAV_H)];
    _purchaseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_purchaseView];
    
    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_NAV_W, 13*Rate_NAV_H, 54*Rate_NAV_W, 25*Rate_NAV_H)];
    total.text = @"总价：";
    total.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    total.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [total sizeToFit];
    [_purchaseView addSubview:total];
    
    UILabel *totalPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(total.frame), 12*Rate_NAV_H, 56*Rate_NAV_W, 25*Rate_NAV_H)];
    totalPrice.text = @"20.00";
    totalPrice.tag = 100;
    totalPrice.textColor = [UIColor redColor];
    totalPrice.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    totalPrice.adjustsFontSizeToFitWidth = YES;
    [_purchaseView addSubview:totalPrice];
    
    UILabel *unit = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(totalPrice.frame), 12*Rate_NAV_H, 26*Rate_NAV_W, 25*Rate_NAV_H)];
    unit.text = @"元";
    unit.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.41 alpha:1.0];
    unit.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_purchaseView addSubview:unit];
    
    UIButton *pay = [[UIButton alloc] initWithFrame:CGRectMake(250*Rate_NAV_W, 0, 125*Rate_NAV_W, 49*Rate_NAV_H)];
    [pay setTitle:@"购买支付" forState:(UIControlStateNormal)];
    [pay setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
    [pay addTarget:self action:@selector(goPay) forControlEvents:(UIControlEventTouchUpInside)];
    [_purchaseView addSubview:pay];
}

#pragma mark -- 选择套餐
- (void)choosePackage:(UIButton *)btn
{
    if (btn.tag == 1)
    {
        [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [btn setBackgroundColor:[UIColor colorWithRed:0.24 green:0.85 blue:0.76 alpha:1.0]];
        UIButton *sender = (UIButton *)[_priceView viewWithTag:2];
        [sender setTitleColor:[UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0] forState:(UIControlStateNormal)];
        [sender setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
        
        UILabel *value = (UILabel *)[_priceView viewWithTag:100];
        value.text = [NSString stringWithFormat:@"%i",10];
        UILabel *price = (UILabel *)[_purchaseView viewWithTag:100];
        price.text = [NSString stringWithFormat:@"%.2f",180.00];
    }
    else if (btn.tag == 2)
    {
        [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [btn setBackgroundColor:[UIColor colorWithRed:0.24 green:0.85 blue:0.76 alpha:1.0]];
        UIButton *sender = (UIButton *)[_priceView viewWithTag:1];
        [sender setTitleColor:[UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0] forState:(UIControlStateNormal)];
        [sender setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
        
        UILabel *value = (UILabel *)[_priceView viewWithTag:100];
        value.text = [NSString stringWithFormat:@"%i",20];
        UILabel *price = (UILabel *)[_purchaseView viewWithTag:100];
        price.text = [NSString stringWithFormat:@"%.2f",340.00];
    }
}

#pragma mark -- 选择数目
- (void)valueChange:(UIButton *)btn
{
    UILabel *value = (UILabel *)[_priceView viewWithTag:100];
    UILabel *price = (UILabel *)[_purchaseView viewWithTag:100];
    NSInteger count  = [value.text integerValue];
    if (btn.tag == 11)
    {
        if (count > 1)
        {
            count--;
            value.text = [NSString stringWithFormat:@"%li",(long)count];
            price.text = [NSString stringWithFormat:@"%.2f",count/20*340.00+(count%20)/10*180.00+((count%20)%10)*20.00];
        }
    }
    else if (btn.tag == 12)
    {
        count++;
        value.text = [NSString stringWithFormat:@"%li",(long)count];
        price.text = [NSString stringWithFormat:@"%.2f",count/20*340.00+(count%20)/10*180.00+((count%20)%10)*20.00];
    }
}

#pragma mark -- 立即支付
- (void)goPay
{
    UILabel *value = (UILabel *)[_priceView viewWithTag:100];
    UILabel *price = (UILabel *)[_purchaseView viewWithTag:100];
    PurchaseViewController * purchase = [[PurchaseViewController alloc] init];
    purchase.totalPrice = price.text;
    purchase.count = value.text;
    purchase.name = @"\"问医生\"问题";
    purchase.patientID = _patientID;
    [self.navigationController pushViewController:purchase animated:YES];
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
