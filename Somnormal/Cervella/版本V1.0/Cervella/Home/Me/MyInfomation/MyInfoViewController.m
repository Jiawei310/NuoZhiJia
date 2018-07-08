//
//  MyInfoViewController.m
//  Cervella
//
//  Created by Justin on 2017/7/7.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "AppDelegate.h"
#import "MyInfoViewController.h"

#import "InterfaceModel.h"

#import "DatePickerView.h"
#import "SexPickerView.h"

#import "JXTAlertManagerHeader.h"
#import "AESCipher.h"

@interface MyInfoViewController ()<UITableViewDelegate,UITableViewDataSource,InterfaceModelDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *InfoTableView;
@property (strong, nonatomic) IBOutlet    UIButton *exitBtn;

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic)     UILabel *sexLabel;
@property (strong, nonatomic)     UILabel *birthLabel;
@property (strong, nonatomic) UITextField *emailTextField;

@property (nonatomic, strong) DatePickerView *datePicker;// 日期选择器
@property (nonatomic, strong)  SexPickerView *sexPicker; // 性别选择器

@end

@implementation MyInfoViewController
{
    InterfaceModel *interfaceModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent=NO;
    
    
    interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
    
    _InfoTableView.scrollEnabled =NO; //设置tableview不能滚动
    _InfoTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    _InfoTableView.delegate = self;
    _InfoTableView.dataSource = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doHideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [_InfoTableView.backgroundView addGestureRecognizer:tap];
    
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self doHideKeyBoard];
}
/*点击编辑区域外的view收起键盘*/
-(void)doHideKeyBoard
{
    [_nameTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
}

#pragma loginTableView -- delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma loginTableView -- dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 80*Rate_NAV_W, 50)];
    textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [cell.contentView addSubview:textLabel];
    
    if (indexPath.row == 0)
    {
        textLabel.text = @"Username";
        
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _nameTextField.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        _nameTextField.textAlignment = NSTextAlignmentRight;
        _nameTextField.tag = 1;
        _nameTextField.enabled = NO;
        [cell.contentView addSubview:_nameTextField];

        _nameTextField.text = _patientInfo.PatientID;
        
        //解密显示
        if (_patientInfo.PatientID.length == 24) {
            _birthLabel.text = aesDecryptString( _patientInfo.Birthday, aes_key_value);
        }
        
    }
    else if (indexPath.row == 1)
    {
        textLabel.text = @"Sex";
        _sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 110,
                                                              0,
                                                              80,
                                                              50)];
        _sexLabel.userInteractionEnabled = YES;
        _sexLabel.textAlignment = NSTextAlignmentRight;
        _sexLabel.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
        if (_patientInfo.PatientSex.length>0)
        {
            _sexLabel.text=@"Male";
            if ([_patientInfo.PatientSex isEqualToString:@"女"] ||
                [_patientInfo.PatientSex isEqualToString:@"Female"] ||
                [_patientInfo.PatientSex isEqualToString:@"F"]) {
                _sexLabel.text = @"Female";
            }
        }
        
        [cell.contentView addSubview:_sexLabel];
    }
    else if (indexPath.row == 2)
    {
        textLabel.text = @"Birthdate";
        _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _birthLabel.textAlignment = NSTextAlignmentRight;
        _birthLabel.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
        if (_patientInfo.Birthday.length > 0)
        {
            NSString *str = _patientInfo.Birthday;
            if ([str containsString:@"-"]) {
                str = [str stringByReplacingOccurrencesOfString:@"-" withString:@"."];
            }
            _birthLabel.text = str;
            
            //解密显示
            if (_patientInfo.Birthday.length == 24) {
                _birthLabel.text = aesDecryptString( _patientInfo.Birthday, aes_key_value);
            }
        }
        
        [cell.contentView addSubview:_birthLabel];
    }
    else if (indexPath.row == 3)
    {
        textLabel.text = @"E-mail";
        
        _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _emailTextField.textAlignment=NSTextAlignmentRight;
        _emailTextField.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
        if (_patientInfo.Email.length > 0 && ![_patientInfo.Email isEqualToString:@"(null)"])
        {
            _emailTextField.text=_patientInfo.Email;
            //解密显示
            if (_patientInfo.Email.length == 24) {
                _emailTextField.text = aesDecryptString( _patientInfo.Email, aes_key_value);
            }
        }
        else
        {
            _emailTextField.text=@"Not filled";
        }
        _emailTextField.tag = 6;
        _emailTextField.enabled = NO;

        
        [cell.contentView addSubview:_emailTextField];
    }
    return cell;
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
            weakBirthLabel.text = [NSString stringWithFormat:@"%@.%@", [valueStr substringWithRange:NSMakeRange(0, 4)], [valueStr substringWithRange:NSMakeRange(5, 2)]];
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


