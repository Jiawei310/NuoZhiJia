//
//  SelectView.h
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol SelectViewDelegate <NSObject>
//- (void)selectIndex:(NSInteger)index;
//@end

@interface SelectView : UIView

@property (nonatomic, strong) NSString *titile;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger selector;

//@property (nonatomic, weak) id<SelectViewDelegate>delegate;
@property (copy) void (^selectViewBlock)(NSInteger);


- (void)showViewInView:(UIView *)view;
- (void)hideView;

@end
