//
//  PostDetailViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/12.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PostDetailViewController.h"
#import "ImageBrowserViewController.h"
#import "UIImageView+EMWebCache.h"
#import "UIViewController+HUD.h"
#import "UIViewController+BackButton.h"
#import "MBProgressHUD.h"
#import "PostCommentModel.h"
#import "PostCommentCell.h"
#import "SquareModel.h"
#import "MJRefresh.h"
#import "DataHandle.h"
#import "FunctionHelper.h"
#import "STInputBar.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>
#import "InterfaceModel.h"

@interface PostDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

//视图
@property (strong, nonatomic) UITableView *tableV;       //数据显示于tableView
@property (strong, nonatomic)      UIView *headerView;   //头视图
@property (strong, nonatomic)     UILabel *failureV;     //获取数据失败的提示
@property (strong, nonatomic)      UIView *btnView;      //悬浮的按钮（收藏、点赞、评论）
@property (strong, nonatomic)     UILabel *browserLable; //浏览的次数
@property (strong, nonatomic)     UILabel *commentLable; //评论的次数
@property (strong, nonatomic)     UILabel *favorLable;   //点赞次数
@property (strong, nonatomic)     UILabel *likeLable;    //点赞
@property (strong, nonatomic)     UILabel *userInfoLable;//用户信息
@property (strong, nonatomic)     UILabel *collectLable; //收藏次数
@property (strong, nonatomic)  STInputBar *inputBar;     //自定制评论键盘

@property (nonatomic, strong) PatientInfo *patientInfo;
//数据处理
@property (copy, nonatomic) SquareModel *model; //帖子数据模型
@property (copy, nonatomic)  DataHandle *handle;//数据处理对象

//属性值
@property (strong, nonatomic) NSMutableArray *dataSource;     //数据源
@property (copy, nonatomic)         NSString *page;           //分页获取的页数
@property (copy, nonatomic)         NSString *accumulatePoint;//积分
@property (copy, nonatomic)         NSString *friendCount;//好友个数
@property (copy, nonatomic)         NSString *patientName;//楼主昵称
@property (copy, nonatomic)         NSString *headerImage;//楼主头像
@property (copy, nonatomic)         NSString *publicCount;//发帖的个数
@property (copy, nonatomic)         NSString *replayCount;//回复的个数
@property (nonatomic)                   BOOL isLike;      //是否点赞了

@end

@implementation PostDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [MobClick beginLogPageView:@"帖子详情"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除键盘监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];//移除self所有通知
    
    [MobClick endLogPageView:@"帖子详情"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"详情";
    
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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //添加单击手势
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleRecognizer];
    
    //数据对象
    _handle = [[DataHandle alloc] init];
    _patientInfo = [PatientInfo shareInstance];
    
    //判断网络
    if ([FunctionHelper isExistenceNetwork])
    {
        if (![self updatePostReplayStateWithPostID:_postModel.PostID])
        {
            [self showHint:@"帖子状态更新失败"];
        }
        //获取数据
        [self getCommentInfoFromDataWorkAndGetPostDetail:YES];
        //创建视图
        [self createTableView];
        [self createWindows];
        [self setValueForUserInfo];
    }
    else
    {
        [self createGetDataFailureViewWithError:@"请检查网络连接" withFrame:_tableV.bounds];
    }
}

- (void)backLoginClick:(UIButton *)click
{
    [self navigationShouldPopOnBackButton];
}

#pragma mark -- 指定返回界面
- (BOOL)navigationShouldPopOnBackButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshView" object:nil userInfo:@{@"state":[NSString stringWithFormat:@"%li",_index],@"browserCount":_browserLable.text,@"favorCount":_favorLable.text,@"commentCount":_commentLable.text}];
    [self.navigationController popViewControllerAnimated:YES];
    
    return NO;
}

