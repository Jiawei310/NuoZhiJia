//
//  STEmojiKeyboard.h
//  STEmojiKeyboard
//
//  Created by zhenlintie on 15/5/29.
//  Copyright (c) 2015年 sTeven. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STEmojiKeyboardDelegate;
@interface STEmojiKeyboard : UIView <UIInputViewAudioFeedback>
+ (instancetype)keyboard;

@property (weak, nonatomic) id<STEmojiKeyboardDelegate> delegate;
@property (strong, nonatomic) id<UITextInput> textView;

@end

@protocol STEmojiKeyboardDelegate <NSObject>

-(void)sendEmoji;

@end
