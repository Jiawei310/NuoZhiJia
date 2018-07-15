//
//  HomeViewController.m
//  Cervella
//
//  Created by Justin on 2017/6/28.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "HomeViewController.h"

#import "BLEInfo.h"

#import "SCNavTabBarController.h"

#import "StartsViewController.h"
#import "AssessViewController.h"

#import "IntelligentHardwareViewController.h"
#import "AboutViewController.h"
#import "HelpViewController.h"

#import "TreatDataViewController.h"
#import "MyInfoViewController.h"

#import "AESCipher.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property UITableView *menuTableView;
@property BLEInfo *BleInfo;

@end

@implementation HomeViewController
{
    UIView *view;
    NSArray *menuArray;
    
    UIImageView *menuImageView;
    
    DataBaseOpration *dbOpration;
    NSArray *treatInfoArray;
    NSArray *evaluateInfoArray;
    
    StartsViewController *startsVC;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewWillAppear:(BOOL)animated
{
    if (SCREENHEIGHT == 812) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar_X"]forBarMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation"]forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Cervella";
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.frame = CGRectMake(0, 0, 44.0, 100);
    titleLab.text = self.title;
    titleLab.textColor = [UIColor whiteColor];
    UIBarButtonItem *titleBtnItem = [[UIBarButtonItem alloc] initWithCustomView:titleLab];
    [self.navigationItem setLeftBarButtonItem:titleBtnItem];
    self.title = @"";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIButton *btn_Menu=[UIButton buttonWithType:UIButtonTypeSystem];
    btn_Menu.frame=CGRectMake(0, 0, 44, 44);
    [btn_Menu setBackgroundImage:[UIImage imageNamed:@"ces_menu"] forState:UIControlStateNormal];
    [btn_Menu addTarget:self action:@selector(addMenuView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menu_Item=[[UIBarButtonItem alloc] initWithCustomView:btn_Menu];
    [self.navigationItem setRightBarButtonItem:menu_Item];
    
    //tabbar
    startsVC = [[StartsViewController alloc] init];
    startsVC.patientInfo = _patientInfo;
    NSDictionary *homeImageDict = @{selectedImage:@"homeSelectedImage", normalImage:@"homeNormalImage"};
    
    TreatDataViewController *assessVC = [[TreatDataViewController alloc] init];
    assessVC.patientInfo = _patientInfo;
    NSDictionary *assessImageDict = @{selectedImage:@"assessSelectedImage", normalImage:@"assessNormalImage"};
    
    MyInfoViewController *meVC = [[MyInfoViewController alloc] init];
    meVC.patientInfo = _patientInfo;
    NSDictionary *meImageDict = @{selectedImage:@"meSelectedImage", normalImage:@"meNormalIamge"};

    SCNavTabBarController *navTabBarController = [[SCNavTabBarController alloc] init];
    navTabBarController.subViewControllers = @[startsVC, assessVC, meVC];

    navTabBarController.navTabBar.isNavTabBarImage = YES;
    navTabBarController.navTabBar.itemImages = @[homeImageDict, assessImageDict, meImageDict];
    if (SCREENHEIGHT == 568) {
        navTabBarController.navTabBar.navTabBarHeight = 44.0;
    } else if (SCREENHEIGHT == 667) {
        navTabBarController.navTabBar.navTabBarHeight = 60.0;
    } else if (SCREENHEIGHT == 736) {
        navTabBarController.navTabBar.navTabBarHeight = 65.0;
    }
    else if (SCREENHEIGHT == 812) {
        navTabBarController.navTabBar.navTabBarHeight = 60.0;
    }
    [navTabBarController addParentController:self];
    
    dbOpration=[[DataBaseOpration alloc] init];
    treatInfoArray=[dbOpration getTreatDataFromDataBase];
    [dbOpration closeDataBase];
    
    //---------------------GCD----------------------支持多核，高效率的多线程技术
    //创建多线程
    dispatch_queue_t queue = dispatch_queue_create("sendValueToService", NULL);
    //创建一个子线程
    dispatch_async(queue, ^{
        // 子线程code... ..
//        [self sendEvaluateDataToSevice];
        [self sendTreatDataToSevice];
    });
}

#pragma mark - 右侧导航菜单栏
-(void)addMenuView
{
    view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    view.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view.window addSubview:view];
    
    _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREENWIDTH*25/40, 64+SCREENHEIGHT/60, SCREENWIDTH*14.5/40, 120)];
    [_menuTableView.layer setCornerRadius:10.0];
    _menuTableView.backgroundColor=[UIColor clearColor];
    
    UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH*25/40, 64+SCREENHEIGHT/60, SCREENWIDTH*14.5/40, 120)];
    [bgView.layer setCornerRadius:10.0];
    bgView.backgroundColor=[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1];
    
    _menuTableView.scrollEnabled=NO;
    menuArray=@[@"Pairing",@"Help"];
    if ([_menuTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_menuTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_menuTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_menuTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    _menuTableView.delegate=self;
    _menuTableView.dataSource=self;
    
    [view addSubview:bgView];
    [view.window addSubview:_menuTableView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestures:)];
    [view addGestureRecognizer:tapGesture];
}

