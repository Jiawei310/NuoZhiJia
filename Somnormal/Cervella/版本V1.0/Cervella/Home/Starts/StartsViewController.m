//
//  StartsViewController.m
//  Cervella
//
//  Created by Justin on 2017/6/29.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "StartsViewController.h"

#import "UIButton+Common.h"
#import "AutoSlider.h"

#import "BindViewController.h"

#import "ColorsSliderView.h"
#import "ImageTitleDetialView.h"
#import "SelectView.h"
#import "BluetoothStatusView.h"

#import "Bluetooth.h"


#define FrequencySelectors @[@"0.5Hz",@"1.5Hz",@"100Hz"]
#define FrequencySelectorsInteger @[@"1",@"2",@"3"]

#define TimeSelectors @[@"10min",@"20min",@"30min",@"40min",@"50min",@"60min"]
#define TimeSelectorsInteger @[@"600",@"1200",@"1800",@"2400",@"3000",@"3600"]

@interface StartsViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate, ColorsSliderViewDelegate, BluetoothDelegate>

@property (nonatomic, strong) Bluetooth *bluetooth;


//接口请求和解析
@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end

@implementation StartsViewController
{
    
    NSInteger intensityLevel;
    UILabel   *intensityLevelLabel;         //用来显示电流强度大小

    ColorsSliderView *colorsSliderView;
    
    ImageTitleDetialView *frequencyView;
    __block NSInteger frequencySelector;
    __block NSInteger timeSelector;
    
    NSInteger timeDuration;              //倒计时总时长 s
    
    DataBaseOpration *dbOpration;
    
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //数据库读取治疗数据
    [self initTreatInfo];
    
    /**************强度***************/
    [self addSectionOne];
    /***************频率和时间**************/
    [self addSectionTwo];
    /***************治疗**************/
    [self addSectionThree];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendBluetoothInfoValue:) name:@"Note" object:nil];
    //注册解绑通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freeBluetoothInfo) name:@"Free" object:nil];
    //注册切换用户通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUser) name:@"ChangeUser" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma  mark - init
- (void)initTreatInfo {
    //数据库读取治疗数据
    dbOpration = [[DataBaseOpration alloc] init];
    NSArray *treatInfoArray = [dbOpration getTreatDataFromDataBase];
    [dbOpration closeDataBase];
    
    TreatInfo *treatInfo = nil;
    if (_patientInfo != nil)
    {
        NSMutableArray *treatInfoAtPatientID = [NSMutableArray array];
        for (TreatInfo *tmp in treatInfoArray)
        {
            if ([tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [treatInfoAtPatientID addObject:tmp];
            }
        }
        //读取最后治疗数据，更改设施
        if (treatInfoAtPatientID.count > 0) {
            treatInfo = [treatInfoAtPatientID objectAtIndex:treatInfoAtPatientID.count-1];
        }
    }
    
    if (treatInfo == nil) {
        frequencySelector = 0;
        timeSelector =  0;
        intensityLevel = 1;
    } else {
        intensityLevel = [treatInfo.Strength integerValue];
        frequencySelector = [FrequencySelectorsInteger indexOfObject:treatInfo.Frequency];
        timeSelector = [TimeSelectorsInteger indexOfObject:treatInfo.Time];
    }
}

/***************强度**************/
-(void)addSectionOne
{
    UIImageView *intensityView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH/12, CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT/30, SCREENWIDTH/15, CES_SCREENH_HEIGHT/21)];
    [intensityView setImage:[UIImage imageNamed:@"ces_strength"]];
    
    UILabel *electricLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/12+SCREENWIDTH/10, CES_SCREENH_HEIGHT/30+CES_SCREENH_HEIGHT/30, SCREENWIDTH/2, CES_SCREENH_HEIGHT/16)];
    electricLabel.text=@"Intensity Level";
    
    intensityLevelLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-SCREENWIDTH/4, CES_SCREENH_HEIGHT/30+CES_SCREENH_HEIGHT/30, SCREENWIDTH/8, CES_SCREENH_HEIGHT/16)];
    
    intensityLevelLabel.textColor = [UIColor redColor];
    intensityLevelLabel.text = [NSString stringWithFormat:@"%ld",(long)intensityLevel];
    [self.view addSubview:intensityView];
    [self.view addSubview:electricLabel];
    [self.view addSubview:intensityLevelLabel];
    
    colorsSliderView = [[ColorsSliderView alloc] init];
    CGFloat w = colorSliderd_d * 11 + colorSliderWidth * 10;
    colorsSliderView.frame = CGRectMake((SCREENWIDTH - w)/2.0, SCREENHEIGHT/6.6, w, 40);
    colorsSliderView.delegate = self;
    colorsSliderView.level = intensityLevel;
    [self.view addSubview:colorsSliderView];
}

