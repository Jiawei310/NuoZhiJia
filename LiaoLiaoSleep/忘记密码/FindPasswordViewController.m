//
//  FindPasswordViewController.m
//  SleepExpert
//
//  Created by 诺之家 on 16/6/21.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "Define.h"

#import "DataBaseOpration.h"
#import "JXTAlertManagerHeader.h"

#import "ResetPasswordViewController.h"

@interface FindPasswordViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate,UITextFieldDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (strong, nonatomic) UITableView *findPasswordTableView;
@property (strong, nonatomic)    UIButton *nextButton;

@end

@implementation FindPasswordViewController
{
    UITextField *phoneNumTextField;
    UITextField *verifyNumTextField;
    
    NSString *code;
    
    DataBaseOpration *dataBaseOpration;
    NSMutableArray *patientArray;                //存储从数据库中取出的用户信息
    
    UIButton *verifyButton;
    
    NSTimer *m_timer; //设置验证按钮计时器
    int secondsCountDown;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"密码找回";
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
    
    _findPasswordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10*Rate_NAV_H, 375*Rate_NAV_W, 100*Rate_NAV_H) style:UITableViewStylePlain];
    if ([_findPasswordTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _findPasswordTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_findPasswordTableView];
    _findPasswordTableView.scrollEnabled = NO;
    _findPasswordTableView.dataSource = self;
    _findPasswordTableView.delegate = self;
    
    _nextButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - 292)/2, 573*Rate_NAV_H - 44, 292, 44)];
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"signin_btn_bg1"] forState:UIControlStateNormal];
    [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    _nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_nextButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
    
    _patientInfo = [PatientInfo shareInstance];
    
    dataBaseOpration = [[DataBaseOpration alloc] init];
    patientArray = [NSMutableArray array];
    patientArray = [dataBaseOpration getPatientDataFromDataBase];
    for (PatientInfo *tmp in patientArray)
    {
        if ([tmp.CellPhone isEqualToString:self.PatientID])
        {
            _patientInfo = tmp;
        }
    }
    [dataBaseOpration closeDataBase];
    
    if (_patientInfo.PatientID == nil)
    {
        [self getPatientInfo];
    }
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getPatientInfo
{
    NSDictionary *jsonPatientID = [NSDictionary dictionaryWithObjectsAndKeys:_PatientID,@"PatientID",nil];
    NSArray *jsonArray = [NSArray arrayWithObjects:jsonPatientID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    NSLog(@"JsonString>>>>%@",jsonString);
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_GetPatientInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_GetPatientInfo xmlns=\"MeetingOnline\">"
                         "<JsonPatientID>%@</JsonPatientID>"
                         "</APP_GetPatientInfo>"
                         "</soap12:Body>"
                         "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    
    //设置网络连接的url
    NSString *urlStr = [NSString stringWithFormat:@"%@",ADDRESS];
    NSURL *url = [NSURL URLWithString:urlStr];
    //设置request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [request setHTTPMethod:@"POST"];//默认是GET
    // 将SOAP消息加到请求中
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    // 创建连接
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    //这里是会报警告的代码
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
#pragma clang diagnostic pop
    if (conn)
    {
        webData = [NSMutableData data];
    }
}

- (void)nextButtonClick:(UIButton *)sender
{
    if ([verifyNumTextField.text isEqualToString:code])
    {
        //页面跳转到重置密码界面
        ResetPasswordViewController *resetPasswordController=[[ResetPasswordViewController alloc] initWithNibName:@"ResetPasswordViewController" bundle:nil];
        
        [self.navigationController pushViewController:resetPasswordController animated:YES];
    }
    else if(verifyNumTextField.text.length == 0 || verifyNumTextField.text == nil)
    {
        //提示验证码不能为空
        jxt_showTextHUDTitleMessage(@"温馨提示", @"验证码不能为空，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
    else if (verifyNumTextField.text.length != 0 && ![verifyNumTextField.text isEqualToString:code])
    {
        //提示验证码输入不正确
        jxt_showTextHUDTitleMessage(@"温馨提示", @"验证码输入不正确，请检查后重新输入");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
}

- (void)backClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//tableview的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*Rate_NAV_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"FindPassword";
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        UIImageView *cellPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 14*Rate_NAV_H, 15*Rate_NAV_W, 22*Rate_NAV_H)];
        [cellPhoneImageView setImage:[UIImage imageNamed:@"icon_phone"]];
        
        phoneNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
        phoneNumTextField.tag = 0;
        if (_patientInfo.PatientID == nil)
        {
            phoneNumTextField.text = self.PatientID;
        }
        else
        {
            phoneNumTextField.text = _patientInfo.CellPhone;
        }
        phoneNumTextField.userInteractionEnabled = NO;
        
        [cell.contentView addSubview:cellPhoneImageView];
        [cell.contentView addSubview:phoneNumTextField];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
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
    return nil;
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

//验证按钮的点击事件
- (void)verifyButton:(UIButton *)sender
{
    NSString *phoneNum = phoneNumTextField.text;
    NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:phoneNum,@"CellPhone",nil];
    NSArray *jsonArray = [NSArray arrayWithObjects:jsonPhoneNum, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_SendShortMessageResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_SendShortMessage xmlns=\"MeetingOnline\">"
                         "<JsonPhoneInfo>%@</JsonPhoneInfo>"
                         "</APP_SendShortMessage>"
                         "</soap12:Body>"
                         "</soap12:Envelope>", jsonString,nil];
    //打印soapMsg信息
    NSLog(@"%@",soapMsg);
    
    //设置网络连接的url
    NSString *urlStr = [NSString stringWithFormat:@"%@",ADDRESS];
    NSURL *url = [NSURL URLWithString:urlStr];
    //设置request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [request setHTTPMethod:@"POST"];//默认是GET
    // 将SOAP消息加到请求中
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    // 创建连接
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        webData = [NSMutableData data];
    }
    //做90秒倒计时
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calcuRemainTime) userInfo:nil repeats:YES];
    secondsCountDown = 90;
    verifyButton.userInteractionEnabled=NO;
}

