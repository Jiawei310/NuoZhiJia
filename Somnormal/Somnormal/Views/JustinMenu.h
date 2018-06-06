//
//  JustinMenu.h
//  Somnormal
//
//  Created by Justin on 2017/7/11.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface JustinMenuItem : NSObject

@property (readwrite, nonatomic, strong)  UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, strong)  UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic)      SEL action;

+ (instancetype)menuItem:(NSString *)title
                   image:(UIImage *)image
                  target:(id)target
                  action:(SEL) action;

@end

@interface JustinMenu : NSObject

+ (void)showMenuInView:(UIView *)view
              fromRect:(CGRect)rect
             menuItems:(NSArray *)menuItems;

+ (void)dismissMenu;

+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;

+ (UIFont *)titleFont;
+ (void)setTitleFont:(UIFont *)titleFont;

@end
