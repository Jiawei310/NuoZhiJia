//
//  SymptomDescViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/11/2.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "SymptomDescViewController.h"
#import "CustomerChatViewController.h"
#import "DataHandle.h"
#import "ConsultQuestionModel.h"
#import "GaugeViewController.h"
#import "FunctionHelper.h"
#import "EMClient.h"
#import <UMMobClick/MobClick.h>
#import "Define.h"

#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"
#import "MBProgressHUD.h"
#import "TZVideoPlayerController.h"

#define BOOKMARK_WORD_LIMIT 100

@interface SymptomDescViewController ()<UITextViewDelegate,TZImagePickerControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UITextView *textV; //症状描述
@property (strong, nonatomic) UILabel *countLable; //照片数量
@property (strong, nonatomic) UIView *descripeView; //症状描述
@property (strong, nonatomic) UIView *judgeView; //是否去过医院
@property (strong, nonatomic) UIImagePickerController *imagePickerVc;//照片选择
@property (strong, nonatomic) NSMutableArray *selectedPhotos;//图片选择
@property (strong, nonatomic) NSMutableArray *selectedAssets;
@property (strong, nonatomic) ConsultQuestionModel * model;
@property (copy, nonatomic)  DataHandle *handle;
@property (strong, nonatomic) EMMessage *imageMessage1;
@property (strong, nonatomic) EMMessage *imageMessage2;
@property (strong, nonatomic) EMMessage *imageMessage3;
@property (strong, nonatomic) EMMessage *imageMessage4;
@property (strong, nonatomic) EMMessage *imageMessage5;

@end

@implementation SymptomDescViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏恢复
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navagation_backImage"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    
    [MobClick beginLogPageView:@"症状描述"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //隐藏tabbar
    self.tabBarController.tabBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SumbitQuestion" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [MobClick endLogPageView:@"症状描述"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"症状描述";
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
    
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDataForSubmit) name:@"SumbitQuestion" object:nil];
    _selectedPhotos  = [NSMutableArray array];
    _selectedAssets  = [NSMutableArray array];
    _handle = [[DataHandle alloc] init];
    [self createTextView];
    [self createPictureView];
    [self createAskView];
    [self createSubmitButton];
    [self createScaleTestWithTime:2];
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 创建症状描述
- (void)createTextView
{
    self.descripeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 246*Ratio)];
    self.descripeView.backgroundColor = [UIColor whiteColor];
    self.descripeView.userInteractionEnabled = YES;
    [self.view addSubview:self.descripeView];
    
    self.textV = [[UITextView alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 12*Rate_NAV_H, 345*Rate_NAV_W, 171*Rate_NAV_H)];
    self.textV.text = @"请输入您的症状描述....";
    self.textV.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    self.textV.textColor = [UIColor lightGrayColor];
    self.textV.delegate = self;
    [self.descripeView addSubview:self.textV];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 195*Rate_NAV_H, 345*Rate_NAV_W, Rate_NAV_H)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [self.descripeView addSubview:line];
}