#pragma mark -- 获取帖子详情
- (BOOL)getPostDetailInfoFromNetWork
{
    NSMutableURLRequest *req1 = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeGetPostDetail) andDictionary:@{@"patientID":_postModel.PatientID,@"postID":_postModel.PostID}];
    req1.timeoutInterval = 5.0;
    NSData *data1 = [NSURLConnection sendSynchronousRequest:req1 returningResponse:nil error:nil];
    if (data1)
    {
        NSArray *temp1 = [_handle objectFromeResponseString:data1 andType:(DataModelBackTypeGetPostDetail)];
        for (NSDictionary *dic in temp1)
        {
            _model = [[SquareModel alloc] initWithDictionary:dic];
        }
    }
    else
    {
        return NO;
    }
    NSMutableURLRequest *req2 = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeGetCommunityPatientInfo) andPrimaryKey:_model.PatientID];
    req2.timeoutInterval = 5.0;
    NSData * data2 = [NSURLConnection sendSynchronousRequest:req2 returningResponse:nil error:nil];
    if (data2)
    {
        NSArray *temp2 = [_handle objectFromeResponseString:data2 andType:(DataModelBackTypeGetCommunityPatientInfo)];
        for (NSDictionary * dic in temp2)
        {
            _accumulatePoint = dic[@"AccumulatePoint"];
            _friendCount = dic[@"FriendCount"];
            _patientName = dic[@"PatientName"];
            _headerImage = dic[@"PhotoUrl"];
            _publicCount = dic[@"PublicCount"];
            _replayCount = dic[@"ReplyCount"];
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -- 获取帖子评论
- (void)getCommentInfoFromDataWorkAndGetPostDetail:(BOOL)getDetail
{
    _dataSource = [NSMutableArray array];
    _page = @"1";
    //是否获取帖子详情
    BOOL isSuccess = YES;
    if (getDetail)
    {
        //获取帖子详情
        isSuccess = [self getPostDetailInfoFromNetWork];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"加载中";
    //判断帖子信息获取是否成功
    if (isSuccess)
    {
        NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeGetPostComment) andDictionary:@{@"postID":_postModel.PostID,@"page":_page}];
        req.timeoutInterval = 5.0;
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (connectionError)
            {
                hud.labelText = @"加载失败，网络繁忙";
                [hud hide:YES afterDelay:0.5];
                [self createGetDataFailureViewWithError:@"网络繁忙,请稍后再试" withFrame:CGRectMake(0, _headerView.frame.size.height, SCREENWIDTH, _tableV.frame.size.height-_headerView.frame.size.height)];
            }
            else
            {
                if (data)
                {
                    hud.labelText = @"加载完成";
                    [hud hide:YES afterDelay:0.1];
                    [self prepareCommentInfoWithData:data];
                }
                else
                {
                    hud.labelText = @"加载失败";
                    [hud hide:YES afterDelay:0.5];
                    [self createGetDataFailureViewWithError:@"获取数据失败" withFrame:CGRectMake(0, _headerView.frame.size.height, SCREENWIDTH, _tableV.frame.size.height-_headerView.frame.size.height)];
                }
            }
        }];
    }
    else
    {
        hud.labelText = @"加载失败";
        [hud hide:YES afterDelay:0.5];
        [self createGetDataFailureViewWithError:@"获取数据失败" withFrame:_tableV.bounds];
    }
}

#pragma mark -- 更新帖子的回复状态
- (BOOL)updatePostReplayStateWithPostID:(NSString *)postID
{
    NSMutableURLRequest *req1 = [_handle RequestForGetDataFromNetWorkWithStringType:(DataModelBackTypeUpdatePostReplayState) andPrimaryKey:postID];
    req1.timeoutInterval = 5.0;
    NSData *data1 = [NSURLConnection sendSynchronousRequest:req1 returningResponse:nil error:nil];
    if (data1)
    {
        if([[_handle objectFromeResponseString:data1 andType:(DataModelBackTypeUpdatePostReplayState)] isEqualToString:@"OK"])
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
    
    return NO;
}

#pragma mark -- 处理从网络获取的数据
- (void)prepareCommentInfoWithData:(NSData *)data
{
    NSArray *temp = [_handle objectFromeResponseString:data andType:(DataModelBackTypeGetPostComment)];
    if(temp == 0)
    {
        [_tableV.mj_footer endRefreshingWithNoMoreData];
    }
    else
    {
        for (NSDictionary *dic in temp)
        {
            PostCommentModel *comment = [[PostCommentModel alloc]initWithDictionary:dic];
            [_dataSource addObject:comment];
        }
        [_tableV reloadData];
    }
    if (_dataSource.count == 0)
    {
        [self createGetDataFailureViewWithError:@"暂无评论" withFrame:CGRectMake(0, _headerView.frame.size.height + 47, SCREENWIDTH, 50)];
    }
}

#pragma mark -- 创建未获取到数据的提示信息
- (void)createGetDataFailureViewWithError:(NSString *)error withFrame:(CGRect)frame
{
    [_failureV removeFromSuperview];
    _failureV = [[UILabel alloc] initWithFrame:frame];
    _failureV.textColor = [UIColor lightGrayColor];
    _failureV.font = [UIFont systemFontOfSize:25];
    _failureV.textAlignment = NSTextAlignmentCenter;
    _failureV.text = error;
    [_tableV addSubview:_failureV];
    _tableV.contentSize = CGSizeMake(SCREENWIDTH, _headerView.frame.size.height + 100);
//    [_tableV setContentInset:UIEdgeInsetsMake(-(_headerView.frame.size.height + 100), 0, 0, 0)];
}

#pragma mark -- 创建回复键盘
- (void)createCommentToolBar
{
    _inputBar = [STInputBar inputBar];
    _inputBar.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_inputBar.frame)+CGRectGetHeight(_inputBar.frame)/2);
    _inputBar.placeHolder = @"我来说两句";
    [self.view addSubview:_inputBar];
    __weak typeof(self) weakSelf = self;
    [_inputBar setDidSendClicked:^(NSString *text) {
        [weakSelf uploadCommentWithContent:text];
    }];
}

