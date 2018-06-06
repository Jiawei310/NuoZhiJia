//
//  TreatDataViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "TreatDataViewController.h"
#import "Define.h"
#import "DataBaseOpration.h"
#import <UMMobClick/MobClick.h>

@interface TreatDataViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@end

@implementation TreatDataViewController
{
    NSInteger flag;
    
    DataBaseOpration *dbOpration;
    NSMutableArray *treatInfoArray;
    NSArray *treatData;
    NSMutableArray *treatInfoAtPatientID;
    
    NSDate *BegainDate;
    NSDate *EndDate;
    NSString *BegainTime;
    NSString *EndTime;
    
    UITableView *DataTableView;
    
    UIView *maskview;
    UIView *dateView;
    
    UIPickerView *PickerView;
    NSInteger year;
    NSInteger month;
    NSInteger day;
    NSInteger monthBegainIndex;
    NSInteger yearBegainIndex;
    NSInteger dayBegainIndex;
    NSInteger monthEndIndex;
    NSInteger yearEndIndex;
    NSInteger dayEndIndex;
    NSInteger monthBegainSelectIndex;
    NSInteger yearBegainSelectIndex;
    NSInteger dayBegainSelectIndex;
    NSInteger monthEndSelectIndex;
    NSInteger yearEndSelectIndex;
    NSInteger dayEndSelectIndex;
    
    UIButton *dateOne_Button;
    UIButton *dateTwo_Button;
    
    UIAlertView *alert;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"治疗数据"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"治疗数据"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"治疗数据";
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
    
    UILabel *dateOne_Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 107*Rate_NAV_W, 30*Rate_NAV_H)];
    dateOne_Label.text = @"查看日期：";
    dateOne_Label.textAlignment = NSTextAlignmentCenter;
    dateOne_Label.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    
    dateOne_Button = [UIButton buttonWithType:UIButtonTypeSystem];
    dateOne_Button.tag = 1;
    dateOne_Button.frame = CGRectMake(107*Rate_NAV_W, 0, 107*Rate_NAV_W, 30*Rate_NAV_H);
    EndDate = [NSDate date];
    BegainDate = [EndDate initWithTimeIntervalSinceNow:-6*24*60*60];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    BegainTime = [dateFormatter stringFromDate:BegainDate];
    yearBegainIndex = [[BegainTime substringWithRange:NSMakeRange(0, 4)] integerValue] - 1900;
    monthBegainIndex = [[BegainTime substringWithRange:NSMakeRange(5, 2)] integerValue] - 1;
    dayBegainIndex = [[BegainTime substringWithRange:NSMakeRange(8, 2)] integerValue] - 1;
    [dateOne_Button setTitle:BegainTime forState:UIControlStateNormal];
    [dateOne_Button addTarget:self action:@selector(chooseDateClick:) forControlEvents:UIControlEventTouchUpInside];
    dateOne_Button.titleLabel.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
    
    UILabel *dateTwo_Label = [[UILabel alloc] initWithFrame:CGRectMake(214*Rate_NAV_W, 0, 53*Rate_NAV_W, 30*Rate_NAV_H)];
    dateTwo_Label.text = @"至";
    dateTwo_Label.textAlignment = NSTextAlignmentCenter;
    dateTwo_Label.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    
    dateTwo_Button = [UIButton buttonWithType:UIButtonTypeSystem];
    dateTwo_Button.tag = 2;
    dateTwo_Button.frame = CGRectMake(267*Rate_NAV_W, 0, 107*Rate_NAV_W, 30*Rate_NAV_H);
    EndTime=[dateFormatter stringFromDate:EndDate];
    yearEndIndex = [[EndTime substringWithRange:NSMakeRange(0, 4)] integerValue]-1900;
    monthEndIndex = [[EndTime substringWithRange:NSMakeRange(5, 2)] integerValue]-1;
    dayEndIndex = [[EndTime substringWithRange:NSMakeRange(8, 2)] integerValue]-1;
    [dateTwo_Button setTitle:EndTime forState:UIControlStateNormal];
    [dateTwo_Button addTarget:self action:@selector(chooseDateClick:) forControlEvents:UIControlEventTouchUpInside];
    dateTwo_Button.titleLabel.font=[UIFont systemFontOfSize:16*Rate_NAV_H];
    
    [self.view addSubview:dateOne_Label];
    [self.view addSubview:dateOne_Button];
    [self.view addSubview:dateTwo_Label];
    [self.view addSubview:dateTwo_Button];
    
    UIView *tableBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 30*Rate_NAV_H, 375*Rate_NAV_W, 34*Rate_NAV_H)];
    tableBackView.backgroundColor = [UIColor colorWithRed:0xF9/255.0 green:0xF9/255.0 blue:0xF9/255.0 alpha:1];
    [self.view addSubview:tableBackView];
    //上下边框线
    UIView *lineViewUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 0.5*Rate_NAV_H)];
    lineViewUp.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xD9/255.0 blue:0xD9/255.0 alpha:1];
    [tableBackView addSubview:lineViewUp];
    UIView *lineViewDown = [[UIView alloc] initWithFrame:CGRectMake(0, 33.5*Rate_NAV_H, 375*Rate_NAV_W, 0.5*Rate_NAV_H)];
    lineViewDown.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xD9/255.0 blue:0xD9/255.0 alpha:1];
    [tableBackView addSubview:lineViewDown];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH/4, 34*Rate_NAV_H)];
    dateLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    dateLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.text = @"日期";
    UILabel *modelLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/4, 0, SCREENWIDTH*3/16, 34*Rate_NAV_H)];
    modelLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    modelLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    modelLabel.textAlignment = NSTextAlignmentCenter;
    modelLabel.text = @"模式";
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*7/16, 0, SCREENWIDTH*3/16, 34*Rate_NAV_H)];
    numLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    numLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.text = @"强度";
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*10/16, 0, SCREENWIDTH*3/16, 34*Rate_NAV_H)];
    startLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    startLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    startLabel.textAlignment = NSTextAlignmentCenter;
    startLabel.text = @"开始时间";
    UILabel *cureLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*13/16, 0, SCREENWIDTH*3/16, 34*Rate_NAV_H)];
    cureLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    cureLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    cureLabel.textAlignment = NSTextAlignmentCenter;
    cureLabel.text = @"治疗时间";
    
    [tableBackView addSubview:dateLabel];
    [tableBackView addSubview:modelLabel];
    [tableBackView addSubview:numLabel];
    [tableBackView addSubview:startLabel];
    [tableBackView addSubview:cureLabel];
    
    DataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64*Rate_NAV_H, 375*Rate_NAV_W, 539*Rate_NAV_H) style:UITableViewStylePlain];
    [DataTableView.tableHeaderView removeFromSuperview];
    DataTableView.tableFooterView = [[UIView alloc] init];
    if ([DataTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        DataTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [DataTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    DataTableView.delegate=self;
    DataTableView.dataSource=self;
    
    [self.view addSubview:DataTableView];
    
    dbOpration = [[DataBaseOpration alloc] init];
    treatInfoArray = [dbOpration getTreatDataFromDataBase];
    [dbOpration closeDataBase];
    
    treatInfoAtPatientID = [NSMutableArray array];
    //最近一周内的治疗数据
    [self putTreatDataToArray];
    //服务器上获取治疗数据
    [self getCureDataFromServer];
    
    //获取系统当前时间
    NSDate *date=[NSDate date];
    unsigned units  = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *component = [myCal components:units fromDate:date];
    year = [component year];
    month = [component month];
    day = [component day];
    _begainDateYearArray = [NSMutableArray array];
    _begainDateMonthArray = [NSMutableArray array];
    _begainDateDayArray = [NSMutableArray array];
    _endDateYearArray = [NSMutableArray array];
    _endDateMonthArray = [NSMutableArray array];
    _endDateDayArray = [NSMutableArray array];
    
    for (int i = 1900; i <= year; i++)
    {
        NSString *yearStr = [NSString stringWithFormat:@"%d",i];
        [_begainDateYearArray addObject:yearStr];
        [_endDateYearArray addObject:yearStr];
    }
    for (int i = 1; i <= 12; i++)
    {
        NSString *monthStr=[NSString stringWithFormat:@"%d",i];
        [_begainDateMonthArray addObject:monthStr];
        [_endDateMonthArray addObject:monthStr];
    }
    for (int i = 1; i <= 31; i++)
    {
        NSString *dayStr = [NSString stringWithFormat:@"%d",i];
        [_begainDateDayArray addObject:dayStr];
        [_endDateDayArray addObject:dayStr];
    }
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

//下载服务器上的治疗数据
- (void)getCureDataFromServer
{
    if (_patientInfo.PatientID!=nil)
    {
        NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:_patientInfo.PatientID,@"PatientID",@"",@"BeginTime",nil];
        NSArray *jsonArray = [NSArray arrayWithObjects:jsonUserID, nil];
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
        
        // 设置我们之后解析XML时用的关键字
        matchingElement = @"APP_GetCureDataResponse";
        // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
        NSString *soapMsg = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap12:Envelope "
                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                             "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap12:Body>"
                             "<APP_GetCureData xmlns=\"MeetingOnline\">"
                             "<JsonCureData>%@</JsonCureData>"
                             "</APP_GetCureData>"
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

//根据开始时间跟结束时间选择评估数据，并把数据放入对应数组
- (void)putTreatDataToArray
{
    if (_patientInfo!=nil)
    {
        for (TreatInfo *tmp in treatInfoArray)
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"YYYY-MM-dd"];
            NSDate *tmp_Date = [dateFormat dateFromString:tmp.Date];
            if ([tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                if ([BegainDate compare:tmp_Date] == NSOrderedAscending && [EndDate compare:tmp_Date] == NSOrderedDescending)
                {
                    [treatInfoAtPatientID addObject:tmp];
                }
                else if ([tmp.Date isEqualToString:BegainTime] || [tmp.Date isEqualToString:EndTime])
                {
                    [treatInfoAtPatientID addObject:tmp];
                }
            }
        }
        if (treatInfoAtPatientID.count>0)
        {
            [self bubbleSort:treatInfoAtPatientID];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return treatInfoAtPatientID.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47*Rate_NAV_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"EvaluateDataCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];

    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH/4, 47*Rate_NAV_H)];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *frequencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/4, 0, SCREENWIDTH*3/16, 47*Rate_NAV_H)];
    frequencyLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *strengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*7/16, 0, SCREENWIDTH*3/16, 47*Rate_NAV_H)];
    strengthLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*10/16, 0, SCREENWIDTH*3/16, 47*Rate_NAV_H)];
    startTimeLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *cureTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*13/16, 0, SCREENWIDTH*3/16, 47*Rate_NAV_H)];
    cureTimeLabel.textAlignment = NSTextAlignmentCenter;
    
    dateLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    frequencyLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    strengthLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    startTimeLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    cureTimeLabel.font = [UIFont systemFontOfSize:15*Rate_NAV_H];
    
    TreatInfo *tmp = [treatInfoAtPatientID objectAtIndex:indexPath.row];
    dateLabel.text = [tmp.BeginTime substringWithRange:NSMakeRange(0, 10)];
    if ([tmp.Frequency isEqualToString:@"0.5"])
    {
        frequencyLabel.text = @"1";
    }
    else if ([tmp.Frequency isEqualToString:@"1.5"])
    {
        frequencyLabel.text = @"2";
    }
    else if ([tmp.Frequency isEqualToString:@"100"])
    {
        frequencyLabel.text = @"3";
    }
    strengthLabel.text = tmp.Strength;
    startTimeLabel.text = [tmp.BeginTime substringWithRange:NSMakeRange(11, 5)];
    cureTimeLabel.text = tmp.CureTime;
    
    [cell.contentView addSubview:dateLabel];
    [cell.contentView addSubview:frequencyLabel];
    [cell.contentView addSubview:strengthLabel];
    [cell.contentView addSubview:startTimeLabel];
    [cell.contentView addSubview:cureTimeLabel];
    
    return cell;
}

