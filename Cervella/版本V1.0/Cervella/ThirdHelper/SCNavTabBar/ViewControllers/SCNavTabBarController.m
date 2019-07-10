//
//  SCNavTabBarController.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBarController.h"
#import "CommonMacro.h"
#import "SCNavTabBar.h"

@interface SCNavTabBarController () <UIScrollViewDelegate, SCNavTabBarDelegate>
{
    NSInteger       _currentIndex;              // current page index    
    UIScrollView    *_mainView;                 // content view
}

@end

@implementation SCNavTabBarController

#pragma mark - Life Cycle
#pragma mark -
- (id)initWithShowArrowButton:(BOOL)show
{
    self = [super init];
    if (self)
    {
        self.navTabBar.showArrowButton = show;
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subViewControllers
{
    self = [super init];
    if (self)
    {
        _subViewControllers = subViewControllers;
    }
    return self;
}

- (id)initWithParentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        [self addParentController:viewController];
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController showArrowButton:(BOOL)show;
{
    self = [self initWithSubViewControllers:subControllers];
    
    self.navTabBar.showArrowButton = show;
    [self addParentController:viewController];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentIndex = 1;

    self.navTabBar.frame = CGRectMake(DOT_COORDINATE, DOT_COORDINATE, SCREEN_WIDTH, self.navTabBar.navTabBarHeight);
    [self viewConfig];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)viewInit
{
    // Load NavTabBar and content view to show on window
    [self.navTabBar updateData];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE,  self.navTabBar.frame.origin.y +  self.navTabBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT -  self.navTabBar.frame.origin.y -  self.navTabBar.frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    _mainView.delegate = self;
    _mainView.pagingEnabled = YES;
    _mainView.bounces = _mainViewBounces;
    _mainView.showsHorizontalScrollIndicator = NO;
    _mainView.contentSize = CGSizeMake(SCREEN_WIDTH * _subViewControllers.count, DOT_COORDINATE);
    [self.view addSubview:_mainView];
    [self.view addSubview: self.navTabBar];
}

- (void)viewConfig
{
    [self viewInit];
    
    // Load children view controllers and add to content view
    [_subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        UIViewController *viewController = (UIViewController *)_subViewControllers[idx];
        viewController.view.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, _mainView.frame.size.height);
        [_mainView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }];
}

#pragma mark - Public Methods
#pragma mark -
- (void)setNavTabbarColor:(UIColor *)navTabbarColor
{
    // prevent set [UIColor clear], because this set can take error display
    CGFloat red, green, blue, alpha;
    if ([navTabbarColor getRed:&red green:&green blue:&blue alpha:&alpha] && !red && !green && !blue && !alpha)
    {
        navTabbarColor = NavTabbarColor;
    }
     self.navTabBar.backgroundColor = navTabbarColor;
}

- (void)addParentController:(UIViewController *)viewController
{
    // Close UIScrollView characteristic on IOS7 and later
    if ([viewController respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
}

#pragma mark - Scroll View Delegate Methods
#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
     self.navTabBar.currentItemIndex = _currentIndex;
}

#pragma mark - SCNavTabBarDelegate Methods
#pragma mark -
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    [_mainView setContentOffset:CGPointMake(index * SCREEN_WIDTH, DOT_COORDINATE) animated:_scrollAnimation];
}

- (void)shouldPopNavgationItemMenu:(BOOL)pop height:(CGFloat)height
{
    if (pop)
    {
        [UIView animateWithDuration:0.5f animations:^{
             self.navTabBar.frame = CGRectMake( self.navTabBar.frame.origin.x,  self.navTabBar.frame.origin.y,  self.navTabBar.frame.size.width, height + self.navTabBar.navTabBarHeight);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
             self.navTabBar.frame = CGRectMake( self.navTabBar.frame.origin.x,  self.navTabBar.frame.origin.y,  self.navTabBar.frame.size.width, self.navTabBar.navTabBarHeight);
        }];
    }
    [ self.navTabBar refresh];
}

- (SCNavTabBar *)navTabBar {
    if (!_navTabBar) {
        _navTabBar = [[SCNavTabBar alloc] init];
        _navTabBar.delegate = self;
        _navTabBar.backgroundColor = _navTabBar.backgroundColor ? _navTabBar.backgroundColor : NavTabbarColor;
    }
    return _navTabBar;
}

@end
