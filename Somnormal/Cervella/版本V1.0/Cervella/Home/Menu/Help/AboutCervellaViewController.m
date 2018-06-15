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
    [self.view addSubview:self.topBackView];
    [self.view addSubview:self.infoLab];
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
