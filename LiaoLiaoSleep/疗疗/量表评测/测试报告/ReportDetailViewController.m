//
//  ReportDetailViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "ReportDetailViewController.h"
#import "Define.h"

#import "EvaluateInfo.h"

#import "YBPlot.h"
#import "FoldLineView.h"
#import "DetailFlodLineView.h"

#import "DateChooseViewController.h"

@interface ReportDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet DetailFlodLineView *lineChartView;

@property (strong, nonatomic) UITableView *dataTableView;

@property (nonatomic, copy) NSMutableArray *dateArray;
@property (nonatomic, copy) NSMutableArray *indexArray;

@end

@implementation ReportDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    if ([_reportType isEqualToString:@"匹兹堡睡眠指数"])
    {
        self.title = @"匹兹堡睡眠报告";
    }
    else if ([_reportType isEqualToString:@"抑郁自评"])
    {
        self.title = @"抑郁自评报告";
    }
    else if ([_reportType isEqualToString:@"焦虑自评"])
    {
        self.title = @"焦虑自评报告";
    }
    else if ([_reportType isEqualToString:@"躯体自评"])
    {
        self.title = @"躯体自评报告";
    }
    
    //添加导航栏右边按钮，筛选时间
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [btn addTarget:self action:@selector(screenTime) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_screen"] forState:(UIControlStateNormal)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"上一季度  16.06.26-16.09.18" attributes:@{NSKernAttributeName:@(1.2)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    _timeLabel.attributedText = attributedString;
    
    [self evaluateDataToArray];
    
    [self addFlodLineView];
    
    UIView *tableBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 401*Ratio, 375*Ratio_W, 34*Ratio)];
    tableBackView.backgroundColor = [UIColor colorWithRed:0xF9/255.0 green:0xF9/255.0 blue:0xF9/255.0 alpha:1];
    [self.view addSubview:tableBackView];
    //上下边框线
    UIView *lineViewUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Ratio_W, 0.5*Ratio)];
    lineViewUp.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xD9/255.0 blue:0xD9/255.0 alpha:1];
    [tableBackView addSubview:lineViewUp];
    UIView *lineViewDown = [[UIView alloc] initWithFrame:CGRectMake(0, 33.5*Ratio, 375*Ratio_W, 0.5*Ratio)];
    lineViewDown.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xD9/255.0 blue:0xD9/255.0 alpha:1];
    [tableBackView addSubview:lineViewDown];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 104*Ratio_W, 34*Ratio_W)];
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.text = @"日期";
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(109*Ratio_W, 0, 106*Ratio_W, 34*Ratio_W)];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.text = @"时间";
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(215*Ratio_W, 0, 65*Ratio_W, 34*Ratio_W)];
    numLabel.font = [UIFont systemFontOfSize:12];
    numLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.text = @"障碍指数";
    UILabel *qualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(280*Ratio_W, 0, 95*Ratio_W, 34*Ratio_W)];
    qualityLabel.font = [UIFont systemFontOfSize:12];
    qualityLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    qualityLabel.textAlignment = NSTextAlignmentCenter;
    qualityLabel.text = @"评估结果";
    [tableBackView addSubview:dateLabel];
    [tableBackView addSubview:timeLabel];
    [tableBackView addSubview:numLabel];
    [tableBackView addSubview:qualityLabel];
    
    _dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 435*Ratio, 375*Ratio_W, 232*Ratio) style:UITableViewStylePlain];
    [_dataTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    [self.view addSubview:_dataTableView];
}

//筛选时间按钮点击事件
- (void)screenTime
{
    DateChooseViewController *dateChooseVC = [[DateChooseViewController alloc] init];
    [self.navigationController pushViewController:dateChooseVC animated:YES];
}