#pragma mark -- 创建Title部分
- (void)createPostTitle
{
    _headerView = [[UIView alloc] init];
    _headerView.userInteractionEnabled = YES;
    _headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_W, 12*Rate_H, 355*Rate_W, 22*Rate_H)];
    titleLable.text = [NSString stringWithFormat:@"【%@】%@",_model.Type,_model.Title];
    titleLable.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];
    titleLable.font = [UIFont systemFontOfSize:16*Rate_H];
    titleLable.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:titleLable];
    
    UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_W, 40*Ratio, 355*Rate_W, 15*Rate_H)];
    timeLable.text = _model.Time;
    timeLable.textColor = [UIColor colorWithRed:0.62 green:0.64 blue:0.64 alpha:1.0];
    timeLable.font = [UIFont systemFontOfSize:11*Rate_H];
    timeLable.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:timeLable];
    
    UIButton *browser = [[UIButton alloc] initWithFrame:CGRectMake(200*Rate_W, 46*Rate_H, 15*Rate_H, 10*Rate_H)];
    [browser setBackgroundImage:[UIImage imageNamed:@"icon_browse.png"] forState:(UIControlStateNormal)];
    [_headerView addSubview:browser];
    
    _browserLable = [[UILabel alloc] initWithFrame:CGRectMake(220*Rate_W, 43.5*Rate_H, 50*Rate_W, 15*Rate_H)];
    _browserLable.text = _model.BrowserCount;
    _browserLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _browserLable.font = [UIFont systemFontOfSize:11*Rate_H];
    _browserLable.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:_browserLable];
    
    UIButton *comment = [[UIButton alloc] initWithFrame:CGRectMake(270*Rate_W, 45*Rate_H, 12*Rate_H, 12*Rate_H)];
    [comment setBackgroundImage:[UIImage imageNamed:@"icon_message.png"] forState:(UIControlStateNormal)];
    [_headerView addSubview:comment];
    
    _commentLable = [[UILabel alloc] initWithFrame:CGRectMake(287*Rate_W, 43.5*Rate_H, 50*Rate_W, 15*Rate_H)];
    _commentLable.text = _model.CommentCount;
    _commentLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _commentLable.font = [UIFont systemFontOfSize:11*Rate_H];
    _commentLable.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:_commentLable];
    
    UIButton *favor = [[UIButton alloc] initWithFrame:CGRectMake(320*Rate_W, 45*Rate_H, 12*Rate_H, 12*Rate_H)];
    [favor setBackgroundImage:[UIImage imageNamed:@"icon_fabulous.png"] forState:(UIControlStateNormal)];
    [_headerView addSubview:favor];
    
    _favorLable = [[UILabel alloc] initWithFrame:CGRectMake(337*Rate_W,43.5*Rate_H, 50*Rate_W, 15*Rate_H)];
    _favorLable.text = _model.FavorCount;
    _favorLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _favorLable.font = [UIFont systemFontOfSize:11*Rate_H];
    _favorLable.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:_favorLable];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 70*Rate_H, SCREENWIDTH, 1)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [_headerView addSubview:line];
    
    [self createContentView];
}