- (void)calcuRemainTime
{
    secondsCountDown--;
    NSString *strTime = [NSString stringWithFormat:@"重新发送(%.2ds)", secondsCountDown];
    [verifyButton setTitle:strTime forState:UIControlStateNormal];
    if (secondsCountDown <= 0)
    {
        [m_timer invalidate];
        [verifyButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        verifyButton.userInteractionEnabled=YES;
    }
}

#pragma mark -
#pragma mark URL Connection Data Delegate Methods

// 刚开始接受响应时调用
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response
{
    [webData setLength: 0];
}

// 每接收到一部分数据就追加到webData中
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *) data
{
    [webData appendData:data];
}

// 出现错误时
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    conn = nil;
    webData = nil;
}

// 完成接收数据时调用
- (void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes]
                                                length:[webData length]
                                              encoding:NSUTF8StringEncoding];
    
    // 打印出得到的XML
    NSLog(@"%@", theXML);
    // 使用NSXMLParser解析出我们想要的结果
    xmlParser = [[NSXMLParser alloc] initWithData: webData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
}


#pragma mark -
#pragma mark XML Parser Delegate Methods

// 开始解析一个元素名
- (void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:matchingElement])
    {
        if (!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        elementFound = YES;
    }
}

// 追加找到的元素值，一个元素值可能要分几次追加
- (void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if (elementFound)
    {
        [soapResults appendString: string];
    }
}

// 结束解析这个元素名
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:matchingElement])
    {
        if ([matchingElement isEqualToString:@"APP_SendShortMessageResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult = [soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            code = [resultDic objectForKey:@"Code"];
            NSLog(@"%@",code);
        }
        else if ([matchingElement isEqualToString:@"APP_GetPatientInfoResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult = [soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultDic = [resultArray objectAtIndex:0];
            
            _patientInfo.PatientID = _PatientID;
            _patientInfo.PatientName = [resultDic objectForKey:@"PatientName"];
            _patientInfo.PatientSex = [resultDic objectForKey:@"PatientSex"];
            _patientInfo.Birthday = [resultDic objectForKey:@"Birthday"];
            _patientInfo.Age = [[resultDic objectForKey:@"Age"] integerValue];
            _patientInfo.Marriage = [resultDic objectForKey:@"Marriage"];
            _patientInfo.NativePlace = [resultDic objectForKey:@"NativePlace"];
            _patientInfo.BloodModel = [resultDic objectForKey:@"BloodModel"];
            _patientInfo.CellPhone = [resultDic objectForKey:@"CellPhone"];
            _patientInfo.FamilyPhone = [resultDic objectForKey:@"FamilyPhone"];
            _patientInfo.Email = [resultDic objectForKey:@"Email"];
            _patientInfo.Vocation = [resultDic objectForKey:@"Vocation"];
            _patientInfo.Address = [resultDic objectForKey:@"Address"];
            _patientInfo.Picture = [resultDic objectForKey:@"PhotoUrl"];
            _patientInfo.PatientHeight = [resultDic objectForKey:@"PatientHeight"];
            _patientInfo.PatientWeight = [resultDic objectForKey:@"PatientWeight"];
        }
        elementFound = FALSE;
        // 强制放弃解析
        [xmlParser abortParsing];
    }
}

// 解析整个文件结束后
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

// 出错时，例如强制结束解析
- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

/*点击编辑区域外的view收起键盘*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [verifyNumTextField resignFirstResponder];
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
