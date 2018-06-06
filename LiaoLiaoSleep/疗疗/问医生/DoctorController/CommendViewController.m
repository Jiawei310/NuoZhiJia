//
//  CommendViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/7.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "CommendViewController.h"

#import "Define.h"
#import "DataHandle.h"
#import "FunctionHelper.h"
#import "UIImageView+EMWebCache.h"
#import <UMMobClick/MobClick.h>

#import "DoctorInfoModel.h"

#import "MyQuestionsViewController.h"

@interface CommendViewController ()<UITextViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIView *displayV;
@property (strong, nonatomic) UITextView *textV;
@property (copy, nonatomic) DoctorInfoModel *model;
@property (copy, nonatomic) DataHandle *handle;
@property (copy, nonatomic) NSString *star;

@end

@implementation CommendViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:@"医生评论"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [MobClick endLogPageView:@"医生评论"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];//在这里注册通知
    _patientID = [EMClient sharedClient].currentUsername;
    _handle = [[DataHandle alloc] init];
    _star = @"0";
    [self prepareData];
    [self createView];
    [self createButton];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareData
{
    NSData *doctorData = [_handle getDataFromNetWorkWithStringType:(DataModelBackTypeGetDoctorInfo) andPrimaryKey:_doctorID];
    NSArray *temp = [_handle objectFromeResponseString:doctorData andType:(DataModelBackTypeGetDoctorInfo)];
    for (NSDictionary *dic in temp)
    {
        _model = [[DoctorInfoModel alloc] initWithDictionary:dic];
    }
}

- (void)createView
{
    _displayV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 466*Rate_NAV_H)];
    _displayV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_displayV];
    
    UIImageView *headerImage = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 70*Rate_NAV_H)/2, 19*Rate_NAV_H, 70*Rate_NAV_H, 70*Rate_NAV_H)];
    [headerImage sd_setImageWithURL:[NSURL URLWithString:_model.doctorIcon] placeholderImage:[UIImage imageNamed:@"headerImage_doctor.png"]];
    headerImage.layer.cornerRadius = 35*Rate_NAV_H;
    headerImage.clipsToBounds = YES;
    [_displayV addSubview:headerImage];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 94*Rate_NAV_H, 175*Rate_NAV_W, 28*Rate_NAV_H)];
    name.text = _model.doctorName;
    name.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    name.textAlignment = NSTextAlignmentCenter;
    name.font = [UIFont systemFontOfSize:20*Rate_NAV_H];
    [_displayV addSubview:name];
    
    UILabel *hospital = [[UILabel alloc] initWithFrame:CGRectMake(0, 127*Rate_NAV_H, SCREENWIDTH, 20*Rate_NAV_H)];
    hospital.text = _model.doctorHospital;
    hospital.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    hospital.textAlignment = NSTextAlignmentCenter;
    hospital.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    [_displayV addSubview:hospital];
    
    for (int i = 0; i < 5; i++)
    {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake((120 + 21*i)*Rate_NAV_W, 154*Rate_NAV_H, 13*Rate_NAV_H, 13*Rate_NAV_H)];
        if (i < [_model.doctorStar intValue])
        {
            star.image = [UIImage imageNamed:@"star_in.png"];
        }
        else
        {
            star.image = [UIImage imageNamed:@"star.png"];
        }
        [_displayV addSubview:star];
    }
    
    UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(229*Rate_NAV_W, 154*Rate_NAV_H, 146*Rate_NAV_W, 14*Rate_NAV_H)];
    count.text = [NSString stringWithFormat:@"(%@)",_model.commentCount];
    count.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    count.textAlignment = NSTextAlignmentLeft;
    [_displayV addSubview:count];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 192*Rate_NAV_H, SCREENWIDTH, Rate_NAV_H)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0].CGColor;
    [_displayV addSubview:line];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(0, 210*Rate_NAV_H, SCREENWIDTH, 25*Rate_NAV_H)];
    notice.textAlignment = NSTextAlignmentCenter;
    notice.text = [NSString stringWithFormat:@"请为%@医师的回答打分",_model.doctorName];
    notice.font = [UIFont systemFontOfSize:18*Ratio];
    [_displayV addSubview:notice];
    
    for (int i = 0; i < 5; i++)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((118 + 29*i)*Rate_NAV_W, 245*Rate_NAV_H, 20*Rate_NAV_H, 20*Rate_NAV_H)];
        btn.tag = 101+i;
        [btn setBackgroundImage:[UIImage imageNamed:@"img_star_hollow.png"] forState:(UIControlStateNormal)];
        [btn addTarget:self action:@selector(star:) forControlEvents:(UIControlEventTouchUpInside)];
        [_displayV addSubview:btn];
    }
    _comment.commentStar = [NSString stringWithFormat:@"%i",0];
    
    _textV = [[UITextView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 292*Rate_NAV_H, 345*Rate_NAV_W, 150*Rate_NAV_H)];
    _textV.delegate = self;
    _textV.layer.borderColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0].CGColor;
    _textV.layer.borderWidth = 1;
    [_displayV addSubview:_textV];
}

#pragma mark -- 打分
- (void)star:(UIButton *)btn
{
    _star = [NSString stringWithFormat:@"%li",btn.tag-100];
    for (int i = 0; i < btn.tag-100; i++)
    {
        UIButton *btn = (UIButton *)[_displayV viewWithTag:i+101];
        [btn setBackgroundImage:[UIImage imageNamed:@"img_star_solid.png"] forState:(UIControlStateNormal)];
    }
    
    for (int i = (int)(btn.tag-100); i < 5; i++)
    {
        UIButton *btn = (UIButton *)[_displayV viewWithTag:i+101];
        [btn setBackgroundImage:[UIImage imageNamed:@"img_star_hollow.png"] forState:(UIControlStateNormal)];
    }
}