#pragma mark -- 创建帖子内容视图
- (void)createContentView
{
    int imagCount = [_model.ImageCount intValue];
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    
    if (imagCount >= 3)
    {
        width = (SCREENWIDTH - 34*Rate_W)/3;
        height = 80*Rate_H;
    }
    else if(imagCount > 1)
    {
        width = (SCREENWIDTH - 27*Rate_W)/2;
        height = 120*Rate_H;
    }
    else if(imagCount > 0)
    {
        width = SCREENWIDTH - 20*Rate_W;
        height = 150*Rate_H;
    }
    __block CGFloat imageV_x = 15.0f;
    for (int i = 0; i < [_model.ImageCount intValue]; i++)
    {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(10*Ratio + (width + 7*Rate_W) * (i%3), 81*Rate_H + 5*Rate_H + (height + 7*Rate_H) * (i/3), width, height)];
        imageV.userInteractionEnabled = YES;
        NSString * imageURL;
        if (i == 0)
        {
            imageURL = _model.Image1;
        }
        else if (i == 1)
        {
            imageURL = _model.Image2;
        }
        else if (i == 2)
        {
            imageURL = _model.Image3;
        }
        else if (i == 3)
        {
            imageURL = _model.Image4;
        }
        else if (i == 4)
        {
            imageURL = _model.Image5;
        }
        else if (i == 5)
        {
            imageURL = _model.Image6;
        }
        [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,imageURL]] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                NSLog(@"获取帖子图片失败！");
            }
            else
            {
//                imageV.image = [self cutImage:image andView:imageV];
                CGFloat scaleH = image.size.height/height;
                
                imageV.image = [FunctionHelper scaleImage:image toScale:scaleH];
                
                CGRect frame = imageV.frame;
                frame.size.width = frame.size.width / scaleH;
                frame.origin.x = imageV_x;
                imageV.frame = frame;
                
                imageV_x = imageV_x + frame.size.width;
            }
        }];
        [_headerView addSubview:imageV];
        UIButton *btn = [[UIButton alloc]initWithFrame:imageV.bounds];
        btn.tag = i+1;
        [btn addTarget:self action:@selector(enLargePicture:) forControlEvents:(UIControlEventTouchUpInside)];
        [imageV addSubview:btn];
    }
    
    UILabel *contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10*Rate_W, 81*Rate_H + 5*Rate_H + (height + 7*Rate_H) * ((imagCount - 1)/3 + 1), SCREENWIDTH - 20*Rate_W, 100*Rate_H)];
    NSString *contentStr = [_model.Content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    CGSize contentSize = [contentStr boundingRectWithSize:CGSizeMake(SCREENWIDTH - 20*Rate_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    contentLable.frame = CGRectMake(10*Rate_W, 81*Rate_H + 5*Rate_H + (height + 7*Rate_H) * ((imagCount - 1)/3 + 1), SCREENWIDTH - 20*Rate_W, contentSize.height);
    contentLable.text = contentStr;
    contentLable.textColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.28 alpha:1.0];
    contentLable.numberOfLines = 0;
    contentLable.font = [UIFont systemFontOfSize:16];
    [_headerView addSubview:contentLable];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentLable.frame)+10, SCREENWIDTH, 1)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [_headerView addSubview:line];
    
    [self createUserInfoViewWithOriginalHeight:CGRectGetMaxY(line.frame)];
}

#pragma mark -- 创建用户信息视图
- (void)createUserInfoViewWithOriginalHeight:(CGFloat)height
{
    UIImageView *headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(10*Rate_W, 15*Rate_H + height, 36*Rate_H, 36*Rate_H)];
    headerImage.layer.cornerRadius = 18*Rate_H;
    headerImage.clipsToBounds = YES;
    [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_headerImage]] placeholderImage:[UIImage imageNamed:@""]];
    [_headerView addSubview:headerImage];
    
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, 15*Rate_H + height, 50*Rate_W, 18*Rate_H)];
    CGSize nameSize = [_patientName boundingRectWithSize:CGSizeMake(MAXFLOAT, 18*Rate_H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14*Rate_NAV_H]} context:nil].size;
    nameLable.frame =CGRectMake(53*Rate_W, 15*Rate_H + height, nameSize.width, 18*Rate_H);
    nameLable.text = _patientName;
    nameLable.textColor = [UIColor colorWithRed:0.39 green:0.41 blue:0.42 alpha:1.0];
    nameLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    nameLable.adjustsFontSizeToFitWidth = YES;
    [_headerView addSubview:nameLable];
    
    UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLable.frame) + 5*Rate_W, 15*Rate_H + height, 34, 15*Rate_H)];
    tag.backgroundColor = [UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0];
    tag.text = @"楼主";
    tag.textColor = [UIColor whiteColor];
    tag.textAlignment = NSTextAlignmentCenter;
    tag.font = [UIFont systemFontOfSize:11*Rate_NAV_H];
    [_headerView addSubview:tag];
    
    _userInfoLable = [[UILabel alloc] initWithFrame:CGRectMake(50*Rate_W, 33*Rate_H + height, SCREENWIDTH - 50*Rate_W, 18*Ratio)];
    _userInfoLable.text = [NSString stringWithFormat:@"发帖 %@   回贴 %@",_publicCount,_replayCount];
    _userInfoLable.textColor = [UIColor colorWithRed:0.62 green:0.64 blue:0.64 alpha:1.0];
    _userInfoLable.font = [UIFont systemFontOfSize:12];
    [_headerView addSubview:_userInfoLable];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_userInfoLable.frame) + 10, SCREENWIDTH, 10)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [_headerView addSubview:line];
    
    _headerView.frame = CGRectMake(0, 0, SCREENWIDTH, CGRectGetMaxY(line.frame)+17);
}