#pragma mark -- 创建图片选择区域
- (void)createPictureView
{
    UIButton *pictureView = [[UIButton alloc] initWithFrame:CGRectMake(17*Rate_NAV_W, 217*Rate_NAV_H, 26*Rate_NAV_H, 22*Rate_NAV_H)];
    [pictureView setBackgroundImage:[UIImage imageNamed:@"icon_picture.png"] forState:(UIControlStateNormal)];
    [pictureView addTarget:self action:@selector(pictureChoose) forControlEvents:(UIControlEventTouchUpInside)];
    [self.descripeView addSubview:pictureView];
    
    for (int i = 0; i < 5; i++)
    {
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake((96+54*i)*Rate_NAV_W, 205*Rate_NAV_H, 48*Rate_NAV_W, 34*Rate_NAV_H)];
        picture.tag = i+100;
        picture.userInteractionEnabled = YES;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(48*Rate_NAV_W - 12*Rate_NAV_H, 0, 12*Rate_NAV_H, 12*Rate_NAV_H)];
        [btn setTitle:@"X" forState:(UIControlStateNormal)];
        [btn setBackgroundColor:[UIColor colorWithRed:0.67 green:0.57 blue:0.60 alpha:1.0]];
        btn.tag = i+100;
        [btn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        [picture addSubview:btn];
        picture.hidden = YES;
        [self.descripeView addSubview:picture];
    }
    _countLable = [[UILabel alloc] initWithFrame:CGRectMake(54*Rate_NAV_W, 221*Rate_NAV_H, 34*Rate_NAV_W, 20*Rate_NAV_H)];
    _countLable.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _countLable.text = @"(0/5)";
    _countLable.adjustsFontSizeToFitWidth = YES;
    [self.descripeView addSubview:_countLable];
}
#pragma mark -- 询问是否去过医院
- (void)createAskView
{
    _judgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 247*Rate_NAV_H, SCREENWIDTH, 49*Rate_NAV_H)];
    _judgeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_judgeView];
    
    UILabel *askLable = [[UILabel alloc] initWithFrame:CGRectMake(15*Rate_NAV_W, 13.5*Rate_NAV_H, 169*Rate_NAV_W, 22*Rate_NAV_H)];
    askLable.text = @"是否去过医院?";
    askLable.font = [UIFont systemFontOfSize:16*Rate_NAV_H];
    [_judgeView addSubview:askLable];
    
    UIButton *yesBtn = [[UIButton alloc] initWithFrame:CGRectMake(190*Rate_NAV_W, 9.5*Rate_NAV_H, 80*Rate_NAV_W, 30*Rate_NAV_H)];
    [yesBtn setBackgroundImage:[UIImage imageNamed:@"btn_yse.png"] forState:(UIControlStateNormal)];
    [yesBtn addTarget:self action:@selector(isHosptial:) forControlEvents:(UIControlEventTouchUpInside)];
    yesBtn.tag = 1;
    [_judgeView addSubview:yesBtn];
    
    UIButton *noBtn = [[UIButton alloc] initWithFrame:CGRectMake(280*Rate_NAV_W, 9.5*Rate_NAV_H, 80*Rate_NAV_W, 30*Rate_NAV_H)];
    [noBtn setBackgroundImage:[UIImage imageNamed:@"btn_no.png"] forState:(UIControlStateNormal)];
    [noBtn addTarget:self action:@selector(isHosptial:) forControlEvents:(UIControlEventTouchUpInside)];
    noBtn.tag = 2;
    [_judgeView addSubview:noBtn];
}

#pragma mark -- 是否进行过量表测评
- (void)createScaleTestWithTime:(NSInteger)time
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 307*Rate_NAV_H, SCREENWIDTH, 60*Rate_NAV_H)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UIImageView *edit = [[UIImageView alloc] initWithFrame:CGRectMake(16*Rate_NAV_W, 15*Rate_NAV_H, 25*Rate_NAV_H, 27*Rate_NAV_H)];
    if (time == 1)
    {
        edit.image = [UIImage imageNamed:@"icon_time.png"];
    }
    else
    {
        edit.image = [UIImage imageNamed:@"icon_evaluating.png"];
    }
    [view addSubview:edit];
    
    UILabel *scaleLable = [[UILabel alloc] initWithFrame:CGRectMake(52*Rate_NAV_W, 9*Rate_NAV_H, 202*Rate_NAV_W, 40*Rate_NAV_H)];
    scaleLable.text = @"量表评测能帮助医生精准诊断，是否现在评测？";
    scaleLable.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    scaleLable.numberOfLines = 0;
    [view addSubview:scaleLable];
    
    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(265*Rate_NAV_W, 12*Rate_NAV_H, 95*Rate_NAV_W, 35*Rate_NAV_H)];
    [testButton setBackgroundImage:[UIImage imageNamed:@"btn_evaluating.png"] forState:(UIControlStateNormal)];
    [testButton addTarget:self action:@selector(testClick) forControlEvents:(UIControlEventTouchUpInside)];
    [view addSubview:testButton];
}

#pragma mark -- 创建提交按钮
- (void)createSubmitButton
{
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - 292)/2, 480*Rate_NAV_H, 292, 44)];
    submit.layer.cornerRadius = 22;
    submit.clipsToBounds = YES;
    submit.backgroundColor = [UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0];
    [submit setTitle:@"提交问题" forState:(UIControlStateNormal)];
    [submit addTarget:self action:@selector(submitClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:submit];
}

