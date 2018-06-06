//
//  DoctorTypeViewController.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/5/10.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "DoctorTypeViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>

#import "DataHandle.h"
#import "QuestionTypeModel.h"
#import "QuestionTypeTableViewCell.h"

#import "SymptomDescViewController.h"
#import "CustomerChatViewController.h"

@interface DoctorTypeViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation DoctorTypeViewController
{
    NSString *clickType; //点击了哪种类型
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"问题类型选择"];
    
    [self getQuestionData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"问题类型选择"];
}

- (void)getQuestionData
{
    DataHandle *handle = [[DataHandle alloc] init];
    NSMutableURLRequest *req = [handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetAnsweringQuestions) andPrimaryKey:[PatientInfo shareInstance].PatientID];
    req.timeoutInterval = 3.0;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    if (data)
    {
        _questionArray = [handle objectFromeResponseString:data andType:(DataModelBackTypeGetAnsweringQuestions)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"问题类型选择";
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
    
    [self prepareDataForTable];
    [self createTypeTableView];
}

#pragma mark -- 返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES]; //跳转
}

- (void)prepareDataForTable
{
    QuestionTypeModel *insomniaModel = [[QuestionTypeModel alloc] init];
    insomniaModel.typeImageName = @"insomniaType";
    insomniaModel.typeStr = @"失眠";
    insomniaModel.typeIntroduceStr = @"失眠是指患者对睡眠时间和（或）质量不满足并影响日间社会功能的一种主观体验";
    
    QuestionTypeModel *depressedModel = [[QuestionTypeModel alloc] init];
    depressedModel.typeImageName = @"depresedType";
    depressedModel.typeStr = @"抑郁";
    depressedModel.typeIntroduceStr = @"抑郁症又称抑郁障碍，以显著而持久的心境低落为主要临床特征，是心境障碍的主要类型";
    
    QuestionTypeModel *anxiousModel = [[QuestionTypeModel alloc] init];
    anxiousModel.typeImageName = @"anxiousType";
    anxiousModel.typeStr = @"焦虑";
    anxiousModel.typeIntroduceStr = @"焦虑症又称焦虑性神经症，是神经症这一大类疾病中最常见的一种，以焦虑情绪体验为主要特征";
    
    QuestionTypeModel *otherModel = [[QuestionTypeModel alloc] init];
    otherModel.typeImageName = @"otherType";
    otherModel.typeStr = @"其他";
    otherModel.typeIntroduceStr = @"躯体化障碍是一种以持久的担心或相信各种躯体症状的优势观念为特征的一组神经症";
    
    _dataArray = @[insomniaModel, depressedModel, anxiousModel, otherModel];
}

- (void)createTypeTableView
{
    UITableView *typeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:UITableViewStylePlain];
    typeTableView.showsVerticalScrollIndicator = NO;
    typeTableView.showsHorizontalScrollIndicator = NO;
    
    typeTableView.delegate = self;
    typeTableView.dataSource = self;
    [self.view addSubview:typeTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"QuestionTypeCellID%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    QuestionTypeTableViewCell *cell = [[QuestionTypeTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = _dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        clickType = @"mian123456";
        if ([self judgeAskJurisdiction:@"mian123456"])
        {
            SymptomDescViewController *writeVC = [[SymptomDescViewController alloc] init];
            writeVC.currentID = @"mian123456";
            [self.navigationController pushViewController:writeVC animated:YES];
        }
        else
        {
//            UIAlertView *alerV = [[UIAlertView alloc] initWithTitle:@"向医生提问" message:@"您当前正在问答的会话未结束，是否前往当前会话？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往", nil];
//            [alerV show];
            
            [self jumpToCustomerChatViewController];
        }
    }
    else if (indexPath.row == 1)
    {
        clickType = @"yu123456";
        if ([self judgeAskJurisdiction:@"yu123456"])
        {
            SymptomDescViewController *writeVC = [[SymptomDescViewController alloc] init];
            writeVC.currentID = @"yu123456";
            [self.navigationController pushViewController:writeVC animated:YES];
        }
        else
        {
//            UIAlertView *alerV = [[UIAlertView alloc] initWithTitle:@"向医生提问" message:@"您当前正在问答的会话未结束，是否前往当前会话？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往", nil];
//            [alerV show];
            
            [self jumpToCustomerChatViewController];
        }
    }
    else if (indexPath.row == 2)
    {
        clickType = @"lv123456";
        if ([self judgeAskJurisdiction:@"lv123456"])
        {
            SymptomDescViewController *writeVC = [[SymptomDescViewController alloc] init];
            writeVC.currentID = @"lv123456";
            [self.navigationController pushViewController:writeVC animated:YES];
        }
        else
        {
//            UIAlertView *alerV = [[UIAlertView alloc] initWithTitle:@"向医生提问" message:@"您当前正在问答的会话未结束，是否前往当前会话？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往", nil];
//            [alerV show];
            
            [self jumpToCustomerChatViewController];
        }
    }
    else if (indexPath.row == 3)
    {
        clickType = @"ta123456";
        if ([self judgeAskJurisdiction:@"ta123456"])
        {
            SymptomDescViewController *writeVC = [[SymptomDescViewController alloc] init];
            writeVC.currentID = @"ta123456";
            [self.navigationController pushViewController:writeVC animated:YES];
        }
        else
        {
//            UIAlertView *alerV = [[UIAlertView alloc] initWithTitle:@"向医生提问" message:@"您当前正在问答的会话未结束，是否前往当前会话？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往", nil];
//            [alerV show];
            
            [self jumpToCustomerChatViewController];
        }
    }
}

- (void)jumpToCustomerChatViewController
{
    NSDictionary *clickDic;
    for (NSDictionary *tmpDic in _questionArray)
    {
        if ([[tmpDic objectForKey:@"DoctorID"] isEqualToString:clickType])
        {
            clickDic = tmpDic;
        }
    }
    //前往正在问答的界面
    CustomerChatViewController *consultView = [[CustomerChatViewController alloc] initWithConversationChatter:clickType];
    consultView.questionID = [clickDic objectForKey:@"QuestionID"];
    NSLog(@"%@",[clickDic objectForKey:@"QuestionID"]);
    consultView.isAsking = YES;
    [self.navigationController pushViewController:consultView animated:YES];
}

- (BOOL)judgeAskJurisdiction:(NSString *)docID
{
    if (_questionArray.count == 0 || _questionArray == nil)
    {
        return YES;
    }
    else
    {
        BOOL notContain = YES;
        for (NSDictionary *tmpDic in _questionArray)
        {
            if ([[tmpDic objectForKey:@"DoctorID"] isEqualToString:docID])
            {
                notContain = NO;
            }
        }
        
        return notContain;
    }
}

//#pragma mark -- delegateForAlertView
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0)
//    {
//        
//    }
//    else
//    {
//        NSDictionary *clickDic;
//        for (NSDictionary *tmpDic in _questionArray)
//        {
//            if ([[tmpDic objectForKey:@"DoctorID"] isEqualToString:clickType])
//            {
//                clickDic = tmpDic;
//            }
//        }
//        //前往正在问答的界面
//        CustomerChatViewController *consultView = [[CustomerChatViewController alloc] initWithConversationChatter:clickType];
//        consultView.questionID = [clickDic objectForKey:@"QuestionID"];
//        NSLog(@"%@",[clickDic objectForKey:@"QuestionID"]);
//        consultView.isAsking = YES;
//        consultView.patientInfo = _patientInfo;
//        [self.navigationController pushViewController:consultView animated:YES];
//    }
//}

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
