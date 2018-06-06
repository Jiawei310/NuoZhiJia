//
//  PublicPostViewController.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PublicPostViewController.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "Define.h"
#import <UMMobClick/MobClick.h>
#import "InterfaceModel.h"

#import "FunctionHelper.h"
#import "DataHandle.h"

#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "UIViewController+HUD.h"
#import "MBProgressHUD.h"

@interface PublicPostViewController ()<UITextViewDelegate,UITextFieldDelegate,TZImagePickerControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>
{
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
}

@property (strong, nonatomic) UIImagePickerController *imagePickerVc;
@property (strong, nonatomic) UITextField *titleFiled;
@property (strong, nonatomic) UITextView *postView;
@property (strong, nonatomic) UIView *inputView;
@property (strong, nonatomic) UISwitch *public;
@property (copy, nonatomic) NSString *patientID; //用户ID
@property (copy, nonatomic) NSString *patientName; //用户姓名
@property (copy, nonatomic) NSString *postContent; //帖子的内容
@property (copy, nonatomic) NSString *postType; //帖子的类别
@property (copy, nonatomic) NSString *postTitle; //帖子的标题
@property (copy, nonatomic) NSString *ImageCount; //帖子的图片数
@property (copy, nonatomic) NSString *image1; //帖子的图片1
@property (copy, nonatomic) NSString *image2; //帖子的图片2
@property (copy, nonatomic) NSString *image3; //帖子的图片3
@property (copy, nonatomic) NSString *image4; //帖子的图片4
@property (copy, nonatomic) NSString *image5; //帖子的图片5
@property (copy, nonatomic) NSString *image6; //帖子的图片6
@property (nonatomic) BOOL isSet;


@end

@implementation PublicPostViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:_titleFiled];
    
    [MobClick beginLogPageView:@"发帖"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除键盘监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:_titleFiled];
    [[NSNotificationCenter defaultCenter] removeObserver:self];//移除self所有通知
    
    [MobClick endLogPageView:@"发帖"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发帖";
    
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
    
    UIButton *releaseButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 22, 40, 20)];
    [releaseButton setTitle:@"发布" forState:(UIControlStateNormal)];
    [releaseButton addTarget:self action:@selector(publicPost) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *releaseButtonItem = [[UIBarButtonItem alloc] initWithCustomView:releaseButton];
    self.navigationItem.rightBarButtonItem = releaseButtonItem;
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    if(![FunctionHelper isExistenceNetwork])
    {
        [self showHint:@"请检查网络连接"];
    }
    _patientID = [PatientInfo shareInstance].PatientID;
    if([FunctionHelper isBlankString:[PatientInfo shareInstance].PatientName])
    {
        _patientName = [NSString stringWithFormat:@"眠友%@",[_patientID substringFromIndex:7]];
        [self createTitleViewWithHeight:40*Rate_NAV_H];
        [self createInputViewWithOriginalHeight:230*Rate_NAV_H];
    }
    else
    {
        _patientName = [PatientInfo shareInstance].PatientName;
        _isSet = YES;
        [self createTitleViewWithHeight:0];
        [self createInputViewWithOriginalHeight:190*Rate_NAV_H];
    }
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    _postContent = @"";
    _image1 = @"";
    _image2 = @"";
    _image3 = @"";
    _image4 = @"";
    _image5 = @"";
    _image6 = @"";
    _ImageCount = @"0";
}

- (void)backLoginClick:(UIButton *)click
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 发布帖子
- (void)publicPost
{
    if ([FunctionHelper isExistenceNetwork])
    {
        if ([_postTitle isEqual:@""])
        {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"帖子标题" message:@"请输入帖子标题，长度为4-25个字符" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertV show];
        }
        else if (_postTitle.length < 4)
        {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"帖子标题" message:@"标题长度为4-25字符" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertV show];
        }
        else if ([_postContent isEqual:@""])
        {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"帖子内容" message:@"请输入帖子内容" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertV show];
        }
        else
        {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"发布帖子" message:@"是否发布该贴？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发布", nil];
            alertV.tag = 1000;
            [alertV show];
        }
    }
    else
    {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"网络未连接" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertV show];
    }
}

