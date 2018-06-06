//
//  RegisterViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/18.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import "Define.h"

#import "DataBaseOpration.h"
#import "InterfaceModel.h"

#import "JXTAlertManagerHeader.h"
#import "DatePickerView.h"

#import "ProtocolViewController.h"

@interface RegisterViewController ()<UITableViewDelegate,UITableViewDataSource,InterfaceModelDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (strong, nonatomic) UITableView *registerTableviewOne;
@property (strong, nonatomic) UITableView *registerTableviewTwo;
@property (strong, nonatomic) IBOutlet UIButton *registerAndLoginBtn;

@property (nonatomic, strong) DatePickerView *datePicker; // 日期选择器
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;

@end

@implementation RegisterViewController
{
    UITextField *phoneNumTextField;    //手机号码输入框
       UIButton *verifyButton;         //验证按钮
    UITextField *verifyNumTextField;   //验证码输入框
    UITextField *passwordTextField;    //密码输入框
       UIButton *changeVisible;        //是否显示输入的密码按钮
           BOOL isVisible;             //标识密码输入框中输入的密码是否可见（默认为不可见）
    UITextField *birthTextField;       //选择出生年月输入框（输入框不可编辑）
    UITextField *sexTextField;         //选择性别（输入框不可编辑）
       UIButton *btnMale;
       UIButton *btnFemale;
    
    DataBaseOpration *dbOpration;
      InterfaceModel *interfaceModel;
    
            NSString *code;            //发送给用户的短信验证码
    
             NSTimer *m_timer;         //设置验证按钮计时器
                 int secondsCountDown;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"注册";
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
    
    _patientInfo = [PatientInfo shareInstance];
    _patientInfo.PatientSex = @"男";
    
    interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
    
    _registerTableviewOne = [[UITableView alloc] initWithFrame:CGRectMake(0, 10*Rate_NAV_H, 375*Rate_NAV_W, 150*Rate_NAV_H) style:UITableViewStylePlain];
    _registerTableviewOne.tag = 0;
    if ([_registerTableviewOne respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _registerTableviewOne.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_registerTableviewOne];
    _registerTableviewOne.scrollEnabled = NO;
    _registerTableviewOne.delegate=self;
    _registerTableviewOne.dataSource=self;
    [_registerTableviewOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10*Rate_NAV_H);
        make.left.equalTo(self.view).offset(0);
        make.height.equalTo(self.view.mas_height).multipliedBy(150.0/603);//multipliedBy中传入的参数必须是浮点数
        make.right.equalTo(self.view).offset(0);
    }];
    
    _registerTableviewTwo = [[UITableView alloc] initWithFrame:CGRectMake(0, 180*Rate_NAV_H, 375*Rate_NAV_W, 100*Rate_NAV_H) style:UITableViewStylePlain];
    _registerTableviewTwo.tag = 1;
    if ([_registerTableviewTwo respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _registerTableviewTwo.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_registerTableviewTwo];
    _registerTableviewTwo.scrollEnabled = NO;
    _registerTableviewTwo.delegate=self;
    _registerTableviewTwo.dataSource=self;
    [_registerTableviewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_registerTableviewOne.mas_bottom).offset(20*Rate_NAV_H);
        make.width.equalTo(_registerTableviewOne.mas_width);//使宽高等于redView
        make.height.equalTo(_registerTableviewOne.mas_height).multipliedBy(2.0/3);
    }];
    
    //设置键盘收起手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doHideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [_registerTableviewOne.backgroundView addGestureRecognizer:tap];
    [self.view  addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    
    //设置注册按钮背景图片
    [_registerAndLoginBtn setBackgroundImage:[UIImage imageNamed:@"signin_btn_bg1"] forState:UIControlStateNormal];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doHideKeyBoard
{
    [phoneNumTextField resignFirstResponder];
    [verifyNumTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

//注册并登录按钮点击事件
- (IBAction)registerAndLoginBtnClick:(UIButton *)sender
{
    if ([verifyNumTextField.text isEqualToString:code])
    {
        if (passwordTextField.text.length < 6 && passwordTextField.text.length > 0)
        {
            //提示密码过短
            jxt_showTextHUDTitleMessage(@"温馨提示", @"密码不能低于6位，请检查后重新输入");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
        else if (passwordTextField.text.length == 0)
        {
            //提示密码过短
            jxt_showTextHUDTitleMessage(@"温馨提示", @"密码不能为空，请检查后重新输入");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
        else
        {
            _patientInfo.PatientID = phoneNumTextField.text;
            _patientInfo.PatientPwd = passwordTextField.text;
            _patientInfo.PatientName = phoneNumTextField.text;
            _patientInfo.CellPhone = phoneNumTextField.text;
            NSString *birthStr_One = [birthTextField.text substringWithRange:NSMakeRange(0, 4)];
            NSString *birthStr_Two = [birthTextField.text substringWithRange:NSMakeRange(5, 2)];
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
            
            ProtocolViewController *protocolVC = [[ProtocolViewController alloc] init];
            [self.navigationController pushViewController:protocolVC animated:YES];
        }
    }
    else if(verifyNumTextField.text == nil)
    {
        jxt_showTextHUDTitleMessage(@"温馨提示", @"验证码不能为空，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if(birthTextField.text == nil)
    {
        jxt_showTextHUDTitleMessage(@"温馨提示", @"出生年月不能为空，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else
    {
        jxt_showTextHUDTitleMessage(@"温馨提示", @"验证码输入错误，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0)
    {
        return 3;
    }
    else if (tableView.tag == 1)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Rate_NAV_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (tableView.tag == 0)
    {
        if (indexPath.row == 0)
        {
            cell =[[UITableViewCell alloc] init];
            
            UIImageView *cellPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 14*Rate_NAV_H, 15*Rate_NAV_W, 22*Rate_NAV_H)];
            [cellPhoneImageView setImage:[UIImage imageNamed:@"icon_phone"]];
            
            phoneNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
            phoneNumTextField.tag = 0;
            phoneNumTextField.placeholder = @"手机号";
            phoneNumTextField.keyboardType=UIKeyboardTypeNumberPad;
            
            [cell.contentView addSubview:cellPhoneImageView];
            [cell.contentView addSubview:phoneNumTextField];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
        else if(indexPath.row == 1)
        {
            cell = [[UITableViewCell alloc] init];
            
            UIImageView *verifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 18.5*Rate_NAV_H, 16*Rate_NAV_W, 13*Rate_NAV_H)];
            [verifyImageView setImage:[UIImage imageNamed:@"icon_code"]];
            
            verifyNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
            verifyNumTextField.tag = 1;
            verifyNumTextField.placeholder = @"验证码";
            verifyNumTextField.keyboardType = UIKeyboardTypeNumberPad;
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 130.5*Rate_NAV_W, 3*Rate_NAV_H, 0.3, 44*Rate_NAV_H)];
            lineView.backgroundColor = [UIColor lightGrayColor];
            
            verifyButton = [UIButton buttonWithType:UIButtonTypeSystem];
            verifyButton.frame = CGRectMake(SCREENWIDTH - 115*Rate_NAV_W, 0, 100*Rate_NAV_W, 50*Rate_NAV_H);
            [verifyButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            verifyButton.tag = 1;
            [verifyButton setTitle:@"发送验证码" forState:UIControlStateNormal];
            [verifyButton addTarget:self action:@selector(verifyButton:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:verifyImageView];
            [cell.contentView addSubview:verifyNumTextField];
            [cell.contentView addSubview:lineView];
            [cell.contentView addSubview:verifyButton];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if (indexPath.row == 2)
        {
            cell = [[UITableViewCell alloc] init];
            
            UIImageView *passwordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 16.5*Rate_NAV_H, 15*Rate_NAV_W, 17*Rate_NAV_H)];
            [passwordImageView setImage:[UIImage imageNamed:@"icon_password"]];
            
            passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
            passwordTextField.tag = 2;
            passwordTextField.placeholder = @"密码";
            passwordTextField.secureTextEntry = YES;
            isVisible = NO;
            
            changeVisible = [UIButton buttonWithType:UIButtonTypeCustom];
            changeVisible.frame = CGRectMake(SCREENWIDTH - 36*Rate_NAV_W, 19*Rate_NAV_H, 21*Rate_NAV_W, 12*Rate_NAV_H);
            [changeVisible setImage:[UIImage imageNamed:@"icon_eye"] forState:UIControlStateNormal];
            [changeVisible addTarget:self action:@selector(setPasswordTextFieldIsVisible:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:passwordImageView];
            [cell.contentView addSubview:passwordTextField];
            [cell.contentView addSubview:changeVisible];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else if (tableView.tag == 1)
    {
        if (indexPath.row == 0)
        {
            cell = [[UITableViewCell alloc] init];
            
            UIImageView *birthImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 17*Rate_NAV_H, 18*Rate_NAV_W, 16*Rate_NAV_H)];
            [birthImageView setImage:[UIImage imageNamed:@"icon_birth"]];
            
            birthTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
            birthTextField.tag = 3;
            birthTextField.placeholder = @"出生年月";
            birthTextField.userInteractionEnabled = NO;
            
            [cell.contentView addSubview:birthImageView];
            [cell.contentView addSubview:birthTextField];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if(indexPath.row == 1)
        {
            cell = [[UITableViewCell alloc] init];
            
            UIImageView *sexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 14.5*Rate_NAV_H, 15*Rate_NAV_W, 21*Rate_NAV_H)];
            [sexImageView setImage:[UIImage imageNamed:@"icon_sex"]];
            sexTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
            sexTextField.userInteractionEnabled = NO;
            sexTextField.placeholder = @"性别";
            
            btnMale = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 128*Rate_NAV_W, 15*Rate_NAV_H, 39*Rate_NAV_W, 21*Rate_NAV_H)];
            btnMale.tag = 1;
            [btnMale setTitleColor:[UIColor colorWithRed:109/255.0 green:111/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
            btnMale.titleLabel.font = [UIFont systemFontOfSize:16];
            [btnMale setTitle:@"男" forState:UIControlStateNormal];
            [btnMale setImage:[UIImage imageNamed:@"icon_man_in"] forState:UIControlStateNormal];
            btnMale.imageEdgeInsets = UIEdgeInsetsMake(1.5*Rate_NAV_H, 0, 1.5*Rate_NAV_H, 21*Rate_NAV_W);
            btnMale.titleEdgeInsets = UIEdgeInsetsMake(1*Rate_NAV_H, 0*Rate_NAV_W, 1*Rate_NAV_H, 0);
            [btnMale addTarget:self action:@selector(chooseGeder:) forControlEvents:UIControlEventTouchUpInside];
            btnFemale = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 54*Rate_NAV_W, 15*Rate_NAV_H, 39*Rate_NAV_W, 21*Rate_NAV_H)];
            btnFemale.tag = 2;
            [btnFemale setTitleColor:[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1] forState:UIControlStateNormal];
            btnFemale.titleLabel.font = [UIFont systemFontOfSize:16];
            [btnFemale setTitle:@"女" forState:UIControlStateNormal];
            [btnFemale setImage:[UIImage imageNamed:@"icon_women"] forState:UIControlStateNormal];
            btnFemale.imageEdgeInsets = UIEdgeInsetsMake(2*Rate_NAV_H, 0, 2*Rate_NAV_H, 22*Rate_NAV_W);
            btnFemale.titleEdgeInsets = UIEdgeInsetsMake(1*Rate_NAV_H, 0*Rate_NAV_W, 1*Rate_NAV_H, 0);
            [btnFemale addTarget:self action:@selector(chooseGeder:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:sexImageView];
            [cell.contentView addSubview:sexTextField];
            [cell.contentView addSubview:btnMale];
            [cell.contentView addSubview:btnFemale];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击cell，判断是第四个cell时底部谈起日期选择
    if (tableView.tag == 1 && indexPath.row == 0)
    {
        if ([birthTextField.text isEqualToString:@"出生年月"])
        {
            birthTextField.text = @"请在底部选择";
            NSDate *EndDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM"];
            NSString *endTime = [dateFormatter stringFromDate:EndDate];
            
            _year = [[endTime substringWithRange:NSMakeRange(0, 4)] integerValue];
            _month = [[endTime substringWithRange:NSMakeRange(5, birthTextField.text.length-6)] integerValue];
        }
        else if ([birthTextField.text containsString:@"年"])
        {
            _year = [[birthTextField.text substringWithRange:NSMakeRange(0, 4)] integerValue];
            _month = [[birthTextField.text substringWithRange:NSMakeRange(5, birthTextField.text.length-6)] integerValue];
        }
        
        self.datePicker = [[DatePickerView alloc] initWithFrame:CGRectMake(0, 359*Rate_NAV_H, 375*Rate_NAV_W, 248*Rate_NAV_H) Year:_year Month:_month];
        [self showDatePicker];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15*Rate_NAV_W, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15*Rate_NAV_W, 0, 0)];
    }
}

//性别选择
- (void)chooseGeder:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        _patientInfo.PatientSex = @"男";
        [sender setImage:[UIImage imageNamed:@"icon_man_in"] forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor colorWithRed:109/255.0 green:111/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
        [btnFemale setImage:[UIImage imageNamed:@"icon_women"] forState:UIControlStateNormal];
        [btnFemale setTitleColor:[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1] forState:UIControlStateNormal];
    }
    else if (sender.tag == 2)
    {
        _patientInfo.PatientSex = @"女";
        [sender setImage:[UIImage imageNamed:@"icon_women_in"] forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor colorWithRed:109/255.0 green:111/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
        [btnMale setImage:[UIImage imageNamed:@"icon_man"] forState:UIControlStateNormal];
        [btnMale setTitleColor:[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1] forState:UIControlStateNormal];
    }
}

/** 显示出生年月选择器 */
- (void)showDatePicker
{
    [self.datePicker show];

    __weak typeof(self) weakSelf = self;
    __weak typeof(birthTextField) weakBirthTextField = birthTextField;
    
    self.datePicker.gotoSrceenOrderBlock = ^(NSString *valueStr){
        [weakSelf.datePicker hide];
        if (![valueStr isEqualToString:weakBirthTextField.text])
        {
            weakBirthTextField.text = valueStr;
        }
    };
}

-(void)setPasswordTextFieldIsVisible:(UIButton *)sender
{
    if (isVisible)
    {
        [changeVisible setImage:[UIImage imageNamed:@"icon_eye"] forState:UIControlStateNormal];
        passwordTextField.secureTextEntry=YES;
        isVisible = NO;
    }
    else
    {
        [changeVisible setImage:[UIImage imageNamed:@"icon_eye_in"] forState:UIControlStateNormal];
        passwordTextField.secureTextEntry=NO;
        isVisible = YES;
    }
}

//验证按钮的点击事件
-(void)verifyButton:(UIButton *)sender
{
    //发送短信之前调用验证手机号借口（根据返回结果判断此手机号是否能注册）
    if ([self isMobileNumber:phoneNumTextField.text])
    {
        //调用接口
        [interfaceModel sendJsonPhoneToServer:phoneNumTextField.text];
    }
    else
    {
        //提示输入的不是手机号码有误
        jxt_showTextHUDTitleMessage(@"温馨提示", @"手机号格式错误，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if(interfaceModelBackType == InterfaceModelBackTypeVerifyAccount)
    {
        //做90秒倒计时
        m_timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calcuRemainTime) userInfo:nil repeats:YES];
        secondsCountDown=90;
        NSString *strTime = [NSString stringWithFormat:@"重新发送(%.2ds)", secondsCountDown];
        [verifyButton setTitle:strTime forState:UIControlStateNormal];
        verifyButton.userInteractionEnabled=NO;
    }
    else if (interfaceModelBackType == InterfaceModelBackTypeMessage)
    {
        code = value;
    }
}

-(void)calcuRemainTime
{
    secondsCountDown--;
    NSString *strTime = [NSString stringWithFormat:@"重新发送(%.2ds)", secondsCountDown];
    [verifyButton setTitle:strTime forState:UIControlStateNormal];
    if (secondsCountDown<=0)
    {
        [m_timer invalidate];
        [verifyButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        verifyButton.userInteractionEnabled=YES;
    }
}

///// 手机号码的有效性判断
//检测是否是手机号码
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     * 联通：130,131,132,145,155,156,170,171,175,176,185,186
     * 电信：133,149,153,170,177,180,181,189
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     */
    NSString *CM = @"^1((3[4-9]|4[7]|5[0-27-9]|7[08]|8[23478])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,145,155,156,170,171,175,176,185,186
     */
    NSString *CU = @"^1(3[0-2]|45|5[56]|7[0156]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,149,153,170,177,180,181,189
     */
    NSString *CT = @"^1(33|49|53|7[07]|8[019])\\d{8}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
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
