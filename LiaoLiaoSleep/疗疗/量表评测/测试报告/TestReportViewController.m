//
//  TestReportViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/21.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "TestReportViewController.h"
#import "Define.h"

#import "EvaluateInfo.h"
#import "InterfaceModel.h"
#import "DataBaseOpration.h"

#import "YBPlot.h"
#import "FoldLineView.h"

#import "ReportDetailViewController.h"

@interface TestReportViewController ()<InterfaceModelDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (strong, nonatomic) FoldLineView *lineChartView;

/* 接口类的全局变量 */
@property (nonatomic, strong) InterfaceModel *interfaceModel;

/* 存储所有评估数据的数组 */
@property (nonatomic, copy) NSMutableArray *evaluateData;
/* 存储匹兹堡睡眠指数数据数组 */
@property (nonatomic, copy) NSMutableArray *pittsburghDataArray;
/* 存储抑郁自评数据数组 */
@property (nonatomic, copy) NSMutableArray *depressedDataArray;
/* 存储焦虑自评数据数组 */
@property (nonatomic, copy) NSMutableArray *anxiousDataArray;
/* 存储躯体自评数据数组 */
@property (nonatomic, copy) NSMutableArray *bodyDataArray;

/* 分别存储匹兹堡睡眠指数数据中障碍指数、日期的数组 */
@property (nonatomic, copy) NSMutableArray *datePittsburghArray;
@property (nonatomic, copy) NSMutableArray *indexPittsburghArray;
/* 分别存储匹兹堡睡眠指数数据中障碍指数、日期的数组 */
@property (nonatomic, copy) NSMutableArray *dateDepressedArray;
@property (nonatomic, copy) NSMutableArray *indexDepressedArray;
/* 分别存储匹兹堡睡眠指数数据中障碍指数、日期的数组 */
@property (nonatomic, copy) NSMutableArray *dateAnxiousArray;
@property (nonatomic, copy) NSMutableArray *indexAnxiousArray;
/* 分别存储匹兹堡睡眠指数数据中障碍指数、日期的数组 */
@property (nonatomic, copy) NSMutableArray *dateBodyArray;
@property (nonatomic, copy) NSMutableArray *indexBodyArray;

@property (nonatomic, copy) NSMutableArray *showDateArray;
/* 显示日期内的日期数组 */
@property (nonatomic, copy) NSMutableArray *dateShowArray;
/* 标注是季度、半年、年的类型 */
@property (nonatomic, strong) NSString *typeStr;
/* 日期显示按钮（只显示不可点击） */
@property (nonatomic, strong) UIButton *dateBtn;

@end

@implementation TestReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //存储量表数据的数组初始化
    _pittsburghDataArray = [NSMutableArray array];
    _depressedDataArray = [NSMutableArray array];
    _anxiousDataArray = [NSMutableArray array];
    _bodyDataArray = [NSMutableArray array];
    
    //从本地数据库取数据
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    _evaluateData = [dbOpration getEvaluateDataFromDataBase];
    [self putEvaluateDataToArray];
    
    //从服务器获取评估数据
    _interfaceModel = [[InterfaceModel alloc] init];
    _interfaceModel.delegate = self;
    [_interfaceModel getEvaluateDataFromServer:_patientInfo.PatientID];
}