#pragma mark -- 给用户信息部分赋值
- (void)setValueForUserInfo
{
    _userInfoLable.text = [NSString stringWithFormat:@"发帖 %@   回贴 %@",_publicCount,_replayCount];
}

#pragma mark -- 悬浮窗口
- (void)createWindows
{
    _btnView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 46*Rate_H - 64, SCREENWIDTH, 46*Rate_H)];
    _btnView.backgroundColor = [UIColor whiteColor];
    _btnView.userInteractionEnabled = YES;
    [self.view addSubview:_btnView];
    
    UIImageView *collect = [[UIImageView alloc] initWithFrame:CGRectMake(35*Rate_W, 12*Rate_H, 22*Rate_H, 20*Rate_H)];
    [collect setImage:[UIImage imageNamed:@"btn_collection.png"]];
    [_btnView addSubview:collect];
    
    _collectLable = [[UILabel alloc] initWithFrame:CGRectMake(65*Rate_W, 15*Rate_H, 50*Rate_W, 18*Rate_H)];
    if (_model.IsCollect)
    {
        _collectLable.text = @"已收藏";
    }
    else
    {
        _collectLable.text = @"收藏";
    }
    _collectLable.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
    _collectLable.font = [UIFont systemFontOfSize:13*Rate_H];
    [_btnView addSubview:_collectLable];
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(125*Rate_W, 8*Rate_H, 1, 31*Rate_H)];
    line1.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [_btnView addSubview:line1];
    
    UIImageView *favor = [[UIImageView alloc] initWithFrame:CGRectMake(161*Rate_W, 12*Rate_H, 19*Rate_H, 20*Rate_H)];
    [favor setImage:[UIImage imageNamed:@"btn_fabulous.png"]];
    [_btnView addSubview:favor];
    
    _likeLable = [[UILabel alloc] initWithFrame:CGRectMake(188*Rate_W, 15*Rate_H, 27*Rate_W, 18*Rate_H)];
    if (_model.IsFavor)
    {
        _likeLable.text = @"已赞";
        _isLike = YES;
    }
    else
    {
        _likeLable.text = @"点赞";
        _isLike = NO;
    }
    _likeLable.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
    _likeLable.font = [UIFont systemFontOfSize:13*Rate_H];
    [_btnView addSubview:_likeLable];
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(250*Rate_W, 8*Rate_H, 1, 31*Rate_H)];
    line2.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [_btnView addSubview:line2];
    
    UIImageView *comment = [[UIImageView alloc] initWithFrame:CGRectMake(286*Rate_W, 12*Rate_H, 20*Rate_H, 20*Rate_H)];
    [comment setImage:[UIImage imageNamed:@"btn_comment.png"]];
    [_btnView addSubview:comment];
    
    UILabel *commentLable = [[UILabel alloc] initWithFrame:CGRectMake(315*Rate_W, 13*Rate_H, 27*Rate_W, 18*Rate_H)];
    commentLable.text = @"评论";
    commentLable.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
    commentLable.font = [UIFont systemFontOfSize:13*Rate_H];
    [_btnView addSubview:commentLable];
    
    for (int i = 0; i < 3; i ++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH*i)/3, 0, SCREENWIDTH/3, 46*Rate_H)];
        [btn addTarget:self action:@selector(postOperation:) forControlEvents:(UIControlEventTouchUpInside)];
        btn.tag = i+10;
        [_btnView addSubview:btn];
    }
}

