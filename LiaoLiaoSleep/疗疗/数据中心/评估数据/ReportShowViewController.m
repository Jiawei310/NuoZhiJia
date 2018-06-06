//
//  ReportShowViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/2/28.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "ReportShowViewController.h"

#import "Define.h"
#import <UMMobClick/MobClick.h>
#import "EvaluateInfo.h"
#import "DataBaseOpration.h"

@interface ReportShowViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (strong, nonatomic) UITableView *dataTableView;

/* 显示数据类型 */
@property (nonatomic, strong) NSString *dataShowType;
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

@end

@implementation ReportShowViewController

- (void)viewWillAppear:(BOOL)animated
{
    //隐藏选项卡
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"评估数据"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"评估数据"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //视图控制器名称
    self.navigationItem.title = @"评估数据";
    
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
    
    [self assessmentDataPrepare];
    [self addAssessmentDataTableView];
    [self addScaleTypeButton];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)assessmentDataPrepare
{
    _dataShowType = @"PSQI";
    //存储量表数据的数组初始化
    _pittsburghDataArray = [NSMutableArray array];
    _depressedDataArray = [NSMutableArray array];
    _anxiousDataArray = [NSMutableArray array];
    _bodyDataArray = [NSMutableArray array];
    
    //从本地数据库取数据
    DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
    _evaluateData = [dbOpration getEvaluateDataFromDataBase];
    [self putEvaluateDataToArray];
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

//冒泡排序
- (void)bubbleSort:(NSMutableArray *)array
{
    for (int j = 0; j < array.count-1; j++)
    {
        for (int i = 0; i < array.count-1-j; i++)
        {
            EvaluateInfo *index_One = [array objectAtIndex:i];
            EvaluateInfo *index_Two = [array objectAtIndex:i+1];
            if ([index_One.Date compare:index_Two.Date] == NSOrderedAscending)
            {
                [array exchangeObjectAtIndex:i withObjectAtIndex:i+1];
            }
        }
    }
}

- (void)addAssessmentDataTableView
{
    UIView *tableBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 34*Rate_NAV_H)];
    tableBackView.backgroundColor = [UIColor colorWithRed:0xF9/255.0 green:0xF9/255.0 blue:0xF9/255.0 alpha:1];
    [self.view addSubview:tableBackView];
    //上下边框线
    UIView *lineViewUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_NAV_W, 0.5*Rate_NAV_H)];
    lineViewUp.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xD9/255.0 blue:0xD9/255.0 alpha:1];
    [tableBackView addSubview:lineViewUp];
    UIView *lineViewDown = [[UIView alloc] initWithFrame:CGRectMake(0, 33.5*Rate_NAV_H, 375*Rate_NAV_W, 0.5*Rate_NAV_H)];
    lineViewDown.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xD9/255.0 blue:0xD9/255.0 alpha:1];
    [tableBackView addSubview:lineViewDown];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 104*Rate_NAV_W, 34*Rate_NAV_H)];
    dateLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    dateLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.text = @"评估日期";
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(109*Rate_NAV_W, 0, 106*Rate_NAV_W, 34*Rate_NAV_H)];
    timeLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    timeLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.text = @"评估时间";
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(215*Rate_NAV_W, 0, 65*Rate_NAV_W, 34*Rate_NAV_H)];
    numLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    numLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.text = @"障碍指数";
    UILabel *qualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(280*Rate_NAV_W, 0, 95*Rate_NAV_W, 34*Rate_NAV_H)];
    qualityLabel.font = [UIFont systemFontOfSize:12*Rate_NAV_H];
    qualityLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    qualityLabel.textAlignment = NSTextAlignmentCenter;
    qualityLabel.text = @"评估结果";
    [tableBackView addSubview:dateLabel];
    [tableBackView addSubview:timeLabel];
    [tableBackView addSubview:numLabel];
    [tableBackView addSubview:qualityLabel];
    
    _dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 34*Rate_NAV_H, 375*Rate_NAV_W, 329*Rate_NAV_H) style:UITableViewStylePlain];
    if ([_dataTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _dataTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_dataTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    [self.view addSubview:_dataTableView];
    
    UIView *lineViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, 363*Rate_NAV_H, 375*Rate_NAV_W, 0.2)];
    lineViewBottom.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xD9/255.0 blue:0xD9/255.0 alpha:1];
    [self.view addSubview:lineViewBottom];
}

