//
//  RegisterViewController.m
//  Cervella
//
//  Created by Justin on 2017/6/27.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "RegisterViewController.h"
#import "WebViewController.h"
#import "DatePickerView.h"
#import "AppDelegate.h"
#import "HomeViewController.h"


@interface RegisterViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, InterfaceModelDelegate>

@property (strong, nonatomic) IBOutlet UITableView *registerTableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *RegisterBtn;

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

@property (strong, nonatomic) UIButton *provisionBtn1;
@property (strong, nonatomic) UIButton *provisionBtn2;
@property (strong, nonatomic) UIButton *provisionBtn3;

@end

@implementation RegisterViewController
{
    InterfaceModel *interfaceModel;
    
    BOOL isOverTime;       //用来标志是否注册超时
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UIView
    self.title = @"Register";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //back btn
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    backLogin.frame = CGRectMake(12, 30, 23, 23);
    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    
    //tableView
    _registerTableView.scrollEnabled =NO; //设置tableview不能滚动
    _registerTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _registerTableView.delegate = self;
    _registerTableView.dataSource = self;
    
    [self addTextView];

    //Data
    _patientInfo = [[PatientInfo alloc] init];
    interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
}

- (void)addTextView {
    self.textView.delegate = self;
    self.textView.editable = NO;
    NSString *htmlStr =  @"<h4 align=\"center\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TERMS OF SERVICE & PRIVACY POLICY</h4>    <p>INNOVATIVE NEUROLOGICAL DEVICES LLC, the makers of Cervella, take your privacy seriously. Before continuing, please read and understand our policies.</p>    <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I confirm I am 18 years old or older.</p>    <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I agree to the<a href=\"https://cervella.us/terms-of-service\">Terms of Service</a> and <a href=\"https://cervella.us/privacy-policy\">Privacy Policy</a>. I consent to the collection, processing, and disclosure of my de-identified treatment activity data by INNOVATIVE NEUROLOGICAL DEVICES LLC as described in the <a href=\"https://cervella.us/privacy-policy\">Privacy Policy</a>. I have the right to withdraw my consent at any time as described in the <a href=\"https://cervella.us/privacy-policy\">Privacy Policy</a>.</p>    <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I give my permission to receive marketing communications from INNOVATIVE NEUROLOGICAL DEVICES LLC about products and services that may be of interest to me. I understand that I have the right to opt-out from marketing communications at any time per the <a href=\"https://cervella.us/privacy-policy\">Privacy Policy</a>.</p>";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.textView.attributedText = str;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.contentOffset = CGPointMake(0, 0);
    
    _provisionBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _provisionBtn1.backgroundColor = [UIColor blueColor];
    [_provisionBtn1 setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    [_provisionBtn1 setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [_provisionBtn1 addTarget:self action:@selector(provisionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.textView addSubview:_provisionBtn1];
    
    _provisionBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [_provisionBtn2 setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    [_provisionBtn2 setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [_provisionBtn2 addTarget:self action:@selector(provisionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.textView addSubview:_provisionBtn2];
    
    _provisionBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    _provisionBtn3.backgroundColor = [UIColor blueColor];
    [_provisionBtn3 setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    [_provisionBtn3 setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [_provisionBtn3 addTarget:self action:@selector(provisionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.textView addSubview:_provisionBtn3];
    if (SCREENHEIGHT == 568) {
        _provisionBtn1.frame = CGRectMake(10, 122, 14, 14);
        _provisionBtn2.frame = CGRectMake(10, 150, 14, 14);
        _provisionBtn3.frame = CGRectMake(10, 278, 14, 14);
    } else if (SCREENHEIGHT == 667) {
        _provisionBtn1.frame = CGRectMake(10, 105 , 14, 14);
        _provisionBtn2.frame = CGRectMake(10, 133, 14, 14);
        _provisionBtn3.frame = CGRectMake(10, 245, 14, 14);
    } else if (SCREENHEIGHT == 736) {
        _provisionBtn1.frame = CGRectMake(10, 105, 14, 14);
        _provisionBtn2.frame = CGRectMake(10, 133, 14, 14);
        _provisionBtn3.frame = CGRectMake(10, 245, 14, 14);
    }
    else if (SCREENHEIGHT == 812) {
        _provisionBtn1.frame = CGRectMake(10, 105, 14, 14);
        _provisionBtn2.frame = CGRectMake(10, 132, 14, 14);
        _provisionBtn3.frame = CGRectMake(10, 246, 14, 14);
    }
    
}

- (void)provisionButtonAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (self.provisionBtn1.selected && self.provisionBtn2.selected) {
        self.RegisterBtn.backgroundColor = [UIColor colorWithRed:37/255.0 green:126/255.0 blue:214/255.0 alpha:1];
        self.RegisterBtn.enabled = YES;
    } else {
        self.RegisterBtn.backgroundColor = [UIColor lightGrayColor];
        self.RegisterBtn.enabled = NO;
    }
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissKeyboard {
    [_acountTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_birthTextField resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
//    if (URL) {
//        WebViewController *webVC = [[WebViewController alloc] init];
//        webVC.url = URL;
//        [self.navigationController pushViewController:webVC animated:YES];
//    }
//    return NO;
    return YES;
}

#pragma loginTableView -- delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 12, 22, 20)];
        [headImageView setImage:[UIImage imageNamed:@"register_head"]];
        [cell.contentView addSubview:headImageView];
        
        _acountTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 2, 230, 40)];
        _acountTextField.font = [UIFont systemFontOfSize:18];
        _acountTextField.placeholder = @"Username";
        _acountTextField.keyboardType = UIKeyboardTypeASCIICapable;
        [cell.contentView addSubview:_acountTextField];
    }
    else if (indexPath.row == 1)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 20, 20)];
        [headImageView setImage:[UIImage imageNamed:@"register_password"]];
        [cell.contentView addSubview:headImageView];
        
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 2, 230, 40)];
        _passwordTextField.font = [UIFont systemFontOfSize:18];
        _passwordTextField.placeholder = @"Password";
        _passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;

        [cell.contentView addSubview:_passwordTextField];
    }
    else if (indexPath.row == 2)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 11, 22, 22)];
        [headImageView setImage:[UIImage imageNamed:@"more_information"]];
        [cell.contentView addSubview:headImageView];
        
        _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 2, 230, 40)];
        _emailTextField.font = [UIFont systemFontOfSize:18];
        _emailTextField.placeholder = @"E-Mail";
        _emailTextField.keyboardType = UIKeyboardTypeASCIICapable;

        [cell.contentView addSubview:_emailTextField];
    }
    else if (indexPath.row == 3)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 12, 22, 20)];
        [headImageView setImage:[UIImage imageNamed:@"register_age"]];
        [cell.contentView addSubview:headImageView];
        
        _birthTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 2, 230, 40)];
        _birthTextField.font = [UIFont systemFontOfSize:18];
        _birthTextField.placeholder = @"Birthday";
        _birthTextField.userInteractionEnabled = NO;
        _birthTextField.keyboardType = UIKeyboardTypeASCIICapable;

        [cell.contentView addSubview:_birthTextField];
    }
    else
    {
        //性别和控件反的
        _maleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _maleBtn.tag = 11;
        _maleBtn.backgroundColor = [UIColor whiteColor];
        _maleBtn.frame = CGRectMake(20, 12, 20, 20);
        [_maleBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        _maleBtn.selected = YES;
        [_maleBtn addTarget:self action:@selector(genderSelect:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_maleBtn];
        
        UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 7, 20, 30)];
        maleLabel.textColor = [UIColor colorWithRed:0xA7/255.0 green:0xA7/255.0 blue:0xA7/255.0 alpha:1.0];
        maleLabel.font = [UIFont systemFontOfSize:18];
        maleLabel.textAlignment = NSTextAlignmentCenter;
        maleLabel.text = @"M";
        [cell.contentView addSubview:maleLabel];
        
        UIImageView *maleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 12, 21, 20)];
        [maleImageView setImage:[UIImage imageNamed:@"register_male"]];
        [cell.contentView addSubview:maleImageView];
        
        _femaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _femaleBtn.tag = 12;
        _femaleBtn.backgroundColor = [UIColor whiteColor];
        _femaleBtn.frame = CGRectMake(120, 12, 20, 20);
        [_femaleBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        [_femaleBtn addTarget:self action:@selector(genderSelect:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_femaleBtn];
        
        UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(145, 7, 20, 30)];
        femaleLabel.textColor = [UIColor colorWithRed:0xA7/255.0 green:0xA7/255.0 blue:0xA7/255.0 alpha:1.0];
        femaleLabel.font = [UIFont systemFontOfSize:18];
        femaleLabel.textAlignment = NSTextAlignmentCenter;
        femaleLabel.text = @"F";
        [cell.contentView addSubview:femaleLabel];
        
        UIImageView *femaleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(170, 12, 13, 20)];
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
        
        self.datePicker = [[DatePickerView alloc] initWithFrame:CGRectMake(0, 359*Rate_NAV_H, 375*Rate_NAV_W, 248*Rate_NAV_H) Year:_year Month:_month ];
        [self showDatePicker];
    }
}

