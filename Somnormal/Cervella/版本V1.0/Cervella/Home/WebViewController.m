//
//  WebViewController.m
//  Cervella
//
//  Created by 一磊 on 2018/6/15.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate> {
}
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.loadingView];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIWebVeiwDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.loadingView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingView stopAnimating];
}

#pragma  mark - get
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height);
        _webView.scalesPageToFit = YES;
        [_webView setMultipleTouchEnabled:YES];
        [_webView setUserInteractionEnabled:YES];
        [_webView.scrollView setScrollEnabled:YES];
        _webView.delegate = self;
        
    }
    return _webView;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] init];
        _loadingView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    return _loadingView;
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
