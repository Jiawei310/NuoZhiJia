//
//  GaugeTestViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/11/10.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "GaugeTestViewController.h"

#import "Define.h"

#import "InterfaceModel.h"

#import "TimePickView.h"
#import "FragmentView.h"
#import "ResultView.h"
#import "JXTAlertManagerHeader.h"
#import <UShareUI/UShareUI.h>
#import <UMMobClick/MobClick.h>

static NSString* const UMS_Title = @"【友盟+】社会化组件U-Share";
static NSString* const UMS_Prog_Title = @"【友盟+】U-Share小程序";
static NSString* const UMS_Text = @"欢迎使用【友盟+】社会化组件U-Share，SDK包最小，集成成本最低，助力您的产品开发、运营与推广！";
static NSString* const UMS_Text_image = @"i欢迎使用【友盟+】社会化组件U-Share，SDK包最小，集成成本最低，助力您的产品开发、运营与推广！";
static NSString* const UMS_Web_Desc = @"W欢迎使用【友盟+】社会化组件U-Share，SDK包最小，集成成本最低，助力您的产品开发、运营与推广！";
static NSString* const UMS_Music_Desc = @"M欢迎使用【友盟+】社会化组件U-Share，SDK包最小，集成成本最低，助力您的产品开发、运营与推广！";
static NSString* const UMS_Video_Desc = @"V欢迎使用【友盟+】社会化组件U-Share，SDK包最小，集成成本最低，助力您的产品开发、运营与推广！";

static NSString* const UMS_THUMB_IMAGE = @"https://mobile.umeng.com/images/pic/home/social/img-1.png";
static NSString* const UMS_IMAGE = @"https://mobile.umeng.com/images/pic/home/social/img-1.png";

static NSString* const UMS_WebLink = @"https://bbs.umeng.com/";

static NSString *UMS_SHARE_TBL_CELL = @"UMS_SHARE_TBL_CELL";

typedef NS_ENUM(NSUInteger, UMS_SHARE_TYPE)
{
    UMS_SHARE_TYPE_TEXT,
    UMS_SHARE_TYPE_IMAGE,
    UMS_SHARE_TYPE_IMAGE_URL,
    UMS_SHARE_TYPE_TEXT_IMAGE,
    UMS_SHARE_TYPE_WEB_LINK,
    UMS_SHARE_TYPE_MUSIC_LINK,
    UMS_SHARE_TYPE_MUSIC,
    UMS_SHARE_TYPE_VIDEO_LINK,
    UMS_SHARE_TYPE_VIDEO,
    UMS_SHARE_TYPE_EMOTION,
    UMS_SHARE_TYPE_FILE,
    UMS_SHARE_TYPE_MINI_PROGRAM
};


@interface GaugeTestViewController ()

@property (strong, nonatomic) UIButton *backLogin;//返回按钮

@property (strong, nonatomic) UIImageView *bedImageView;
@property (strong, nonatomic) UIProgressView *questionProgress;
@property (strong, nonatomic) UILabel *questionLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *alertLabel;
@property (strong, nonatomic) UIButton *beforeBtn;
@property (strong, nonatomic) UIButton *continueBtn;

@property (nonatomic, assign) NSInteger questionIndex;

@property (nonatomic, strong) TimePickView *timePV_M;
@property (nonatomic, strong) TimePickView *timePV_H;
@property (nonatomic, strong) TimePickView *timePV_MH1;
@property (nonatomic, strong) TimePickView *timePV_MH2;
@property (nonatomic, strong) FragmentView *fragmentV;

@end

