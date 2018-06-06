//
//  YBLoopBanner.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/8/15.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "YBLoopBanner.h"
#import "FunctionHelper.h"
#import "UIImageView+WebCache.h"

@interface YBLoopBanner () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *middleImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, assign) NSInteger curIndex;

// scroll timer
@property (nonatomic, strong) NSTimer *scrollTimer;

// scroll duration
@property (nonatomic, assign) NSTimeInterval scrollDuration;

@end

@implementation YBLoopBanner


#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame scrollDuration:(NSTimeInterval)duration
{
    if (self = [super initWithFrame:frame])
    {
        self.scrollDuration = 0.f;
        [self addObservers];
        [self setupViews];
        if (duration > 0.f)
        {
            self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:(self.scrollDuration = duration)
                                                                target:self
                                                              selector:@selector(scrollTimerDidFired:)
                                                              userInfo:nil
                                                               repeats:YES];
            [self.scrollTimer setFireDate:[NSDate distantFuture]];
        }
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.scrollDuration = 0.f;
        [self addObservers];
        [self setupViews];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeObservers];
    
    if (self.scrollTimer)
    {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}

#pragma mark - setupViews
- (void)setupViews
{
    [self addSubview:self.scrollView];
//    [self addSubview:self.pageControl];
    
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.middleImageView];
    [self.scrollView addSubview:self.rightImageView];
    
    [self placeSubviews];
}

- (void)placeSubviews
{
    CGFloat imageWidth = CGRectGetWidth(self.scrollView.bounds);
    CGFloat imageHeight = CGRectGetHeight(self.scrollView.bounds);
    NSLog(@"%f-%f",imageWidth,imageHeight);
    _leftImageView.frame    = CGRectMake(imageWidth * 0, 0, imageWidth, imageHeight);
    NSLog(@"%f-%f-%f-%f",_leftImageView.frame.origin.x,_leftImageView.frame.origin.y,imageWidth,imageHeight);
    self.middleImageView.frame  = CGRectMake(imageWidth * 1, 0, imageWidth, imageHeight);
    NSLog(@"%f-%f-%f-%f",_middleImageView.frame.origin.x,_middleImageView.frame.origin.y,imageWidth,imageHeight);
    self.rightImageView.frame   = CGRectMake(imageWidth * 2, 0, imageWidth, imageHeight);
    self.scrollView.contentSize = CGSizeMake(imageWidth * 3, 0);
    
    [self setScrollViewContentOffsetCenter];
}

#pragma mark - set scrollView contentOffset to center
- (void)setScrollViewContentOffsetCenter
{
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0);
}

#pragma mark - kvo
- (void)addObservers
{
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        [self caculateCurIndex];
    }
}

#pragma mark - getters
- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [UIScrollView new];
        _scrollView.frame = self.bounds;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    
    return _scrollView;
}

//- (UIPageControl *)pageControl
//{
//    if (!_pageControl)
//    {
//        _pageControl = [UIPageControl new];
//        _pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 30.f, CGRectGetWidth(self.bounds), 20.f);
//        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
//        _pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
//    }
//    
//    return _pageControl;
//}

- (UIImageView *)leftImageView
{
    if (!_leftImageView)
    {
        _leftImageView = [UIImageView new];
        _leftImageView.contentMode = UIViewContentModeScaleToFill;
        [_leftImageView setImage:[UIImage imageNamed:@"home_bg"]];
    }
    
    return _leftImageView;
}

- (UIImageView *)middleImageView
{
    if (!_middleImageView)
    {
        _middleImageView = [UIImageView new];
        _middleImageView.contentMode = UIViewContentModeScaleToFill;
        [_middleImageView setImage:[UIImage imageNamed:@"home_bg"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked:)];
        [_middleImageView addGestureRecognizer:tap];
        _middleImageView.userInteractionEnabled = YES;
    }
    
    return _middleImageView;
}

- (UIImageView *)rightImageView
{
    if (!_rightImageView)
    {
        _rightImageView = [UIImageView new];
        _rightImageView.contentMode = UIViewContentModeScaleToFill;
        [_rightImageView setImage:[UIImage imageNamed:@"home_bg"]];
    }
    
    return _rightImageView;
}


#pragma mark - setters
- (void)setImageURLStrings:(NSArray *)imageURLStrings
{
    if (imageURLStrings)
    {
        _imageURLStrings = imageURLStrings;
        self.curIndex = 0;
        
        if (imageURLStrings.count > 1)
        {
            // auto scroll
            [self.scrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.scrollDuration]];
//            self.pageControl.numberOfPages = imageURLStrings.count;
//            self.pageControl.currentPage = 0;
//            self.pageControl.hidden = NO;
        }
        else
        {
//            self.pageControl.hidden = YES;
            [_leftImageView removeFromSuperview];
            [_rightImageView removeFromSuperview];
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), 0);
        }
    }
}

- (void)setCurIndex:(NSInteger)curIndex
{
    if (_curIndex >= 0)
    {
        _curIndex = curIndex;
        
        // caculate index
        NSInteger imageCount = _imageURLStrings.count;
        NSInteger leftIndex = (curIndex + imageCount - 1) % imageCount;
        NSInteger rightIndex= (curIndex + 1) % imageCount;
        
        // TODO: if need use image from server, can import SDWebImage SDK and modify the codes below.
        // fill image
        [_leftImageView sd_setImageWithURL:[NSURL URLWithString:_imageURLStrings[leftIndex]] placeholderImage:[UIImage imageNamed:@"home_bg"]];
        [_middleImageView sd_setImageWithURL:[NSURL URLWithString:_imageURLStrings[curIndex]] placeholderImage:[UIImage imageNamed:@"home_bg"]];
        [_rightImageView sd_setImageWithURL:[NSURL URLWithString:_imageURLStrings[rightIndex]] placeholderImage:[UIImage imageNamed:@"home_bg"]];
        
        [self setScrollViewContentOffsetCenter];
        
//        _pageControl.currentPage = curIndex;
    }
}

#pragma mark - caculate curIndex
- (void)caculateCurIndex
{
    if (self.imageURLStrings && self.imageURLStrings.count > 0) {
        CGFloat pointX = self.scrollView.contentOffset.x;
        
        // judge critical value，first and third imageView's contentoffset
        CGFloat criticalValue = .2f;
        
        // scroll right, judge right critical value
        if (pointX > 2 * CGRectGetWidth(self.scrollView.bounds) - criticalValue)
        {
            self.curIndex = (self.curIndex + 1) % self.imageURLStrings.count;
        }
        else if (pointX < criticalValue)
        {
            // scroll left，judge left critical value
            self.curIndex = (self.curIndex + self.imageURLStrings.count - 1) % self.imageURLStrings.count;
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.imageURLStrings.count > 1)
    {
        [self.scrollTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.imageURLStrings.count > 1)
    {
        [self.scrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.scrollDuration]];
    }
}

#pragma mark - button actions
- (void)imageClicked:(UITapGestureRecognizer *)tap
{
    if (self.clickAction)
    {
        self.clickAction (self.curIndex);
    }
}

#pragma mark - timer action
- (void)scrollTimerDidFired:(NSTimer *)timer {
    // correct the imageview's frame, because after every auto scroll,
    // may show two images in one page
    CGFloat criticalValue = .2f;
    if (self.scrollView.contentOffset.x < CGRectGetWidth(self.scrollView.bounds) - criticalValue || self.scrollView.contentOffset.x > CGRectGetWidth(self.scrollView.bounds) + criticalValue)
    {
        [self setScrollViewContentOffsetCenter];
    }
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.bounds), self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
}

@end
