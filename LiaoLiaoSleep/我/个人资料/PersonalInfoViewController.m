//
//  PersonalInfoViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "AppDelegate.h"
#import "Define.h"
#import "EMClient.h"
#import <UMMobClick/MobClick.h>

#import "DataBaseOpration.h"
#import "InterfaceModel.h"

#import "DatePickerView.h"
#import "SexPickerView.h"
#import "JXTAlertManagerHeader.h"

#import "PhotoAndNicknameViewController.h"

#define HEIGHT (tableView.frame.size.height/6)

@interface PersonalInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,InterfaceModelDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (strong, nonatomic)     UILabel *acountLabel;
@property (strong, nonatomic) UITableView *personalInfoTableView;
@property (strong, nonatomic)    UIButton *exitLoginBtn;

@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic)     UILabel *nameLabel;
@property (strong, nonatomic)     UILabel *birthLabel;
@property (strong, nonatomic)     UILabel *sexLabel;

@property (nonatomic, strong) DatePickerView *datePicker;// 日期选择器
@property (nonatomic, strong)  SexPickerView *sexPicker; // 性别选择器

@property (strong, nonatomic) UITextField *userEmailTextField;
@property (strong, nonatomic) UITextField *userAddressTextField;
@property (strong, nonatomic) UITextField *userRemarkTextField;

@end

@implementation PersonalInfoViewController
{
    UIButton *saveButton;
    NSArray *personalInfoTableViewArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    //让下方tabbar隐藏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"个人资料"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"个人资料"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"个人资料";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    //设置View的位置不下移64像素
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.exitLoginBtn.layer.cornerRadius = 5;
    
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
    //添加保存按钮
    saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 22, 50, 20)];
    [saveButton setTitle:@"保存" forState:(UIControlStateNormal)];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    _patientInfo = [PatientInfo shareInstance];
    
    [self createAcountView];
    [self createAcountInfoTableView];
    [self createQuitBtn];
    
    //设置键盘收起手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doWillHideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [_personalInfoTableView.backgroundView addGestureRecognizer:tap];
    [self.view  addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    //返回上一界面
    [self.navigationController popViewControllerAnimated:YES];
}

//界面右上角保存按钮点击事件
- (void)saveButtonClick:(UIButton *)sender
{
    if (!sender.selected)
    {
        if (_userEmailTextField.text == nil || _userEmailTextField.text.length == 0)
        {
            //调用借口保存用户个人信息
            InterfaceModel *interfaceModel = [[InterfaceModel alloc] init];
            interfaceModel.delegate = self;
            
            _patientInfo.Birthday = _birthLabel.text;
            _patientInfo.PatientSex = _sexLabel.text;
            _patientInfo.PatientName = _patientInfo.PatientName;
            _patientInfo.Email = _userEmailTextField.text;
            _patientInfo.Address = _userAddressTextField.text;
            _patientInfo.PatientRemarks = _userRemarkTextField.text;
            [interfaceModel sendJsonSaveInfoToServer:_patientInfo isPhotoAlter:NO];
        }
        else
        {
            if ([self isValidateEmail:_userEmailTextField.text])
            {
                //调用借口保存用户个人信息
                InterfaceModel *interfaceModel = [[InterfaceModel alloc] init];
                interfaceModel.delegate = self;
                
                _patientInfo.Birthday = _birthLabel.text;
                _patientInfo.PatientSex = _sexLabel.text;
                _patientInfo.Email = _userEmailTextField.text;
                _patientInfo.Address = _userAddressTextField.text;
                _patientInfo.PatientRemarks = _userRemarkTextField.text;
                [interfaceModel sendJsonSaveInfoToServer:_patientInfo isPhotoAlter:NO];
            }
            else
            {
                jxt_showTextHUDTitleMessage(@"温馨提示", @"请检查邮箱输入是否正确");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
            }
        }
        sender.selected = YES;
    }
}

