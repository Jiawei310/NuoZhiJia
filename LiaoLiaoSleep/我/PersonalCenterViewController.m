//
//  PersonalCenterViewController.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 16/10/22.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "Define.h"

#import "JXTAlertManagerHeader.h"
#import "PhotoKitViewController.h"
#import "UIView+CommonOption.h"
#import "UIImage+CommonOption.h"
#import "UIImagePickerController+CommonOption.h"
#import "UIImage+WYBScaleImage.h"
#import <UMMobClick/MobClick.h>
#import "InterfaceModel.h"
#import "DataBaseOpration.h"

#import "PersonalInfoViewController.h"
#import "MyCollectionViewController.h"
#import "FootPrintViewController.h"
#import "SettingViewController.h"
#import "PointInstructViewController.h"
#import "PurchaseRecordViewController.h"
#import "PointDetailViewController.h"

@interface PersonalCenterViewController ()<UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,PhotoKitDelegate,InterfaceModelDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *postNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *integralLabel;

@property (strong, nonatomic) IBOutlet UITableView *personalInfoTableView;
@property (strong, nonatomic) IBOutlet UITableView *personalSettingTableView;

@property (strong, nonatomic) UILabel *nameLabel;

@property (nonatomic, strong) PatientInfo *patientInfo;

@end

@implementation PersonalCenterViewController
{
    NSArray *pointArray;
    
    UIButton *integralBtn;
    
    NSArray *personalInfoTableViewArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    //设置导航栏半透明效果
    /*
     * translucent
     */
    self.navigationController.navigationBar.translucent = NO;
    //去除导航栏下方分割线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    self.tabBarController.tabBar.hidden = NO;
    
    [MobClick beginLogPageView:@"个人中心"];
    
    [self changePatientInfo:nil];
    //调用积分接口
    InterfaceModel *interfaceM = [[InterfaceModel alloc] init];
    interfaceM.delegate = self;
    [interfaceM getPointFromServer:self.patientInfo.PatientID pointPage:@"1"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"个人中心"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"个人中心";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF6/255.0 blue:0xF8/255.0 alpha:1];
    
    [self createPartOneViews];
    [self createPartTwoViews];
    
    [self createPersonalTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePatientInfo:) name:@"patientInfoChange" object:nil];
}

- (void)changePatientInfo:(NSNotification *)notification
{
    if (notification) {
        _patientInfo = [notification.userInfo objectForKey:@"patientInfo"];
    }
    _nameLabel.text = [NSString stringWithFormat:@"%@",self.patientInfo.PatientName? self.patientInfo.PatientName:self.patientInfo.PatientID];
    
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:self.patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
    [_photoImageView setImage:[[UIImage alloc] initWithData:imageData]];
}

//创建个人信息部分view
- (void)createPartOneViews
{
    UIImageView *personalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375*Rate_W, 172*Rate_H)];
    [personalImageView setImage:[UIImage imageNamed:@"self_bg"]];
    [self.view addSubview:personalImageView];
    
    _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 70*Rate_H)/2, 18*Rate_H, 70*Rate_H, 70*Rate_H)];
    [_photoImageView.layer setCornerRadius:self.photoImageView.frame.size.width/2];
    [_photoImageView.layer setMasksToBounds:YES];
    if (self.patientInfo.Picture == nil || self.patientInfo.Picture.length == 0)
    {
        [_photoImageView setImage:[UIImage imageNamed:@"Default"]];
    }
    else
    {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:self.patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
        [_photoImageView setImage:[[UIImage alloc] initWithData:imageData]];
    }
    [personalImageView addSubview:_photoImageView];
    //添加头像点击手势
    personalImageView.userInteractionEnabled = YES;
    _photoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapControlPlay:)];
    tapGesture.numberOfTouchesRequired = 1; //手指数
    tapGesture.numberOfTapsRequired = 1; //tap次数
    tapGesture.delegate= self;
    [_photoImageView addGestureRecognizer:tapGesture];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120*Rate_W, 89*Rate_H, 134*Rate_W, 30*Rate_H)];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:24];
    _nameLabel.text = [NSString stringWithFormat:@"%@",self.patientInfo.PatientName];
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [personalImageView addSubview:_nameLabel];
    
    integralBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - 105*Rate_H)/2, 126*Rate_H, 105*Rate_H, 24*Rate_H)];
    [integralBtn setBackgroundImage:[UIImage imageNamed:@"self_btn"] forState:UIControlStateNormal];
    integralBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [integralBtn setTitle:@"现有积分：0" forState:UIControlStateNormal];
    integralBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    integralBtn.titleEdgeInsets = UIEdgeInsetsMake(3*Rate_H, 24*Rate_H, 3*Rate_H, 0);
    [integralBtn addTarget:self action:@selector(pushToPointDetail) forControlEvents:UIControlEventTouchUpInside];
    [personalImageView addSubview:integralBtn];
}

