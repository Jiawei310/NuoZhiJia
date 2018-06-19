//
//  ImageTitleDetialView.h
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol ImageTitleDetialViewDelegate <NSObject>
//- (void)selectIndex:(NSInteger)index;
//@end

@interface ImageTitleDetialView : UIView

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger selector;
@property (nonatomic, assign) BOOL isCanSelect;

//@property (nonatomic, weak) id<ImageTitleDetialViewDelegate>delegate;

@property (copy) void (^imageTitleDetailViewBlock)();

@end