#pragma 借口调用的代理方法
- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeAlertPatientInfo)
    {
        NSDictionary *tmpDic = value;
        //更新成功
        if ([[tmpDic objectForKey:@"state"] isEqualToString:@"OK"])
        {
            [_personalInfoTableView reloadData];
            //通知所有界面用户个人信息已修改
            NSDictionary *patientDic = @{@"patientInfo":_patientInfo};
            NSNotification *notification = [[NSNotification alloc] initWithName:@"patientInfoChange" object:nil userInfo:patientDic];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //将个人信息保存到本地数据库
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            [dbOpration updataUserInfo:_patientInfo];
            [dbOpration closeDataBase];
            
            //提示“更新成功”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"更新成功");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
            //保存按钮恢复点击
            saveButton.selected = NO;
        }
        else
        {
            //跟新失败
            //提示“更新失败”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"更新失败");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
            //保存按钮恢复点击
            saveButton.selected = NO;
        }
    }
}

//隐藏键盘
-(void)doWillHideKeyBoard
{
    [_userEmailTextField resignFirstResponder];
    [_userAddressTextField resignFirstResponder];
    [_userRemarkTextField resignFirstResponder];
}

//创建帐号view
- (void)createAcountView
{
    UIView *partOneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 60*Rate_NAV_H)];
    partOneView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:partOneView];
    
    _acountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 180*Rate_NAV_W, 60*Rate_NAV_H)];
    _acountLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    _acountLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
    _acountLabel.textAlignment = NSTextAlignmentLeft;
    _acountLabel.text = [NSString stringWithFormat:@"账号：%@",_patientInfo.PatientID];
    [partOneView addSubview:_acountLabel];
}

