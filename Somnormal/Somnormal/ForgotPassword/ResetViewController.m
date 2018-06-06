//
//  ResetViewController.m
//  Somnormal
//
//  Created by Justin on 2017/6/28.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "ResetViewController.h"

@interface ResetViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSXMLParserDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *resetTableView;

@property (strong, nonatomic) UITextField *passwordTextfield;
@property (strong, nonatomic) UITextField *refillTextfield;

@property (strong,nonatomic)   NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic)     NSXMLParser *xmlParser;
@property (nonatomic)                   BOOL elementFound;
@property (strong,nonatomic)        NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end

@implementation ResetViewController
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Password Reset";
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
    
    _resetTableView.scrollEnabled =NO; //设置tableview不能滚动
    _resetTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _resetTableView.delegate = self;
    _resetTableView.dataSource = self;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF4/255.0 blue:0xF4/255.0 alpha:1.0];
    if (indexPath.row == 0)
    {
        _passwordTextfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SCREENWIDTH - 20, 40)];
        _passwordTextfield.placeholder = @"Password should be 6-18 numbers";
        _passwordTextfield.secureTextEntry = YES;
        [cell.contentView addSubview:_passwordTextfield];
    }
    else
    {
        _refillTextfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SCREENWIDTH - 20, 40)];
        _refillTextfield.placeholder = @"Please enter the password again";
        _refillTextfield.secureTextEntry = YES;
        [cell.contentView addSubview:_refillTextfield];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (IBAction)confirmBtnClick:(UIButton *)sender
{
    if (_passwordTextfield.text.length > 5)
    {
        if ([_passwordTextfield.text isEqualToString:_refillTextfield.text])
        {
            NSString *PatientID = _patientInfo.PatientID;
            NSString *PatientPwd = _refillTextfield.text;
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
            jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Two password is not consistent.Please check and re-enter");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
    }
    else
    {
        //提示输入密码过短
        jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Password length should have at least 6 numbers.Please check and re-enter");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
}

#pragma mark - UITextFieldDelegate实现
/*点击编辑区域外的view收起键盘*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_passwordTextfield resignFirstResponder];
    [_refillTextfield resignFirstResponder];
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
                _patientInfo.PatientPwd = _refillTextfield.text;
                DataBaseOpration *dataBaseOpration = [[DataBaseOpration alloc] init];
                [dataBaseOpration updataUserInfo:_patientInfo];
                [dataBaseOpration closeDataBase];
                //提示修改成功
                jxt_showTextHUDTitleMessage(@"Kindly Reminder", @"Modified successful");
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