- (void)pushToPointDetail
{
    PointDetailViewController *pointDetailVC = [[PointDetailViewController alloc] init];
    pointDetailVC.page = @"1";
    pointDetailVC.pointDataSource = [NSMutableArray arrayWithArray:pointArray];
    
    [self.navigationController pushViewController:pointDetailVC animated:YES];
}

#pragma -- tapGesture点击手势的方法实现
- (void)tapControlPlay:(UITapGestureRecognizer *)gesture
{
    [self jxt_showActionSheetWithTitle:nil message:nil appearanceProcess:^(JXTAlertController * _Nonnull alertMaker) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            alertMaker.popoverPresentationController.sourceRect = _photoImageView.bounds;
            alertMaker.popoverPresentationController.sourceView = _photoImageView;
        }
        alertMaker.addActionCancelTitle(@"取消");
        alertMaker.addActionDefaultTitle(@"打开相机");
        alertMaker.addActionDefaultTitle(@"打开相册");
    } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nonnull action, JXTAlertController * _Nonnull alertSelf) {
        if ([action.title isEqualToString:@"取消"])
        {
            
        }
        else if ([action.title isEqualToString:@"打开相机"])
        {
            [self takePictureByCamera];
        }
        else if ([action.title isEqualToString:@"打开相册"])
        {
            [self selectPicturesFromAlbum];
        }
    }];
}

#pragma mark - UIImagePickerController
- (void)takePictureByCamera
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
- (void)selectPicturesFromAlbum
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
    
    NSData *pictureData = UIImageJPEGRepresentation(targetImage,1);
    NSString *pictureDataString = [pictureData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    self.patientInfo.Picture = pictureDataString;
    
    //调用借口保存用户个人信息
    InterfaceModel *interfaceModel = [[InterfaceModel alloc] init];
    interfaceModel.delegate = self;
    [interfaceModel sendJsonSaveInfoToServer:self.patientInfo isPhotoAlter:NO];
}

#pragma 借口调用的代理方法
- (void)sendValueBackToController:(id)value type:(InterfaceModelBackType)interfaceModelBackType
{
    if (interfaceModelBackType == InterfaceModelBackTypeAlertPatientInfo)
    {
        NSDictionary *tmpDic = value;
        //更新成功
        if ([[tmpDic objectForKey:@"state"] isEqualToString:@"OK"])
        {
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:self.patientInfo.Picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [_photoImageView setImage:[[UIImage alloc] initWithData:imageData]];
            //通知所有界面用户个人信息已修改
            NSDictionary *patientDic = @{@"patientInfo":self.patientInfo};
            NSNotification *notification = [[NSNotification alloc] initWithName:@"patientInfoChange" object:nil userInfo:patientDic];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //将个人信息保存到本地数据库
            DataBaseOpration *dbOpration = [[DataBaseOpration alloc] init];
            [dbOpration updataUserInfo:self.patientInfo];
            [dbOpration closeDataBase];
            //提示“更新成功”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"更新成功");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
        else
        {
            //跟新失败
            //提示“更新失败”
            jxt_showTextHUDTitleMessage(@"温馨提示", @"更新失败");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                jxt_dismissHUD();
            });
        }
    }
    else if (interfaceModelBackType == InterfaceModelBackTypePoint)
    {
        pointArray = value;
        if (pointArray.count > 0)
        {
            NSDictionary *pointDic = [pointArray objectAtIndex:0];
            [integralBtn setTitle:[NSString stringWithFormat:@"现有积分：%@",[pointDic objectForKey:@"CurrentPoint"]] forState:UIControlStateNormal];
        }
        else
        {
            [integralBtn setTitle:@"现有积分：0" forState:UIControlStateNormal];
        }
    }
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