- (void)textFiledEditChanged:(NSNotification*)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    if(toBeString.length > 15)
    {
        textField.text= [toBeString substringToIndex:15];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1)
    {
        //修改姓名
        if (_patientInfo!=nil)
        {
            _patientInfo.PatientName=textField.text;
            [interfaceModel sendJsonSaveInfoToServer:_patientInfo isPhotoAlter:NO];
        }
    }
    else if (textField.tag == 6)
    {
        //修改电子邮件
        if (_patientInfo != nil)
        {
            if ([self isValidateEmail:textField.text])
            {
                _patientInfo.Email=textField.text;
                [interfaceModel sendJsonSaveInfoToServer:_patientInfo isPhotoAlter:NO];
            }
            else
            {
                _emailTextField.text = nil;
                [JXTAlertView showToastViewWithTitle:@"温馨提示" message:@"请检查邮箱输入是否正确" duration:2.0 dismissCompletion:^(NSInteger buttonIndex) {
                    NSLog(@"关闭!");
                }];
            }
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //修改地址
    if (_patientInfo!=nil)
    {
        _patientInfo.Address=textView.text;
        [interfaceModel sendJsonSaveInfoToServer:_patientInfo isPhotoAlter:NO];
    }
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeAlertPatientInfo)
    {
        NSString *state = [value objectForKey:@"state"];
        NSString *description = [value objectForKey:@"description"];
        if ([state isEqualToString:@"OK"])
        {
            //把patientInfo更新到本地数据库
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            [dbOpration updataUserInfo:_patientInfo];
            [dbOpration closeDataBase];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.51 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [JXTAlertView showToastViewWithTitle:@"温馨提示" message:@"修改成功" duration:2.0 dismissCompletion:^(NSInteger buttonIndex) {
                    NSLog(@"关闭!");
                }];
            });
        }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.51 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [JXTAlertView showToastViewWithTitle:@"温馨提示" message:description duration:2.0 dismissCompletion:^(NSInteger buttonIndex) {
                    NSLog(@"关闭!");
                }];
            });
        }
    }
}

- (IBAction)exitBtnClick:(UIButton *)sender
{
    [JXTAlertView showAlertViewWithTitle:@"" message:@"Confirm Log Out" cancelButtonTitle:@"Yes" otherButtonTitle:@"No" cancelButtonBlock:^(NSInteger buttonIndex) {
        
        //切换账号
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
        
        //清除缓存（例：绑定刺激仪后，切换用户，不断开外设以及清楚缓存，刺激仪将一致处于连接状态）
        NSNotification *notification = [NSNotification notificationWithName:@"ChangeUser" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        //删除本地数据库蓝牙绑定信息
        DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
        [dbOpration deletePeripheralInfo];
        [dbOpration closeDataBase];
        
        //调用AppDelegate的代理方法，切换根视图
        UIApplication *app = [UIApplication sharedApplication];
        AppDelegate *appDelegate = (AppDelegate *)app.delegate;
        [appDelegate application:app didFinishLaunchingWithOptions:nil];
        
    } otherButtonBlock:^(NSInteger buttonIndex) {
        
        NSLog(@"关闭!");
        
    }];
}

- (BOOL)isValidateEmail:(NSString *)email
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
