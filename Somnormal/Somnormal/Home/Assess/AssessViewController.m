//
//  AssessViewController.m
//  Somnormal
//
//  Created by Justin on 2017/6/29.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "AssessViewController.h"

#import "CircleView.h"
#import "AssessmentViewController.h"

@interface AssessViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation AssessViewController
{
    UIView *line;                          //屏幕中间横线
    
    UIView *view;                          //用来当作门板
    UITableView *MyTableView;              //门板view上的tableview，进行选择对哪项进行评估
    NSArray *evaluateArray;                //存储评估项目的数据源
    UIButton *MyImageButton;               //标志是否选中哪项评估
    NSMutableArray *MyImageButtonArray;    //存储评估标志MyImageButton的数组
    NSInteger evaluateIndex;               //记录选择哪项评估的index
    UIImageView *start_bg;
    UIButton *btn_start;                   //评估按钮
    UITapGestureRecognizer *tapGesture_evaluate;    //添加的点击手势
    UIView *fatherView;                    //放置扇形图CircleView的父视图，不然CircleView直接加在self.view上看不见
    CircleView *circle;                    //扇形图表类全局变量
    UITableView *chartTableView;           //显示最近十天睡眠评估的tableview
    UILabel *tenDayLabel;                  //最近十天体验的睡眠治疗数据
    
    DataBaseOpration *dbOption;            //数据库对象全局变量
    NSMutableArray *evaluateData;          //存储数据库中评估数据
    NSMutableArray *SleepEvaluate;         //存储最近十天的睡眠评估数据
    NSDate *BegainDate;                    //NSDate类型的查看日期的开始日期
    NSDate *EndDate;                       //NSDate类型的查看日期的截止日期
    NSString *BegainTime;                  //NSString类型的查看日期的开始日期
    NSString *EndTime;                     //NSString类型的查看日期的截止日期
    int countGood;
    int countGeneral;
    int countBad;
    int countVeryBad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SleepEvaluate=[NSMutableArray array];
    [self addView];
    
    //获取通知中心单例对象
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(refreshDataOnEvaluateView) name:@"refreshData" object:nil];
}

-(void)refreshDataOnEvaluateView
{
    DataBaseOpration *db=[[DataBaseOpration alloc] init];
    evaluateData = [db getEvaluateDataFromDataBase];
    [self bubbleSort:evaluateData];
    [dbOption closeDataBase];
    [self putEvaluateDataToArray];
    [chartTableView reloadData];
}

