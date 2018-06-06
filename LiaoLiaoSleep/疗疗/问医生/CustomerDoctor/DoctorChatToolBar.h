//
//  DoctorChatToolBar.h
//  Chat
//
//  Created by 甘伟 on 16/12/26.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol DoctorChatToolbarDelegate;
@interface DoctorChatToolBar : UIView<UITextViewDelegate>

@property (weak, nonatomic) id<DoctorChatToolbarDelegate> delegate;
@property(strong, nonatomic)UITextView * textView;
@property(strong, nonatomic)UILabel * placeHolderLabel;
@property(strong, nonatomic)UIButton * scaleButton;
@property(strong, nonatomic)UIButton * pictureButton;

-(instancetype)initWithFrame:(CGRect)frame;

@end

@protocol DoctorChatToolbarDelegate<NSObject>

@optional
- (void)sendPictureActionSheet:(DoctorChatToolBar *)chatTool;
- (void)sendScaleUpdate:(DoctorChatToolBar *)chatTool;
- (void)inputTextViewDidBeginEditing:(UITextView * )inputTextView;
- (void)inputTextViewWillBeginEditing:(UITextView * )inputTextView;
- (void)inputTextViewDidChange:(UITextView *)inputTextView;
- (void)sendText:(NSString *)text;

@end