- (UIImagePickerController *)imagePickerVc
{
    if (_imagePickerVc == nil)
    {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later)
        {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        }
        else
        {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    
    return _imagePickerVc;
}

#pragma mark -- 删除图片
- (void)deleteClick:(UIButton *)sender
{
    if (_selectedPhotos.count > 0)
    {
        [_selectedPhotos removeObjectAtIndex:_selectedPhotos.count-(5-(sender.tag-100)-1)-1];
        [_selectedAssets removeObjectAtIndex:_selectedAssets.count-(5-(sender.tag-100)-1)-1];
        for (int i = 0; i < _selectedPhotos.count; i++)
        {
            UIImageView *imageV = (UIImageView *)[self.descripeView viewWithTag:104-(_selectedPhotos.count-i-1)];
            imageV.hidden = NO;
            imageV.image = _selectedPhotos[i];
        }
        _countLable.text = [NSString stringWithFormat:@"(%lu/5)",(unsigned long)_selectedPhotos.count];
        for (int i = 0; i < 5-_selectedPhotos.count; i++)
        {
            UIImageView *imageV = (UIImageView *)[self.descripeView viewWithTag:i+100];
            imageV.hidden = YES;
        }
        _countLable.text = [NSString stringWithFormat:@"(%lu/5)",(unsigned long)_selectedPhotos.count];
    }
}

#pragma mark -- textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqual:@"请输入您的症状描述...."])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual:@""])
    {
        textView.text = @"请输入您的症状描述....";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    //该判断用于联想输入
    if (textView.text.length > BOOKMARK_WORD_LIMIT)
    {
        textView.text = [textView.text substringToIndex:BOOKMARK_WORD_LIMIT];
    }
}

#pragma mark -- 触碰屏幕收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textV resignFirstResponder];
}

//#warning 此处添加了立即评测的跳转
#pragma mark -- 立即进行量表测评
- (void)testClick
{
    GaugeViewController *gauge = [[GaugeViewController alloc] init];
    gauge.typeFlag = @"Symptom";
    [self.navigationController pushViewController:gauge animated:YES];
}

#pragma mark -- 选择图片
- (void)pictureChoose
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"去相册选择", nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    { // take photo / 去拍照
        [self takePhoto];
    }
    else if (buttonIndex == 1)
    {
        [self pushImagePickerController];
    }
}

#pragma mark - TZImagePickerController
- (void)pushImagePickerController
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:5 delegate:self];
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
#pragma mark - 到这里为止
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    for (int i = 0; i < _selectedPhotos.count; i++)
    {
        UIImageView * imageV = (UIImageView *)[self.descripeView viewWithTag:104-(_selectedPhotos.count-i-1)];
        imageV.hidden = NO;
        imageV.image = _selectedPhotos[i];
    }
    
    for (int i = 0; i < 5-_selectedPhotos.count; i++)
    {
        UIImageView * imageV = (UIImageView *)[self.descripeView viewWithTag:i+100];
        imageV.hidden = YES;
    }
    _countLable.text = [NSString stringWithFormat:@"(%lu/5)",(unsigned long)_selectedPhotos.count];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:5 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = YES;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image completion:^{
            [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                    [tzImagePickerVc hideProgressHUD];
                    TZAssetModel *assetModel = [models firstObject];
                    if (tzImagePickerVc.sortAscendingByModificationDate)
                    {
                        assetModel = [models lastObject];
                    }
                    [_selectedAssets addObject:assetModel.asset];
                    [_selectedPhotos addObject:image];
                    for (int i = 0; i < _selectedPhotos.count; i++)
                    {
                        UIImageView * imageV = (UIImageView *)[self.descripeView viewWithTag:104-(_selectedPhotos.count-i-1)];
                        imageV.hidden = NO;
                        imageV.image = _selectedPhotos[i];
                    }
                    for (int i = 0; i < 5-_selectedPhotos.count; i++)
                    {
                        UIImageView * imageV = (UIImageView *)[self.descripeView viewWithTag:i+100];
                        imageV.hidden = YES;
                    }
                    _countLable.text = [NSString stringWithFormat:@"(%lu/5)",(unsigned long)_selectedPhotos.count];
                }];
            }];
        }];
    }
}

