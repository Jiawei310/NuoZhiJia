//
//  RegisterViewController.m
//  Somnormal
//
//  Created by Justin on 2017/6/27.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "RegisterViewController.h"

#import "DatePickerView.h"

@interface RegisterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *registerTableView;

@property (strong, nonatomic) PatientInfo *patientInfo;

@property (strong, nonatomic) UITextField *acountTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *birthTextField;

@property (nonatomic, strong) DatePickerView *datePicker; // 日期选择器
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;

@property (strong, nonatomic) UIButton *maleBtn;
@property (strong, nonatomic) UIButton *femaleBtn;

@end

@implementation RegisterViewController
{
    DataBaseOpration *dbOpration;
    InterfaceModel *interfaceModel;
    
    BOOL isOverTime;       //用来标志是否注册超时
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Register";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
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
    
    _registerTableView.scrollEnabled =NO; //设置tableview不能滚动
    _registerTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _registerTableView.delegate = self;
    _registerTableView.dataSource = self;
    
    _patientInfo = [[PatientInfo alloc] init];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma loginTableView -- delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma loginTableView -- dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF4/255.0 blue:0xF4/255.0 alpha:1.0];
    if (indexPath.row == 0)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 15, 22, 20)];
        [headImageView setImage:[UIImage imageNamed:@"register_head"]];
        [cell.contentView addSubview:headImageView];
        
        _acountTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 5, 230, 40)];
        _acountTextField.font = [UIFont systemFontOfSize:18];
        _acountTextField.placeholder = @"Acount";
        [cell.contentView addSubview:_acountTextField];
    }
    else if (indexPath.row == 1)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
        [headImageView setImage:[UIImage imageNamed:@"register_password"]];
        [cell.contentView addSubview:headImageView];
        
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 5, 230, 40)];
        _passwordTextField.font = [UIFont systemFontOfSize:18];
        _passwordTextField.placeholder = @"Password";
        [cell.contentView addSubview:_passwordTextField];
    }
    else if (indexPath.row == 2)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 14, 22, 22)];
        [headImageView setImage:[UIImage imageNamed:@"more_information"]];
        [cell.contentView addSubview:headImageView];
        
        _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 5, 230, 40)];
        _emailTextField.font = [UIFont systemFontOfSize:18];
        _emailTextField.placeholder = @"E-Mail";
        [cell.contentView addSubview:_emailTextField];
    }
    else if (indexPath.row == 3)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 15, 22, 20)];
        [headImageView setImage:[UIImage imageNamed:@"register_age"]];
        [cell.contentView addSubview:headImageView];
        
        _birthTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 5, 230, 40)];
        _birthTextField.font = [UIFont systemFontOfSize:18];
        _birthTextField.placeholder = @"Birthday";
        _birthTextField.userInteractionEnabled = NO;
        [cell.contentView addSubview:_birthTextField];
    }
    else
    {
        _maleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _maleBtn.tag = 11;
        _maleBtn.backgroundColor = [UIColor whiteColor];
        _maleBtn.frame = CGRectMake(20, 15, 20, 20);
        [_maleBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        _maleBtn.selected = YES;
        [_maleBtn addTarget:self action:@selector(genderSelect:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_maleBtn];
        
        UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 20, 30)];
        maleLabel.textColor = [UIColor colorWithRed:0xA7/255.0 green:0xA7/255.0 blue:0xA7/255.0 alpha:1.0];
        maleLabel.font = [UIFont systemFontOfSize:18];
        maleLabel.textAlignment = NSTextAlignmentCenter;
        maleLabel.text = @"M";
        [cell.contentView addSubview:maleLabel];
        
        UIImageView *maleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 15, 21, 20)];
        [maleImageView setImage:[UIImage imageNamed:@"register_male"]];
        [cell.contentView addSubview:maleImageView];
        
        _femaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _femaleBtn.tag = 12;
        _femaleBtn.backgroundColor = [UIColor whiteColor];
        _femaleBtn.frame = CGRectMake(120, 15, 20, 20);
        [_femaleBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        [_femaleBtn addTarget:self action:@selector(genderSelect:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_femaleBtn];
        
        UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(145, 10, 20, 30)];
        femaleLabel.textColor = [UIColor colorWithRed:0xA7/255.0 green:0xA7/255.0 blue:0xA7/255.0 alpha:1.0];
        femaleLabel.font = [UIFont systemFontOfSize:18];
        femaleLabel.textAlignment = NSTextAlignmentCenter;
        femaleLabel.text = @"F";
        [cell.contentView addSubview:femaleLabel];
        
        UIImageView *femaleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(170, 15, 13, 20)];
        [femaleImageView setImage:[UIImage imageNamed:@"register_female"]];
        [cell.contentView addSubview:femaleImageView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击cell，判断是第四个cell时底部谈起日期选择
    if (indexPath.row == 3)
    {
        if ([_birthTextField.text isEqualToString:@"Birthday"])
        {
            _birthTextField.text = @"请在底部选择";
            NSDate *EndDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM"];
            NSString *endTime = [dateFormatter stringFromDate:EndDate];
            
            _year = [[endTime substringWithRange:NSMakeRange(0, 4)] integerValue];
            _month = [[endTime substringWithRange:NSMakeRange(5, _birthTextField.text.length-6)] integerValue];
        }
        else if ([_birthTextField.text containsString:@"年"])
        {
            _year = [[_birthTextField.text substringWithRange:NSMakeRange(0, 4)] integerValue];
            _month = [[_birthTextField.text substringWithRange:NSMakeRange(5, _birthTextField.text.length-6)] integerValue];
        }
        
        self.datePicker = [[DatePickerView alloc] initWithFrame:CGRectMake(0, 359*Rate_NAV_H, 375*Rate_NAV_W, 248*Rate_NAV_H) Year:_year Month:_month];
        [self showDatePicker];
    }
}

