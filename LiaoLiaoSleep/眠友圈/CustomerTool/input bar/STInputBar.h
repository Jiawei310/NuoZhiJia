//
//  STInputBar.h
//  STEmojiKeyboard
//
//  Created by zhenlintie on 15/5/29.
//  Copyright (c) 2015年 sTeven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STEmojiKeyboard.h"

@interface STInputBar : UIView<STEmojiKeyboardDelegate>

+ (instancetype)inputBar;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *sendButton;
@property (assign, nonatomic) BOOL fitWhenKeyboardShowOrHide;

- (void)setDidSendClicked:(void(^)(NSString *text))handler;

@property (copy, nonatomic) NSString *placeHolder;

@end