- (void)createTitleViewWithHeight:(CGFloat)height
{
    if (!_isSet)
    {
        UIButton *notice = [[UIButton alloc] initWithFrame:CGRectMake(10*Rate_NAV_W, 10*Rate_NAV_H, 355*Rate_NAV_W, 40*Rate_NAV_H)];
        notice.layer.cornerRadius = 4;
        notice.clipsToBounds = YES;
        notice.backgroundColor = [UIColor colorWithRed:0.24 green:0.85 blue:0.76 alpha:1.0];
        [notice setTitle:@"您还未设置独一无二的昵称和头像，点击这里马上设置" forState:(UIControlStateNormal)];
        [notice setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        notice.titleLabel.font = [UIFont systemFontOfSize:14*Rate_H];
        notice.titleLabel.numberOfLines = 0;
        notice.titleLabel.adjustsFontSizeToFitWidth = YES;
        [notice addTarget:self action:@selector(setNickName) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:notice];
    }
    
    UILabel *choose = [[UILabel alloc] initWithFrame:CGRectMake(0, 22*Rate_NAV_H + height, SCREENWIDTH, 24*Rate_NAV_H)];
    choose.text = @"请选择帖子类别";
    choose.textAlignment = NSTextAlignmentCenter;
    choose.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    choose.font = [UIFont systemFontOfSize:17];
    choose.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:choose];
    
    _postType = @"1";
    for (int i = 0; i < 4; i++)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(30*Rate_NAV_W + (163*Rate_NAV_W)*(i%2), 60*Rate_NAV_H + (60*Rate_NAV_H)*(i/2) + height, 153*Rate_NAV_W, 48*Rate_NAV_H)];
        btn.layer.cornerRadius = 3;
        btn.clipsToBounds = YES;
        if (i == 0)
        {
            [btn setTitle:@"助眠干货" forState:(UIControlStateNormal)];
            [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [btn setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
        }
        else if (i == 1)
        {
            [btn setTitle:@"讨论疗疗" forState:(UIControlStateNormal)];
            [btn setTitleColor:[UIColor colorWithRed:0.53 green:0.55 blue:0.55 alpha:1.0] forState:(UIControlStateNormal)];
            [btn setBackgroundColor:[UIColor whiteColor]];
        }
        else if (i == 2)
        {
            [btn setTitle:@"压力树洞" forState:(UIControlStateNormal)];
            [btn setTitleColor:[UIColor colorWithRed:0.53 green:0.55 blue:0.55 alpha:1.0] forState:(UIControlStateNormal)];
            [btn setBackgroundColor:[UIColor whiteColor]];
        }
        else
        {
            [btn setTitle:@"其它" forState:(UIControlStateNormal)];
            [btn setTitleColor:[UIColor colorWithRed:0.53 green:0.55 blue:0.55 alpha:1.0] forState:(UIControlStateNormal)];
            [btn setBackgroundColor:[UIColor whiteColor]];
        }
        btn.tag = i+1;
        [btn addTarget:self action:@selector(titleChoose:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:btn];
    }
}

#pragma mark -- 选择昵称
- (void)setNickName
{
    
}

#pragma mark -- 选择类别
- (void)titleChoose:(UIButton *)sender
{
    for (int i = 1; i <= 4; i++)
    {
        if (i == sender.tag)
        {
            _postType = [NSString stringWithFormat:@"%i",i];
            [sender setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [sender setBackgroundColor:[UIColor colorWithRed:0.18 green:0.76 blue:0.87 alpha:1.0]];
        }
        else
        {
            UIButton *btn = (UIButton *)[self.view viewWithTag:i];
            [btn setTitleColor:[UIColor colorWithRed:0.53 green:0.55 blue:0.55 alpha:1.0] forState:(UIControlStateNormal)];
            [btn setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

#pragma mark -- 创建输入视图
- (void)createInputViewWithOriginalHeight:(CGFloat)originalY
{
    _inputView = [[UIView alloc] initWithFrame:CGRectMake(0, originalY, SCREENWIDTH, SCREENHEIGHT - originalY - 64)];
    _inputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_inputView];
    
    UILabel *inputTitle = [[UILabel alloc] initWithFrame:CGRectMake(17*Rate_NAV_W, 15*Rate_NAV_H, 120*Rate_NAV_W, 25*Rate_NAV_H)];
    inputTitle.text = @" 请输入标题";
    inputTitle.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    inputTitle.font = [UIFont systemFontOfSize:16];
    inputTitle.adjustsFontSizeToFitWidth = YES;
    [_inputView addSubview:inputTitle];
    
    _titleFiled = [[UITextField alloc] initWithFrame:CGRectMake(137*Rate_NAV_W, 15*Rate_NAV_H, SCREENWIDTH - 154*Rate_NAV_W, 25*Rate_NAV_H)];
    _titleFiled.placeholder = @"4-25";
    _titleFiled.delegate = self;
    [_inputView addSubview:_titleFiled];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 53*Rate_NAV_H, SCREENWIDTH, 1)];
    line.layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    [_inputView addSubview:line];
    
    _postView = [[UITextView alloc] initWithFrame:CGRectMake(17*Rate_NAV_W, 64*Rate_NAV_H, SCREENWIDTH - 34*Rate_NAV_W, 190*Rate_NAV_H)];
    _postView.delegate = self;
    _postView.text = @"请输入正文        0-5000";
    _postView.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    _postView.font = [UIFont systemFontOfSize:16];
    [_inputView addSubview:_postView];
    
    for (int i = 0; i < 5; i++)
    {
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(17*Rate_NAV_W + ((SCREENWIDTH - 64*Rate_NAV_W)/4 + 10*Rate_NAV_W)*(i%3), 260*Rate_NAV_H + 60*(i/3)*Rate_NAV_H, (SCREENWIDTH - 64*Rate_NAV_W)/4, 55*Rate_NAV_H)];
        picture.tag = i+100;
        picture.userInteractionEnabled = YES;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(picture.frame.size.width - 15*Rate_NAV_W, 0, 15*Rate_NAV_W, 15*Rate_NAV_H)];
        [btn setImage:[UIImage imageNamed:@"deleteImge"] forState:UIControlStateNormal];
        btn.tag = i+100;
        [btn addTarget:self action:@selector(deleteClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [picture addSubview:btn];
        picture.hidden = YES;
        [_inputView addSubview:picture];
    }
    
    UIButton *photo = [[UIButton alloc] initWithFrame:CGRectMake(17*Rate_NAV_W, 384*Rate_NAV_H, 26*Rate_NAV_W, 22*Rate_NAV_H)];
    [photo setBackgroundImage:[UIImage imageNamed:@"icon_img.png"] forState:(UIControlStateNormal)];
    [photo addTarget:self action:@selector(takePictures) forControlEvents:(UIControlEventTouchUpInside)];
    [_inputView addSubview:photo];
    
    UILabel *picture = [[UILabel alloc] initWithFrame:CGRectMake(58*Rate_NAV_W, 385*Rate_NAV_H, 73*Rate_NAV_W, 20*Rate_NAV_H)];
    picture.text = @"可上传图片";
    picture.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
    picture.font = [UIFont systemFontOfSize:14*Rate_NAV_H];
    [_inputView addSubview:picture];
}

#pragma mark -- 选择图片
- (void)takePictures
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选取",nil];
    [sheet showInView:self.view];
}

#pragma mark ----  delegateForTextView
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_postView.text isEqual:@"请输入正文        0-5000"])
    {
        _postView.text = @"";
        _postView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_postView.text isEqual:@""])
    {
        _postView.text = @"请输入正文        0-5000";
        _postView.textColor = [UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0];
        _postContent = @"";
    }
    else
    {
        _postContent = _postView.text;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    //该判断用于联想输入
    if (textView.text.length > 5000)
    {
        textView.text = [textView.text substringToIndex:5000];
    }
    else
    {
        if ([_postView.text isEqual:@"请输入正文        0-5000"])
        {
            _postContent = @"";
        }
        else
        {
            _postContent = _postView.text;
        }
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    _postContent = _postView.text;
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_postView resignFirstResponder];
    [_titleFiled resignFirstResponder];
}