- (IBAction)changeFoldLineViewSegment:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        _typeStr = @"季度";
        //按季度画折线图
        if (self.lineChartView != nil)
        {
            [_lineChartView removeFromSuperview];
            _lineChartView = nil;
        }
        _lineChartView = [[FoldLineView alloc] initWithFrame:CGRectMake(25*Ratio_NAV_W, 64 + 100*Ratio_NAV_H, 325*Ratio_NAV_W, 230*Ratio_NAV_H)];
        _lineChartView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_lineChartView];
        if (_showDateArray != nil)
        {
            [_showDateArray removeAllObjects];
            _showDateArray = nil;
        }
        _showDateArray = [NSMutableArray array];
        for (int i=0; i<24; i++)
        {
            NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            NSDate *date = [[NSDate alloc] init];
            date =[df dateFromString:@"20151122"];
            
            NSTimeInterval myInterval = 24*60*60*6*i;
            NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
            NSString *strDate = [df stringFromDate:myDate];
            [_showDateArray addObject:strDate];
        }
        
        [self addFlodLineView];
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        _typeStr = @"半年";
        //按半年画折线图
        if (self.lineChartView != nil)
        {
            [_lineChartView removeFromSuperview];
            _lineChartView = nil;
        }
        _lineChartView = [[FoldLineView alloc] initWithFrame:CGRectMake(25*Ratio_NAV_W, 64 + 100*Ratio_NAV_H, 325*Ratio_NAV_W, 230*Ratio_NAV_H)];
        _lineChartView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_lineChartView];
        if (_showDateArray != nil)
        {
            [_showDateArray removeAllObjects];
            _showDateArray = nil;
        }
        _showDateArray = [NSMutableArray array];
        for (int i=0; i<24; i++)
        {
            NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            NSDate *date = [[NSDate alloc] init];
            date =[df dateFromString:@"20151122"];
            
            NSTimeInterval myInterval = 24*60*60*13*i;
            NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
            NSString *strDate = [df stringFromDate:myDate];
            [_showDateArray addObject:strDate];
        }
        
        [self addFlodLineView];
    }
    else if (sender.selectedSegmentIndex == 2)
    {
        _typeStr = @"年";
        //按年画折线图
        if (self.lineChartView != nil)
        {
            [_lineChartView removeFromSuperview];
            _lineChartView = nil;
        }
        _lineChartView = [[FoldLineView alloc] initWithFrame:CGRectMake(25*Ratio_NAV_W, 64 + 100*Ratio_NAV_H, 325*Ratio_NAV_W, 230*Ratio_NAV_H)];
        _lineChartView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_lineChartView];
        if (_showDateArray != nil)
        {
            [_showDateArray removeAllObjects];
            _showDateArray = nil;
        }
        _showDateArray = [NSMutableArray array];
        for (int i=0; i<24; i++)
        {
            NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            NSDate *date = [[NSDate alloc] init];
            date =[df dateFromString:@"20151122"];
            
            NSTimeInterval myInterval = 24*60*60*27*i;
            NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
            NSString *strDate = [df stringFromDate:myDate];
            [_showDateArray addObject:strDate];
        }
        
        [self addFlodLineView];
    }
}


//添加折线图
- (void)addFlodLineView
{
    [self evaluateDataToArray];
    [self addPittsburghFlodLineView];
}