//创建积分商城、积分说明部分view
- (void)createPartTwoViews
{
    UIView *partTwoView = [[UIView alloc] initWithFrame:CGRectMake(0, 172*Rate_H, 375*Rate_W, 50*Rate_H)];
    partTwoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:partTwoView];
    
    UIButton *integralMallBtn = [[UIButton alloc] initWithFrame:CGRectMake(30*Rate_W, 5*Rate_H, 127*Rate_W, 40*Rate_H)];
    [integralMallBtn setImage:[UIImage imageNamed:@"self_mall"] forState:UIControlStateNormal];
    integralMallBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_H];
    [integralMallBtn setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
    [integralMallBtn setTitle:@"积分商城" forState:UIControlStateNormal];
    integralMallBtn.imageEdgeInsets = UIEdgeInsetsMake(10*Rate_H, 10*Rate_W, 10*Rate_H, 85*Rate_W);
    [integralMallBtn addTarget:self action:@selector(integralMallBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [partTwoView addSubview:integralMallBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(187*Rate_W, 12*Rate_H, Rate_W, 26*Rate_H)];
    lineView.backgroundColor = [UIColor colorWithRed:0xEA/255.0 green:0xEA/255.0 blue:0xEA/255.0 alpha:1];
    [partTwoView addSubview:lineView];
    
    UIButton *integralTaskBtn = [[UIButton alloc] initWithFrame:CGRectMake(218*Rate_W, 5*Rate_H, 127*Rate_W, 40*Rate_H)];
    [integralTaskBtn setImage:[UIImage imageNamed:@"self_task"] forState:UIControlStateNormal];
    integralTaskBtn.titleLabel.font = [UIFont systemFontOfSize:16*Rate_H];
    [integralTaskBtn setTitleColor:[UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1] forState:UIControlStateNormal];
    [integralTaskBtn setTitle:@"积分说明" forState:UIControlStateNormal];
    integralTaskBtn.imageEdgeInsets = UIEdgeInsetsMake(9*Rate_H, 10*Rate_W, 9*Rate_H, 85*Rate_W);
    [integralTaskBtn addTarget:self action:@selector(integralTaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [partTwoView addSubview:integralTaskBtn];
}

//创建个人信息、个人设置的tableview
- (void)createPersonalTableView
{
    _personalInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 232*Rate_H, 375*Rate_W, 240*Rate_H)];
    _personalInfoTableView.tag = 0;
    _personalInfoTableView.scrollEnabled = NO;
    _personalInfoTableView.tableHeaderView = [[UIView alloc] init];
    if ([_personalInfoTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _personalInfoTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    _personalInfoTableView.delegate = self;
    _personalInfoTableView.dataSource = self;
    [self.view addSubview:_personalInfoTableView];
    
    personalInfoTableViewArray = @[@"我的订单",@"我的收藏",@"个人资料",@"眠友圈足迹",@"问医生购买记录"];
    
    _personalSettingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 482*Rate_H, 375*Rate_W, 48*Rate_H)];
    _personalSettingTableView.tag = 1;
    _personalSettingTableView.scrollEnabled = NO;
    if ([_personalSettingTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _personalSettingTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    _personalSettingTableView.delegate = self;
    _personalSettingTableView.dataSource = self;
    [self.view addSubview:_personalSettingTableView];
}

//积分商城按钮点击事件
- (void)integralMallBtnClick:(UIButton *)sender
{
    [self alertNotOpen];
}

//提示“暂未开通”
- (void)alertNotOpen
{
    jxt_showTextHUDTitleMessage(@"温馨提示", @"暂未开通");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        jxt_dismissHUD();
    });
}

//积分说明按钮点击事件
- (void)integralTaskBtnClick:(UIButton *)sender
{
    PointInstructViewController *pointInstructVC = [[PointInstructViewController alloc] init];
    [self.navigationController pushViewController:pointInstructVC animated:YES];
}

#pragma tableview的delegate、dataSource代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0)
    {
        return 5;
    }
    else if(tableView.tag == 1)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 0)
    {
        return tableView.frame.size.height/5;
    }
    else if (tableView.tag == 1)
    {
        return tableView.frame.size.height;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView.tag == 0)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        if (indexPath.row == 0)
        {
            UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 12*Rate_H, 18*Rate_W, 24*Rate_H)];
            [myImageView setImage:[UIImage imageNamed:@"self_order"]];
            [cell addSubview:myImageView];
            UILabel *myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(59*Rate_W, 0, 115*Rate_W, tableView.frame.size.height/5)];
            myTextLabel.font = [UIFont systemFontOfSize:16*Rate_H];
            myTextLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
            myTextLabel.text = @"我的订单";
            myTextLabel.textAlignment = NSTextAlignmentLeft;
            [cell addSubview:myTextLabel];
        }
        else if (indexPath.row == 1)
        {
            UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 12*Rate_H, 22*Rate_W, 22*Rate_H)];
            [myImageView setImage:[UIImage imageNamed:@"self_collection"]];
            [cell addSubview:myImageView];
            UILabel *myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(59*Rate_W, 0, 115*Rate_W, tableView.frame.size.height/5)];
            myTextLabel.font = [UIFont systemFontOfSize:16*Rate_H];
            myTextLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
            myTextLabel.text = @"我的收藏";
            myTextLabel.textAlignment = NSTextAlignmentLeft;
            [cell addSubview:myTextLabel];
        }
        else if (indexPath.row == 2)
        {
            UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 13.5*Rate_H, 22*Rate_W, 21*Rate_H)];
            [myImageView setImage:[UIImage imageNamed:@"self_data"]];
            [cell addSubview:myImageView];
            UILabel *myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(59*Rate_W, 0, 115*Rate_W, tableView.frame.size.height/5)];
            myTextLabel.font = [UIFont systemFontOfSize:16*Rate_H];
            myTextLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
            myTextLabel.text = @"个人资料";
            myTextLabel.textAlignment = NSTextAlignmentLeft;
            [cell addSubview:myTextLabel];
        }
        else if (indexPath.row == 3)
        {
            UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 10.5*Rate_H, 22*Rate_W, 27*Rate_H)];
            [myImageView setImage:[UIImage imageNamed:@"self_zuji"]];
            [cell addSubview:myImageView];
            UILabel *myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(59*Rate_W, 0, 115*Rate_W, tableView.frame.size.height/5)];
            myTextLabel.font = [UIFont systemFontOfSize:16*Rate_H];
            myTextLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
            myTextLabel.text = @"眠友圈足迹";
            myTextLabel.textAlignment = NSTextAlignmentLeft;
            [cell addSubview:myTextLabel];
        }
        else
        {
            UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 13.5*Rate_H, 18*Rate_W, 21*Rate_H)];
            [myImageView setImage:[UIImage imageNamed:@"self_askdoc"]];
            [cell addSubview:myImageView];
            UILabel *myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(59*Rate_W, 0, 115*Rate_W, tableView.frame.size.height/5)];
            myTextLabel.font = [UIFont systemFontOfSize:16*Rate_H];
            myTextLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
            myTextLabel.text = @"问医生购买记录";
            myTextLabel.textAlignment = NSTextAlignmentLeft;
            [cell addSubview:myTextLabel];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (tableView.tag == 1)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20*Rate_W, 14.5*Rate_H, 19*Rate_W, 19*Rate_W)];
        [myImageView setImage:[UIImage imageNamed:@"self_shezhi"]];
        [cell addSubview:myImageView];
        UILabel *myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(59*Rate_W, 0, 115*Rate_W, tableView.frame.size.height)];
        myTextLabel.font = [UIFont systemFontOfSize:16*Rate_H];
        myTextLabel.textColor = [UIColor colorWithRed:0x64/255.0 green:0x69/255.0 blue:0x6A/255.0 alpha:1];
        myTextLabel.text = @"设置";
        myTextLabel.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:myTextLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 0)
    {
        if (indexPath.row == 0)
        {
            //跳转到我的订单界面(暂时点击提示暂未开放)
            [self alertNotOpen];
        }
        else if (indexPath.row == 1)
        {
            //跳转到我的收藏界面
            MyCollectionViewController *myCollect = [[MyCollectionViewController alloc]init];
            [self.navigationController pushViewController:myCollect animated:YES];
        }
        else if (indexPath.row == 2)
        {
            //跳转到个人资料界面
            PersonalInfoViewController *personalInfoVC = [[PersonalInfoViewController alloc] init];
            [self.navigationController pushViewController:personalInfoVC animated:YES];
        }
        else if (indexPath.row == 3)
        {
            //眠友圈足迹
            FootPrintViewController *footVC = [[FootPrintViewController alloc]init];
            [self.navigationController pushViewController:footVC animated:YES];
        }
        else
        {
            //问医生购买记录界面
            PurchaseRecordViewController *purchaseRecordVc = [[PurchaseRecordViewController alloc]init];
            purchaseRecordVc.patientID = self.patientInfo.PatientID;
            [self.navigationController pushViewController:purchaseRecordVc animated:YES];
        }
    }
    else if (tableView.tag == 1)
    {
        //跳转到设置界面
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 20*Rate_W, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 20*Rate_W, 0, 0)];
    }
}

- (PatientInfo *)patientInfo {
    _patientInfo = [PatientInfo shareInstance];
    return _patientInfo;
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