#pragma mark -- delegateForTextFiled
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _postTitle = _titleFiled.text;
    [_titleFiled resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _postTitle = _titleFiled.text;
    [_titleFiled resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 25)
    {
        textField.text = [textField.text substringToIndex:25];
    }
    _postTitle = _titleFiled.text;
}

#pragma mark - Notification Method
- (void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 25)
        {
            [self showHint:@"标题长度为4-25"];
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:25];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:25];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 25)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
     _postTitle = textField.text;
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

#pragma mark - TZImagePickerController
- (void)pushImagePickerController
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:self];
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
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

#pragma mark - UIImagePickerController
- (void)takePhoto
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS8Later)
    {
        // 无权限 做一个友好的提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)// take photo  去拍照
    {
        [self takePhoto];
    }
    else if (buttonIndex == 1)
    {
        [self pushImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == 1)
        { // 上传数据
            DataHandle *handle = [[DataHandle alloc] init];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.labelText = @"数据上传中";

            NSMutableURLRequest *req = [handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPost) andDictionary:@{@"PatientID":_patientID,@"PatientName":_patientName,@"PostID":[self getPostIDWithPatientID:_patientID],@"PostTitle":_postTitle,@"PostContent":_postContent,@"PostDate":[self getCurrentDate],@"PostType":_postType,@"ImageCount":_ImageCount,@"PostImage1":_image1,@"PostImage2":_image2,@"PostImage3":_image3,@"PostImage4":_image4,@"PostImage5":_image5,@"PostImage6":_image6}];
            req.timeoutInterval = 10.0;
            [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                if (data)
                {
                    //修改我的发帖数
                    NSMutableURLRequest *req2 = [handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUploadPatientCount) andDictionary:@{@"patientID":[PatientInfo shareInstance].PatientID,@"type":@"1"}];
                    req2.timeoutInterval = 3;
                    NSData * data2 = [NSURLConnection sendSynchronousRequest:req2 returningResponse:nil error:nil];
                    if([[handle objectFromeResponseString:data andType:(DataModelBackTypeUploadPost)] isEqualToString:@"OK"] && [[handle objectFromeResponseString:data2 andType:(DataModelBackTypeUploadPatientCount)] isEqualToString:@"OK"]){
                        
                        //更新服务器积分
                        InterfaceModel *mod = [[InterfaceModel alloc] init];
                        [mod uploadPointToServer:[PatientInfo shareInstance].PatientID pointType:@"5"];
                        
                        [hud hide:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshView" object:nil userInfo:@{@"state":@"post"}];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        UIAlertView *alterV = [[UIAlertView alloc]initWithTitle:@"发帖失败" message:@"可能您的帖子内容包含过多表情，服务器无法处理！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alterV show];
                        hud.labelText = @"上传失败";
                        [hud hide:YES afterDelay:0.5];
                    }
                }
                else
                {
                    hud.labelText = @"上传失败";
                    [hud hide:YES afterDelay:0.5];
                }
            }];
        }
        else
        { // 取消上传数据
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {

    }
    else
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
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
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
                        UIImageView *imageV = (UIImageView *)[_inputView viewWithTag:100+i];
                        imageV.hidden = NO;
                        imageV.image = [self cutImage:_selectedPhotos[i] andView:imageV];
                    }
                    for (int i = (int)(_selectedPhotos.count); i < 5; i++)
                    {
                        UIImageView *imageV = (UIImageView *)[_inputView viewWithTag:i+100];
                        imageV.hidden = YES;
                    }
                    _ImageCount = [NSString stringWithFormat:@"%lu",(unsigned long)_selectedPhotos.count];
                    [self pictureHandle];
                }];
            }];
        }];
    }
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    for (int i = 0; i < _selectedPhotos.count; i++)
    {
        UIImageView *imageV = (UIImageView *)[_inputView viewWithTag:100+i];
        imageV.hidden = NO;
        imageV.image = [self cutImage:_selectedPhotos[i] andView:imageV];
    }
    for (int i = (int)(_selectedPhotos.count); i < 5; i++)
    {
        UIImageView *imageV = (UIImageView *)[_inputView viewWithTag:i+100];
        imageV.hidden = YES;
    }
    _ImageCount = [NSString stringWithFormat:@"%lu",(unsigned long)_selectedPhotos.count];
    [self pictureHandle];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset
{
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
}

