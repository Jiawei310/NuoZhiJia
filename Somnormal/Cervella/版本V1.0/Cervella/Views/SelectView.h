//
//  SelectView.h
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectView : UIView

@property (nonatomic, strong) NSString *titile;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger selector;

- (void)showViewInView:(UIView *)view;
- (void)hideView;

@end