//创建帐号信息的tableview
- (void)createAcountInfoTableView
{
    _personalInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 75*Rate_NAV_H, 375*Rate_NAV_W, 360*Rate_NAV_H)];
    _personalInfoTableView.scrollEnabled = NO;
    if ([_personalInfoTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _personalInfoTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_personalInfoTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    _personalInfoTableView.delegate = self;
    _personalInfoTableView.dataSource = self;
    [self.view addSubview:_personalInfoTableView];
    
    personalInfoTableViewArray = @[@"王夜宾",@"出生年月",@"性别",@"电子邮箱",@"家庭住址",@"备注"];
}

//创建退出登录按钮
- (void)createQuitBtn
{
    _exitLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 523*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [_exitLoginBtn setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
    _exitLoginBtn.layer.cornerRadius = 25*Rate_NAV_H;
    _exitLoginBtn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_exitLoginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_exitLoginBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [_exitLoginBtn addTarget:self action:@selector(exitLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_exitLoginBtn];
}

//退出登录按钮点击事件
- (IBAction)exitLoginBtnClick:(UIButton *)sender
{
    //切换用户提示
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"是否切换用户？" message:nil delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    
    alertView.tag=0;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==0)
    {
        if (buttonIndex==0)
        {
            [MobClick profileSignOff];
            //退出环信
            [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
                if (!aError)
                {
                    NSLog(@"退出成功");
                }
            }];
            
            //切换账号
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
            //清除缓存（例：绑定刺激仪后，切换用户，不断开外设以及清楚缓存，刺激仪将一致处于连接状态）
            NSNotification *notification=[NSNotification notificationWithName:@"ChangeUser" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //删除本地数据库蓝牙绑定信息
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            [dbOpration deletePeripheralInfo];
            //调用AppDelegate的代理方法，切换根视图
            UIApplication *app = [UIApplication sharedApplication];
            AppDelegate *appDelegate = (AppDelegate *)app.delegate;
            [appDelegate application:app didFinishLaunchingWithOptions:nil];
        }
    }
}

#pragma tableview的delegate、dataSource代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"personalInfoTableViewCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    //显示账号信息
    if(indexPath.row == 0)
    {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, (HEIGHT - 40*Rate_NAV_H)/2, 40*Rate_NAV_H, 40*Rate_NAV_H)];
        [_photoImageView.layer setCornerRadius:self.photoImageView.frame.size.width/2];
        [_photoImageView.layer setMasksToBounds:YES];
        if (_patientInfo.Picture == nil || _patientInfo.Picture.length == 0)
        {
            [_photoImageView setImage:[UIImage imageNamed:@"Default"]];
        }
        else
        {
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:_patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [_photoImageView setImage:[[UIImage alloc] initWithData:imageData]];
        }
        [cell addSubview:_photoImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 227*Rate_NAV_W, HEIGHT)];
        _nameLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        _nameLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        _nameLabel.textAlignment = NSTextAlignmentRight;
        _nameLabel.text = [NSString stringWithFormat:@"%@",self.patientInfo.PatientName? self.patientInfo.PatientName:self.patientInfo.PatientID];
        [cell addSubview:_nameLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //显示出生年月
    else if(indexPath.row == 1)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 80*Rate_NAV_W, HEIGHT)];
        textLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
        textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        textLabel.text = [personalInfoTableViewArray objectAtIndex:indexPath.row];
        [cell addSubview:textLabel];
        
        _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 227*Rate_NAV_W, HEIGHT)];
        _birthLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        _birthLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        _birthLabel.textAlignment = NSTextAlignmentRight;
        _birthLabel.text = _patientInfo.Birthday;
        [cell addSubview:_birthLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //显示性别
    else if(indexPath.row == 2)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 80*Rate_NAV_W, HEIGHT)];
        textLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
        textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        textLabel.text = [personalInfoTableViewArray objectAtIndex:indexPath.row];
        [cell addSubview:textLabel];
        
        _sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(300*Rate_NAV_W, 0, 27*Rate_NAV_W, HEIGHT)];
        _sexLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        _sexLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        _sexLabel.textAlignment = NSTextAlignmentRight;
        _sexLabel.text = [NSString stringWithFormat:@"%@",_patientInfo.PatientSex];
        [cell addSubview:_sexLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //填写电子邮箱
    else if(indexPath.row == 3)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 80*Rate_NAV_W, HEIGHT)];
        textLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
        textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        textLabel.text = [personalInfoTableViewArray objectAtIndex:indexPath.row];
        [cell addSubview:textLabel];
        
        _userEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(104*Rate_NAV_W, 0, 271*Rate_NAV_W, HEIGHT)];
        _userEmailTextField.tag = 1;
        _userEmailTextField.delegate = self;
        _userEmailTextField.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        if (_patientInfo.Email != nil && _patientInfo.Email.length > 0)
        {
            _userEmailTextField.text = _patientInfo.Email;
        }
        else
        {
            _userEmailTextField.placeholder = @"请输入电子邮箱";
        }
        [cell addSubview:_userEmailTextField];
    }
    //填写家庭住址
    else if(indexPath.row == 4)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 80*Rate_NAV_W, HEIGHT)];
        textLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
        textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        textLabel.text = [personalInfoTableViewArray objectAtIndex:indexPath.row];
        [cell addSubview:textLabel];
        
        _userAddressTextField = [[UITextField alloc] initWithFrame:CGRectMake(104*Rate_NAV_W, 0, 271*Rate_NAV_W, HEIGHT)];
        _userAddressTextField.tag = 2;
        _userAddressTextField.delegate = self;
        _userAddressTextField.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        if (_patientInfo.Email != nil && _patientInfo.Email.length > 0)
        {
            _userAddressTextField.text = _patientInfo.Address;
        }
        else
        {
            _userAddressTextField.placeholder = @"请输入家庭住址";
        }
        [cell addSubview:_userAddressTextField];
    }
    //填写备注
    else if(indexPath.row == 5)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 80*Rate_NAV_W, HEIGHT)];
        textLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
        textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        textLabel.text = [personalInfoTableViewArray objectAtIndex:indexPath.row];
        [cell addSubview:textLabel];
        
        _userRemarkTextField = [[UITextField alloc] initWithFrame:CGRectMake(104*Rate_NAV_W, 0, 271*Rate_NAV_W, HEIGHT)];
        _userRemarkTextField.tag = 3;
        _userRemarkTextField.delegate = self;
        _userRemarkTextField.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        if (_patientInfo.Email != nil && _patientInfo.Email.length > 0)
        {
            _userRemarkTextField.text = _patientInfo.PatientRemarks;
        }
        else
        {
            _userRemarkTextField.placeholder = @"可输入病史、药物过敏情况等";
        }
        [cell addSubview:_userRemarkTextField];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转到头像、昵称界面
    if (indexPath.row == 0)
    {
        PhotoAndNicknameViewController *photoAndNicknameVC = [[PhotoAndNicknameViewController alloc] init];
        [photoAndNicknameVC returnInfoBlock:^(PatientInfo *_tempInfo) {
            _patientInfo = _tempInfo;
            [_personalInfoTableView reloadData];
        }];
        
        [self.navigationController pushViewController:photoAndNicknameVC animated:YES];
    }
    //弹出日期选择控件
    else if (indexPath.row == 1)
    {
        NSInteger year = 0;
        NSInteger month = 0;
        if (_birthLabel.text.length == 0 || _birthLabel.text == nil)
        {
            NSDate *EndDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM"];
            NSString *endTime = [dateFormatter stringFromDate:EndDate];
            
            year = [[endTime substringWithRange:NSMakeRange(0, 4)] integerValue];
            month = [[endTime substringWithRange:NSMakeRange(5, 2)] integerValue];
        }
        else
        {
            year = [[_birthLabel.text substringWithRange:NSMakeRange(0, 4)] integerValue];
            if (_birthLabel.text.length < 7)
            {
                month = 1;
            }
            else if (_birthLabel.text.length == 7)
            {
                month = [[_birthLabel.text substringWithRange:NSMakeRange(5, 2)] integerValue];
            }
        }
        self.datePicker = [[DatePickerView alloc] initWithFrame:CGRectMake(0, 359*Rate_NAV_H, 375*Rate_NAV_W, 248*Rate_NAV_H) Year:year Month:month];
        [self showDatePicker];
    }
    //弹出性别选择控件
    else if (indexPath.row == 2)
    {
        self.sexPicker = [[SexPickerView alloc] initWith:_sexLabel.text];
        [self showSexPicker];
    }
}

