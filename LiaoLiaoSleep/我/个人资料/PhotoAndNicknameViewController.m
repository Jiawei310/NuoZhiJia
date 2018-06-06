//
//  PhotoAndNicknameViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/23.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PhotoAndNicknameViewController.h"
#import "Define.h"
#import <UMMobClick/MobClick.h>
#import "UIView+CommonOption.h"
#import "UIImage+CommonOption.h"
#import "UIImagePickerController+CommonOption.h"
#import "UIImage+WYBScaleImage.h"
#import "PhotoKitViewController.h"

@interface PhotoAndNicknameViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,PhotoKitDelegate>

@property (nonatomic, strong) PatientInfo *patientInfo;

@property (nonatomic, strong)      UIView *nickView;
@property (nonatomic, strong) UITextField *nickTextField;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong)    UIButton *confirmBtn;

@end

@implementation PhotoAndNicknameViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"头像昵称"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"头像昵称"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"头像昵称";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _patientInfo = [PatientInfo shareInstance];
    
    [self createNicknameView];
    
    [self createPhotoView];
    
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
    //添加确定按钮（进入界面，以及昵称填写正确之前用户不可点击；等到昵称设置正确、头像更改完成用户才可点击）
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _confirmBtn.frame = CGRectMake(0, 553*Rate_NAV_H, 375*Rate_NAV_W, 50*Rate_NAV_H);
    _confirmBtn.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:18*Rate_H];
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn.userInteractionEnabled = NO;
    [self.view addSubview:_confirmBtn];
    
    //设置键盘收起手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doWillHideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [_nickView addGestureRecognizer:tap];
    [self.view  addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//隐藏键盘
-(void)doWillHideKeyBoard
{
    [_nickTextField becomeFirstResponder];
    [_nickTextField resignFirstResponder];
}

//创建昵称的view以及view上的控件
- (void)createNicknameView
{
    UIView *nickView = [[UIView alloc] initWithFrame:CGRectMake(0, 20*Rate_H, 375*Rate_W, 50*Rate_H)];
    nickView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nickView];
    
    UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(20*Rate_W, 0, 40*Rate_W, 50*Rate_H)];
    nickLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    nickLabel.textAlignment = NSTextAlignmentLeft;
    nickLabel.font = [UIFont systemFontOfSize:16*Rate_H];
    nickLabel.text = @"昵称";
    [nickView addSubview:nickLabel];
    
    _nickTextField = [[UITextField alloc] initWithFrame:CGRectMake(100*Rate_W, 0, 275*Rate_W, 50*Rate_H)];
    _nickTextField.font = [UIFont systemFontOfSize:16*Rate_H];
    //不可修改
    if (_patientInfo.PatientName.length > 0 && ![_patientInfo.PatientName isEqualToString:_patientInfo.PatientID])
    {
        _nickTextField.delegate = self;
        _nickTextField.text = _patientInfo.PatientName;
    }
    else//可以修改
    {
        _nickTextField.delegate = self;
        _nickTextField.placeholder = @"请输入您的昵称";
    }
    [nickView addSubview:_nickTextField];
}

//编辑结束
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0)
    {
        _confirmBtn.backgroundColor = [UIColor colorWithRed:0xD9/255.0 green:0xE0/255.0 blue:0xE2/255.0 alpha:1];
        _confirmBtn.userInteractionEnabled = NO;
    }
    else
    {
        _confirmBtn.backgroundColor = [UIColor colorWithRed:0x3E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
        _confirmBtn.userInteractionEnabled = YES;
        _patientInfo.PatientName = textField.text;
    }
}