@implementation GaugeTestViewController
{
    UIView *view;  //界面的蒙板view
    
    NSMutableArray *resultArray;           //存储量表测试选项的结果
    NSMutableArray *initArray;                    //存储选择的量表初始化数组
    
    NSMutableArray *fragmentBtnArray;      //存储碎片化搜集的选项按钮
    NSMutableArray *fragmentLbArray;       //存储碎片化搜集的选项按钮下方显示label的数组
    NSMutableArray *pittsburghPointBtnArray;    //存储匹兹堡睡眠指数量表第15题到第十八题的point按钮数组
    NSMutableArray *pittsburghTitleBtnArray;    //存储匹兹堡睡眠指数量表第15题到第十八题的Title按钮数组
    
    NSMutableArray *depressedAndAnxiousPointBtnArray;    //存储抑郁、焦虑自评量表的point按钮数组
    NSMutableArray *depressedAndAnxiousTitleBtnArray;    //存储抑郁、焦虑自评量表的Title按钮数组
    
    NSMutableArray *bodyPointBtnArray;    //存储躯体自评量表的point按钮数组
    NSMutableArray *bodyTitleBtnArray;    //存储躯体自评量表的Title按钮数组
    
    ResultView *resultV;
    
    UIImage *screenTmp;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.hidden = YES;
    
    [MobClick beginLogPageView:_typeStr];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:_typeStr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeView];
    
    //数组初始化
    if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
    {
        self.navigationItem.title = @"匹兹堡睡眠指数";
        _bedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(122*Rate_NAV_W, 49*Rate_NAV_H, 186*Rate_NAV_H, 53*Rate_NAV_H)];
        _bedImageView.image = [UIImage imageNamed:@"icon_bed"];
        [self.view addSubview:_bedImageView];
        
        initArray = [NSMutableArray arrayWithObjects:@"21:30",@"30",@"07:30",@"7",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4", nil];
        resultArray = initArray;
        
        fragmentBtnArray = [NSMutableArray array];
        fragmentLbArray = [NSMutableArray array];
        pittsburghPointBtnArray = [NSMutableArray array];
        pittsburghTitleBtnArray = [NSMutableArray array];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35*Rate_NAV_W, 490*Rate_NAV_H, 90*Rate_NAV_W, 25*Rate_NAV_H)];
        _timeLabel.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
        _timeLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_timeLabel];
    }
    else if ([_typeStr isEqualToString:@"抑郁自评"])
    {
        self.navigationItem.title = @"抑郁自评";
        initArray = [NSMutableArray arrayWithObjects:@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4", nil];
        resultArray = initArray;
        
        depressedAndAnxiousPointBtnArray = [NSMutableArray array];
        depressedAndAnxiousTitleBtnArray = [NSMutableArray array];
    }
    else if ([_typeStr isEqualToString:@"焦虑自评"])
    {
        self.navigationItem.title = @"焦虑自评";
        initArray = [NSMutableArray arrayWithObjects:@"4",@"4",@"4",@"4",@"4",@"4",@"4", nil];
        resultArray = initArray;
        
        depressedAndAnxiousPointBtnArray = [NSMutableArray array];
        depressedAndAnxiousTitleBtnArray = [NSMutableArray array];
    }
    else if ([_typeStr isEqualToString:@"躯体自评"])
    {
        self.navigationItem.title = @"躯体自评";
        initArray = [NSMutableArray arrayWithObjects:@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4",@"4", nil];
        resultArray = initArray;
        
        bodyPointBtnArray = [NSMutableArray array];
        bodyTitleBtnArray = [NSMutableArray array];
    }
    
    //添加返回按钮
    _backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    _backLogin.frame = CGRectMake(12, 30, 46, 23);
    [_backLogin setTitle:@"结束" forState:UIControlStateNormal];
    [_backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:_backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    
    //全局变量questionIndex的初始化赋值
    _questionIndex = 0;
    [self setQuestionIndex:_questionIndex];
}

/*
 * 初始化控件
 */
- (void)initializeView
{
    //1.进度条控件
    _questionProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 424*Rate_NAV_H, SCREENWIDTH, 2)];
    _questionProgress.progressTintColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    _questionProgress.trackTintColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    [self.view addSubview:_questionProgress];
    //2.题目
    _questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 436*Rate_NAV_H, 345*Rate_NAV_W, 50*Rate_NAV_H)];
    _questionLabel.textColor = [UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1];
    _questionLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    _questionLabel.numberOfLines = 0;
    [self.view addSubview:_questionLabel];
    //4.提示
    _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(270*Rate_NAV_W, 490*Rate_NAV_H, 90*Rate_NAV_W, 15*Rate_NAV_H)];
    _alertLabel.textColor = [UIColor colorWithRed:0x3D/255.0 green:0xD8/255.0 blue:0xC1/255.0 alpha:1];
    _alertLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    _alertLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_alertLabel];
    //5.上一题
    _beforeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _beforeBtn.frame = CGRectMake(166*Rate_NAV_W, 505*Rate_NAV_H, 44*Rate_NAV_W, 20*Rate_NAV_H);
    [_beforeBtn setTitleColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1] forState:UIControlStateNormal];
    _beforeBtn.titleLabel.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_beforeBtn setTitle:@"上一题" forState:UIControlStateNormal];
    [_beforeBtn addTarget:self action:@selector(beforeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_beforeBtn];
    //6.继续
    _continueBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _continueBtn.frame = CGRectMake(68*Rate_NAV_W, 538*Rate_NAV_H, 240*Rate_NAV_W, 50*Rate_NAV_H);
    [_continueBtn setBackgroundImage:[UIImage imageNamed:@"test_btn_bg"] forState:UIControlStateNormal];
    [_continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _continueBtn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_NAV_H];
    [_continueBtn setTitle:@"继续" forState:UIControlStateNormal];
    [_continueBtn addTarget:self action:@selector(continueBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_continueBtn];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//全局变量questionIndex的set方法，每当其值变化时调用一次
- (void)setQuestionIndex:(NSInteger)questionIndex
{
    //“上一题”按钮在questionIndex＝0的时候，第一题不显示
    if (questionIndex == 0)
    {
        _beforeBtn.hidden = YES;
    }
    else if (questionIndex > 0)
    {
        _beforeBtn.hidden = NO;
    }
    //设置进度条进度
    _questionProgress.progress = (float)(questionIndex + 1)/initArray.count;
    //问题显示
    if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
    {
        [self createPittsburghScale:questionIndex];
        if (_questionIndex >= 4 && _questionIndex <= 13)
        {
            self.questionLabel.text = @"5-14. 近一个月，因下列情况影响睡眠而烦恼";
        }
        else
        {
            self.questionLabel.text = [_questionArray objectAtIndex:questionIndex];
        }
    }
    else if ([_typeStr isEqualToString:@"抑郁自评"])
    {
        self.questionLabel.text = [_questionArray objectAtIndex:questionIndex];
        [self createDepressedAndAnxiousScale:questionIndex];
    }
    else if ([_typeStr isEqualToString:@"焦虑自评"])
    {
        self.questionLabel.text = [_questionArray objectAtIndex:questionIndex];
        [self createDepressedAndAnxiousScale:questionIndex];
    }
    else if ([_typeStr isEqualToString:@"躯体自评"])
    {
        self.questionLabel.text = [_questionArray objectAtIndex:questionIndex];
        [self createBodyScale:questionIndex];
    }
    //设置字间距
    NSDictionary *dic = @{NSKernAttributeName:@0.5f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:self.questionLabel.text attributes:dic];
    self.questionLabel.attributedText = attributeStr;
    
    CGSize adviseContentLabelSize = [_questionLabel sizeThatFits:CGSizeMake(345*Rate_NAV_W, MAXFLOAT)];
    _questionLabel.frame = CGRectMake(_questionLabel.frame.origin.x, _questionLabel.frame.origin.y, self.questionLabel.frame.size.width, adviseContentLabelSize.height);
    
    if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
    {
        if (questionIndex == 0)
        {
            _timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x, self.questionLabel.frame.origin.y+adviseContentLabelSize.height+4, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
            _timeLabel.text = [resultArray objectAtIndex:0];
            _timeLabel.hidden = NO;
        }
        else if (questionIndex == 1)
        {
            _timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x, self.questionLabel.frame.origin.y+adviseContentLabelSize.height+4, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
            NSString *strTmp = [resultArray objectAtIndex:1];
            if ([strTmp isEqualToString:@"1"])
            {
                _timeLabel.text = @"1小时";
            }
            else
            {
                _timeLabel.text = [NSString stringWithFormat:@"%@分钟",strTmp];
            }
            _timeLabel.hidden = NO;
        }
        else if (questionIndex == 2)
        {
            _timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x, self.questionLabel.frame.origin.y+adviseContentLabelSize.height+4, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
            _timeLabel.text = [resultArray objectAtIndex:2];
            _timeLabel.hidden = NO;
        }
        else if (questionIndex == 3)
        {
            _timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x, self.questionLabel.frame.origin.y+adviseContentLabelSize.height+4, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
            _timeLabel.text = [NSString stringWithFormat:@"%@小时",[resultArray objectAtIndex:3]];
            _timeLabel.hidden = NO;
        }
        else
        {
            _timeLabel.hidden = YES;
        }
    }
    else
    {
        _timeLabel.hidden = YES;
    }
    
    _alertLabel.frame = CGRectMake(_alertLabel.frame.origin.x, _questionLabel.frame.origin.y+adviseContentLabelSize.height+4, _alertLabel.frame.size.width, _alertLabel.frame.size.height);
    if (questionIndex == initArray.count/2)
    {
        _alertLabel.text = @"做了快一半了";
        _alertLabel.hidden = NO;
    }
    else if (questionIndex == initArray.count - 4)
    {
        _alertLabel.text = @"就快结束了";
        _alertLabel.hidden = NO;
    }
    else if (questionIndex == initArray.count - 3)
    {
        _alertLabel.text = @"还有两题了";
        _alertLabel.hidden = NO;
    }
    else if (questionIndex == initArray.count - 2)
    {
        _alertLabel.text = @"马上完成了";
        _alertLabel.hidden = NO;
    }
    else if (questionIndex == initArray.count - 1)
    {
        _alertLabel.text = @"终于做完了";
        _alertLabel.hidden = NO;
    }
    else
    {
        _alertLabel.hidden = YES;
    }
}

//”上一题“按钮的点击事件
- (IBAction)beforeBtnClick:(UIButton *)sender
{
    if (_questionIndex > 0)
    {
        if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
        {
            if (_questionIndex == 14)
            {
                _questionIndex -= 10;
            }
            else
            {
                _questionIndex--;
            }
        }
        else
        {
            _questionIndex--;
        }
        
        [self setQuestionIndex:_questionIndex];
    }
    else
    {
        //此时是第一题
    }
}

//“继续”按钮的点击事件
- (IBAction)continueBtnClick:(UIButton *)sender
{
    if (_questionIndex < _questionArray.count - 1)
    {
        if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
        {
            if (_questionIndex == 4)
            {
                _questionIndex += 10;
            }
            else
            {
                if (_questionIndex >= 14)
                {
                    NSString *str = [resultArray objectAtIndex:_questionIndex];
                    if ([str integerValue] == 4)
                    {
                        //提示未作答
                        //提示答完这题才可进入下一题
                        jxt_showTextHUDTitleMessage(@"温馨提示", @"请先答完该题");
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            jxt_dismissHUD();
                        });
                    }
                    else
                    {
                        _questionIndex++;
                    }
                }
                else
                {
                    _questionIndex++;
                }
            }
        }
        else
        {
            NSString *str = [resultArray objectAtIndex:_questionIndex];
            if ([str integerValue] == 4)
            {
                //提示未作答
                //提示答完这题才可进入下一题
                jxt_showTextHUDTitleMessage(@"温馨提示", @"请先答完该题");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    jxt_dismissHUD();
                });
            }
            else
            {
                _questionIndex++;
            }
        }
        
        [self setQuestionIndex:_questionIndex];
    }
    else
    {
        NSString *str = [resultArray objectAtIndex:_questionIndex];
        if ([str integerValue] == 4)
        {
            //提示未作答
            //提示答完这题才可进入下一题
            jxt_showTextHUDTitleMessage(@"温馨提示", @"请先答完该题");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
        else
        {
            NSString *dateStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Point",_typeStr]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            NSString *currentDateStr = [df stringFromDate:[NSDate date]];
            if (![currentDateStr isEqualToString:dateStr])
            {
                [self integralUpdate];
            }
            //当前是最后一题
            resultV = [[ResultView alloc] initWithScaleData:resultArray andType:_typeStr andPatientInfo:[PatientInfo shareInstance] andFlag:_typeFlag];
            resultV.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
            [self.view addSubview:resultV];
            
            //添加返回按钮
            UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            shareBtn.frame = CGRectMake(12, 30, 46, 23);
            [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
            self.navigationItem.rightBarButtonItem = shareItem;
            
            //修改Title以及返回按钮的样式
            _backLogin.frame = CGRectMake(12, 30, 23, 23);
            [_backLogin setTitle:@"" forState:UIControlStateNormal];
            [_backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
            if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
            {
                self.navigationItem.title = @"匹兹堡睡眠指数 PSQI";
            }
            else if ([_typeStr isEqualToString:@"抑郁自评"])
            {
                self.navigationItem.title = @"抑郁自评 PHQ-9";
            }
            else if ([_typeStr isEqualToString:@"焦虑自评"])
            {
                self.navigationItem.title = @"焦虑自评 GAD-7";
            }
            else if ([_typeStr isEqualToString:@"躯体自评"])
            {
                self.navigationItem.title = @"躯体自评 PHQ-15";
            }
        }
    }
}

//scrollView上所有内容的截图
- (UIImage *)captureScrollView:(UIScrollView *)scrollView
{
    UIImage* image = nil;
    
    CGSize imageSize = CGSizeMake(scrollView.frame.size.width, scrollView.contentSize.height - 53*Rate_NAV_H - 64 - 44);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    CGPoint savedContentOffset = scrollView.contentOffset;
    scrollView.contentOffset = CGPointZero;
    scrollView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    scrollView.contentOffset = savedContentOffset;
    
    UIGraphicsEndImageContext();
    
    if (image != nil)
    {
        return image;
    }
    
    return nil;
}

//图片合成
- (UIImage *)synchroniseImage:(UIImage *)mainImage otherImage:(UIImage *)secondaryImage
{
    //size
    CGSize size = CGSizeMake(mainImage.size.width, mainImage.size.height + secondaryImage.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // Draw image1
    [mainImage drawInRect:CGRectMake(0, 0, mainImage.size.width, mainImage.size.height)];
    
    // Draw image2
    [secondaryImage drawInRect:CGRectMake((mainImage.size.width - secondaryImage.size.width)/2, mainImage.size.height, secondaryImage.size.width, secondaryImage.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

- (void)shareBtnClick:(UIButton *)sender
{
    screenTmp = [self synchroniseImage:[self captureScrollView:resultV.resultScrollView] otherImage:[UIImage imageNamed:@"downloadCode"]];
    
    [UMSocialUIManager removeAllCustomPlatformWithoutFilted];
    [UMSocialShareUIConfig shareInstance].sharePageGroupViewConfig.sharePageGroupViewPostionType = UMSocialSharePageGroupViewPositionType_Bottom;
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageItemStyleType = UMSocialPlatformItemViewBackgroudType_IconAndBGRadius;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [self shareImageToPlatformType:platformType];
    }];
}

//创建匹兹堡睡眠指数量表
- (void)createPittsburghScale:(NSUInteger)questionIndex
{
    if (questionIndex == 0)
    {
        _timePV_M.hidden = YES;
        _timePV_H.hidden = YES;
        _timePV_MH2.hidden = YES;
        if (_timePV_MH1 == nil)
        {
            _timePV_MH1 = [[TimePickView alloc] initWithType:TimePickTypeHourAndMinute AndTime:[initArray objectAtIndex:questionIndex]];
            _timePV_MH1.frame = CGRectMake(50*Rate_NAV_W, 121*Rate_NAV_H, 275*Rate_NAV_W, 281*Rate_NAV_H);
            
            [self.view addSubview:_timePV_MH1];
            
            __weak typeof(resultArray) weakResultArray = resultArray;
            __weak typeof(_timeLabel) weakTimeLabel = _timeLabel;
            _timePV_MH1.timePick = ^(NSString *timeValue){
                [weakResultArray replaceObjectAtIndex:0 withObject:timeValue];
                weakTimeLabel.text = timeValue;
            };
        }
        else
        {
            _timePV_MH1.hidden = NO;
        }
    }
    else if (questionIndex == 1)
    {
        _timePV_H.hidden = YES;
        _timePV_MH1.hidden = YES;
        _timePV_MH2.hidden = YES;
        if (_timePV_M == nil)
        {
            _timePV_M = [[TimePickView alloc] initWithType:TimePickTypeMinute AndTime:[initArray objectAtIndex:questionIndex]];
            _timePV_M.frame = CGRectMake(50*Rate_NAV_W, 121*Rate_NAV_H, 275*Rate_NAV_W, 281*Rate_NAV_H);
            
            [self.view addSubview:_timePV_M];
            
            __weak typeof(resultArray) weakResultArray = resultArray;
            __weak typeof(_timeLabel) weakTimeLabel = _timeLabel;
            _timePV_M.timePick = ^(NSString *timeValue){
                [weakResultArray replaceObjectAtIndex:1 withObject:timeValue];
                if ([timeValue isEqualToString:@"1"])
                {
                    weakTimeLabel.text = @"1小时";
                }
                else
                {
                    weakTimeLabel.text = [NSString stringWithFormat:@"%@分钟",timeValue];
                }
            };
        }
        else
        {
            _timePV_M.hidden = NO;
        }
    }
    else if (questionIndex == 2)
    {
        _timePV_M.hidden = YES;
        _timePV_H.hidden = YES;
        _timePV_MH1.hidden = YES;
        if (_timePV_MH2 == nil)
        {
            _timePV_MH2 = [[TimePickView alloc] initWithType:TimePickTypeHourAndMinute AndTime:[initArray objectAtIndex:questionIndex]];
            _timePV_MH2.frame = CGRectMake(50*Rate_NAV_W, 121*Rate_NAV_H, 275*Rate_NAV_W, 281*Rate_NAV_H);
            
            [self.view addSubview:_timePV_MH2];
            
            __weak typeof(resultArray) weakResultArray = resultArray;
            __weak typeof(_timeLabel) weakTimeLabel = _timeLabel;
            _timePV_MH2.timePick = ^(NSString *timeValue){
                [weakResultArray replaceObjectAtIndex:2 withObject:timeValue];
                weakTimeLabel.text = timeValue;
            };
        }
        else
        {
            _timePV_MH2.hidden = NO;
        }
    }
    else if (questionIndex == 3)
    {
        _bedImageView.hidden = NO;
        _timePV_M.hidden = YES;
        _timePV_MH1.hidden = YES;
        _timePV_MH2.hidden = YES;
        for (UIButton *tmp in fragmentBtnArray)
        {
            [tmp removeFromSuperview];
        }
        for (UILabel *tmp in fragmentLbArray)
        {
            [tmp removeFromSuperview];
        }
        if (_timePV_H == nil)
        {
            _timePV_H = [[TimePickView alloc] initWithType:TimePickTypeHour AndTime:[initArray objectAtIndex:questionIndex]];
            _timePV_H.frame = CGRectMake(50*Rate_NAV_W, 121*Rate_NAV_H, 275*Rate_NAV_W, 281*Rate_NAV_H);
            
            [self.view addSubview:_timePV_H];
            
            __weak typeof(resultArray) weakResultArray = resultArray;
            __weak typeof(_timeLabel) weakTimeLabel = _timeLabel;
            _timePV_H.timePick = ^(NSString *timeValue){
                [weakResultArray replaceObjectAtIndex:3 withObject:timeValue];
                weakTimeLabel.text = [NSString stringWithFormat:@"%@小时",timeValue];
            };
        }
        else
        {
            _timePV_H.hidden = NO;
        }
        
    }
    else if (questionIndex >= 4 && questionIndex <= 13)
    {
        _bedImageView.hidden = YES;
        _timePV_M.hidden = YES;
        _timePV_H.hidden = YES;
        _timePV_MH1.hidden = YES;
        _timePV_MH2.hidden = YES;
        for (UIButton *tmp in pittsburghPointBtnArray)
        {
            [tmp removeFromSuperview];
        }
        for (UIButton *tmp in pittsburghTitleBtnArray)
        {
            [tmp removeFromSuperview];
        }
        //创建碎片化搜集的问题按钮
        if (fragmentBtnArray.count == 0)
        {
            NSArray *btnTitleArray = @[@"入睡困难",@"易醒或早醒",@"夜间去厕所",@"呼吸不畅",@"咳嗽或鼾声大",@"感觉冷",@"感觉热",@"做噩梦",@"疼痛不适",@"其他事情"];
            for (int i = 0; i < 2; i++)
            {
                for (int j = 0; j < 5; j++)
                {
                    //添加碎片化选项按钮
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake((29 + 163*i)*Rate_NAV_W, (30 + 78*j)*Rate_NAV_H, 153*Rate_NAV_W, 48*Rate_NAV_H);
                    btn.tag = i + j*2;
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    btn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
                    [btn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
                    [btn setTitle:[btnTitleArray objectAtIndex:(i + j*2)] forState:UIControlStateNormal];
                    btn.layer.shadowColor = [UIColor colorWithRed:0xDE/255.0 green:0xE4/255.0 blue:0xE7/255.0 alpha:1].CGColor;
                    btn.layer.shadowOffset = CGSizeMake(0, 1);//偏移距离
                    btn.layer.cornerRadius = 3.0;
                    btn.layer.borderColor = [UIColor colorWithRed:0xDE/255.0 green:0xE4/255.0 blue:0xE7/255.0 alpha:1].CGColor;
                    
                    [btn addTarget:self action:@selector(selectAnswer:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:btn];
                    [fragmentBtnArray addObject:btn];
                    
                    //添加碎片化选项按钮下方详细选项
                    UILabel *lb = [[UILabel alloc] init];
                    lb.frame = CGRectMake((56 + 161*i)*Rate_NAV_W, (81 + 78*j)*Rate_NAV_H, 98*Rate_NAV_W, 20*Rate_NAV_H);
                    lb.tag = i + j*2;
                    lb.textAlignment = NSTextAlignmentCenter;
                    lb.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
                    lb.adjustsFontSizeToFitWidth = YES;
                    lb.textColor = [UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
                    lb.text = @"";
                    [self.view addSubview:lb];
                    [fragmentLbArray addObject:lb];
                }
            }
        }
        else
        {
            //获取按钮
            for (UIButton *tmp in fragmentBtnArray)
            {
                [self.view addSubview:tmp];
            }
            //获取Label
            for (UILabel *tmp in fragmentLbArray)
            {
                [self.view addSubview:tmp];
            }
        }
    }
    else if (questionIndex == 14)
    {
        for (UIButton *tmp in fragmentBtnArray)
        {
            [tmp removeFromSuperview];
        }
        for (UIButton *tmp in fragmentLbArray)
        {
            [tmp removeFromSuperview];
        }
        [self createPittsburghQuestion:questionIndex];
    }
    else if (questionIndex == 15)
    {
        if (pittsburghPointBtnArray.count >0)
        {
            for (UIButton *tmp in pittsburghPointBtnArray)
            {
                [tmp removeFromSuperview];
            }
            [pittsburghPointBtnArray removeAllObjects];
        }
        if (pittsburghTitleBtnArray.count >0)
        {
            for (UIButton *tmp in pittsburghTitleBtnArray)
            {
                [tmp removeFromSuperview];
            }
            [pittsburghTitleBtnArray removeAllObjects];
        }
        [self createPittsburghQuestion:questionIndex];
    }
    else if (questionIndex == 16)
    {
        if (pittsburghPointBtnArray.count >0)
        {
            for (UIButton *tmp in pittsburghPointBtnArray)
            {
                [tmp removeFromSuperview];
            }
            [pittsburghPointBtnArray removeAllObjects];
        }
        if (pittsburghTitleBtnArray.count >0)
        {
            for (UIButton *tmp in pittsburghTitleBtnArray)
            {
                [tmp removeFromSuperview];
            }
            [pittsburghTitleBtnArray removeAllObjects];
        }
        [self createPittsburghQuestion:questionIndex];
    }
    else if (questionIndex == 17)
    {
        if (pittsburghPointBtnArray.count >0)
        {
            for (UIButton *tmp in pittsburghPointBtnArray)
            {
                [tmp removeFromSuperview];
            }
            [pittsburghPointBtnArray removeAllObjects];
        }
        if (pittsburghTitleBtnArray.count >0)
        {
            for (UIButton *tmp in pittsburghTitleBtnArray)
            {
                [tmp removeFromSuperview];
            }
            [pittsburghTitleBtnArray removeAllObjects];
        }
        [self createPittsburghQuestion:questionIndex];
    }
}

//碎片化搜集的十道匹兹堡睡眠指数题目的按钮点击事件
- (void)selectAnswer:(UIButton *)sender
{
    if (sender.selected == NO)
    {
        //添加蒙板
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        view.backgroundColor = [UIColor colorWithRed:0x2F/255.0 green:0x2F/255.0 blue:0x2F/255.0 alpha:0.75];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        //弹出碎片化搜集的详细选择View
        _fragmentV = [[FragmentView alloc] initWithQuestion:sender.titleLabel.text Selected:[resultArray objectAtIndex:_questionIndex + sender.tag]];
        [view addSubview:_fragmentV];
        
        __weak typeof(fragmentLbArray) weakFragmentLbArray = fragmentLbArray;
        __weak typeof(resultArray) weakResultArray = resultArray;
        __weak typeof(_fragmentV) weakFragmentV = _fragmentV;
        __weak typeof(view) weakView = view;
        _fragmentV.answerSelect = ^(NSString *selectStr){
            if ([selectStr isEqualToString:@"没有"])
            {
                for (UILabel *tmp in weakFragmentLbArray)
                {
                    if (tmp.tag == sender.tag)
                    {
                        tmp.text = @"";
                        [sender setBackgroundColor:[UIColor whiteColor]];
                        [sender setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
                        
                        [weakResultArray replaceObjectAtIndex:4+sender.tag withObject:@"0"];
                    }
                }
            }
            else if ([selectStr isEqualToString:@"每周不到一次"])
            {
                for (UILabel *tmp in weakFragmentLbArray)
                {
                    if (tmp.tag == sender.tag)
                    {
                        tmp.text = @"每周不到一次";
                        [sender setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
                        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        
                        [weakResultArray replaceObjectAtIndex:4+sender.tag withObject:@"1"];
                    }
                }
            }
            else if ([selectStr isEqualToString:@"每周一到两次"])
            {
                for (UILabel *tmp in weakFragmentLbArray)
                {
                    if (tmp.tag == sender.tag)
                    {
                        tmp.text = @"每周一到两次";
                        [sender setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
                        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        
                        [weakResultArray replaceObjectAtIndex:4+sender.tag withObject:@"2"];
                    }
                }
            }
            else if ([selectStr isEqualToString:@"每周三次或更多"])
            {
                for (UILabel *tmp in weakFragmentLbArray)
                {
                    if (tmp.tag == sender.tag)
                    {
                        tmp.text = @"每周三次或更多";
                        [sender setBackgroundColor:[UIColor colorWithRed:0x2E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1]];
                        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        
                        [weakResultArray replaceObjectAtIndex:4+sender.tag withObject:@"3"];
                    }
                }
            }
            [weakFragmentV removeFromSuperview];
            [weakView removeFromSuperview];
        };
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGesture:)];
        [view addGestureRecognizer:tapGesture];
    }
    else
    {
        sender.selected = NO;
        [sender setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor whiteColor]];
    }
}

//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGesture:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<_fragmentV.frame.origin.x || point.x >_fragmentV.frame.origin.x+_fragmentV.frame.size.width || point.y<_fragmentV.frame.origin.y || point.y>_fragmentV.frame.origin.y+_fragmentV.frame.size.height)
    {
        [_fragmentV removeFromSuperview];
        [view removeFromSuperview];
    }
}

//创建抑郁、焦虑自评量表
- (void)createDepressedAndAnxiousScale:(NSUInteger)questionIndex
{
    if (depressedAndAnxiousPointBtnArray.count >0)
    {
        for (UIButton *tmp in depressedAndAnxiousPointBtnArray)
        {
            [tmp removeFromSuperview];
        }
        [depressedAndAnxiousPointBtnArray removeAllObjects];
    }
    if (depressedAndAnxiousTitleBtnArray.count >0)
    {
        for (UIButton *tmp in depressedAndAnxiousTitleBtnArray)
        {
            [tmp removeFromSuperview];
        }
        [depressedAndAnxiousTitleBtnArray removeAllObjects];
    }
    [self createDepressedAndAnxiousQuestion:questionIndex];
}

//创建躯体自评量表
- (void)createBodyScale:(NSUInteger)questionIndex
{
    if (bodyPointBtnArray.count >0)
    {
        for (UIButton *tmp in bodyPointBtnArray)
        {
            [tmp removeFromSuperview];
        }
        [bodyPointBtnArray removeAllObjects];
    }
    if (bodyTitleBtnArray.count >0)
    {
        for (UIButton *tmp in bodyTitleBtnArray)
        {
            [tmp removeFromSuperview];
        }
        [bodyTitleBtnArray removeAllObjects];
    }
    [self createBodyQuestion:questionIndex];
}

//根据questionIndex创建匹兹堡问题
- (void)createPittsburghQuestion:(NSInteger)questionIndex
{
    NSArray *titleArray;
    if (questionIndex == 14)
    {
        titleArray = @[@"很好",@"较好",@"较差",@"很差"];
    }
    else if (questionIndex == 15)
    {
        titleArray = @[@"不使用",@"每周不到一次",@"每周一到两次",@"每周三次或更多"];
    }
    else if (questionIndex == 16 || questionIndex == 17)
    {
        titleArray = @[@"没有",@"偶尔有",@"有时有",@"经常有"];
    }
    
    for (int i = 0; i < 4; i++)
    {
        UIButton *pointBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pointBtn.frame = CGRectMake(29*Rate_NAV_W, (92 + i*70)*Rate_NAV_H, 22*Rate_NAV_H, 22*Rate_NAV_H);
        pointBtn.tag = i;
        if (i == [[resultArray objectAtIndex:questionIndex] integerValue])
        {
            [pointBtn setBackgroundImage:[UIImage imageNamed:@"point4"] forState:UIControlStateNormal];
        }
        else
        {
            [pointBtn setBackgroundImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
        }
        [pointBtn addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:pointBtn];
        [pittsburghPointBtnArray addObject:pointBtn];
        
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake(57*Rate_NAV_W, (74 + i*70)*Rate_NAV_H, 289*Rate_NAV_W, 58*Rate_NAV_H);
        titleBtn.tag = i;
        [titleBtn setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        if (i == [[resultArray objectAtIndex:questionIndex] integerValue])
        {
            [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"gauge_selected_bg"] forState:UIControlStateNormal];
        }
        else
        {
            [titleBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"gauge_notselected_bg"] forState:UIControlStateNormal];
        }
        
        [titleBtn addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:titleBtn];
        [pittsburghTitleBtnArray addObject:titleBtn];
    }
}

//根据questionIndex创建抑郁自评、焦虑自评问题
- (void)createDepressedAndAnxiousQuestion:(NSInteger)questionIndex
{
    NSArray *titleArray = @[@"完全不会",@"好几天",@"超过一周",@"几乎每天"];
    for (int i = 0; i < 4; i++)
    {
        UIButton *pointBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pointBtn.frame = CGRectMake(29*Rate_NAV_W, (92 + i*70)*Rate_NAV_H, 22*Rate_NAV_H, 22*Rate_NAV_H);
        pointBtn.tag = i;
        if (i == [[resultArray objectAtIndex:questionIndex] integerValue])
        {
            [pointBtn setBackgroundImage:[UIImage imageNamed:@"point4"] forState:UIControlStateNormal];
        }
        else
        {
            [pointBtn setBackgroundImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
        }
        [pointBtn addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:pointBtn];
        [depressedAndAnxiousPointBtnArray addObject:pointBtn];
        
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake(57*Rate_NAV_W, (74 + i*70)*Rate_NAV_H, 289*Rate_NAV_W, 58*Rate_NAV_H);
        titleBtn.tag = i;
        [titleBtn setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        if (i == [[resultArray objectAtIndex:questionIndex] integerValue])
        {
            [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"gauge_selected_bg"] forState:UIControlStateNormal];
        }
        else
        {
            [titleBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"gauge_notselected_bg"] forState:UIControlStateNormal];
        }
        
        [titleBtn addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:titleBtn];
        [depressedAndAnxiousTitleBtnArray addObject:titleBtn];
    }
}

//根据questionIndex创建躯体自评问题
- (void)createBodyQuestion:(NSInteger)questionIndex
{
    NSArray *titleArray = @[@"没有困扰",@"少许困扰",@"很多困扰"];
    for (int i = 0; i < 3; i++)
    {
        UIButton *pointBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pointBtn.frame = CGRectMake(29*Rate_NAV_W, (112 + i*70)*Rate_NAV_H, 22*Rate_NAV_H, 22*Rate_NAV_H);
        pointBtn.tag = i;
        if (i == [[resultArray objectAtIndex:questionIndex] integerValue])
        {
            [pointBtn setBackgroundImage:[UIImage imageNamed:@"point4"] forState:UIControlStateNormal];
        }
        else
        {
            [pointBtn setBackgroundImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
        }
        [pointBtn addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:pointBtn];
        [bodyPointBtnArray addObject:pointBtn];
        
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake(57*Rate_NAV_W, (94 + i*70)*Rate_NAV_H, 289*Rate_NAV_W, 58*Rate_NAV_H);
        titleBtn.tag = i;
        [titleBtn setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
        if (i == [[resultArray objectAtIndex:questionIndex] integerValue])
        {
            [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"gauge_selected_bg"] forState:UIControlStateNormal];
        }
        else
        {
            [titleBtn setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"gauge_notselected_bg"] forState:UIControlStateNormal];
        }
        
        [titleBtn addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:titleBtn];
        [bodyTitleBtnArray addObject:titleBtn];
    }
}

//匹兹堡睡眠指数第15-18题按钮、抑郁自评选项按钮、焦虑自评选项按钮点击事件
- (void)chooseAnswer:(UIButton *)sender
{
    if (sender.selected == NO)
    {
        if ([_typeStr isEqualToString:@"匹兹堡睡眠指数"])
        {
            for (UIButton *tmp in pittsburghTitleBtnArray)
            {
                if (tmp.tag != sender.tag)
                {
                    tmp.selected = NO;
                    [tmp setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
                    [tmp setBackgroundImage:[UIImage imageNamed:@"gauge_notselected_bg"] forState:UIControlStateNormal];
                }
                else
                {
                    tmp.selected = YES;
                    [tmp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [tmp setBackgroundImage:[UIImage imageNamed:@"gauge_selected_bg"] forState:UIControlStateNormal];
                }
            }
            for (UIButton *tmp in pittsburghPointBtnArray)
            {
                if (tmp.tag != sender.tag)
                {
                    tmp.selected = NO;
                    [tmp setBackgroundImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
                }
                else
                {
                    tmp.selected = YES;
                    [tmp setBackgroundImage:[UIImage imageNamed:@"point4"] forState:UIControlStateNormal];
                }
            }
        }
        else if ([_typeStr isEqualToString:@"抑郁自评"] || [_typeStr isEqualToString:@"焦虑自评"])
        {
            for (UIButton *tmp in depressedAndAnxiousTitleBtnArray)
            {
                if (tmp.tag != sender.tag)
                {
                    tmp.selected = NO;
                    [tmp setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
                    [tmp setBackgroundImage:[UIImage imageNamed:@"gauge_notselected_bg"] forState:UIControlStateNormal];
                }
                else
                {
                    tmp.selected = YES;
                    [tmp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [tmp setBackgroundImage:[UIImage imageNamed:@"gauge_selected_bg"] forState:UIControlStateNormal];
                }
            }
            for (UIButton *tmp in depressedAndAnxiousPointBtnArray)
            {
                if (tmp.tag != sender.tag)
                {
                    tmp.selected = NO;
                    [tmp setBackgroundImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
                }
                else
                {
                    tmp.selected = YES;
                    [tmp setBackgroundImage:[UIImage imageNamed:@"point4"] forState:UIControlStateNormal];
                }
            }
        }
        else if ([_typeStr isEqualToString:@"躯体自评"])
        {
            for (UIButton *tmp in bodyTitleBtnArray)
            {
                if (tmp.tag != sender.tag)
                {
                    tmp.selected = NO;
                    [tmp setTitleColor:[UIColor colorWithRed:0x43/255.0 green:0x47/255.0 blue:0x48/255.0 alpha:1] forState:UIControlStateNormal];
                    [tmp setBackgroundImage:[UIImage imageNamed:@"gauge_notselected_bg"] forState:UIControlStateNormal];
                }
                else
                {
                    tmp.selected = YES;
                    [tmp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [tmp setBackgroundImage:[UIImage imageNamed:@"gauge_selected_bg"] forState:UIControlStateNormal];
                }
            }
            for (UIButton *tmp in bodyPointBtnArray)
            {
                if (tmp.tag != sender.tag)
                {
                    tmp.selected = NO;
                    [tmp setBackgroundImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
                }
                else
                {
                    tmp.selected = YES;
                    [tmp setBackgroundImage:[UIImage imageNamed:@"point4"] forState:UIControlStateNormal];
                }
            }
        }
        
        [resultArray replaceObjectAtIndex:_questionIndex withObject:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
    }
}

#pragma mark - share type
//分享文本
- (void)shareTextToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //设置文本
    messageObject.text = UMS_Text;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}

//分享图片
- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图本地
    shareObject.thumbImage = [UIImage imageNamed:@"icon"];
    
    [shareObject setShareImage:screenTmp];
    
    // 设置Pinterest参数
    if (platformType == UMSocialPlatformType_Pinterest) {
        [self setPinterstInfo:messageObject];
    }
    
    // 设置Kakao参数
    if (platformType == UMSocialPlatformType_KakaoTalk) {
        messageObject.moreInfo = @{@"permission" : @1}; // @1 = KOStoryPermissionPublic
    }
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}

//分享网络图片
- (void)shareImageURLToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = UMS_THUMB_IMAGE;
        
    [shareObject setShareImage:UMS_IMAGE];
        
    // 设置Pinterest参数
    if (platformType == UMSocialPlatformType_Pinterest)
    {
        [self setPinterstInfo:messageObject];
    }
        
    // 设置Kakao参数
    if (platformType == UMSocialPlatformType_KakaoTalk)
    {
        messageObject.moreInfo = @{@"permission" : @1}; // @1 = KOStoryPermissionPublic
    }
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
        
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}

- (void)setPinterstInfo:(UMSocialMessageObject *)messageObj
{
    messageObj.moreInfo = @{@"source_url": @"http://www.umeng.com",
                            @"app_name": @"U-Share",
                            @"suggested_board_name": @"UShareProduce",
                            @"description": @"U-Share: best social bridge"};
}

//分享图片和文字
- (void)shareImageAndTextToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //设置文本
    messageObject.text = UMS_Text_image;
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    if (platformType == UMSocialPlatformType_Linkedin)
    {
        // linkedin仅支持URL图片
        shareObject.thumbImage = UMS_THUMB_IMAGE;
        [shareObject setShareImage:UMS_IMAGE];
    }
    else
    {
        shareObject.thumbImage = [UIImage imageNamed:@"icon"];
        shareObject.shareImage = [UIImage imageNamed:@"logo"];
    }
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}

//网页分享
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString* thumbURL =  UMS_THUMB_IMAGE;
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:UMS_Title descr:UMS_Web_Desc thumImage:thumbURL];
    //设置网页地址
    shareObject.webpageUrl = UMS_WebLink;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error)
        {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }
        else
        {
            if ([data isKindOfClass:[UMSocialShareResponse class]])
            {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }
            else
            {
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}

- (void)alertWithError:(NSError *)error
{
    NSString *result = nil;
    if (!error)
    {
        result = [NSString stringWithFormat:@"分享成功"];
        //更新服务器积分
        InterfaceModel *mod = [[InterfaceModel alloc] init];
        [mod uploadPointToServer:[PatientInfo shareInstance].PatientID pointType:@"9"];
    }
    else
    {
        NSMutableString *str = [NSMutableString string];
        if (error.userInfo)
        {
            for (NSString *key in error.userInfo)
            {
                [str appendFormat:@"%@ = %@\n", key, error.userInfo[key]];
            }
        }
        if (error)
        {
            result = @"分享失败";
        }
        else
        {
            result = @"分享失败";
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享"
                                                    message:result
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//积分修改
- (void)integralUpdate
{
    //更新服务器积分
    InterfaceModel *mod = [[InterfaceModel alloc] init];
    [mod uploadPointToServer:[PatientInfo shareInstance].PatientID pointType:@"7"];
    //从NSUserDefaults当中标记当天积分是否已经给过，给过则不重复给
    //此处利用NSUserDefaults进行标记
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [df stringFromDate:[NSDate date]];
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:currentDateStr forKey:[NSString stringWithFormat:@"%@Point",_typeStr]];
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
