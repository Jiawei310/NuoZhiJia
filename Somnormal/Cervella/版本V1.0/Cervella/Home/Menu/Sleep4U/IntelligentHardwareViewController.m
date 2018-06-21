//
//  IntelligentHardwareViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/6.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "IntelligentHardwareViewController.h"
#import "BindViewController.h"
#import "FreeBindViewController.h"
#import "CircleView.h"

@interface IntelligentHardwareViewController ()
@property (assign, nonatomic) BOOL isBind;
@end

@implementation IntelligentHardwareViewController
{
    CAShapeLayer *myLayer;
    CAShapeLayer *progressLayer;
    UILabel *percentLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Pairing";
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
    
    /**************UI*************/
    //圆环
    myLayer = [[CAShapeLayer alloc] init];
    if (SCREENWIDTH ==320)
    {
        myLayer.frame=CGRectMake(72.5, 114, 175, 175);
    }
    else if (SCREENWIDTH==375)
    {
        myLayer.frame=CGRectMake(95, 124, 185, 185);
    }
    else if (SCREENWIDTH==414)
    {
        myLayer.frame=CGRectMake(109.5, 114, 195, 195);
    }
    myLayer.path = [self drawPathWithArcCenter:4];
    myLayer.fillColor = [UIColor clearColor].CGColor;
    myLayer.strokeColor = [UIColor colorWithRed:0.86f green:0.86f blue:0.86f alpha:0.4f].CGColor;
    myLayer.lineWidth = 10;
    [self.view.layer addSublayer:myLayer];

    
    //百分比
    percentLabel=[[UILabel alloc] init];
    percentLabel.textAlignment=NSTextAlignmentCenter;
    percentLabel.font=[UIFont systemFontOfSize:20];
    if (SCREENWIDTH==320)
    {
        percentLabel.frame=CGRectMake(5, 70, 165, 35);
    }
    else if (SCREENWIDTH==375)
    {
        percentLabel.frame=CGRectMake(5, 75, 175, 35);
    }
    else if (SCREENWIDTH==414)
    {
        percentLabel.frame=CGRectMake(5, 80, 185, 35);
    }
    [myLayer addSublayer:percentLabel.layer];
    
    //battery level
    UILabel *batteryLab = [[UILabel alloc] init];
    batteryLab.frame = CGRectMake(30, myLayer.frame.size.height + myLayer.frame.origin.y + 15, SCREENWIDTH - 60, 30);
    batteryLab.textAlignment = NSTextAlignmentCenter;
    batteryLab.text = @"Cervella Battery Level";
    [self.view addSubview:batteryLab];
    
    UIView *lineOne=[[UIView alloc] initWithFrame:CGRectMake(0, batteryLab.frame.origin.y + 40, SCREENWIDTH, 1)];
    lineOne.backgroundColor=[UIColor grayColor];
    [self.view addSubview:lineOne];
    
    UIButton *turnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    turnBtn.frame = CGRectMake(0, lineOne.frame.origin.y + 1, SCREENWIDTH, 44.0f);
    [turnBtn addTarget:self action:@selector(turnBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [turnBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:turnBtn];
                                   
    
    UIView *lineTwo=[[UIView alloc] initWithFrame:CGRectMake(turnBtn.frame.origin.x, turnBtn.frame.origin.y+44.0, SCREENWIDTH, 1)];
    lineTwo.backgroundColor=[UIColor grayColor];
    [self.view addSubview:lineTwo];
    
    /**************Data*************/
    if (self.isBind)
    {
        [turnBtn setTitle:@"Unbind Cervella" forState:UIControlStateNormal];
        if (_battery > 0)
        {
            percentLabel.text = [NSString stringWithFormat:@"%ld%%", _battery];
        }
        else
        {
            percentLabel.text=@"Not Connected";
        }
    }
    else
    {
        [turnBtn setTitle:@"Search for Cervella" forState:UIControlStateNormal];

        percentLabel.text=@"Not Connected";
    }
  
    [self setupLayer];
}

- (void)turnBtnAction {
    if (self.isBind)
    {
        FreeBindViewController *freeBindViewController=[[FreeBindViewController alloc] initWithNibName:@"FreeBindViewController" bundle:nil];
        
        [self.navigationController pushViewController:freeBindViewController animated:YES];
    }
    else
    {
        BindViewController *bindViewController=[[BindViewController alloc] initWithNibName:@"BindViewController" bundle:nil];
        bindViewController.bindFlag=@"2";
        
        [self.navigationController pushViewController:bindViewController animated:YES];
    }
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupLayer
{
    progressLayer = [CAShapeLayer layer];
    CGFloat position_y = myLayer.frame.size.height/2;
    CGFloat position_x = myLayer.frame.size.width/2;
    progressLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y)
                                                        radius:position_y
                                                    startAngle:(3*M_PI/2 - (_battery/100.0)*(M_PI * 2))
                                                      endAngle:(3*M_PI/2)
                                                     clockwise:YES].CGPath;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0].CGColor;
    progressLayer.lineWidth = 10;
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.lineJoin = kCALineJoinRound;
    [myLayer addSublayer:progressLayer];
}

- (CGPathRef)drawPathWithArcCenter:(CGFloat)x
{
    CGFloat position_y = myLayer.frame.size.height/2;
    CGFloat position_x = myLayer.frame.size.width/2; // Assuming that width == height
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y) radius:position_y startAngle:(-M_PI/2) endAngle:((x-1)*M_PI/2)clockwise:YES].CGPath;
}


- (BOOL)isBind {
    //从数据库读取之前绑定设备
    DataBaseOpration *dataBaseOpration = [[DataBaseOpration alloc] init];
    NSArray *bluetoothInfoArray=[dataBaseOpration getBluetoothDataFromDataBase];
    [dataBaseOpration closeDataBase];
    return bluetoothInfoArray.count;
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
