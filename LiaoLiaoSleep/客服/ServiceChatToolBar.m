//
//  ServiceChatToolBar.m
//  Chat
//
//  Created by 甘伟 on 16/12/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "ServiceChatToolBar.h"
#import "EaseEmotionEscape.h"

#define kSTIBDefaultHeight 50
#define kSTLeftButtonWidth 50
#define kSTLeftButtonHeight 30
#define kSTRightButtonWidth 55
#define kSTTextviewDefaultHeight 34
#define kSTTextviewMaxHeight 80

@implementation ServiceChatToolBar
{
    BOOL _isRegistedKeyboardNotif;
    BOOL _isDefaultKeyboard;
    NSArray *_switchKeyboardImages;
}
@synthesize recordView = _recordView;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        _isRegistedKeyboardNotif = NO;
        _isDefaultKeyboard = YES;
        [self customerView];
    }
    
    return self;
}

- (void)customerView
{
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    _keyboard = [STEmojiKeyboard keyboard];
    _keyboard.delegate = self;
    
    //文字输入框
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(kSTLeftButtonWidth, (kSTIBDefaultHeight-kSTTextviewDefaultHeight)/2, CGRectGetWidth(self.frame)-kSTLeftButtonWidth-2*kSTRightButtonWidth, kSTTextviewDefaultHeight)];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.textColor = [UIColor blackColor];
    self.textView.layer.cornerRadius = 5;
    self.textView.clipsToBounds = YES;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    self.textView.tintColor = [UIColor blackColor];
    self.textView.scrollEnabled = NO;
    self.textView.showsVerticalScrollIndicator = NO;
    
    self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSTLeftButtonWidth+5, CGRectGetMinY(_textView.frame), CGRectGetWidth(_textView.frame), kSTTextviewDefaultHeight)];
    self.placeHolderLabel.adjustsFontSizeToFitWidth = YES;
    self.placeHolderLabel.minimumScaleFactor = 0.9;
    self.placeHolderLabel.textColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.84 alpha:1.0];
    self.placeHolderLabel.font = _textView.font;
    self.placeHolderLabel.text = @"请输入信息";
    self.placeHolderLabel.userInteractionEnabled = NO;
    
    self.recordMark = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, (kSTIBDefaultHeight-kSTLeftButtonHeight)/2, kSTLeftButtonWidth, kSTLeftButtonHeight)];
    [self.recordMark setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_record"] forState:UIControlStateNormal];
    [self.recordMark setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_keyboard"] forState:UIControlStateSelected];
    [self.recordMark addTarget:self action:@selector(styleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.recordButton = [[UIButton alloc]initWithFrame:self.textView.frame];
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_recordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_recordSelectedBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:kTouchToRecord forState:UIControlStateNormal];
    [self.recordButton setTitle:kTouchToFinish forState:UIControlStateHighlighted];
    self.recordButton.hidden = YES;
    [self.recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
    
    self.faceBtn = [[UIButton alloc]init];
    self.faceBtn.frame = CGRectMake(self.frame.size.width-2*kSTRightButtonWidth, 0, kSTRightButtonWidth, kSTIBDefaultHeight);
    self.faceBtn.tag = 0;
    [self.faceBtn setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_face@2x.png"] forState:UIControlStateNormal];
    [self.faceBtn setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_faceSelected@2x.png"] forState:UIControlStateHighlighted];
    [self.faceBtn addTarget:self action:@selector(keyboardTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageBtn = [[UIButton alloc]init];
    self.imageBtn.frame = CGRectMake(self.frame.size.width-kSTRightButtonWidth, 0, kSTRightButtonWidth, kSTIBDefaultHeight);
    [self.imageBtn setImage:[UIImage imageNamed:@"icon_picture.pn"] forState:(UIControlStateNormal)];
    [self.imageBtn addTarget:self action:@selector(pictureClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.textView];
    [self addSubview:self.placeHolderLabel];
    [self addSubview:self.recordMark];
    [self addSubview:self.recordButton];
    [self addSubview:self.faceBtn];
    [self addSubview:self.imageBtn];
}

- (void)layout
{
    self.placeHolderLabel.hidden = ![@"" isEqualToString:self.textView.text];
    
    CGRect textViewFrame = self.textView.frame;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];
    
    CGFloat offset = 10;
    self.textView.scrollEnabled = (textSize.height > kSTTextviewMaxHeight-offset);
    textViewFrame.size.height = MAX(kSTTextviewDefaultHeight, MIN(kSTTextviewMaxHeight, textSize.height));
    self.textView.frame = textViewFrame;
    
    CGRect addBarFrame = self.frame;
    CGFloat maxY = CGRectGetMaxY(addBarFrame);
    addBarFrame.size.height = textViewFrame.size.height+offset;
    addBarFrame.origin.y = maxY-addBarFrame.size.height;
    self.frame = addBarFrame;
    
    self.recordMark.center = CGPointMake(CGRectGetMidX(self.recordMark.frame), CGRectGetHeight(addBarFrame)/2.0f);
    self.faceBtn.center = CGPointMake(CGRectGetMidX(self.faceBtn.frame), CGRectGetHeight(addBarFrame)/2.0f);
    self.imageBtn.center = CGPointMake(CGRectGetMidX(self.imageBtn.frame), CGRectGetHeight(addBarFrame)/2.0f);
}

#pragma mark - getter
- (UIView *)recordView
{
    if (_recordView == nil)
    {
        _recordView = [[EaseRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    }
    
    return _recordView;
}

- (void)setRecordView:(UIView *)recordView
{
    if(_recordView != recordView)
    {
        _recordView = recordView;
    }
}

#pragma mark - public
- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [_textView resignFirstResponder];
}

- (void)sendEmoji
{
    NSString *chatText = self.textView.text;
    if (chatText.length > 0)
    {
        if ([self.delegate respondsToSelector:@selector(didSendText:)])
        {
            if (![_textView.text isEqualToString:@""])
            {
                [self.delegate didSendText:_textView.text];
                self.textView.text = @"";
            }
        }
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)])
    {
        [self.delegate inputTextViewWillBeginEditing:self.textView];
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)])
    {
        [self.delegate inputTextViewDidBeginEditing:self.textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self layout];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        if ([_delegate respondsToSelector:@selector(didSendText:)])
        {
            [self.delegate didSendText:textView.text];
            self.textView.text = @"";
            [textView resignFirstResponder];
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - action
- (void)recordButtonTouchDown
{
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)])
    {
        [_delegate didStartRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)])
    {
        [_delegate didCancelRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpInside
{
    self.recordButton.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction:)])
    {
        [self.delegate didFinishRecoingVoiceAction:self.recordView];
    }
    self.recordButton.enabled = YES;
}

- (void)recordDragOutside
{
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)]){
        [self.delegate didDragOutsideAction:self.recordView];
    }
}