/** 显示出生年月选择器 */
- (void)showDatePicker
{
    [self dismissKeyboard];
    
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
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Cell-phone number cannot be empyt,please check and re-enter.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if (_passwordTextField.text.length < 6)
    {
        //提示密码过短
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Password length should have at least 6 numbers.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if(_emailTextField.text.length == 0 || ![self isEmailAddress:_emailTextField.text])
    {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Email format incorrect,please re-try. ");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if(_birthTextField.text.length == 0)
    {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Please select Date of birth.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if (!_femaleBtn.selected && !_maleBtn) {
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Please select a gender.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if (!self.provisionBtn1.selected || !self.provisionBtn2.selected) {
       
    }
    else
    {
        _patientInfo.PatientID = _acountTextField.text;
        _patientInfo.PatientPwd = _passwordTextField.text;
        _patientInfo.PatientName = _passwordTextField.text;
        _patientInfo.Birthday = _birthTextField.text;
        _patientInfo.Email = _emailTextField.text;
        _patientInfo.PatientSex = @"Male";
        if (_femaleBtn.selected) {
            _patientInfo.PatientSex = @"Female";
        }
        _patientInfo.CellPhone = @"";
        _patientInfo.Age = 0;
        _patientInfo.FamilyPhone = @"";
        _patientInfo.PatientContactWay = @"";
        _patientInfo.Marriage = @"";
        _patientInfo.Vocation = @"";
        _patientInfo.PatientHeight = @"";
        _patientInfo.PatientWeight = @"";
        _patientInfo.NativePlace = @"";
        _patientInfo.BloodModel = @"";
        _patientInfo.Address = @"";
        _patientInfo.PatientRemarks = @"";
        _patientInfo.Picture = @"";
        _patientInfo.PhotoUrl = @"";
        
//        [{"Address":"","Age":"32","Birthday":"1987.06.03","BloodModel":"","CellPhone":"","Email":"123456@163.com","FamilyPhone":"","IDCard":"","Marriage":"","NativePlace":"","PatientHeight":"","PatientID":"Mine","PatientName":"","PatientPwd":"123456","PatientRemarks":"","PatientSex":"Male","PatientType":"2","PatientWeight":"","Picture":"","Vocation":""}]
        
        //做一个默认头像
        //图片下载完成  在这里进行相关操作，如加到数组里 或者显示在imageView上
//        UIImage *photoImage = [UIImage imageNamed:@"Default.jpg"];
//        NSData *imageData = UIImagePNGRepresentation(photoImage);
//        _patientInfo.Picture = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//        _patientInfo.PhotoUrl = @"//PatientHeadImg//Default.jpg";
        
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
        if ([value isKindOfClass:[PatientInfo class]]) {
            isOverTime=NO;
            
            _patientInfo = value;
            //隐藏Loading
            jxt_dismissHUD();
            
            [self changeRoot];
        } else {
            jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"密码输入错误，请重新输入");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
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

//切换app的根视图控制器
- (void)changeRoot
{
    //变更app的根视图控制器
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *app2 =  (AppDelegate*)app.delegate;
    app2.window.backgroundColor = [UIColor whiteColor];
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.patientInfo = _patientInfo;
    
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    app2.window.rootViewController = rootVC;
    
    [app2.window makeKeyAndVisible];
}

//邮箱
- (BOOL)isEmailAddress:(NSString *)str{
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [pre evaluateWithObject:str];
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