#pragma mark -- 图片处理
- (void)pictureHandle
{
    _ImageCount = [NSString stringWithFormat:@"%lu",(unsigned long)_selectedPhotos.count];
    for (int  i = 0; i < [_ImageCount intValue]; i++)
    {
        NSData *imageData;
        imageData = UIImageJPEGRepresentation(_selectedPhotos[i], 0.5);
        if (i == 0)
        {
            _image1 = [imageData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
        }
        else if (i == 1)
        {
            _image2 = [imageData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
        }
        else if (i == 2)
        {
            _image3 = [imageData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
        }
        else if (i == 3)
        {
            _image4 = [imageData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
        }
        else if (i == 4)
        {
            _image5 = [imageData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
        }
    }
}

#pragma -- 裁剪图片
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

#pragma mark 删除图片
- (void)deleteClick:(UIButton *)sender
{
    [_selectedPhotos removeObjectAtIndex:(sender.tag-100)];
    [_selectedAssets removeObjectAtIndex:(sender.tag-100)];
    for (int i = 0; i < _selectedPhotos.count; i++)
    {
        UIImageView *imageV = (UIImageView *)[_inputView viewWithTag:100+i];
        imageV.hidden = NO;
        imageV.image = [self cutImage:_selectedPhotos[i] andView:imageV];
    }
    for (int i = (int)(_selectedPhotos.count); i < 5; i++)
    {
        UIImageView *imageV = (UIImageView *)[_inputView viewWithTag:i+100];
        imageV.hidden = YES;
    }
    
}

#pragma mark - keyboard events -- 键盘显示事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    CGFloat offset = (_inputView.frame.origin.y+_inputView.frame.size.height) - (self.view.frame.size.height - kbHeight);
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = CGRectMake(0.0f, -offset+64+100, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

#pragma mark - keyboard events -- 键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notify
{
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (NSString *)getPostIDWithPatientID:(NSString *)patientID
{
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    return [NSString stringWithFormat:@"%@_%llu",patientID,theTime];
}

- (NSString * )getCurrentDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return  [formatter stringFromDate:[NSDate date]];
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