#pragma  mark -- 创建TableView
- (void)createTableView
{
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 46*Rate_H - 64) style:(UITableViewStylePlain)];
    _tableV.showsVerticalScrollIndicator = NO;
    _tableV.showsHorizontalScrollIndicator = NO;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    //上拉刷新
    _tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    [self createPostTitle];
    _tableV.tableHeaderView = _headerView;
    _tableV.userInteractionEnabled = YES;
    [self.view addSubview:_tableV];
}

#pragma mark -- 上拉加载数据
- (void)loadMoreTopic
{
    int count = [_page intValue];
    count = count+1;
    _page = [NSString stringWithFormat:@"%d",count];
    [_tableV.mj_footer endRefreshing];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"加载中";
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeGetPostComment) andDictionary:@{@"postID":_model.PostID,@"page":_page}];
    req.timeoutInterval = 5.0;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError)
        {
            hud.labelText = @"加载失败，网络繁忙";
            [hud hide:YES afterDelay:0.5];
            [self createGetDataFailureViewWithError:@"网络繁忙,请稍后再试" withFrame:CGRectMake(0, _headerView.frame.size.height, SCREENWIDTH, _tableV.frame.size.height-_headerView.frame.size.height)];
        }
        else
        {
            if (data)
            {
                hud.labelText = @"加载完成";
                [hud hide:YES afterDelay:0.1];
                [self prepareCommentInfoWithData:data];
                [_tableV reloadData];
            }
            else
            {
                hud.labelText = @"加载失败";
                [hud hide:YES afterDelay:0.5];
                [self createGetDataFailureViewWithError:@"获取数据失败" withFrame:CGRectMake(0, _headerView.frame.size.height, SCREENWIDTH, _tableV.frame.size.height-_headerView.frame.size.height)];
            }
        }
    }];
}

#pragma mark -- tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 47;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 47)];
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(14, 9, SCREENWIDTH-28, 20)];
        lable.text = [NSString stringWithFormat:@"热门评论(%@)",_model.CommentCount];
        lable.font = [UIFont systemFontOfSize:14];
        [view addSubview:lable];
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, SCREENWIDTH, 10)];
        line.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
        [view addSubview:line];
        return view;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"detailCommentCellID";
    PostCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[PostCommentCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    }
    cell.model = _dataSource[indexPath.row];
    
    return cell;
}

#pragma mark -- 收藏、点赞、评论
- (void)postOperation:(UIButton *)sender
{
    if (sender.tag == 10)
    {
        if(!_model.IsCollect)
        {
            if ([self updatePostCountWithType:@"3"])
            {
                _collectLable.text = @"已收藏";
                _model.IsCollect = YES;
                [self showHint:@"已收藏"];
            }
        }
        else
        {
            if ([self DeleteCollectetedPost])
            {
                _collectLable.text = @"收藏";
                _model.IsCollect = NO;
                [self showHint:@"取消收藏"];
            }
        }
    }
    else if (sender.tag == 11)
    {
        _isLike = !_isLike;
        if (_isLike)
        {
            [self showHint:@"点赞+1"];
            if ([self updatePostFavorCountWithState:@"1"])
            {
                int count = [_favorLable.text intValue];
                _favorLable.text = [NSString stringWithFormat:@"%i",count+1];
                _likeLable.text = @"已赞";
            }
        }
        else
        {
            [self showHint:@"取消点赞"];
            if ([self updatePostFavorCountWithState:@"0"])
            {
                int count = [_favorLable.text intValue];
                _favorLable.text = [NSString stringWithFormat:@"%i",count-1];
                _likeLable.text = @"点赞";
            }
        }
    }
    else if (sender.tag == 12)
    {
        _btnView.hidden = YES;
        [self createCommentToolBar];
    }
}

#pragma mark -- 帖子点赞
- (BOOL)updatePostFavorCountWithState:(NSString *)state
{
    //帖子的点赞数加1
    NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUpdatePostFavorCount) andDictionary:@{@"patientID":_model.PatientID,@"postID":_model.PostID,@"state":state}];
    req.timeoutInterval = 3;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    if (data)
    {
        //两者皆返回成功
        if([[_handle objectFromeResponseString:data andType:(DataModelBackTypeUpdatePostFavorCount)] isEqualToString:@"OK"])
        {
            return YES;
        }
        else
        {
            [self showHint:@"点赞失败"];
            return NO;
        }
    }
    else
    {
        [self showHint:@"服务器出错"];
        return NO;
    }
}