#pragma mark - UIImagePickerController
- (void)takePhoto
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS8Later)
    {
        // 无权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1001;
        [alert show];
    }
    else
    { // 调用相机
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            self.imagePickerVc.sourceType = sourceType;
            if(iOS8Later)
            {
                _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:_imagePickerVc animated:YES completion:nil];
        }
        else
        {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        if (buttonIndex == 1)
        { // 去设置界面，开启相机访问权限
            if (iOS8Later)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
            }
        }
    }
    else if (alertView.tag == 1000)
    {
        if (buttonIndex == 1)
        {
            [self prepareDataForSubmit];
        }
    }
}

#pragma mark -- 提交问题的数据准备
- (void)prepareDataForSubmit
{
    //获取当前时间
    NSString *date = [self getCurrentTime];
    //上传数据
    _model = [[ConsultQuestionModel alloc] init];
    _model.patientID = [PatientInfo shareInstance].PatientID;
    _model.questionID = [self getQuestionIDWithPatientID:_model.patientID];
    NSString *content = _textV.text;
    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    _model.question = content;
    _model.startTime = date;
    _model.doctorID = [self selectedDoctor:@""];
    [self sendMessageWithTime:date];
}

#pragma mark -- 删选医生
- (NSString *)selectedDoctor:(NSString *)patientID
{
//    NSArray *doctors = @[@"test2"];
//    if([patientID isEqual:@""])
//    {
//        int x = arc4random() % (doctors.count);
//        [[NSUserDefaults standardUserDefaults] setObject:doctors[x] forKey:@"currentDoctorID"];
//        
//        return doctors[x];
//    }
//    else
//    {
//        while (1)
//        {
//            int x = arc4random() % (doctors.count);
//            if (![doctors[x] isEqualToString:patientID])
//            {
//                [[NSUserDefaults standardUserDefaults] setObject:doctors[x] forKey:@"currentDoctorID"];
//                
//                return doctors[x];
//                break;
//            }
//        }
//    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_currentID forKey:@"currentDoctorID"];
    
    return _currentID;
}

#pragma mark -- 提交问题
- (void)submitClick
{
    if ([self.textV.text isEqual:@""] || [self.textV.text isEqualToString:@"请输入您的症状描述...."])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"症状描述未填写" message:@"请填写您的症状描述" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提交问题" message:@"确定提交您的问题？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.tag = 1000;
        [alert show];
    }
}

#pragma mark -- 是否去过医院
- (void)isHosptial:(UIButton *)sender
{
    if(sender.tag == 1)
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"btn_yse_in.png"] forState:(UIControlStateNormal)];
        _isHospital = @"YES";
        UIButton *btn = (UIButton *)[self.judgeView viewWithTag:2];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_no.png"] forState:(UIControlStateNormal)];
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"btn_no_in.png"] forState:(UIControlStateNormal)];
        _isHospital = @"NO";
        UIButton *btn = (UIButton *)[self.judgeView viewWithTag:1];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_yse.png"] forState:(UIControlStateNormal)];
    }
}

#pragma mark --提交问题上传数据
//-(void)uploadInfoAboutQuestion{
//    NSData * data = [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadQuestionInfo) andDictionary:@{@"QuestionID":[self getQuestionIDWithPatientID:_model.patientID],@"Question":_model.question,@"StartTime":_model.startTime,@"IsHospital":@"0",@"PatientID":_model.patientID,@"Name":@"",@"Sex":@"",@"Birth":@"",@"DoctorID":_model.doctorID}];
//    [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadLeaveNumber) andDictionary:@{@"LeaveNumber":@"-1",@"PatientID":_model.patientID}];
//    [self sendMessageWithTime:_model.startTime];
//}