//将evaluateArray数组当中的数据，障碍指数、日期分别存在对应数组当中
- (void)evaluateDataToArray
{
    if (_evaluateArray.count > 0)
    {
        _dateArray = [NSMutableArray array];
        _indexArray = [NSMutableArray array];
        for (int i=0; i < _evaluateArray.count; i++)
        {
            EvaluateInfo *tmp = [_evaluateArray objectAtIndex:i];
            [_dateArray addObject:[tmp.Date stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            [_indexArray addObject:tmp.Score];
        }
    }
}

//添加折线图
- (void)addFlodLineView
{
    NSArray *plottingYDataValues1 = _indexArray;
    NSArray *plottingXDataValues1 = _dateArray;
    
    self.lineChartView.y_max = 30;
    self.lineChartView.y_min = 0;
    
    self.lineChartView.x_max = [[_dateArray objectAtIndex:_dateArray.count-1] floatValue];
    self.lineChartView.x_min = [[_dateArray objectAtIndex:0] floatValue];
    
    self.lineChartView.y_interval = (self.lineChartView.y_max-self.lineChartView.y_min)/6;
    self.lineChartView.x_interval = 27;
    
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    NSMutableArray* xAxisValues = [@[] mutableCopy];
    for (int i = 0; i < 7; i++)
    {
        NSString* str = [NSString stringWithFormat:@"%f", self.lineChartView.y_min+self.lineChartView.y_interval*i];
        [yAxisValues addObject:str];
    }
    for (int i=0; i<plottingXDataValues1.count+1; i++)
    {
        NSDateFormatter*df = [[NSDateFormatter alloc]init];//格式化
        [df setDateFormat:@"yyyyMMdd"];
        NSDate *date = [[NSDate alloc]init];
        date =[df dateFromString:@"20151122"];
        
        NSTimeInterval myInterval = 24*60*60*27*i;
        NSDate *myDate = [date initWithTimeInterval:myInterval sinceDate:date];
        NSString *strDate = [df stringFromDate:myDate];
        [xAxisValues addObject:strDate];
    }
    
    self.lineChartView.xAxisValues = xAxisValues;
    self.lineChartView.yAxisValues = yAxisValues;
    self.lineChartView.axisLeftLineWidth = 39;
    
    //添加第一条折线（匹兹堡睡眠指数）
    YBPlot *plot1 = [[YBPlot alloc] init];
    plot1.plottingYValues = plottingYDataValues1;
    plot1.plottingXValues = plottingXDataValues1;
    
    plot1.lineColor = [UIColor whiteColor];
    plot1.lineWidth = 1;
    
    [self.lineChartView addPlot:plot1];
}

#pragma dataTableView的delegate、dataSource代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47*Ratio;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _evaluateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"EvaluateDataCell";
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 104*Ratio_W, 47*Ratio_W)];
    dateLabel.font = [UIFont systemFontOfSize:14];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(109*Ratio_W, 0, 106*Ratio_W, 47*Ratio_W)];
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(215*Ratio_W, 0, 65*Ratio_W, 47*Ratio_W)];
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *qualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(280*Ratio_W, 0, 95*Ratio_W, 47*Ratio_W)];
    qualityLabel.font = [UIFont systemFontOfSize:14];
    qualityLabel.textAlignment = NSTextAlignmentCenter;
    
    EvaluateInfo *tmp = [[EvaluateInfo alloc] init];
    if ([_reportType isEqualToString:@"匹兹堡睡眠指数"])
    {
        tmp = [_evaluateArray objectAtIndex:indexPath.row];
        dateLabel.text = tmp.Date;
        timeLabel.text = [tmp.Time substringWithRange:NSMakeRange(0, 5)];
        numLabel.text = tmp.Score;
        if ([tmp.Quality containsString:@"很好"])
        {
            qualityLabel.text = @"很好";
        }
        else if ([tmp.Quality containsString:@"一般"])
        {
            qualityLabel.text = @"一般";
        }
        else if ([tmp.Quality containsString:@"较差"])
        {
            qualityLabel.text = @"较差";
        }
        else if ([tmp.Quality containsString:@"很差"])
        {
            qualityLabel.text = @"很差";
        }
    }
    else if ([_reportType isEqualToString:@"抑郁自评"] || [_reportType isEqualToString:@"焦虑自评"])
    {
        tmp = [_evaluateArray objectAtIndex:indexPath.row];
        dateLabel.text = tmp.Date;
        timeLabel.text = [tmp.Time substringWithRange:NSMakeRange(0, 5)];
        numLabel.text = tmp.Score;
        qualityLabel.text = [tmp.Quality substringWithRange:NSMakeRange(0, 2)];
    }
    else if ([_reportType isEqualToString:@"躯体自评"])
    {
        tmp = [_evaluateArray objectAtIndex:indexPath.row];
        dateLabel.text = tmp.Date;
        timeLabel.text = [tmp.Time substringWithRange:NSMakeRange(0, 5)];
        numLabel.text = tmp.Score;
    }
    
    [cell.contentView addSubview:dateLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:numLabel];
    [cell.contentView addSubview:qualityLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_lineChartView setNeedsDisplay];
    
    _lineChartView.pointDate = [_dateArray objectAtIndex:indexPath.row];
    _lineChartView.pointIndex = [_indexArray objectAtIndex:indexPath.row];
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