- (void)addPittsburghFlodLineView
{
    self.lineChartView.y_max = 30;
    self.lineChartView.y_min = 0;
    
    self.lineChartView.x_max = [[_datePittsburghArray objectAtIndex:_datePittsburghArray.count-1] floatValue];
    self.lineChartView.x_min = [[_datePittsburghArray objectAtIndex:0] floatValue];
    
    self.lineChartView.y_interval = (self.lineChartView.y_max-self.lineChartView.y_min)/6;
    
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    NSMutableArray* xAxisValues = [@[] mutableCopy];
    for (int i = 0; i < 7; i++)
    {
        NSString* str = [NSString stringWithFormat:@"%f", self.lineChartView.y_min+self.lineChartView.y_interval*i];
        [yAxisValues addObject:str];
    }
    if ([_typeStr isEqualToString:@"季度"])
    {
        self.lineChartView.x_interval = 27;
        EvaluateInfo *tmpInfo = [_evaluateData objectAtIndex:_evaluateData.count-1];
        NSString *dfStr = [tmpInfo.Date stringByReplacingOccurrencesOfString:@"-" withString:@""];
        for (int i = 0; i < 25; i++)
        {
            NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            NSDate *date = [[NSDate alloc] init];
            date =[df dateFromString:dfStr];
            
            NSTimeInterval myInterval = 24*60*60*27*i;
            NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
            NSString *strDate = [df stringFromDate:myDate];
            [xAxisValues addObject:strDate];
            if ([myDate compare:[NSDate date]] == NSOrderedDescending)
            {
                break;
            }
        }
    }
    else if ([_typeStr isEqualToString:@"半年"])
    {
        self.lineChartView.x_interval = 55;
        for (int i = 0; i < 6; i++)
        {
            NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            NSDate *date = [[NSDate alloc] init];
            date =[df dateFromString:@"20151122"];
            
            NSTimeInterval myInterval = 24*60*60*55*i;
            NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
            NSString *strDate = [df stringFromDate:myDate];
            [xAxisValues addObject:strDate];
        }
    }
    else if ([_typeStr isEqualToString:@"年"])
    {
        self.lineChartView.x_interval = 111;
        for (int i = 0; i < 6; i++)
        {
            NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            NSDate *date = [[NSDate alloc] init];
            date =[df dateFromString:@"20151122"];
            
            NSTimeInterval myInterval = 24*60*60*111*i;
            NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
            NSString *strDate = [df stringFromDate:myDate];
            [xAxisValues addObject:strDate];
        }
    }
    
    self.lineChartView.xAxisValues = xAxisValues;
    self.lineChartView.yAxisValues = yAxisValues;
    self.lineChartView.axisLeftLineWidth = 39;
    
    //添加第一条折线（匹兹堡睡眠指数）
    NSArray *plottingYDataValues1 = _indexPittsburghArray;
    NSArray *plottingXDataValues1 = _datePittsburghArray;
    YBPlot *plot1 = [[YBPlot alloc] init];
    plot1.plottingYValues = plottingYDataValues1;
    plot1.plottingXValues = plottingXDataValues1;
    
    plot1.lineColor = [UIColor colorWithRed:0x3F/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    plot1.lineWidth = 0.5;
    
    [self.lineChartView addPlot:plot1];
    
    //添加第二条折线（抑郁自评）
    NSArray *plottingYDataValues2 = _indexDepressedArray;
    NSArray *plottingXDataValues2 = _dateDepressedArray;
    
    YBPlot *plot2 = [[YBPlot alloc] init];
    plot2.plottingYValues = plottingYDataValues2;
    plot2.plottingXValues = plottingXDataValues2;
    
    plot2.lineColor = [UIColor colorWithRed:0xA9/255.0 green:0xB2/255.0 blue:0xB3/255.0 alpha:1];
    plot2.lineWidth = 0.5;
    
    [self.lineChartView addPlot:plot2];
    
    //添加第三条折线（焦虑自评）
    NSArray *plottingYDataValues3 = _indexAnxiousArray;
    NSArray *plottingXDataValues3 = _dateAnxiousArray;
    
    YBPlot *plot3 = [[YBPlot alloc] init];
    plot3.plottingYValues = plottingYDataValues3;
    plot3.plottingXValues = plottingXDataValues3;
    
    plot3.lineColor = [UIColor colorWithRed:0x85/255.0 green:0x8F/255.0 blue:0xFF/255.0 alpha:1];
    plot3.lineWidth = 0.5;
    
    [self.lineChartView addPlot:plot3];
    
    //添加第四条折线（躯体自评）
    NSArray *plottingYDataValues4 = _indexBodyArray;
    NSArray *plottingXDataValues4 = _dateBodyArray;
    
    YBPlot *plot4 = [[YBPlot alloc] init];
    plot4.plottingYValues = plottingYDataValues4;
    plot4.plottingXValues = plottingXDataValues4;
    
    plot4.lineColor = [UIColor colorWithRed:0x00/255.0 green:0xA1/255.0 blue:0xFF/255.0 alpha:1];
    plot4.lineWidth = 0.5;
    
    [self.lineChartView addPlot:plot4];
}

//添加量表类型按钮
- (void)addScaleTypeButton
{
    //匹兹堡睡眠指数按钮
    UIButton *pittsburghBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pittsburghBtn.tag = 0;
    pittsburghBtn.frame = CGRectMake(65*Ratio, 64 + 358*Ratio, 246*Ratio, 34*Ratio);
    [pittsburghBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    pittsburghBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [pittsburghBtn setTitle:@"匹兹堡睡眠指数（PSQI）" forState:UIControlStateNormal];
    [pittsburghBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    pittsburghBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    pittsburghBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Ratio, 0, 0);
    [pittsburghBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pittsburghBtn];
    
    UIView *pittsburghView = [[UIView alloc] initWithFrame:CGRectMake(19*Ratio, 13*Ratio, 10*Ratio, 10*Ratio)];
    pittsburghView.layer.cornerRadius = 5*Ratio;
    pittsburghView.backgroundColor = [UIColor colorWithRed:0x3F/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    [pittsburghBtn addSubview:pittsburghView];
    
    //抑郁症状自评按钮
    UIButton *depressedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    depressedBtn.tag = 1;
    depressedBtn.frame = CGRectMake(65*Ratio, 64 + 404*Ratio, 246*Ratio, 34*Ratio);
    [depressedBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    depressedBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [depressedBtn setTitle:@"抑郁症状自评（PHQ-9）" forState:UIControlStateNormal];
    [depressedBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    depressedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    depressedBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Ratio, 0, 0);
    [depressedBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:depressedBtn];
    
    UIView *depressedView = [[UIView alloc] initWithFrame:CGRectMake(19*Ratio, 13*Ratio, 10*Ratio, 10*Ratio)];
    depressedView.layer.cornerRadius = 5*Ratio;
    depressedView.backgroundColor = [UIColor colorWithRed:0xA9/255.0 green:0xB2/255.0 blue:0xB3/255.0 alpha:1];
    [depressedBtn addSubview:depressedView];
    
    //焦虑症状自评按钮
    UIButton *anxiousBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    anxiousBtn.tag = 2;
    anxiousBtn.frame = CGRectMake(65*Ratio, 64 + 450*Ratio, 246*Ratio, 34*Ratio);
    [anxiousBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    anxiousBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [anxiousBtn setTitle:@"焦虑症状自评（GAD-7）" forState:UIControlStateNormal];
    [anxiousBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    anxiousBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    anxiousBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Ratio, 0, 0);
    [anxiousBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:anxiousBtn];
    
    UIView *anxiousView = [[UIView alloc] initWithFrame:CGRectMake(19*Ratio, 13*Ratio, 10*Ratio, 10*Ratio)];
    anxiousView.layer.cornerRadius = 5*Ratio;
    anxiousView.backgroundColor = [UIColor colorWithRed:0x85/255.0 green:0x8F/255.0 blue:0xFF/255.0 alpha:1];
    [anxiousBtn addSubview:anxiousView];
    
    //躯体症状自评按钮
    UIButton *bodyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    bodyBtn.tag = 3;
    bodyBtn.frame = CGRectMake(65*Ratio, 64 + 496*Ratio, 246*Ratio, 34*Ratio);
    [bodyBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    bodyBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [bodyBtn setTitle:@"躯体症状自评（PHQ-15）" forState:UIControlStateNormal];
    [bodyBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    bodyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    bodyBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Ratio, 0, 0);
    [bodyBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bodyBtn];
    
    UIView *bodyView = [[UIView alloc] initWithFrame:CGRectMake(19*Ratio, 13*Ratio, 10*Ratio, 10*Ratio)];
    bodyView.layer.cornerRadius = 5*Ratio;
    bodyView.backgroundColor = [UIColor colorWithRed:0x00/255.0 green:0xA1/255.0 blue:0xFF/255.0 alpha:1];
    [bodyBtn addSubview:bodyView];
}

- (void)checkReportDetail:(UIButton *)sender
{
    ReportDetailViewController *reportDetailVC = [[ReportDetailViewController alloc] init];
    if (sender.tag == 0)//跳转到匹兹堡睡眠报告
    {
        reportDetailVC.reportType = @"匹兹堡睡眠指数";
        reportDetailVC.evaluateArray = _pittsburghDataArray;
//        reportDetailVC.dateArray = _datePittsburghArray;
//        reportDetailVC.indexArray = _indexPittsburghArray;
        [self.navigationController pushViewController:reportDetailVC animated:YES];
    }
    else if (sender.tag == 1)//跳转到抑郁自评报告
    {
        reportDetailVC.reportType = @"抑郁自评";
        reportDetailVC.evaluateArray = _depressedDataArray;
//        reportDetailVC.dateArray = _dateDepressedArray;
//        reportDetailVC.indexArray = _indexDepressedArray;
        [self.navigationController pushViewController:reportDetailVC animated:YES];
    }
    else if (sender.tag == 2)//跳转到焦虑自评报告
    {
        reportDetailVC.reportType = @"焦虑自评";
        reportDetailVC.evaluateArray = _anxiousDataArray;
//        reportDetailVC.dateArray = _dateAnxiousArray;
//        reportDetailVC.indexArray = _indexAnxiousArray;
        [self.navigationController pushViewController:reportDetailVC animated:YES];
    }
    else if (sender.tag == 3)//跳转到躯体自评报告
    {
        reportDetailVC.reportType = @"躯体自评";
        reportDetailVC.evaluateArray = _bodyDataArray;
//        reportDetailVC.dateArray = _dateBodyArray;
//        reportDetailVC.indexArray = _indexBodyArray;
        [self.navigationController pushViewController:reportDetailVC animated:YES];
    }
}

- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeGetEvaluateData)
    {
        NSArray *resultArray = value;
        if (resultArray.count!=0)
        {
            for (int i=0; i<resultArray.count; i++)
            {
                EvaluateInfo *tmp_evaluateInfo = [[EvaluateInfo alloc] init];
                tmp_evaluateInfo.PatientID = _patientInfo.PatientID;
                tmp_evaluateInfo.ListFlag = [[resultArray objectAtIndex:i] objectForKey:@"Type"];
                tmp_evaluateInfo.Date = [[resultArray objectAtIndex:i] objectForKey:@"Date"];
                tmp_evaluateInfo.Time = [[resultArray objectAtIndex:i] objectForKey:@"SaveTime"];
                tmp_evaluateInfo.Score = [[resultArray objectAtIndex:i] objectForKey:@"Score"];
                tmp_evaluateInfo.Quality = [[resultArray objectAtIndex:i] objectForKey:@"Quality"];
                
                EvaluateInfo *tmpInfo;
                for (EvaluateInfo *tmp in _evaluateData)
                {
                    if ([tmp_evaluateInfo.Date isEqualToString:tmp.Date] && [tmp_evaluateInfo.ListFlag isEqualToString:tmp.ListFlag] && [tmp_evaluateInfo.PatientID isEqualToString:_patientInfo.PatientID])
                    {
                        tmpInfo=tmp;
                    }
                }
                if (tmpInfo == nil)
                {
                    [_evaluateData addObject:tmp_evaluateInfo];
                    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
                    [dbOpration insertEvaluateInfo:tmp_evaluateInfo];
                    [dbOpration closeDataBase];
                }
            }
            [_pittsburghDataArray removeAllObjects];
            [_depressedDataArray removeAllObjects];
            [_anxiousDataArray removeAllObjects];
            [_bodyDataArray removeAllObjects];
            [self putEvaluateDataToArray];
        }
        
        _dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(125*Ratio_NAV_W, 64 + 65*Ratio_NAV_H, 125*Ratio_NAV_W, 20*Ratio_NAV_H)];
        [_dateBtn setTitleColor:[UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1] forState:UIControlStateNormal];
        EvaluateInfo *tmpInfoStart = [_evaluateData objectAtIndex:_evaluateData.count-1];
        EvaluateInfo *tmpInfoEnd = [_evaluateData objectAtIndex:0];
        NSString *dfStrStart = [tmpInfoStart.Date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        NSString *dfStrEnd = [tmpInfoEnd.Date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        [_dateBtn setTitle:[NSString stringWithFormat:@"%@-%@",dfStrStart,dfStrEnd] forState:UIControlStateNormal];
        _dateBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_dateBtn];
        
        //按季度画图
        _typeStr = @"季度";
        _lineChartView = [[FoldLineView alloc] initWithFrame:CGRectMake(25*Ratio_NAV_W, 64 + 100*Ratio_NAV_H, 325*Ratio_NAV_W, 230*Ratio_NAV_H)];
        _lineChartView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_lineChartView];
        _showDateArray = [NSMutableArray array];
        EvaluateInfo *tmpInfo = [_evaluateData objectAtIndex:_evaluateData.count-1];
        NSString *dfStr = [tmpInfo.Date stringByReplacingOccurrencesOfString:@"-" withString:@""];
        for (int i = 0; i < 100; i++)
        {
            NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
            [df setDateFormat:@"yyyyMMdd"];
            NSDate *date = [[NSDate alloc] init];
            date =[df dateFromString:dfStr];
            
            NSTimeInterval myInterval = 24*60*60*6*i;
            NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
            NSString *strDate = [df stringFromDate:myDate];
            [_showDateArray addObject:strDate];
            if ([myDate compare:[NSDate date]] == NSOrderedDescending)
            {
                break;
            }
        }
        [self addFlodLineView];
        [self addScaleTypeButton];
    }
}

//根据开始时间跟结束时间选择评估数据，并把数据放入对应数组
- (void)putEvaluateDataToArray
{
    if (_patientInfo!=nil)
    {
        for (EvaluateInfo *tmp in _evaluateData)
        {
            if ([tmp.ListFlag integerValue]==1 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [_pittsburghDataArray addObject:tmp];
            }
            else if ([tmp.ListFlag integerValue]==2 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [_depressedDataArray addObject:tmp];
            }
            else if ([tmp.ListFlag integerValue]==3 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [_anxiousDataArray addObject:tmp];
            }
            else if ([tmp.ListFlag integerValue]==4 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [_bodyDataArray addObject:tmp];
            }
        }
        if (_pittsburghDataArray.count>0)
        {
            [self bubbleSort:_pittsburghDataArray];
        }
        if (_depressedDataArray.count>0)
        {
            [self bubbleSort:_depressedDataArray];
        }
        if (_anxiousDataArray.count>0)
        {
            [self bubbleSort:_anxiousDataArray];
        }
        if (_bodyDataArray.count>0)
        {
            [self bubbleSort:_bodyDataArray];
        }
    }
}

//将evaluateArray数组当中的数据，障碍指数、日期分别存在对应数组当中
- (void)evaluateDataToArray
{
    if (_pittsburghDataArray.count > 0)
    {
        _datePittsburghArray = [NSMutableArray array];
        _indexPittsburghArray = [NSMutableArray array];
        NSMutableArray *tmpData = [NSMutableArray arrayWithArray:_pittsburghDataArray];
        for (int i=0; i<_showDateArray.count; i++)
        {
            NSString *dateStr = [_showDateArray objectAtIndex:i];
            NSInteger index = [self binarySearchKey:tmpData andTarget:dateStr];
            EvaluateInfo *tmp = [tmpData objectAtIndex:index];
            [_datePittsburghArray addObject:[tmp.Date stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            [_indexPittsburghArray addObject:tmp.Score];
        }
    }
    if (_depressedDataArray.count > 0)
    {
        _dateDepressedArray = [NSMutableArray array];
        _indexDepressedArray = [NSMutableArray array];
        for (int i=0; i<_showDateArray.count; i++)
        {
            NSString *dateStr = [_showDateArray objectAtIndex:i];
            NSInteger index = [self binarySearchKey:_depressedDataArray andTarget:dateStr];
            EvaluateInfo *tmp = [_depressedDataArray objectAtIndex:index];
            [_dateDepressedArray addObject:[tmp.Date stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            [_indexDepressedArray addObject:tmp.Score];
        }
    }
    if (_anxiousDataArray.count > 0)
    {
        _dateAnxiousArray = [NSMutableArray array];
        _indexAnxiousArray = [NSMutableArray array];
        for (int i=0; i<_showDateArray.count; i++)
        {
            NSString *dateStr = [_showDateArray objectAtIndex:i];
            NSInteger index = [self binarySearchKey:_anxiousDataArray andTarget:dateStr];
            EvaluateInfo *tmp = [_anxiousDataArray objectAtIndex:index];
            [_dateAnxiousArray addObject:[tmp.Date stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            [_indexAnxiousArray addObject:tmp.Score];
        }
    }
    if (_bodyDataArray.count > 0)
    {
        _dateBodyArray = [NSMutableArray array];
        _indexBodyArray = [NSMutableArray array];
        for (int i=0; i<_showDateArray.count; i++)
        {
            NSString *dateStr = [_showDateArray objectAtIndex:i];
            NSInteger index = [self binarySearchKey:_bodyDataArray andTarget:dateStr];
            EvaluateInfo *tmp = [_bodyDataArray objectAtIndex:index];
            [_dateBodyArray addObject:[tmp.Date stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            [_indexBodyArray addObject:tmp.Score];
        }
    }
}

//冒泡排序
- (void)bubbleSort:(NSMutableArray *)array
{
    for (int j=0; j<array.count-1; j++)
    {
        for (int i=0; i<array.count-1-j; i++)
        {
            EvaluateInfo *index_One=[array objectAtIndex:i];
            EvaluateInfo *index_Two=[array objectAtIndex:i+1];
            if ([index_One.Date compare:index_Two.Date]==NSOrderedDescending)
            {
                [array exchangeObjectAtIndex:i withObjectAtIndex:i+1];
            }
        }
    }
}

- (NSInteger)binarySearchKey:(NSArray *)dataArray andTarget:(NSString *)targetDate
{
    for (int i = 0; i < dataArray.count; i++)
    {
        NSLog(@"%@",[dataArray objectAtIndex:i]);
    }
    
    NSInteger left = 0;
    NSInteger right = 0;
    for (right = dataArray.count-1; left!=right;)
    {
        NSInteger midIndex = (right + left)/2;
        NSInteger mid = (right - left);
        EvaluateInfo *tmp = [dataArray objectAtIndex:midIndex];
        
        NSString *midValue = [tmp.Date stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if ([targetDate isEqualToString:midValue])
        {
            return midIndex;
        }
        
        if([self dateTimeDifferenceWithStartTime:targetDate endTime:midValue] < 0)
        {
            left = midIndex;
        }
        else
        {
            right = midIndex;
        }
        
        if (mid <= 1)
        {
            break;
        }
    }
    
    EvaluateInfo *rightEva = [dataArray objectAtIndex:right];
    EvaluateInfo *leftEva = [dataArray objectAtIndex:left];
    NSString *rightEndDate = [rightEva.Date stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *leftEndDate = [leftEva.Date stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSInteger a = labs([self dateTimeDifferenceWithStartTime:targetDate endTime:rightEndDate]);
    NSInteger b = labs([self dateTimeDifferenceWithStartTime:targetDate endTime:leftEndDate]);
    NSInteger rect = a > b ? left :right;
    return rect;
}


/**
 * 开始到结束的时间差的天数
 */
- (NSInteger)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyyMMdd"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    NSInteger day = value / (24 * 3600);
    return day;
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