//创建更换头像view以及view上的控件
- (void)createPhotoView
{
    UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(0, 117*Rate_H, 375*Rate_W, 70*Rate_H)];
    photoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:photoView];
    
    _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 10*Rate_H, 50*Rate_H, 50*Rate_H)];
    [_photoImageView.layer setCornerRadius:25*Rate_H];
    [_photoImageView.layer setMasksToBounds:YES];
    
    if (_patientInfo.Picture == nil || _patientInfo.Picture.length == 0)
    {
        [_photoImageView setImage:[UIImage imageNamed:@"Default"]];
    }
    else
    {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:_patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
        [_photoImageView setImage:[[UIImage alloc] initWithData:imageData]];
    }
    [photoView addSubview:_photoImageView];
    
    UILabel *photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(39*Rate_W + 50*Rate_H, 10*Rate_H, 80*Rate_W, 50*Rate_H)];
    photoLabel.textColor = [UIColor colorWithRed:0x9E/255.0 green:0xA2/255.0 blue:0xA3/255.0 alpha:1];
    photoLabel.textAlignment = NSTextAlignmentLeft;
    photoLabel.font = [UIFont systemFontOfSize:16*Rate_H];
    photoLabel.text = @"更换头像";
    [photoView addSubview:photoLabel];
    
    UIButton *photoBtnCamera = [[UIButton alloc] initWithFrame:CGRectMake(275*Rate_W, 27*Rate_H, 20*Rate_W, 16*Rate_H)];
    [photoBtnCamera setImage:[UIImage imageNamed:@"self_paizhao"] forState:UIControlStateNormal];
    [photoBtnCamera addTarget:self action:@selector(takePictureByCamera:) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:photoBtnCamera];
    
    UIButton *photoBtnAlbum = [[UIButton alloc] initWithFrame:CGRectMake(326*Rate_W, 27*Rate_H, 19*Rate_W, 16*Rate_H)];
    [photoBtnAlbum setImage:[UIImage imageNamed:@"self_xiangce"] forState:UIControlStateNormal];
    [photoBtnAlbum addTarget:self action:@selector(selectPicturesFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:photoBtnAlbum];
}

#pragma mark - UIImagePickerController
- (void)takePictureByCamera:(UIButton *)sender
{
    UIImagePickerController *controller = [UIImagePickerController imagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    
    if ([controller isAvailableCamera] && [controller isSupportTakingPhotos])
    {
        [controller setDelegate:self];
        [self presentViewController:controller animated:YES completion:nil];
    }else
    {
        NSLog(@"%s %@", __FUNCTION__, @"相机权限受限");
    }
}

#pragma mark - TZImagePickerController
- (void)selectPicturesFromAlbum:(UIButton *)sender
{
    UIImagePickerController *controller = [UIImagePickerController imagePickerControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [controller setDelegate:self];
    if ([controller isAvailablePhotoLibrary])
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - --- delegate 视图委托 ---

#pragma mark - 1.STPhotoKitDelegate的委托
- (void)photoKitController:(PhotoKitViewController *)photoKitController resultImage:(UIImage *)resultImage
{
    UIImage *targetImage = [UIImage scaleImage:resultImage toKb:5];
    self.photoImageView.image = targetImage;
    _confirmBtn.backgroundColor = [UIColor colorWithRed:0x3E/255.0 green:0xC3/255.0 blue:0xDE/255.0 alpha:1];
    _confirmBtn.userInteractionEnabled = YES;
    
    NSData *pictureData = UIImageJPEGRepresentation(targetImage,1);
    NSString *pictureDataString = [pictureData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    _patientInfo.Picture = pictureDataString;
}

#pragma mark - 2.UIImagePickerController的委托
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *imageOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
        PhotoKitViewController *photoVC = [PhotoKitViewController new];
        [photoVC setDelegate:self];
        [photoVC setImageOriginal:imageOriginal];
        [self presentViewController:photoVC animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

//确定按钮点击事件
- (void)confirmBtnClick:(UIButton *)sender
{
    if (self.returnInfoBlock != nil)
    {
        if (_nickTextField.text.length > 0)
        {
            _patientInfo.PatientName = _nickTextField.text;
        }
        
        self.returnInfoBlock(_patientInfo);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)returnInfoBlock:(ReturnInfoBlock)myBlock
{
    self.returnInfoBlock = myBlock;
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