- (void)chooseDateClick:(UIButton *)sender
{
    maskview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    maskview.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view.window addSubview:maskview];
    dateView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/10, SCREENHEIGHT*3/8, SCREENWIDTH*4/5, 192*Rate_NAV_H)];
    [dateView.layer setCornerRadius:10.0];
    dateView.backgroundColor=[UIColor whiteColor];
    
    PickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH*4/5, 162*Rate_NAV_H)];
    [PickerView.layer setCornerRadius:10.0];
    PickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    PickerView.backgroundColor = [UIColor whiteColor];
    PickerView.tag = sender.tag;
    UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*6/25, 67.5*Rate_NAV_H, 30*Rate_NAV_W, 27*Rate_NAV_H)];
    yearLabel.text = @"年";
    yearLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*12/25, 67.5*Rate_NAV_H, 30*Rate_NAV_W, 27*Rate_NAV_H)];
    monthLabel.text = @"月";
    monthLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*18/25, 67.5*Rate_NAV_H, 30*Rate_NAV_W, 27*Rate_NAV_H)];
    dayLabel.text = @"日";
    dayLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    
    yearBegainSelectIndex = yearBegainIndex;
    monthBegainSelectIndex = monthBegainIndex;
    dayBegainSelectIndex = dayBegainIndex;
    
    yearEndSelectIndex = yearEndIndex;
    monthEndSelectIndex = monthEndIndex;
    dayEndSelectIndex = dayEndIndex;
    
    PickerView.delegate = self;
    PickerView.dataSource = self;
    if (sender.tag == 1)
    {
        [PickerView selectRow:yearBegainIndex inComponent:0 animated:YES];
        [PickerView selectRow:monthBegainIndex inComponent:1 animated:YES];
        [PickerView selectRow:dayBegainIndex inComponent:2 animated:YES];
    }
    else if (sender.tag == 2)
    {
        [PickerView selectRow:yearEndIndex inComponent:0 animated:YES];
        [PickerView selectRow:monthEndIndex inComponent:1 animated:YES];
        [PickerView selectRow:dayEndIndex inComponent:2 animated:YES];
    }
    [PickerView reloadAllComponents];
    
    [PickerView addSubview:yearLabel];
    [PickerView addSubview:monthLabel];
    [PickerView addSubview:dayLabel];
    
    UIButton *determineButton = [UIButton buttonWithType:UIButtonTypeSystem];
    determineButton.frame = CGRectMake(SCREENWIDTH*8/25, 162*Rate_NAV_H, SCREENWIDTH*4/25, 30*Rate_NAV_H);
    determineButton.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [determineButton setTitle:@"确定" forState:UIControlStateNormal];
    determineButton.tag = sender.tag;
    [determineButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [determineButton addTarget:self action:@selector(determineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [dateView addSubview:PickerView];
    [dateView addSubview:determineButton];
    [maskview addSubview:dateView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGesture:)];
    [maskview addGestureRecognizer:tapGesture];
}
//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGesture:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:maskview];
    if (point.x<dateView.frame.origin.x || point.x >dateView.frame.origin.x+dateView.frame.size.width || point.y<dateView.frame.origin.y || point.y>dateView.frame.origin.y+dateView.frame.size.height)
    {
        [dateView removeFromSuperview];
        [maskview removeFromSuperview];
    }
}
//弹出view中确定按钮的点击事件
-(void)determineButtonClick:(UIButton *)sender
{
    if (sender.tag==1)
    {
        NSString *yearString = [NSString stringWithFormat:@"%@",[_begainDateYearArray objectAtIndex:yearBegainSelectIndex]];
        NSString *monthString = [NSString stringWithFormat:@"%@",[_begainDateMonthArray objectAtIndex:monthBegainSelectIndex]];
        NSString *dayString;
        if (dayBegainSelectIndex > _begainDateDayArray.count-1)
        {
            if (_begainDateDayArray.count == 30)
            {
                dayString=@"30";
            }
            else if (_begainDateDayArray.count == 29)
            {
                dayString=@"29";
            }
            else if (_begainDateDayArray.count == 28)
            {
                dayString=@"28";
            }
        }
        else
        {
            dayString = [NSString stringWithFormat:@"%@",[_begainDateDayArray objectAtIndex:dayBegainSelectIndex]];
        }
        
        BegainTime = [NSString stringWithFormat:@"%@-%@-%@",yearString,monthString,dayString];
        if ([self getIntervalTimeFrom:[self stringToDate:BegainTime] toDate:[self stringToDate:dateTwo_Button.titleLabel.text]] >= 0)
        {
            [dateOne_Button setTitle:BegainTime forState:UIControlStateNormal];
            yearBegainIndex = yearBegainSelectIndex;
            monthBegainIndex = monthBegainSelectIndex;
            dayBegainIndex = dayBegainSelectIndex;
        }
        else
        {
            //提示日期选择错误
            BegainTime = dateOne_Button.titleLabel.text;
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"开始时间不能选择在截止日期之后" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
    }
    else
    {
        NSString *yearString = [NSString stringWithFormat:@"%@",[_endDateYearArray objectAtIndex:yearEndIndex]];
        NSString *monthString = [NSString stringWithFormat:@"%@",[_endDateMonthArray objectAtIndex:monthEndIndex]];
        NSString *dayString;
        if (dayEndSelectIndex > _endDateDayArray.count-1)
        {
            if (_endDateDayArray.count == 30)
            {
                dayString=@"30";
            }
            else if (_endDateDayArray.count == 29)
            {
                dayString=@"29";
            }
            else if (_endDateDayArray.count==28)
            {
                dayString=@"28";
            }
        }
        else
        {
            dayString=[NSString stringWithFormat:@"%@",[_endDateDayArray objectAtIndex:dayEndSelectIndex]];
        }
        EndTime = [NSString stringWithFormat:@"%@-%@-%@",yearString,monthString,dayString];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *nowTime = [dateFormatter stringFromDate:[NSDate date]];
        if ([self getIntervalTimeFrom:[self stringToDate:EndTime] toDate:[self stringToDate:nowTime]]>=0)
        {
            if([self getIntervalTimeFrom:[self stringToDate:dateOne_Button.titleLabel.text] toDate:[self stringToDate:EndTime]] >= 0)
            {
                [dateTwo_Button setTitle:EndTime forState:UIControlStateNormal];
                yearEndIndex = yearEndSelectIndex;
                monthEndIndex = monthEndSelectIndex;
                dayEndIndex = dayEndSelectIndex;
            }
            else
            {
                //提示日期选择错误
                EndTime = dateTwo_Button.titleLabel.text;
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"截止时间不能选择在开始日期之前" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
            }
        }
        else
        {
            //提示日期选择错误
            EndTime = dateTwo_Button.titleLabel.text;
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"截止时间不能选择在系统日期之后" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
    }
    [dateView removeFromSuperview];
    [maskview removeFromSuperview];
    
    //更新开始日期跟结束日期的数组
    [treatInfoAtPatientID removeAllObjects];
    for (int i = 0; i < treatInfoArray.count; i++)
    {
        TreatInfo *tmpTreatInfo = [treatInfoArray objectAtIndex:i];
        NSString *tmpStringDate = [tmpTreatInfo.BeginTime substringWithRange:NSMakeRange(0, 10)];
        NSInteger tmpOne = [self getIntervalTimeFrom:[self stringToDate:BegainTime] toDate:[self stringToDate:tmpStringDate]];
        NSInteger tmpTwo = [self getIntervalTimeFrom:[self stringToDate:tmpStringDate] toDate:[self stringToDate:EndTime]];
        if (tmpOne >= 0 && tmpTwo >= 0 && [tmpTreatInfo.PatientID isEqualToString:_patientInfo.PatientID])
        {
            [treatInfoAtPatientID addObject:tmpTreatInfo];
        }
    }
    if (treatInfoAtPatientID.count>0)
    {
        [self bubbleSort:treatInfoAtPatientID];
    }
    [DataTableView reloadData];
}

- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:16*Rate_NAV_H]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        if(component == 0)
        {
            return [self.begainDateYearArray count];
        }
        else if(component == 1)
        {
            return [self.begainDateMonthArray count];
        }
        else
        {
            return [self.begainDateDayArray count];
        }
    }
    else
    {
        if(component == 0)
        {
            return [self.endDateYearArray count];
        }
        else if(component == 1)
        {
            return [self.endDateMonthArray count];
        }
        else
        {
            return [self.endDateDayArray count];
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag==1)
    {
        if (component == 0)
        {
            return self.begainDateYearArray[row];
        }
        else if(component == 1)
        {
            return self.begainDateMonthArray[row];
        }
        else
        {
            return self.begainDateDayArray[row];
        }
    }
    else
    {
        if (component == 0)
        {
            return self.endDateYearArray[row];
        }
        else if(component == 1)
        {
            return self.endDateMonthArray[row];
        }
        else
        {
            return self.endDateDayArray[row];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        if (component == 0)
        {
            yearBegainSelectIndex = row;
        }
        else if(component == 1)
        {
            monthBegainSelectIndex = row;
        }
        else
        {
           dayBegainSelectIndex = row;
        }
        NSInteger tmp = 1900 + yearBegainSelectIndex;
        //判断是否是闰年，其他为平年
        if ((tmp%4 == 0 && tmp%100 != 0) || (tmp%100 == 0 && tmp%400 == 0))//闰年
        {
            if (monthBegainSelectIndex == 1)//2月份闰年的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i=1; i<=29; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex == 0 || monthBegainSelectIndex == 2 || monthBegainSelectIndex == 4 || monthBegainSelectIndex == 6 || monthBegainSelectIndex == 7 || monthBegainSelectIndex == 9 || monthBegainSelectIndex == 11)//大月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i = 1; i <= 31; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex == 3 || monthBegainSelectIndex == 5 || monthBegainSelectIndex == 8 || monthBegainSelectIndex == 10)//小月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i = 1; i <= 30; i++)//小月的天数
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
        }
        else//平年
        {
            if (monthBegainSelectIndex == 1)//2月份平年的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i = 1; i <= 28; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex == 0 || monthBegainSelectIndex == 2 || monthBegainSelectIndex == 4 || monthBegainSelectIndex == 6 || monthBegainSelectIndex == 7 || monthBegainSelectIndex == 9 || monthBegainSelectIndex == 11)//大月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i = 1; i <= 31; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex == 3 || monthBegainSelectIndex == 5 || monthBegainSelectIndex == 8 || monthBegainSelectIndex == 10)//小月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i = 1; i <= 30; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
        }
        [PickerView reloadComponent:2];
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if (component == 0)
        {
            yearEndSelectIndex = row;
        }
        else if(component == 1)
        {
            monthEndSelectIndex = row;
        }
        else
        {
            dayEndSelectIndex = row;
        }
        NSInteger tmp = 1900 + yearEndSelectIndex;
        //判断是否是闰年，其他为平年
        if ((tmp%4 == 0 && tmp%100 != 0) || (tmp%100 == 0 && tmp%400 == 0))//闰年
        {
            if (monthEndSelectIndex==1)//2月份闰年的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i = 1; i <= 29; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else if(monthEndSelectIndex == 0 || monthEndSelectIndex == 2 || monthEndSelectIndex == 4 || monthEndSelectIndex == 6 || monthEndSelectIndex == 7 || monthEndSelectIndex == 9 || monthEndSelectIndex == 11)//大月的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i = 1; i <= 31; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else
            {
                [_endDateDayArray removeAllObjects];
                for (int i = 1; i <= 30; i++)//小月的天数
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
        }
        else//平年
        {
            if (monthEndSelectIndex == 1)//2月份平年的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i = 1; i <= 28; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else if(monthEndSelectIndex == 0 || monthEndSelectIndex == 2 || monthEndSelectIndex == 4 || monthEndSelectIndex == 6 || monthEndSelectIndex == 7 || monthEndSelectIndex == 9 || monthEndSelectIndex == 11)//大月的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i = 1; i <= 31; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else if(monthEndSelectIndex == 3 || monthEndSelectIndex == 5 || monthEndSelectIndex == 8 || monthEndSelectIndex == 10)//小月的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i = 1; i <= 30; i++)
                {
                    NSString *dayStr = [NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
        }
        [PickerView reloadComponent:2];
    }
}

#pragma mark -
#pragma mark URL Connection Data Delegate Methods

// 刚开始接受响应时调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response
{
    [webData setLength: 0];
}

// 每接收到一部分数据就追加到webData中
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *) data
{
    [webData appendData:data];
}

// 出现错误时
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    conn = nil;
    webData = nil;
}

// 完成接收数据时调用
- (void)connectionDidFinishLoading:(NSURLConnection *) connection
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
- (void)parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict
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
        if ([matchingElement isEqualToString:@"APP_GetCureDataResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult = [soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            if (resultArray.count != 0)
            {
                for (int i = 0; i<resultArray.count; i++)
                {
                    TreatInfo *tmp_treatInfo = [[TreatInfo alloc] init];
                    tmp_treatInfo.PatientID = _patientInfo.PatientID;
                    NSString *tmpStr = [[resultArray objectAtIndex:i] objectForKey:@"BeginTime"];
                    if (tmpStr.length == 16)
                    {
                        tmp_treatInfo.BeginTime = [NSString stringWithFormat:@"%@-%@-%@ %@",[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(0, 4)],[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(5, 2)],[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(8, 2)],[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(11, 5)],nil];
                    }
                    else
                    {
                        tmp_treatInfo.BeginTime = [NSString stringWithFormat:@"%@-%@-%@ %@",[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(0, 4)],[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(5, 2)],[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(8, 2)],[[[resultArray objectAtIndex:i] objectForKey:@"BeginTime"] substringWithRange:NSMakeRange(11, 8)],nil];
                    }
                    tmp_treatInfo.EndTime = [[resultArray objectAtIndex:i] objectForKey:@"EndTime"];
                    tmp_treatInfo.CureTime = [[resultArray objectAtIndex:i] objectForKey:@"CureTime"];
                    tmp_treatInfo.Strength = [[resultArray objectAtIndex:i] objectForKey:@"Strength"];
                    tmp_treatInfo.Date = [tmp_treatInfo.BeginTime substringWithRange:NSMakeRange(0, 10)];
                    tmp_treatInfo.Frequency = [[resultArray objectAtIndex:i] objectForKey:@"Freq"];
                    tmp_treatInfo.Time = @"1200";
                    
                    TreatInfo *tmpInfo;
                    for (TreatInfo *tmp in treatInfoArray)
                    {
                        if ([tmp_treatInfo.BeginTime isEqualToString:tmp.BeginTime])
                        {
                            tmpInfo = tmp;
                        }
                    }
                    if (tmpInfo == nil)
                    {
                        [treatInfoArray addObject:tmp_treatInfo];
                        dbOpration = [[DataBaseOpration alloc] init];
                        [dbOpration insertTreatInfo:tmp_treatInfo];
                        [dbOpration closeDataBase];
                    }
                }
                [treatInfoAtPatientID removeAllObjects];
                [self putTreatDataToArray];
                [DataTableView reloadData];
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
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

//计算两个时间点之间的时间差（即计算治疗时间）
- (NSInteger)getIntervalTimeFrom:(NSDate *)StartDate toDate:(NSDate *)FinishDate
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *interval = [cal components:unitFlags fromDate:StartDate toDate:FinishDate options:0];
    
    return [interval day];
}
//把字符串转换成日期
- (NSDate *)stringToDate:(NSString *)dateString
{
    NSDateFormatter *inputForMatter = [[NSDateFormatter alloc] init];
    [inputForMatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *inputDate = [inputForMatter dateFromString:dateString];
    
    return inputDate;
}
//把日期转换成字符串
- (NSString *)dateToString:(NSDate *)stringDate
{
    NSDateFormatter *outputForMatter = [[NSDateFormatter alloc] init];
    [outputForMatter setDateFormat:@"yyyy/MM/dd"];
    NSString *outputDate = [outputForMatter stringFromDate:stringDate];
    return outputDate;
}

//冒泡排序
- (void)bubbleSort:(NSMutableArray *)array
{
    for (int j = 0; j < array.count-1; j++)
    {
        for (int i = 0; i < array.count-1-j; i++)
        {
            TreatInfo *index_One = [array objectAtIndex:i];
            TreatInfo *index_Two = [array objectAtIndex:i+1];
            if ([index_One.BeginTime compare:index_Two.BeginTime] == NSOrderedAscending)
            {
                [array exchangeObjectAtIndex:i withObjectAtIndex:i+1];
            }
        }
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