#pragma mark -- 删除收藏的帖子
- (BOOL)DeleteCollectetedPost
{
    NSData *data = [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeDeleteCollectedPost) andDictionary:@{@"postID":_model.PostID,@"patientID":_patientInfo.PatientID}];
    if([[_handle objectFromeResponseString:data andType:(DataModelBackTypeDeleteCollectedPost)] isEqualToString:@"OK"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -- 修改帖子数据
- (BOOL)updatePostCountWithType:(NSString *)type
{
    if([type intValue] == 3)
    {
        //帖子的收藏数加1
        NSMutableURLRequest *req1 = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPostCount) andDictionary:@{@"postID":_model.PostID,@"type":type}];
        req1.timeoutInterval = 3;
        NSData *data1 = [NSURLConnection sendSynchronousRequest:req1 returningResponse:nil error:nil];
        
        //加入我的收藏
        NSLog(@"join = %@",_patientInfo.PatientID);
        NSMutableURLRequest *req2 = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeCollectedPost) andDictionary:@{@"postID":_model.PostID,@"patientID":_patientInfo.PatientID}];
        req2.timeoutInterval = 3;
        NSData *data2 = [NSURLConnection sendSynchronousRequest:req2 returningResponse:nil error:nil];
        //两者皆成功
        if (data1 && data2)
        {
            //两者皆返回成功
            if([[_handle objectFromeResponseString:data1 andType:(DataModelBackTypeUploadPostCount)] isEqualToString:@"OK"] && [[_handle objectFromeResponseString:data2 andType:(DataModelBackTypeCollectedPost)] isEqualToString:@"OK"])
            {
                return YES;
            }
            else
            {
                [self showHint:@"收藏失败"];
                return NO;
            }
        }
        else
        {
            [self showHint:@"服务器出错"];
            return NO;
        }
    }
    else if ([type intValue] == 2)
    {
        //帖子的点赞数加1
        NSMutableURLRequest *req = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPostCount) andDictionary:@{@"postID":_model.PostID,@"type":type}];
        req.timeoutInterval = 3;
        NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
        if (data)
        {
            //两者皆返回成功
            if([[_handle objectFromeResponseString:data andType:(DataModelBackTypeUploadPostCount)] isEqualToString:@"OK"])
            {
                return YES;
            }
            else
            {
                [self showHint:@"点赞失败"];
                return NO;
            }
        }
        else
        {
            [self showHint:@"服务器出错"];
            return NO;
        }
    }
    else
    {
        //帖子的评论数加1
        NSMutableURLRequest *req1 = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPostCount) andDictionary:@{@"postID":_model.PostID,@"type":type}];
        req1.timeoutInterval = 3;
        NSData * data1 = [NSURLConnection sendSynchronousRequest:req1 returningResponse:nil error:nil];
        
        //修改我的回复数
        NSMutableURLRequest *req2 = [_handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPatientCount) andDictionary:@{@"patientID":_patientInfo.PatientID,@"type":@"2"}];
        req2.timeoutInterval = 3;
        NSData *data2 = [NSURLConnection sendSynchronousRequest:req2 returningResponse:nil error:nil];
        //两者皆成功
        if (data1 && data2)
        {
            //两者皆返回成功
            if([[_handle objectFromeResponseString:data1 andType:(DataModelBackTypeUploadPostCount)] isEqualToString:@"OK"] && [[_handle objectFromeResponseString:data2 andType:(DataModelBackTypeUploadPatientCount)] isEqualToString:@"OK"])
            {
                //更新服务器积分
                InterfaceModel *mod = [[InterfaceModel alloc] init];
                [mod uploadPointToServer:_patientInfo.PatientID pointType:@"6"];
                
                return YES;
            }
            else
            {
                return NO;
            }
        }
        else
        {
            [self showHint:@"服务器出错"];
            return NO;
        }
    }
}