#pragma mark - ColorsSliderViewDelegate
- (void)selectIndex:(NSInteger)index {
    intensityLevel = index;
    intensityLevelLabel.text = [NSString stringWithFormat:@"%ld",(long)intensityLevel];
    
    //设置蓝牙
    if (self.bluetooth.connectSate == ConnectStateNormal) {
        [self.bluetooth changeLevel:self.bluetooth.equipment.level];
    }
}

/***************frequency time**************/
-(void)addSectionTwo
{
    frequencyView = [[ImageTitleDetialView alloc] init];
    frequencyView.frame = CGRectMake(SCREENWIDTH/12,
                                     CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60,
                                     SCREENWIDTH - 60,
                                     50.0f);
    frequencyView.items = @[@{@"image":@"ces_freq",@"title":@"Frequency",@"detail":FrequencySelectors[frequencySelector]}];
    frequencyView.isCanSelect = YES;
    
    SelectView *frequencySelectView = [[SelectView alloc] init];
    frequencySelectView.titile = @"请选择";
    frequencySelectView.items = FrequencySelectors;
    frequencySelectView.frame = CGRectMake(0, 0, SCREENWIDTH - 60, 150);
    __weak typeof (*&self) weakSelf = self;
    frequencySelectView.selectViewBlock = ^(NSInteger index) {
        frequencySelector = index;
        frequencyView.items = @[@{@"image":@"ces_freq",@"title":@"Frequency",@"detail":FrequencySelectors[frequencySelector]}];
        if (weakSelf.bluetooth.connectSate == ConnectStateNormal) {
            [weakSelf.bluetooth changeWorkModel:frequencySelector];
        }
    };
    
    frequencyView.imageTitleDetailViewBlock = ^() {
        frequencySelectView.selector = frequencySelector;
        [frequencySelectView showViewInView:weakSelf.view];
    };
    [self.view addSubview:frequencyView];
    
    ImageTitleDetialView *timeView = [[ImageTitleDetialView alloc] init];
    timeView.frame = CGRectMake(SCREENWIDTH/12,
                                CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60 + 50,
                                SCREENWIDTH - 60,
                                50.0f);
    timeView.items = @[@{@"image":@"time",@"title":@"Time",@"detail":TimeSelectors[timeSelector]}];
    
    SelectView *timeSelectView = [[SelectView alloc] init];
    timeSelectView.titile = @"请选择";
    timeSelectView.items = TimeSelectors;
    timeSelectView.frame = CGRectMake(0, 0, SCREENWIDTH - 60, 150);
    timeSelectView.selectViewBlock = ^(NSInteger index) {
        timeSelector = index;
        timeDuration = [TimeSelectorsInteger[index] integerValue];
        timeView.items = @[@{@"image":@"time",@"title":@"Time",@"detail":TimeSelectors[timeSelector]}];
    };
    
    timeView.imageTitleDetailViewBlock = ^() {
        timeSelectView.selector  = timeSelector;
        [timeSelectView showViewInView:weakSelf.view];
    };
    [self.view addSubview:timeView];
    
    UIView *lineTopView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/12,
                                                                   CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60,
                                                                   SCREENWIDTH - 60,
                                                                   1.5)];
    lineTopView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineTopView];
    
    UIView *lineCenterView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/12,
                                                                   CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60 + 50,
                                                                   SCREENWIDTH - 60,
                                                                   0.5)];
    lineCenterView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineCenterView];
    
    UIView *linebottomView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/12,
                                                                      CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60 + 100,
                                                                      SCREENWIDTH - 60,
                                                                      0.5)];
    linebottomView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:linebottomView];
}

/***************第四部分**************/
-(void)addSectionThree
{
    BluetoothStatusView *bluetoothStatusView = [[BluetoothStatusView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 150)/2.0, SCREENHEIGHT - 300.0f, 120, 120)];
    bluetoothStatusView.timers = 60 * 10;
    bluetoothStatusView.statusType = StatusTypeStart;
    [self.view addSubview:bluetoothStatusView];
}



#pragma mark -- BluetoothDelegate
- (void)scanedEquipments:(NSArray *)equipments {
    //搜索到设备
    NSLog(@"%@", equipments);
}

- (void)connectState:(ConnectState)connectState Error:(NSError *)error {
    if (connectState == ConnectStateNormal) { //正常链接成功
        
    }
    else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"有错误，连接失败" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *  action) {
            
        }];
        [alertC addAction:alert];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

- (void)wearState:(WearState)wearState Error:(NSError *)error {
    if (wearState == WearStateNormal) {
        NSLog(@"WearStateNormal");
    }
    else {
        NSLog(@"WearStateError");
    }
}