//添加评估界面主视图
-(void)addView
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    EndDate=[NSDate date];
    BegainDate=[EndDate initWithTimeIntervalSinceNow:-10*24*60*60];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    BegainTime=[dateFormatter stringFromDate:BegainDate];
    EndTime=[dateFormatter stringFromDate:EndDate];
    
    dbOption=[[DataBaseOpration alloc] init];
    evaluateData = [dbOption getEvaluateDataFromDataBase];
    if (evaluateData.count > 0)
    {
       [self bubbleSort:evaluateData];
    }
    [dbOption closeDataBase];
    
    //最近十天内的评估数据
    [self putEvaluateDataToArray];
    
    start_bg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start_bg"]];
    btn_start=[UIButton buttonWithType:UIButtonTypeSystem];
    if (SCREENHEIGHT==480)
    {
        start_bg.frame=CGRectMake(SCREENWIDTH*3.5/16, SCREENHEIGHT/15-SCREENHEIGHT/20, SCREENWIDTH*9/16, SCREENWIDTH*15/32);
        btn_start.frame=CGRectMake(SCREENWIDTH*7.5/24, SCREENHEIGHT/8.5-SCREENHEIGHT/20, SCREENWIDTH*9/24, SCREENWIDTH*9/24);
    }
    else
    {
        start_bg.frame=CGRectMake(SCREENWIDTH*3.5/16, SCREENHEIGHT/15, SCREENWIDTH*9/16, SCREENWIDTH*15/32);
        btn_start.frame=CGRectMake(SCREENWIDTH*7.3/24, SCREENHEIGHT/9, SCREENWIDTH*9/24, SCREENWIDTH*9/24);
    }
    [btn_start setBackgroundImage:[UIImage imageNamed:@"start_src"] forState:UIControlStateNormal];
    [btn_start addTarget:self action:@selector(evaluateTapPressGestures) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:start_bg];
    [self.view addSubview:btn_start];
    
    //添加横线
    line = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT/2.5, SCREENWIDTH, 0.5)];
    if (SCREENHEIGHT==480)
    {
        line.frame=CGRectMake(0, SCREENHEIGHT/2.8, SCREENWIDTH, 0.5);
    }
    line.backgroundColor=[UIColor blackColor];
    [self.view addSubview:line];
    
    chartTableView=[[UITableView alloc] initWithFrame:CGRectMake(SCREENWIDTH/10+SCREENWIDTH/3, SCREENHEIGHT*5.5/12, SCREENWIDTH*34/60, SCREENWIDTH/2) style:UITableViewStylePlain];
    if (SCREENHEIGHT==480)
    {
        chartTableView.frame=CGRectMake(SCREENWIDTH/10+SCREENWIDTH/3, SCREENHEIGHT*4.5/12, SCREENWIDTH*34/60, SCREENWIDTH/2);
    }
    chartTableView.tag=0;
    chartTableView.scrollEnabled=NO;
    chartTableView.userInteractionEnabled=NO;
    chartTableView.delegate=self;
    chartTableView.dataSource=self;
    [self.view addSubview:chartTableView];
    
    tenDayLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/10+SCREENWIDTH/3, SCREENHEIGHT*5.5/12+SCREENWIDTH/2, SCREENWIDTH*34/60, 30)];
    
    if (SCREENHEIGHT==480)
    {
        tenDayLabel.frame=CGRectMake(SCREENWIDTH/10+SCREENWIDTH/3, SCREENHEIGHT*4.5/12+SCREENWIDTH/2, SCREENWIDTH*34/60, 30);
    }
    tenDayLabel.textAlignment=NSTextAlignmentCenter;
    if (SCREENHEIGHT==480)
    {
        tenDayLabel.font=[UIFont systemFontOfSize:12];
    }
    else if (SCREENHEIGHT==568)
    {
        tenDayLabel.font=[UIFont systemFontOfSize:12];
    }
    else if (SCREENHEIGHT==667)
    {
        tenDayLabel.font=[UIFont systemFontOfSize:14];
    }
    else
    {
        tenDayLabel.font=[UIFont systemFontOfSize:16];
    }
    tenDayLabel.textColor=[UIColor grayColor];
    tenDayLabel.text=@"*Data records are the last 10 assessments";
    tenDayLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:tenDayLabel];
    
    evaluateArray=[NSArray arrayWithObjects:@"PSQI",@"PHQ-9",@"GAD-7", nil];
    MyImageButtonArray=[NSMutableArray array];
}