/** 显示出生年月选择器 */
- (void)showDatePicker
{
    [self.datePicker show];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.birthLabel) weakBirthLabel = self.birthLabel;
    
    self.datePicker.gotoSrceenOrderBlock = ^(NSString *valueStr){
        [weakSelf.datePicker hide];
        if (![valueStr isEqualToString:weakBirthLabel.text])
        {
            weakBirthLabel.text = [NSString stringWithFormat:@"%@-%@", [valueStr substringWithRange:NSMakeRange(0, 4)], [valueStr substringWithRange:NSMakeRange(5, 2)]];
        }
    };
}

/** 显示性别选择器 */
- (void)showSexPicker
{
    [self.sexPicker show];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.sexLabel) weakSexLabel = self.sexLabel;
    
    self.sexPicker.gotoSrceenOrderBySexPickBlock = ^(NSString *valueStr){
        [weakSelf.sexPicker hide];
        if (![valueStr isEqualToString:weakSexLabel.text])
        {
            weakSexLabel.text = valueStr;
        }
    };
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1 || textField.tag == 2 || textField.tag == 3)
    {
        //键盘高度216
        //滑动效果（动画）
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -166.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
        
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 64.0f, SCREENWIDTH, SCREENHEIGHT); //64-216
    
    [UIView commitAnimations];
}

//判断邮箱输入是否正确
-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
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