#pragma mark -- 发送消息
- (void)sendMessageWithTime:(NSString *)date
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isRecieve"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCreateChatView"];
    //清空聊天记录
    [[EMClient sharedClient].chatManager deleteConversation:_model.doctorID isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
    }];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"正在提交问题";
    //文字消息
    EMTextMessageBody *bodyText = [[EMTextMessageBody alloc] initWithText:_textV.text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    //用户信息生成扩展信息
    NSDictionary *messageExt = [[NSDictionary alloc] initWithObjectsAndKeys:_model.patientID, @"name", @"", @"birth", @"", @"sex",@"0", @"isHospital", nil];
    //生成Message
    EMMessage *messageText = [[EMMessage alloc] initWithConversationID:_model.doctorID from:from to:_model.doctorID body:bodyText ext:messageExt];
    messageText.chatType = EMChatTypeChat;// 设置为单聊消息
    [[EMClient sharedClient].chatManager sendMessage:messageText progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
        //若发送消息成功
        if (!aError)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadQuestionInfo) andDictionary:@{@"QuestionID":_model.questionID,@"Question":_model.question,@"StartTime":_model.startTime,@"IsHospital":@"0",@"PatientID":[PatientInfo shareInstance].PatientID,@"Name":@"",@"Sex":@"",@"Birth":@"",@"DoctorID":_model.doctorID}];
                BOOL questionResult = NO;
                if ([[_handle objectFromeResponseString:data andType:(DataModelBackTypeUploadQuestionInfo)] isEqualToString:@"OK"])
                {
                    questionResult = YES;
                }
                BOOL result = [FunctionHelper uploadHistoryChatMessageWithMessage:messageText withQuestionID:_model.questionID];
//#warning 将发送图片分装
                [self sendPictureMessage];
                if (questionResult && result)
                {
                    NSData *leaveData =  [_handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadLeaveNumber) andDictionary:@{@"LeaveNumber":@"-1",@"PatientID":_model.patientID}];
                    if ([[_handle objectFromeResponseString:leaveData andType:(DataModelBackTypeUploadLeaveNumber)] isEqualToString:@"OK"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:_model.questionID forKey:@"currentQuestionID"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[EMClient sharedClient].contactManager addContact:_model.doctorID message:@""];
                            CustomerChatViewController *consult = [[CustomerChatViewController alloc] initWithConversationChatter:_model.doctorID];
                            consult.time = _model.startTime;
                            consult.question = _model.question;
                            consult.questionID = _model.questionID;
                            consult.doctorID = _model.doctorID;
                            [self.navigationController pushViewController:consult animated:YES];
                        });
                    }
                    else
                    {
                        hud.labelText = @"服务器繁忙,请稍后提交";
                        [hud hide:YES afterDelay:2];
                    }
                }
                else
                {
                    hud.labelText = @"服务器繁忙,请稍后提交";
                    [hud hide:YES afterDelay:2];
                }
            });
            [hud hide:YES afterDelay:0];
            [hud removeFromSuperViewOnHide];
        }
        else
        {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"问题提交" message:@"问题提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertV show];
            [hud hide:YES afterDelay:0];
            [hud removeFromSuperViewOnHide];
        }
    }];
//#warning 去除原本的
}

//#warning 添加发送图片方法
#pragma mark -- 发送图片
- (void)sendPictureMessage
{
    if(_selectedPhotos.count > 0)
    {
        NSString *from = [[EMClient sharedClient] currentUsername];
        for (int i = 0; i < _selectedPhotos.count; i++)
        {
            //将图片转化为字节流发送
            NSData *data;
            if (UIImagePNGRepresentation(_selectedPhotos[i]) == nil)
            {
                data = UIImageJPEGRepresentation(_selectedPhotos[i], 1);
            }
            else
            {
                data = UIImagePNGRepresentation(_selectedPhotos[i]);
            }
            //图片消息
            EMImageMessageBody *bodyImage = [[EMImageMessageBody alloc] initWithData:data displayName:@"image.png"];
            //生成Message
            EMMessage *message = [[EMMessage alloc] initWithConversationID:_model.doctorID from:from to:_model.doctorID body:bodyImage ext:nil];
            message.chatType = EMChatTypeChat;// 设置为单聊消息
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                //若图片发送成功
                if (!aError)
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        BOOL result =  [FunctionHelper uploadHistoryChatMessageWithMessage:message withQuestionID:_model.questionID];
                        if (result)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                            });
                        }
                        else
                        {
                            
                        }
                    });
                }
                else
                {
                    //                    UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"问题提交" message:@"图片提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    //                    [alertV show];
                }
            }];
        }
    }
}

#pragma mark -- 获取时间
- (NSString *)getCurrentTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

- (NSString *)getQuestionIDWithPatientID:(NSString *)patientID
{
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    if (patientID.length == 11)
    {
        patientID = [patientID substringFromIndex:7];
    }
    return [NSString stringWithFormat:@"%@_%llu",patientID,theTime];
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