//根据开始时间跟结束时间选择评估数据，并把数据放入对应数组
-(void)putEvaluateDataToArray
{
    [SleepEvaluate removeAllObjects];
    countGood=0;
    countGeneral=0;
    countBad=0;
    countVeryBad=0;
    if (_patientInfo!=nil)
    {
        for (EvaluateInfo *tmp in evaluateData)
        {
            if (SleepEvaluate.count >= 10) {
                break;
            }
            
            if ([tmp.ListFlag integerValue] == 1 && [_patientInfo.PatientID isEqualToString:tmp.PatientID])
            {
                if ([tmp.Quality isEqualToString:@"睡眠质量很好"] || [tmp.Quality isEqualToString:@"good"])
                {
                    countGood++;
                }
                else if ([tmp.Quality isEqualToString:@"睡眠质量一般"] || [tmp.Quality isEqualToString:@"normal"])
                {
                    countGeneral++;
                }
                else if ([tmp.Quality isEqualToString:@"睡眠质量较差"] || [tmp.Quality isEqualToString:@"poor"])
                {
                    countBad++;
                }
                else if ([tmp.Quality isEqualToString:@"睡眠质量很差"] || [tmp.Quality isEqualToString:@"very poor"])
                {
                    countVeryBad++;
                }
                [SleepEvaluate addObject:tmp];
            }
        }
        if (SleepEvaluate.count==0)
        {
            fatherView=[[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/20, SCREENHEIGHT*6.5/12, SCREENWIDTH/3, SCREENWIDTH/3)];
            if (SCREENHEIGHT==480)
            {
                fatherView.frame=CGRectMake(SCREENWIDTH/20, SCREENHEIGHT*5.5/12, SCREENWIDTH/3, SCREENWIDTH/3);
            }
            fatherView.backgroundColor=[UIColor clearColor];
            circle=[[CircleView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH/3, SCREENWIDTH/3)];
            circle.radiansVeryGood=360;
            circle.radiansGeneral=360;
            circle.radiansBad=360;
            circle.radiansVeryBad=360;
            circle.backgroundColor=[UIColor clearColor];
            [fatherView addSubview:circle];
            [self.view addSubview:fatherView];
        }
        else
        {
            fatherView=[[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/20, SCREENHEIGHT*6.5/12, SCREENWIDTH/3, SCREENWIDTH/3)];
            if (SCREENHEIGHT==480)
            {
                fatherView.frame=CGRectMake(SCREENWIDTH/20, SCREENHEIGHT*5.5/12, SCREENWIDTH/3, SCREENWIDTH/3);
            }
            fatherView.backgroundColor=[UIColor clearColor];
            circle=[[CircleView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH/3, SCREENWIDTH/3)];
            circle.radiansVeryGood=360*countGood/SleepEvaluate.count;
            circle.radiansGeneral=360*(countGood+countGeneral)/SleepEvaluate.count;
            circle.radiansBad=360*(countGood+countGeneral+countBad)/SleepEvaluate.count;
            circle.radiansVeryBad=360;
            circle.backgroundColor=[UIColor clearColor];
            [fatherView addSubview:circle];
            [self.view addSubview:fatherView];
        }
    }
}

//点击弹出view之外的地方清楚弹出的view
-(void)evaluateTapPressGestures
{
    [self addAGrayView];
}

//添加一层半透明灰色的UIview
-(void)addAGrayView
{
    view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    view.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view.window addSubview:view];
    
    MyTableView=[[UITableView alloc] initWithFrame:CGRectMake(SCREENWIDTH/10, SCREENHEIGHT*3/8, SCREENWIDTH*4/5, 120+SCREENHEIGHT/20)];
    [MyTableView.layer setCornerRadius:10.0];
    MyTableView.tag=1;
    MyTableView.backgroundColor=[UIColor whiteColor];
    MyTableView.scrollEnabled=NO;
    MyTableView.delegate=self;
    MyTableView.dataSource=self;
    
    [view.window addSubview:MyTableView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGesture:)];
    [view addGestureRecognizer:tapGesture];
}

//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGesture:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<MyTableView.frame.origin.x || point.x >MyTableView.frame.origin.x+MyTableView.frame.size.width || point.y<MyTableView.frame.origin.y || point.y>MyTableView.frame.origin.y+MyTableView.frame.size.height)
    {
        [MyTableView removeFromSuperview];
        [view removeFromSuperview];
    }
}

#pragma tableview的delegate和dataSource代理方法
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH*4/5, SCREENHEIGHT/20)];
        customView.backgroundColor=[UIColor colorWithRed:0xed/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.highlightedTextColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:20];
        headerLabel.textAlignment=NSTextAlignmentCenter;
        headerLabel.frame =CGRectMake(0, 0, SCREENWIDTH*4/5, SCREENHEIGHT/20);
        
        headerLabel.text = @"Assessment Types";
        
        [customView addSubview:headerLabel];
        return customView;
    }
    else
    {
        return nil;
    }
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        return SCREENHEIGHT/20;
    }
    else
    {
        return 0;
    }
}