#pragma mark -- 上传评论
- (void)uploadCommentWithContent:(NSString *)content
{
    
    NSMutableURLRequest *req = [_handle GenerateRequestWithJsonType:(DataModelBackTypeUploadPostComment) andDictionary:@{
                                                                                                                         @"PostID":_model.PostID,
                                                                                                                         @"CommentID":[NSString stringWithFormat:@"%@_%@",_patientInfo.PatientID,[FunctionHelper getNowTimeInterval]],
                                                                                                                         @"CommentContent":content,
                                                                                                                         @"IsHot":@"0",
                                                                                                                         @"PatientID":_patientInfo.PatientID,
                                                                                                                         @"CommentTime":[self getCurrentDate]}];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"上传评论中";
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data)
        {
            BOOL upload = NO;
            BOOL update = NO;
            NSString *result = [_handle objectFromeResponseString:data andType:DataModelBackTypeUploadPostComment];
            if ([result isEqualToString:@"OK"])
            {
                upload = YES;
                update = [self updatePostCountWithType:@"4"];
            }
            if (upload && update)
            {
                if (_failureV)
                {
                    [_failureV removeFromSuperview];
                }
                hud.labelText = @"评论上传成功";
                [hud hide:YES afterDelay:0.1];
                _commentLable.text = [NSString stringWithFormat:@"%i",[_commentLable.text intValue]+1];
                [self getCommentInfoFromDataWorkAndGetPostDetail:NO];
            }
            else if(upload && !update)
            {
                hud.labelText = @"数据更新失败";
                [hud hide:YES afterDelay:0.5];
                [self getCommentInfoFromDataWorkAndGetPostDetail:NO];
            }
            else if(!upload)
            {
                hud.labelText = @"数据上传失败";
                [hud hide:YES afterDelay:0.5];
            }
        }
        else
        {
            hud.labelText = @"数据上传失败";
            [hud hide:YES afterDelay:0.5];
        }
    }];
}

#pragma mark -- 键盘通知
- (void)keyboardWillChangeFrameNotification:(NSNotification *)note
{
    //取出键盘动画的时间(根据userInfo的key----UIKeyboardAnimationDurationUserInfoKey)
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //取得键盘最后的frame(根据userInfo的key----UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 227}, {320, 253}}";)
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
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

#pragma mark -- 单击手势
- (void)handleSingleTapFrom
{
    [_inputBar removeFromSuperview];
    _btnView.hidden = NO;
}

- (NSString * )getCurrentDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return  [formatter stringFromDate:[NSDate date]];
}

- (void)enLargePicture:(UIButton *)btn
{
    NSMutableArray *networkImages = [NSMutableArray array];
    for (int i = 0; i < [_model.ImageCount  intValue]; i++)
    {
        NSString *photoURL;
        if (i == 0)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image1];
            [networkImages addObject:photoURL];
        }
        else if (i == 1)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image2];
            [networkImages addObject:photoURL];
        }
        else if (i == 2)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image3];
            [networkImages addObject:photoURL];
        }
        else if (i == 3)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image4];
            [networkImages addObject:photoURL];
        }
        else if (i == 4)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image5];
            [networkImages addObject:photoURL];
        }
        else if (i == 5)
        {
            photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image6];
            [networkImages addObject:photoURL];
        }
    }
    [ImageBrowserViewController show:self type:PhotoBroswerVCTypeModal index:btn.tag-1 imagesBlock:^NSArray *{
        return networkImages;
    }];
}

- (void)chaImage:(UIButton *)btn
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.userInteractionEnabled = YES;
    [self.view.window addSubview:imageView];
    
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseImage:)];
    [imageView addGestureRecognizer:tapImageView];
    NSString * photoURL;
    if (btn.tag == 1)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image1];
    }
    else if (btn.tag == 2)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image2];
    }
    else if (btn.tag == 3)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image3];
    }
    else if (btn.tag == 4)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image4];
    }
    else if (btn.tag == 5)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image5];
    }
    else if (btn.tag == 6)
    {
        photoURL = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_model.Image6];
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:nil];
}

//裁剪图片
- (UIImage *)cutImage:(UIImage*)image andView:(UIView *)myView
{
    CGSize newSize;
    CGImageRef imageRef = nil;
    
    if ((image.size.width / image.size.height) < myView.frame.size.width / myView.frame.size.height)
    {
        newSize.height = image.size.height;
        newSize.width = image.size.height * myView.frame.size.width / myView.frame.size.height;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, (image.size.height - myView.frame.size.height)/2, newSize.width, newSize.height));
    }
    else if ((image.size.width / image.size.height) >= myView.frame.size.width / myView.frame.size.height)
    {
        newSize.width = image.size.width;
        newSize.height = image.size.width * myView.frame.size.height / myView.frame.size.width;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake((image.size.width - myView.frame.size.width)/2, 0, newSize.width, newSize.height));
    }
    
    return [UIImage imageWithCGImage:imageRef];
}

- (void)CloseImage:(UITapGestureRecognizer *)tap
{
    [tap.view removeFromSuperview];
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