- (void)recordDragInside
{
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)])
    {
        [self.delegate didDragInsideAction:self.recordView];
    }
}

- (void)cancelTouchRecord
{
    if ([_recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)_recordView recordButtonTouchUpInside];
        [_recordView removeFromSuperview];
    }
}

#pragma mark -- 语音与输入法切换
- (void)styleButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected)
    {
        self.textView.text = @"";
        [self textViewDidChange:self.textView];
        [self.textView resignFirstResponder];
    }
    else
    {
        [self.textView becomeFirstResponder];
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.recordButton.hidden = !button.selected;
        self.textView.hidden = button.selected;
    } completion:nil];
}

#pragma mark -- 发送表情
- (void)keyboardTypeButtonClicked:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        self.textView.inputView = nil;
    }
    else
    {
        [_keyboard setTextView:self.textView];
    }
    [self.textView reloadInputViews];
    sender.tag = (sender.tag+1)%2;
    [_textView becomeFirstResponder];
    self.recordButton.hidden = YES;
    self.textView.hidden = NO;
}

#pragma mark -- 发送照片
- (void)pictureClicked:(UIButton *)sender
{
    [_textView resignFirstResponder];
    self.recordButton.hidden = YES;
    self.textView.hidden = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(takePictureActionSheet:)])
    {
        [_delegate takePictureActionSheet:self];
    }
}

@end
