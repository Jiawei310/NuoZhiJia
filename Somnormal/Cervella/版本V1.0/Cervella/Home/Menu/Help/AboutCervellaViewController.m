//
//  AboutCervellaViewController.m
//  Cervella
//
//  Created by 一磊 on 2018/6/15.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "AboutCervellaViewController.h"

@interface AboutCervellaViewController ()
@property (nonatomic, strong) UIView *topBackView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *logoLab;

@property (nonatomic, strong) UILabel *infoLab;

@end

@implementation AboutCervellaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.frame = CGRectMake(0, 0, 44.0, 100);
    titleLab.text = self.title;
    titleLab.textColor = [UIColor whiteColor];
    UIBarButtonItem *titleBtnItem = [[UIBarButtonItem alloc] initWithCustomView:titleLab];
    self.title = nil;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent=YES;
    //添加返回按钮
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    backLogin.frame = CGRectMake(12, 30, 23, 23);
    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem, titleBtnItem];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 64);
    imageView.image = [UIImage imageNamed:@"about"];
    [self.view addSubview:imageView];
    
    UIButton *linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    linkBtn.backgroundColor = [UIColor redColor];
    [linkBtn addTarget:self action:@selector(linkBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    emailBtn.backgroundColor = [UIColor blueColor];
    [emailBtn addTarget:self action:@selector(emailBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:linkBtn];
    [self.view addSubview:emailBtn];
    
    if (SCREENHEIGHT == 568) {
        linkBtn.frame = CGRectMake(30, 390, SCREENWIDTH - 60, 30);
        emailBtn.frame = CGRectMake(30, 425, SCREENWIDTH - 60, 30);
    } else if (SCREENHEIGHT == 667) {
        linkBtn.frame = CGRectMake(30, 445, SCREENWIDTH - 60, 40);
        emailBtn.frame = CGRectMake(30, 490, SCREENWIDTH - 60, 40);
    } else if (SCREENHEIGHT == 736) {
        linkBtn.frame = CGRectMake(30, 500, SCREENWIDTH - 60, 40);
        emailBtn.frame = CGRectMake(30, 545, SCREENWIDTH - 60, 40);
    }
    else if (SCREENHEIGHT == 812) {
        linkBtn.frame = CGRectMake(30, 548, SCREENWIDTH - 60, 44);
        emailBtn.frame = CGRectMake(30, 598, SCREENWIDTH - 60, 44);
    }
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)linkBtnAction {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.cervella.us"]];
}

- (void)emailBtnAction {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://support@cervella.us"]];
}


#pragma mark - get
- (UIView *)topBackView {
    if (!_topBackView) {
        _topBackView = [[UIView alloc] init];
        CGFloat w = self.view.frame.size.width - 10;
        CGFloat h = self.view.frame.size.height/2.0 - 74;
        _topBackView.frame = CGRectMake(5,
                                        64,
                                        w,
                                        h);
        _topBackView.layer.borderColor = [UIColor colorWithRed:69/255.0 green:137/255.0 blue:211/255.0 alpha:1].CGColor;
        _topBackView.layer.borderWidth = 1.0;
        
        self.logoImageView.frame = CGRectMake(0, h/2.0 - 160, w, w*3/4);
        self.logoLab.frame = CGRectMake(0, h/2.0, w, h/2.0);
        [_topBackView addSubview:self.logoImageView];
        [_topBackView addSubview:self.logoLab];

    }
    return _topBackView;
}
- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.image = [UIImage imageNamed:@"cervellaLogo"];
    }
    return _logoImageView;
}

- (UILabel *)logoLab {
    if (!_logoLab) {
        _logoLab = [[UILabel alloc] init];
        _logoLab.textAlignment = NSTextAlignmentCenter;
        _logoLab.numberOfLines = 0;
        _logoLab.text = @"Innovative nono-drug treament of\nInsomnia,Depression,and\nAnxiety";
    }
    return _logoLab;
}
- (UILabel *)infoLab {
    if (!_infoLab) {
        _infoLab = [[UILabel alloc] init];
    
        _infoLab.layer.borderColor = [UIColor colorWithRed:69/255.0 green:137/255.0 blue:211/255.0 alpha:1].CGColor;
        _infoLab.layer.borderWidth = 1.0;
        _infoLab.textAlignment = NSTextAlignmentCenter;
        _infoLab.numberOfLines = 0;
        _infoLab.frame = CGRectMake(5,
                                    self.view.frame.size.height/2.0 + 10,
                                    self.view.frame.size.width - 10,
                                    self.view.frame.size.height/2.0 - 40);
        _infoLab.text = @"INNOVATIVE NEUROLOGICIAL DEVICES LLC\n\nwww.cervella.us\nsupport@cervella.us\n\n13295 lllinois Street,Suite 312\nCarnek,IN 46032\nUSA";
        
    }
    return _infoLab;
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