//tabeview的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==0)
    {
        return 5;
    }
    else
    {
        return evaluateArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==0)
    {
        static NSString *Identifier = @"ChartCell";
        
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        UILabel *dayCount=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*24/60, 0, SCREENWIDTH/6, SCREENWIDTH/10)];
        dayCount.textAlignment=NSTextAlignmentCenter;
        
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"SleepQuality";
            dayCount.text=@"Days";
        }
        else if (indexPath.row==1)
        {
            cell.textLabel.text=@"Good";
            dayCount.text=[NSString stringWithFormat:@"%d",countGood];
            cell.backgroundColor=[UIColor colorWithRed:0xc6/255.0 green:0xff/255.0 blue:0x8c/255.0 alpha:1];
        }
        else if (indexPath.row==2)
        {
            cell.textLabel.text=@"Mormal";
            dayCount.text=[NSString stringWithFormat:@"%d",countGeneral];
            cell.backgroundColor=[UIColor colorWithRed:0xff/255.0 green:0xf7/255.0 blue:0x8c/255.0 alpha:1];
        }
        else if (indexPath.row==3)
        {
            cell.textLabel.text=@"Poor";
            dayCount.text=[NSString stringWithFormat:@"%d",countBad];
            cell.backgroundColor=[UIColor colorWithRed:0xff/255.0 green:0xd3/255.0 blue:0x87/255.0 alpha:1];
        }
        else if (indexPath.row==4)
        {
            cell.textLabel.text=@"Very Poor";
            dayCount.text=[NSString stringWithFormat:@"%d",countVeryBad];
            cell.backgroundColor=[UIColor colorWithRed:0x8c/255.0 green:0xeb/255.0 blue:0xff/255.0 alpha:1];
        }
        
        if (SCREENWIDTH==320)
        {
            cell.textLabel.font=[UIFont systemFontOfSize:18];
            dayCount.font=[UIFont systemFontOfSize:18];
        }
        else if (SCREENWIDTH==375)
        {
            cell.textLabel.font=[UIFont systemFontOfSize:20];
            dayCount.font=[UIFont systemFontOfSize:20];
        }
        else
        {
            cell.textLabel.font=[UIFont systemFontOfSize:22];
            dayCount.font=[UIFont systemFontOfSize:22];
        }
        
        [cell.contentView addSubview:dayCount];
        
        return cell;
    }
    else
    {
        static NSString *Identifier = @"MyCell";
        
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        //选择框，可用button代替，这样点击选择框也可触发点击事件
        MyImageButton=[[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH*3/5, 0, 30,40)];
        if (indexPath.row == evaluateIndex)
        {
            [MyImageButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        }
        else
        {
            [MyImageButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        }
        MyImageButton.tag=indexPath.row;
        [MyImageButton addTarget:self action:@selector(selectEvaluateTable:) forControlEvents:UIControlEventTouchUpInside];
        [MyImageButtonArray addObject:MyImageButton];
        
        if (SCREENWIDTH==320)
        {
            cell.textLabel.font=[UIFont systemFontOfSize:18];
        }
        else if (SCREENWIDTH==375)
        {
            cell.textLabel.font=[UIFont systemFontOfSize:20];
        }
        else
        {
            cell.textLabel.font=[UIFont systemFontOfSize:22];
        }
        
        cell.textLabel.text=[evaluateArray objectAtIndex:indexPath.row];
        [cell.contentView addSubview:MyImageButton];
        [cell setSelected:YES animated:YES];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==0)
    {
        return SCREENWIDTH/10;
    }
    else
    {
        return 40;
    }
}

-(void)selectEvaluateTable:(UIButton *)sender
{
    if (sender.tag==0)
    {
        //跳转到AssessmentViewController界面，并传递睡眠评估量表的相关数据
        AssessmentViewController *sleepAssessment=[[AssessmentViewController alloc] init];
        sleepAssessment.tableListTag=1;
        sleepAssessment.patientInfo=_patientInfo;
        [self.navigationController pushViewController:sleepAssessment animated:YES];
        [MyTableView removeFromSuperview];
        [view removeFromSuperview];
    }
    else if (sender.tag==1)
    {
        //跳转到AssessmentViewController界面，并传递抑郁评估量表的相关数据
        AssessmentViewController *depressedAssessment=[[AssessmentViewController alloc] init];
        depressedAssessment.tableListTag=2;
        depressedAssessment.patientInfo=_patientInfo;
        [self.navigationController pushViewController:depressedAssessment animated:YES];
        [MyTableView removeFromSuperview];
        [view removeFromSuperview];
    }
    else if (sender.tag==2)
    {
        //跳转到AssessmentViewController界面，并传递焦虑评估量表的相关数据
        AssessmentViewController *worriedAssessment=[[AssessmentViewController alloc] init];
        worriedAssessment.tableListTag=3;
        worriedAssessment.patientInfo=_patientInfo;
        [self.navigationController pushViewController:worriedAssessment animated:YES];
        [MyTableView removeFromSuperview];
        [view removeFromSuperview];
    }
    else if (sender.tag==3)
    {
        //跳转到AssessmentViewController界面，并传递躯体评估量表的相关数据
        AssessmentViewController *bodyAssessment=[[AssessmentViewController alloc] init];
        bodyAssessment.tableListTag=4;
        bodyAssessment.patientInfo=_patientInfo;
        [self.navigationController pushViewController:bodyAssessment animated:YES];
        [MyTableView removeFromSuperview];
        [view removeFromSuperview];
    }
    evaluateIndex=sender.tag;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1)
    {
        if (indexPath.row==0)
        {
            //跳转到AssessmentViewController界面，并传递睡眠评估量表的相关数据
            AssessmentViewController *sleepAssessment=[[AssessmentViewController alloc] init];
            sleepAssessment.tableListTag=1;
            sleepAssessment.patientInfo=_patientInfo;
            [self.navigationController pushViewController:sleepAssessment animated:YES];
            [MyTableView removeFromSuperview];
            [view removeFromSuperview];
        }
        else if (indexPath.row==1)
        {
            //跳转到AssessmentViewController界面，并传递抑郁评估量表的相关数据
            AssessmentViewController *depressedAssessment=[[AssessmentViewController alloc] init];
            depressedAssessment.tableListTag=2;
            depressedAssessment.patientInfo=_patientInfo;
            [self.navigationController pushViewController:depressedAssessment animated:YES];
            [MyTableView removeFromSuperview];
            [view removeFromSuperview];
        }
        else if (indexPath.row==2)
        {
            //跳转到AssessmentViewController界面，并传递焦虑评估量表的相关数据
            AssessmentViewController *worriedAssessment=[[AssessmentViewController alloc] init];
            worriedAssessment.tableListTag=3;
            worriedAssessment.patientInfo=_patientInfo;
            [self.navigationController pushViewController:worriedAssessment animated:YES];
            [MyTableView removeFromSuperview];
            [view removeFromSuperview];
        }
        else if (indexPath.row==3)
        {
            //跳转到AssessmentViewController界面，并传递躯体评估量表的相关数据
            AssessmentViewController *bodyAssessment=[[AssessmentViewController alloc] init];
            bodyAssessment.tableListTag=4;
            bodyAssessment.patientInfo=_patientInfo;
            [self.navigationController pushViewController:bodyAssessment animated:YES];
            [MyTableView removeFromSuperview];
            [view removeFromSuperview];
        }
        evaluateIndex=indexPath.row;
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