#pragma mark -- textViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    _comment.commentContent = textView.text;
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    //该判断用于联想输入
    if (textView.text.length > 100){
        textView.text = [textView.text substringToIndex:100];
    }
    _comment.commentContent = textView.text;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_textV resignFirstResponder];
}

#pragma mark -- 创建提交按钮
- (void)createButton
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 510*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [btn setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
    btn.layer.cornerRadius = 25*Rate_NAV_H;
    btn.clipsToBounds = YES;
    [btn setTitle:@"提交评价" forState:(UIControlStateNormal)];
    btn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [btn addTarget:self action:@selector(submit) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
}

#pragma mark -- 提交评论
- (void)submit
{
    //判断网络连接
    if ([FunctionHelper isExistenceNetwork])
    {
        if ([_textV.text isEqual:@""])
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提交评论" message:@"请填写评论信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSLog(@"doctor ----- %@",_patientID);
            NSData * uploadData =  [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadCommendInfo) andDictionary:@{@"DoctorID":_doctorID,
                                                                                                                                    @"CommentID":[NSString stringWithFormat:@"%@_%@",_patientID,[FunctionHelper getNowTimeInterval]],
                                                                                                                             @"PatientID":_patientID,
                                                                                                                             @"CommentTime":[self getCurrentTime],
                                                                                                                             @"CommentContent":_textV.text,
                                                                                                                             @"CommentStar":_star}];
            //医生的五星评价数加1
            if([_star intValue] == 5)
            {
                [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadAnswerCountOrFullStar) andDictionary:@{@"DoctorID":_doctorID,@"AnswerCount":@"0",@"FullStarCount":@"1"}];
            }
            if ([[_handle objectFromeResponseString:uploadData andType:(DataModelBackTypeUploadCommendInfo)] isEqualToString:@"OK"])
            {
                [_displayV removeFromSuperview];
                [self createCommentSuccess];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"服务器出错" message:@"评价提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"网络出错" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)createCommentSuccess
{
    self.navigationItem.title = @"评价成功";
    _displayV = [[UIView alloc] initWithFrame:self.view.bounds];
    _displayV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_displayV];
    
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 90*Rate_NAV_H, SCREENWIDTH, 30*Rate_NAV_H)];
    lable1.text = @"感谢您的评价！";
    lable1.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    lable1.textAlignment = NSTextAlignmentCenter;
    lable1.font = [UIFont systemFontOfSize:24*Rate_NAV_H];
    [_displayV addSubview:lable1];
    
    UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(100*Rate_NAV_W, 140*Rate_NAV_H, 90*Rate_NAV_W, 25*Rate_NAV_H)];
    lable2.text = @"您的积分:";
    lable2.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    lable2.textAlignment = NSTextAlignmentCenter;
    lable2.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_displayV addSubview:lable2];
    
    UILabel *lable3 = [[UILabel alloc] initWithFrame:CGRectMake(200*Rate_NAV_W, 140*Rate_NAV_H, 40*Rate_NAV_H, 25*Rate_NAV_H)];
    lable3.text = @"+10";
    lable3.textColor = [UIColor redColor];
    lable3.textAlignment = NSTextAlignmentCenter;
    lable3.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_displayV addSubview:lable3];
    
    UILabel *lable4 = [[UILabel alloc] initWithFrame:CGRectMake(255*Rate_NAV_W, 140*Rate_NAV_H, 25*Rate_NAV_W, 25*Rate_NAV_H)];
    lable4.text = @"分";
    lable4.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    lable4.textAlignment = NSTextAlignmentCenter;
    lable4.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_displayV addSubview:lable4];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(106*Rate_NAV_W, 250*Rate_NAV_H, 163*Rate_NAV_W, 159*Rate_NAV_H)];
    icon.image = [UIImage imageNamed:@"icon_score.png"];
    [_displayV addSubview:icon];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(22*Rate_NAV_W, 510*Rate_NAV_H, 331*Rate_NAV_W, 50*Rate_NAV_H)];
    [btn setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
    btn.layer.cornerRadius = 25*Rate_NAV_H;
    btn.clipsToBounds = YES;
    [btn setTitle:@"完成" forState:(UIControlStateNormal)];
    btn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [btn addTarget:self action:@selector(complete) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
}

#pragma mark -- 完成
- (void)complete
{
    if (_isJump)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[MyQuestionsViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}

#pragma mark -- 获取当前时间
- (NSString *)getCurrentTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate dateWithTimeInterval:10 sinceDate:[NSDate date]]];
    return dateTime;
}

#pragma mark - 监听键盘方法
/**
 * 键盘的frame发生改变时调用（显示、隐藏等）
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    //取出键盘动画的时间(根据userInfo的key----UIKeyboardAnimationDurationUserInfoKey)
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //取得键盘最后的frame(根据userInfo的key----UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 227}, {320, 253}}";)
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //计算控制器的view需要平移的距离
    CGFloat transformY;
    if (self.view.frame.origin.y == 0)
    {
        transformY = keyboardFrame.origin.y - (self.view.frame.size.height);
    }
    else
    {
        transformY = keyboardFrame.origin.y - (self.view.frame.size.height+64);
    }
    //执行动画
    [UIView animateWithDuration:duration animations:^{
        //平移
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
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