//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGestures:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<_menuTableView.frame.origin.x || point.x >_menuTableView.frame.origin.x+_menuTableView.frame.size.width || point.y<_menuTableView.frame.origin.y || point.y>_menuTableView.frame.origin.y+_menuTableView.frame.size.height)
    {
        [_menuTableView removeFromSuperview];
        [view removeFromSuperview];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"MemuCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    
    menuImageView=[[UIImageView alloc] init];
    if (indexPath.row==0)
    {
        [menuImageView setImage:[UIImage imageNamed:@"menu_device"]];
        menuImageView.frame=CGRectMake(5, 15, 30,30);
    }
    else if (indexPath.row==1)
    {
        [menuImageView setImage:[UIImage imageNamed:@"help"]];
        menuImageView.frame=CGRectMake(5, 15, 30, 30);
    }
   

    UILabel *listLabel=[[UILabel alloc] initWithFrame:CGRectMake(40, 0, SCREENWIDTH*11/40, 60)];
    listLabel.textColor=[UIColor whiteColor];
    listLabel.font=[UIFont systemFontOfSize:16];
    listLabel.text=[menuArray objectAtIndex:indexPath.row];
    [cell addSubview:menuImageView];
    [cell addSubview:listLabel];
    cell.backgroundColor=[UIColor clearColor];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        //智能硬件(绑定蓝牙，解绑蓝牙的界面)
        IntelligentHardwareViewController *IHViewController=[[IntelligentHardwareViewController alloc] initWithNibName:@"IntelligentHardwareViewController" bundle:nil];
        
        [self.navigationController pushViewController:IHViewController animated:YES];
    }
    else if (indexPath.row==1)
    {
        //帮助(跳转到帮助界面)
        HelpViewController *helpViewController=[[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
        
        [self.navigationController pushViewController:helpViewController animated:YES];
    }
    [_menuTableView removeFromSuperview];
    [view removeFromSuperview];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - service
//向服务器传输评估数据
-(void)sendEvaluateDataToSevice
{
    if (evaluateInfoArray.count!=0)
    {
        EvaluateInfo *evaluateInfo=[[EvaluateInfo alloc] init];
        for (int i=1; i<=evaluateInfoArray.count; i++)
        {
            evaluateInfo=[evaluateInfoArray objectAtIndex:i-1];
            //循环调用插入评估数据接口
            NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:evaluateInfo.PatientID,@"PatientID",evaluateInfo.Time,@"SaveTime",evaluateInfo.Quality,@"Quality",evaluateInfo.Date,@"Date",evaluateInfo.Score,@"Score",evaluateInfo.ListFlag,@"Type",nil];
            NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
            NSLog(@"JsonString>>>>%@",jsonString);
            
            // 设置我们之后解析XML时用的关键字
            matchingElement = @"APP_InsertAndUpdateEvaluateDataResponse";
            // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
            NSString *soapMsg = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap12:Envelope "
                                 "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                 "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                 "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap12:Body>"
                                 "<APP_InsertAndUpdateEvaluateData xmlns=\"MeetingOnline\">"
                                 "<JsonEvaluateData>%@</JsonEvaluateData>"
                                 "</APP_InsertAndUpdateEvaluateData>"
                                 "</soap12:Body>"
                                 "</soap12:Envelope>", jsonString,nil];
            //打印soapMsg信息
            NSLog(@"%@",soapMsg);
            
            //设置网络连接的url
            NSString *urlStr = [NSString stringWithFormat:@"%@",ADDRESS];
            NSURL *url = [NSURL URLWithString:urlStr];
            //设置request
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
            NSString *msgLength=[NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
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
        }
    }
}

//向服务器传输治疗数据
-(void)sendTreatDataToSevice
{
    //循环将治疗数据以及评估数据上传至服务器
    if (treatInfoArray.count!=0)
    {
        TreatInfo *treatInfo=[[TreatInfo alloc] init];
        for (int i=1; i<=treatInfoArray.count; i++)
        {
            treatInfo=[treatInfoArray objectAtIndex:i-1];
            //循环调用插入治疗数据接口
            NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:treatInfo.PatientID,@"PatientID",treatInfo.Strength,@"Strength",treatInfo.Frequency,@"Freq",treatInfo.BeginTime ,@"BeginTime",treatInfo.EndTime,@"EndTime",treatInfo.CureTime,@"CureTime",nil];
            
            NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
            NSLog(@"JsonString>>>>%@",jsonString);
            
            // 设置我们之后解析XML时用的关键字
            matchingElement = @"APP_InsertCureDataResponse";
            // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
            NSString *soapMsg = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap12:Envelope "
                                 "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                 "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                 "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap12:Body>"
                                 "<APP_InsertCureData xmlns=\"MeetingOnline\">"
                                 "<JsonCureData>%@</JsonCureData>"
                                 "</APP_InsertCureData>"
                                 "</soap12:Body>"
                                 "</soap12:Envelope>", jsonString,nil];
            //打印soapMsg信息
            NSLog(@"%@",soapMsg);
            
            //设置网络连接的url
            NSString *urlStr = [NSString stringWithFormat:@"%@",ADDRESS];
            NSURL *url = [NSURL URLWithString:urlStr];
            //设置request
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
            NSString *msgLength=[NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
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
        }
    }
}

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