#pragma dataTableView的delegate、dataSource代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47*Rate_NAV_H;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dataShowType isEqualToString:@"PHQ-9"])
    {
        return _depressedDataArray.count;
    }
    else if ([_dataShowType isEqualToString:@"GAD-7"])
    {
        return _anxiousDataArray.count;
    }
    else if ([_dataShowType isEqualToString:@"PHQ-15"])
    {
        return _bodyDataArray.count;
    }
    else
    {
        return _pittsburghDataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"EvaluateDataCell";
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 104*Rate_NAV_W, 47*Rate_NAV_H)];
    dateLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(109*Rate_NAV_W, 0, 106*Rate_NAV_W, 47*Rate_NAV_H)];
    timeLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(215*Rate_NAV_W, 0, 65*Rate_NAV_W, 47*Rate_NAV_H)];
    numLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    numLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *qualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(280*Rate_NAV_W, 0, 95*Rate_NAV_W, 47*Rate_NAV_H)];
    qualityLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    qualityLabel.textAlignment = NSTextAlignmentCenter;
    
    EvaluateInfo *tmp = [[EvaluateInfo alloc] init];
    if ([_dataShowType isEqualToString:@"PSQI"])
    {
        tmp = [_pittsburghDataArray objectAtIndex:indexPath.row];
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
    else if ([_dataShowType isEqualToString:@"PHQ-9"])
    {
        tmp = [_depressedDataArray objectAtIndex:indexPath.row];
        dateLabel.text = tmp.Date;
        timeLabel.text = [tmp.Time substringWithRange:NSMakeRange(0, 5)];
        numLabel.text = tmp.Score;
        qualityLabel.text = [tmp.Quality substringWithRange:NSMakeRange(0, 2)];
    }
    else if ([_dataShowType isEqualToString:@"GAD-7"])
    {
        tmp = [_anxiousDataArray objectAtIndex:indexPath.row];
        dateLabel.text = tmp.Date;
        timeLabel.text = [tmp.Time substringWithRange:NSMakeRange(0, 5)];
        numLabel.text = tmp.Score;
        qualityLabel.text = [tmp.Quality substringWithRange:NSMakeRange(0, 2)];
    }
    else if ([_dataShowType isEqualToString:@"PHQ-15"])
    {
        tmp = [_bodyDataArray objectAtIndex:indexPath.row];
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

//添加量表类型按钮
- (void)addScaleTypeButton
{
    //匹兹堡睡眠指数按钮
    UIButton *pittsburghBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pittsburghBtn.tag = 10;
    pittsburghBtn.frame = CGRectMake(65*Rate_NAV_W, 398*Rate_NAV_H, 246*Rate_NAV_W, 34*Rate_NAV_H);
    [pittsburghBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_bg"] forState:UIControlStateNormal];
    pittsburghBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [pittsburghBtn setTitle:@"匹兹堡睡眠指数（PSQI）" forState:UIControlStateNormal];
    [pittsburghBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    pittsburghBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    pittsburghBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Rate_NAV_W, 0, 0);
    [pittsburghBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pittsburghBtn];
    
    UIView *pittsburghView = [[UIView alloc] initWithFrame:CGRectMake(19*Rate_NAV_W, 12*Rate_NAV_H, 10*Rate_NAV_H, 10*Rate_NAV_H)];
    pittsburghView.layer.cornerRadius = 5*Rate_NAV_H;
    pittsburghView.backgroundColor = [UIColor colorWithRed:0x3F/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    [pittsburghBtn addSubview:pittsburghView];
    
    //抑郁症状自评按钮
    UIButton *depressedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    depressedBtn.tag = 11;
    depressedBtn.frame = CGRectMake(65*Rate_NAV_W, 444*Rate_NAV_H, 246*Rate_NAV_W, 34*Rate_NAV_H);
    [depressedBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    depressedBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [depressedBtn setTitle:@"抑郁症状自评（PHQ-9）" forState:UIControlStateNormal];
    [depressedBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    depressedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    depressedBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Rate_NAV_W, 0, 0);
    [depressedBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:depressedBtn];
    
    UIView *depressedView = [[UIView alloc] initWithFrame:CGRectMake(19*Rate_NAV_W, 12*Rate_NAV_H, 10*Rate_NAV_H, 10*Rate_NAV_H)];
    depressedView.layer.cornerRadius = 5*Rate_NAV_H;
    depressedView.backgroundColor = [UIColor colorWithRed:0xA9/255.0 green:0xB2/255.0 blue:0xB3/255.0 alpha:1];
    [depressedBtn addSubview:depressedView];
    
    //焦虑症状自评按钮
    UIButton *anxiousBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    anxiousBtn.tag = 12;
    anxiousBtn.frame = CGRectMake(65*Rate_NAV_W, 490*Rate_NAV_H, 246*Rate_NAV_W, 34*Rate_NAV_H);
    [anxiousBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    anxiousBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [anxiousBtn setTitle:@"焦虑症状自评（GAD-7）" forState:UIControlStateNormal];
    [anxiousBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    anxiousBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    anxiousBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Rate_NAV_W, 0, 0);
    [anxiousBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:anxiousBtn];
    
    UIView *anxiousView = [[UIView alloc] initWithFrame:CGRectMake(19*Rate_NAV_W, 12*Rate_NAV_H, 10*Rate_NAV_H, 10*Rate_NAV_H)];
    anxiousView.layer.cornerRadius = 5*Rate_NAV_H;
    anxiousView.backgroundColor = [UIColor colorWithRed:0x85/255.0 green:0x8F/255.0 blue:0xFF/255.0 alpha:1];
    [anxiousBtn addSubview:anxiousView];
    
    //躯体症状自评按钮
    UIButton *bodyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    bodyBtn.tag = 13;
    bodyBtn.frame = CGRectMake(65*Rate_NAV_W, 536*Rate_NAV_H, 246*Rate_NAV_W, 34*Rate_NAV_H);
    [bodyBtn setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    bodyBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [bodyBtn setTitle:@"躯体症状自评（PHQ-15）" forState:UIControlStateNormal];
    [bodyBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
    bodyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    bodyBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 36*Rate_NAV_W, 0, 0);
    [bodyBtn addTarget:self action:@selector(checkReportDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bodyBtn];
    
    UIView *bodyView = [[UIView alloc] initWithFrame:CGRectMake(19*Rate_NAV_W, 12*Rate_NAV_H, 10*Rate_NAV_H, 10*Rate_NAV_H)];
    bodyView.layer.cornerRadius = 5*Rate_NAV_H;
    bodyView.backgroundColor = [UIColor colorWithRed:0x00/255.0 green:0xA1/255.0 blue:0xFF/255.0 alpha:1];
    [bodyBtn addSubview:bodyView];
}

- (void)checkReportDetail:(UIButton *)sender
{
    [sender setBackgroundImage:[UIImage imageNamed:@"report_btn_bg"] forState:UIControlStateNormal];
    if (sender.tag == 10)//跳转到匹兹堡睡眠报告
    {
        _dataShowType = @"PSQI";
        [_dataTableView reloadData];
        
        UIButton *btnOne = [self.view viewWithTag:11];
        [btnOne setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnTwo = [self.view viewWithTag:12];
        [btnTwo setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnThree = [self.view viewWithTag:13];
        [btnThree setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    }
    else if (sender.tag == 11)//跳转到抑郁自评报告
    {
        _dataShowType = @"PHQ-9";
        [_dataTableView reloadData];
        
        UIButton *btnZero = [self.view viewWithTag:10];
        [btnZero setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnTwo = [self.view viewWithTag:12];
        [btnTwo setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnThree = [self.view viewWithTag:13];
        [btnThree setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    }
    else if (sender.tag == 12)//跳转到焦虑自评报告
    {
        _dataShowType = @"GAD-7";
        [_dataTableView reloadData];
        
        UIButton *btnZero = [self.view viewWithTag:10];
        [btnZero setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnOne = [self.view viewWithTag:11];
        [btnOne setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnThree = [self.view viewWithTag:13];
        [btnThree setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
    }
    else if (sender.tag == 13)//跳转到躯体自评报告
    {
        _dataShowType = @"PHQ-15";
        [_dataTableView reloadData];
        
        UIButton *btnZero = [self.view viewWithTag:10];
        [btnZero setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnOne = [self.view viewWithTag:11];
        [btnOne setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
        UIButton *btnTwo = [self.view viewWithTag:12];
        [btnTwo setBackgroundImage:[UIImage imageNamed:@"report_btn_notselected_bg"] forState:UIControlStateNormal];
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