/** 显示出生年月选择器 */
- (void)showDatePicker
{
    [self.datePicker show];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(_birthTextField) weakBirthTextField = _birthTextField;
    
    self.datePicker.gotoSrceenOrderBlock = ^(NSString *valueStr){
        [weakSelf.datePicker hide];
        if (![valueStr isEqualToString:weakBirthTextField.text])
        {
            weakBirthTextField.text = valueStr;
        }
    };
}

- (void)genderSelect:(UIButton *)sender
{
    if (sender.tag == 11)
    {
        if (_maleBtn.selected)
        {
            [_maleBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
            [_femaleBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
            _maleBtn.selected = NO;
            _femaleBtn.selected = YES;
        }
        else
        {
            [_maleBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
            [_femaleBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
            _maleBtn.selected = YES;
            _femaleBtn.selected = NO;
        }
    }
    else
    {
        if (_femaleBtn.selected)
        {
            [_maleBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
            [_femaleBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
            _maleBtn.selected = YES;
            _femaleBtn.selected = NO;
        }
        else
        {
            [_maleBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
            [_femaleBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
            _maleBtn.selected = NO;
            _femaleBtn.selected = YES;
        }
    }
}

- (IBAction)registerAndLoginAction:(UIButton *)sender
{
    if (_acountTextField.text.length == 0)
    {
        //提示账号不可为空
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Account number must be entered");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if (_passwordTextField.text.length < 6 && _passwordTextField.text.length > 0)
    {
        //提示密码过短
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Password should have 6-18 numbers");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if (_passwordTextField.text.length == 0)
    {
        //提示密码过短
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Password must be entered");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if(_emailTextField.text == nil)
    {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Email must be entered");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if(_birthTextField.text == nil)
    {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Please select Date of birth");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else
    {
        _patientInfo.PatientID = _acountTextField.text;
        _patientInfo.PatientPwd = _passwordTextField.text;
        _patientInfo.PatientName = _passwordTextField.text;
        _patientInfo.CellPhone = _passwordTextField.text;
        NSString *birthStr_One = [_birthTextField.text substringWithRange:NSMakeRange(0, 4)];
        NSString *birthStr_Two = [_birthTextField.text substringWithRange:NSMakeRange(5, 2)];
        _patientInfo.Birthday = [NSString stringWithFormat:@"%@-%@",birthStr_One,birthStr_Two];
        _patientInfo.Age = 0;
        _patientInfo.FamilyPhone = @"";
        _patientInfo.PatientContactWay = @"";
        _patientInfo.Marriage = @"";
        _patientInfo.Vocation = @"";
        _patientInfo.PatientHeight = @"";
        _patientInfo.PatientWeight = @"";
        _patientInfo.NativePlace = @"";
        _patientInfo.BloodModel = @"";
        _patientInfo.Email = @"";
        _patientInfo.Address = @"";
        _patientInfo.PatientRemarks = @"";
        //做一个默认头像
        //图片下载完成  在这里进行相关操作，如加到数组里 或者显示在imageView上
        UIImage *photoImage = [UIImage imageNamed:@"Default.jpg"];
        NSData *imageData = UIImagePNGRepresentation(photoImage);
        _patientInfo.Picture = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        _patientInfo.PhotoUrl = @"//PatientHeadImg//Default.jpg";
        
        //添加Loading
        jxt_showLoadingHUDTitleMessage(@"Sign in", @"Loading...");
        isOverTime = YES;
        
        [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(overTimeOpration) userInfo:nil repeats:NO];
        //借口请求，后台添加账号
        [interfaceModel sendJsonRegisterInfoToServer:_patientInfo];
    }
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeLogin)
    {
        isOverTime=NO;
        
        _patientInfo = value;
        //隐藏Loading
        jxt_dismissHUD();
    }
}

- (void)overTimeOpration
{
    if (isOverTime)
    {
        //隐藏Loading
        jxt_dismissHUD();
        jxt_showAlertTitle(@"Login timeout");
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
