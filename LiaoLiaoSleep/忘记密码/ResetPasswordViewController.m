//
//  ResetPasswordViewController.m
//  SleepExpert
//
//  Created by 诺之家 on 16/6/21.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "Define.h"

#import "DataBaseOpration.h"
#import "JXTAlertManagerHeader.h"

@interface ResetPasswordViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate,UITextFieldDelegate>

@property (strong, nonatomic) UITableView *resetPasswordTableView;
@property (strong, nonatomic)    UIButton *submitButton;

@end

@implementation ResetPasswordViewController
{
    UITextField *newPasswordTextField;
    UITextField *repeatTextField;
    
    DataBaseOpration *dataBaseOpration;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"密码重置";
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
    
    _resetPasswordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10*Rate_NAV_H, 375*Rate_NAV_W, 100*Rate_NAV_H) style:UITableViewStylePlain];
    [self.view addSubview:_resetPasswordTableView];
    _resetPasswordTableView.scrollEnabled = NO;
    if ([_resetPasswordTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _resetPasswordTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    _resetPasswordTableView.dataSource = self;
    _resetPasswordTableView.delegate = self;
    
    _submitButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - 292)/2, 573*Rate_NAV_H - 44, 292, 44)];
    [_submitButton setBackgroundImage:[UIImage imageNamed:@"signin_btn_bg1"] forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
    _submitButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_submitButton addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitButton];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitButtonClick:(UIButton *)sender
{
    if (newPasswordTextField.text.length>5)
    {
        if ([newPasswordTextField.text isEqualToString:repeatTextField.text])
        {
            NSString *PatientID = [PatientInfo shareInstance].PatientID;
            NSString *PatientPwd = repeatTextField.text;
            NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:PatientID,@"PatientID",PatientPwd,@"PatientNewPwd",nil];
            NSArray *jsonArray = [NSArray arrayWithObjects:jsonPhoneNum, nil];
            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
            NSLog(@"JsonString>>>>%@",jsonString);
            
            // 设置我们之后解析XML时用的关键字
            matchingElement = @"APP_PatientUpdatePwdResponse";
            // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
            NSString *soapMsg = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap12:Envelope "
                                 "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                 "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                 "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap12:Body>"
                                 "<APP_PatientUpdatePwd xmlns=\"MeetingOnline\">"
                                 "<JsonUpdatePwd>%@</JsonUpdatePwd>"
                                 "</APP_PatientUpdatePwd>"
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
            //这里是会报警告的代码
            // 创建连接
            conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
#pragma clang diagnostic pop
            if (conn)
            {
                webData = [NSMutableData data];
            }
        }
        else
        {
            //提示输入不一致
            jxt_showTextHUDTitleMessage(@"温馨提示", @"密码输入不一致，请检查后重新输入");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
    }
    else
    {
        //提示输入密码过短
        jxt_showTextHUDTitleMessage(@"温馨提示", @"密码长度过短，请重新设置");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
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
        
        UIImageView *passwordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 16.5*Rate_NAV_H, 15*Rate_NAV_W, 17*Rate_NAV_H)];
        [passwordImageView setImage:[UIImage imageNamed:@"icon_password"]];
        
        newPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
        newPasswordTextField.tag = 2;
        newPasswordTextField.placeholder = @"输入6-18位新密码";
        newPasswordTextField.secureTextEntry = YES;
        
        [cell.contentView addSubview:passwordImageView];
        [cell.contentView addSubview:newPasswordTextField];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        UIImageView *passwordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 16.5*Rate_NAV_H, 15*Rate_NAV_W, 17*Rate_NAV_H)];
        [passwordImageView setImage:[UIImage imageNamed:@"icon_password"]];
        
        repeatTextField = [[UITextField alloc] initWithFrame:CGRectMake(50*Rate_NAV_W, 0, 325*Rate_NAV_W, 50*Rate_NAV_H)];
        repeatTextField.tag = 2;
        repeatTextField.placeholder = @"请再次输入新密码";
        repeatTextField.secureTextEntry = YES;
        
        [cell.contentView addSubview:passwordImageView];
        [cell.contentView addSubview:repeatTextField];
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

#pragma mark -
#pragma mark URL Connection Data Delegate Methods

// 刚开始接受响应时调用
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response
{
    [webData setLength: 0];
}

// 每接收到一部分数据就追加到webData中
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *) data
{
    [webData appendData:data];
}

// 出现错误时
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    conn = nil;
    webData = nil;
}

// 完成接收数据时调用
-(void) connectionDidFinishLoading:(NSURLConnection *) connection
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
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict
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
-(void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if (elementFound)
    {
        [soapResults appendString: string];
    }
}

// 结束解析这个元素名
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:matchingElement])
    {
        if ([matchingElement isEqualToString:@"APP_PatientUpdatePwdResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult = [soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *state = [resultDic objectForKey:@"state"];
            if ([state isEqualToString:@"OK"])
            {
                PatientInfo *patientInfo = [PatientInfo shareInstance];
                patientInfo.PatientPwd = repeatTextField.text;
                dataBaseOpration = [[DataBaseOpration alloc] init];
                [dataBaseOpration updataUserInfo:patientInfo];
                [dataBaseOpration closeDataBase];
                //提示修改成功
                jxt_showTextHUDTitleMessage(@"温馨提示", @"修改成功");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                //没有更新到服务器，查看网络连接是否正常
            }
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [newPasswordTextField resignFirstResponder];
    [repeatTextField resignFirstResponder];
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
