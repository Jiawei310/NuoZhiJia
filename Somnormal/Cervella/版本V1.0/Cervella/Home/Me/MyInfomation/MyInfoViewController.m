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

@interface MyInfoViewController ()<UITableViewDelegate,UITableViewDataSource,InterfaceModelDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *InfoTableView;
@property (strong, nonatomic) IBOutlet    UIButton *exitBtn;

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic)     UILabel *sexLabel;
@property (strong, nonatomic)     UILabel *birthLabel;
@property (strong, nonatomic) UITextField *contactTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic)  UITextView *addressTextView;

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
    
    self.title = @"My Information";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent=NO;
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

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*点击编辑区域外的view收起键盘*/
-(void)doHideKeyBoard
{
    [_nameTextField resignFirstResponder];
    [_contactTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_addressTextView resignFirstResponder];
}

#pragma loginTableView -- delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma loginTableView -- dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF4/255.0 blue:0xF4/255.0 alpha:1.0];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_H, 0, 80*Rate_NAV_W, 50)];
    textLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    textLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [cell.contentView addSubview:textLabel];
    
    if (indexPath.row == 0)
    {
        textLabel.text = @"Account";
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        detailLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        detailLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        detailLabel.textAlignment = NSTextAlignmentRight;
        detailLabel.text = _patientInfo.PatientID;
        [cell.contentView addSubview:detailLabel];
    }
    else if (indexPath.row == 1)
    {
        textLabel.text = @"Name";
        
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _nameTextField.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        _nameTextField.textAlignment = NSTextAlignmentRight;
        _nameTextField.text = _patientInfo.PatientName;
        _nameTextField.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        _nameTextField.tag = 1;
        _nameTextField.delegate = self;
        
        [cell.contentView addSubview:_nameTextField];
    }
    else if (indexPath.row == 2)
    {
        textLabel.text = @"Sex";
        
        _sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(313*Rate_NAV_W, 0, 27*Rate_NAV_W, 50)];
        _sexLabel.userInteractionEnabled = YES;
        _sexLabel.textAlignment = NSTextAlignmentRight;
        _sexLabel.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
        _sexLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        if (_patientInfo.PatientSex.length>0)
        {
            _sexLabel.text=_patientInfo.PatientSex;
        }
        
        [cell.contentView addSubview:_sexLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 3)
    {
        textLabel.text = @"Birthday";
        
        _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _birthLabel.textAlignment = NSTextAlignmentRight;
        _birthLabel.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
        _birthLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        if (_patientInfo.Birthday.length > 0)
        {
            _birthLabel.text = _patientInfo.Birthday;
        }
        
        [cell.contentView addSubview:_birthLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 4)
    {
        textLabel.text = @"Contact";
        
        _contactTextField = [[UITextField alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _contactTextField.textAlignment=NSTextAlignmentRight;
        _contactTextField.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
        _contactTextField.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        if (_patientInfo.CellPhone.length>0)
        {
            _contactTextField.text = _patientInfo.CellPhone;
        }
        [_contactTextField setEnabled:NO];
        
        [cell.contentView addSubview:_contactTextField];
    }
    else if (indexPath.row == 5)
    {
        textLabel.text = @"E-mail";
        
        _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _emailTextField.textAlignment=NSTextAlignmentRight;
        _emailTextField.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
        _emailTextField.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        if (_patientInfo.Email.length > 0 && ![_patientInfo.Email isEqualToString:@"(null)"])
        {
            _emailTextField.text=_patientInfo.Email;
        }
        else if ([_patientInfo.Email isEqualToString:@"(null)"])
        {
            _emailTextField.placeholder=@"未填写";
        }
        else
        {
            _emailTextField.placeholder=@"未填写";
        }
        _emailTextField.tag = 6;
        _emailTextField.delegate = self;
        
        [cell.contentView addSubview:_emailTextField];
    }
    else if (indexPath.row == 6)
    {
        textLabel.text = @"Address";
        
        _addressTextView = [[UITextView alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 0, 240*Rate_NAV_W, 50)];
        _addressTextView.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF4/255.0 blue:0xF4/255.0 alpha:1.0];
        _addressTextView.textAlignment = NSTextAlignmentRight;
        _addressTextView.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        _addressTextView.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        if (_patientInfo.Address.length > 0 && ![_patientInfo.Address isEqualToString:@"(null)"])
        {
            _addressTextView.text = _patientInfo.Address;
        }
        else if ([_patientInfo.Address isEqualToString:@"(null)"])
        {
            _addressTextView.text = @"";
        }
        else
        {
            _addressTextView.text = @"";
        }
        _addressTextView.tag = 7;
        _addressTextView.delegate = self;
        
        [cell.contentView addSubview:_addressTextView];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==2)
    {
        //选择性别
        self.sexPicker = [[SexPickerView alloc] initWith:_sexLabel.text];
        [self showSexPicker];
    }
    else if (indexPath.row==3)
    {
        //调用选择生日按钮的点击事件方法
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
    if (textField.tag==5 || textField.tag==6 || textField.tag==7 || textField.tag==8)
    {
        //键盘高度216
        
        //滑动效果（动画）
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard"  context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -100.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
        
        [UIView commitAnimations];
    }
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
    else if (textField.tag == 5)
    {
        //修改家庭号码
        if (_patientInfo!=nil)
        {
            _patientInfo.FamilyPhone=textField.text;
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
                [JXTAlertView showToastViewWithTitle:@"温馨提示" message:@"请检查邮箱输入是否正确" duration:2.0 dismissCompletion:^(NSInteger buttonIndex) {
                    NSLog(@"关闭!");
                }];
            }
        }
    }
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
}

- (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, -100.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //修改地址
    if (_patientInfo!=nil)
    {
        _patientInfo.Address=textView.text;
        [interfaceModel sendJsonSaveInfoToServer:_patientInfo isPhotoAlter:NO];
    }
    
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
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
    [JXTAlertView showAlertViewWithTitle:@"" message:@"是否切换用户？" cancelButtonTitle:@"是" otherButtonTitle:@"否" cancelButtonBlock:^(NSInteger buttonIndex) {
        
        //切换账号
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
        //清除缓存（例：绑定刺激仪后，切换用户，不断开外设以及清楚缓存，刺激仪将一致处于连接状态）
        NSNotification *notification = [NSNotification notificationWithName:@"ChangeUser" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        //删除本地数据库蓝牙绑定信息
        DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
        [dbOpration deletePeripheralInfo];
        //调用AppDelegate的代理方法，切换根视图
        UIApplication *app = [UIApplication sharedApplication];
        AppDelegate *appDelegate = (AppDelegate *)app.delegate;
        [appDelegate application:app didFinishLaunchingWithOptions:nil];
        
    } otherButtonBlock:^(NSInteger buttonIndex) {
        
        NSLog(@"关闭!");
        
    }];
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
