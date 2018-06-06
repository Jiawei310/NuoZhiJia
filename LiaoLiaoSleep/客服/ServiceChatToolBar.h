//
//  ServiceChatToolBar.h
//  Chat
//
//  Created by 甘伟 on 16/12/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseLocalDefine.h"
#import "EaseRecordView.h"
#import "STEmojiKeyboard.h"

#define kTouchToRecord NSEaseLocalizedString(@"message.toolBar.record.touch", @"hold down to talk")
#define kTouchToFinish NSEaseLocalizedString(@"message.toolBar.record.send", @"loosen to send")

@protocol ServiceChatToolbarDelegate;
@interface ServiceChatToolBar : UIView<UITextViewDelegate,STEmojiKeyboardDelegate>

@property (nonatomic, weak)  id<ServiceChatToolbarDelegate> delegate;
@property (nonatomic, strong)      UITextView *textView;
@property (nonatomic, strong)         UILabel *placeHolderLabel;
@property (nonatomic, strong)          UIView *recordView;
@property (nonatomic, strong)          UIView *faceView;
@property (nonatomic, strong) STEmojiKeyboard *keyboard;
@property (nonatomic, strong)        UIButton *recordMark;
@property (nonatomic, strong)        UIButton *recordButton;
@property (nonatomic, strong)        UIButton *faceBtn;
@property (nonatomic, strong)        UIButton *imageBtn;


- (instancetype)initWithFrame:(CGRect)frame;

@end

@protocol ServiceChatToolbarDelegate <NSObject>

@optional

- (void)inputTextViewDidBeginEditing:(UIView *)inputTextView;
- (void)inputTextViewWillBeginEditing:(UIView *)inputTextView;
- (void)didSendText:(NSString *)text;
- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext;
- (BOOL)didInputAtInLocation:(NSUInteger)location;
- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location;
- (void)sendEmojiWith:(NSString *)emoji;
- (void)didStartRecordingVoiceAction:(UIView *)recordView;
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;
- (void)didFinishRecoingVoiceAction:(UIView *)recordView;
- (void)didDragOutsideAction:(UIView *)recordView;
- (void)didDragInsideAction:(UIView *)recordView;
- (void)takePictureActionSheet:(ServiceChatToolBar *)toolBar;

@end