//电池状态
- (void)battery:(NSUInteger )battery Error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(sendElectricQualityValue:)]) {
        [self.delegate sendElectricQualityValue:[NSString stringWithFormat:@"%ld", battery]];
    }
}

//圆形操作按钮点击事件（绑定疗疗、开始点刺激、停止等等）
//BindViewController *bindViewController=[[BindViewController alloc] initWithNibName:@"BindViewController" bundle:nil];
//bindViewController.bindFlag=@"1";
//
//[self.navigationController pushViewController:bindViewController animated:YES];



//存储治疗数据到数据库
//初始化数据库
//dbOpration=[[DataBaseOpration alloc] init];
//if (_patientInfo.PatientID!=nil)
//{
//    TreatInfo *treatInfoTmp=[[TreatInfo alloc] init];
//    treatInfoTmp.PatientID=_patientInfo.PatientID;
//    treatInfoTmp.Date=[BegainTime substringWithRange:NSMakeRange(0, 10)];
//    treatInfoTmp.Strength=[NSString stringWithFormat:@"%ld",(long)intensityLevel];
//    if (frequencySelector==0)
//    {
//        treatInfoTmp.Frequency=@"1";
//    }
//    else if (frequencySelector==1)
//    {
//        treatInfoTmp.Frequency=@"2";
//    }
//    else if (frequencySelector==2)
//    {
//        treatInfoTmp.Frequency=@"3";
//    }
//
//    if (timeSelector==0)
//    {
//        treatInfoTmp.Time=@"600";
//    }
//    else if (timeSelector==1)
//    {
//        treatInfoTmp.Time=@"1200";
//    }
//    else if (timeSelector==2)
//    {
//        treatInfoTmp.Time=@"2400";
//    }
//    else if (timeSelector==3)
//    {
//        treatInfoTmp.Time=@"3600";
//    }
//    treatInfoTmp.BeginTime=BegainTime;
//    treatInfoTmp.EndTime=BegainTime;
//    treatInfoTmp.CureTime=@"1";
//
//    //插入CureTime为1的数据进入数据库
//    [dbOpration insertTreatInfo:treatInfoTmp];
//    [dbOpration closeDataBase];


//更新治疗数据到数据库
//初始化数据库
//dbOpration=[[DataBaseOpration alloc] init];
//TreatInfo *treatInfoTmp=[[TreatInfo alloc] init];
//treatInfoTmp.PatientID=_patientInfo.PatientID;
//treatInfoTmp.Date=[BegainTime substringWithRange:NSMakeRange(0, 10)];
//treatInfoTmp.Strength=[NSString stringWithFormat:@"%ld",(long)intensityLevel];;
//if (frequencySelector==0)
//{
//    treatInfoTmp.Frequency=@"1";
//}
//else if (frequencySelector==1)
//{
//    treatInfoTmp.Frequency=@"2";
//}
//else if (frequencySelector==2)
//{
//    treatInfoTmp.Frequency=@"3";
//}
//if (timeSelector==0)
//{
//    treatInfoTmp.Time=@"600";
//}
//else if (timeSelector==1)
//{
//    treatInfoTmp.Time=@"1200";
//}
//else if (timeSelector==2)
//{
//    treatInfoTmp.Time=@"2400";
//}
//else if (timeSelector==3)
//{
//    treatInfoTmp.Time=@"3600";
//}
//treatInfoTmp.BeginTime=BegainTime;
//NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
//[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//EndTime=[dateFormatter stringFromDate:[NSDate date]];
//treatInfoTmp.EndTime=EndTime;
//treatInfoTmp.CureTime=[NSString stringWithFormat:@"%d",(time-timeout)/60];
////更新数据
//if (![treatInfoTmp.CureTime isEqualToString:@"0"])
//{
//    [dbOpration updateTreatInfo:treatInfoTmp];
//    [dbOpration closeDataBase];
//}
#pragma mark setter and getter
- (Bluetooth *)bluetooth {
    if (!_bluetooth) {
        _bluetooth = [Bluetooth shareBluetooth];
        _bluetooth.delegate = self;
    }
    return _bluetooth;
}

- (void)postBindDevice:(NSString *)deviceID {
//    NSString *deviceID=[NSString stringWithFormat:@"%@-%@%@-%@%@%@",[deviceIDArray objectAtIndex:0],[deviceIDArray objectAtIndex:1],[deviceIDArray objectAtIndex:2],[deviceIDArray objectAtIndex:3],[deviceIDArray objectAtIndex:4],[deviceIDArray objectAtIndex:5]];
    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:_patientInfo.PatientID,@"PatientID",deviceID,@"DeviceID",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_SetPatientDeviceIDResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_SetPatientDeviceID xmlns=\"MeetingOnline\">"
                         "<JsonDeviceInfo>%@</JsonDeviceInfo>"
                         "</APP_SetPatientDeviceID>"
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
