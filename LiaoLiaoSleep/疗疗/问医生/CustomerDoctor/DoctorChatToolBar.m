//
//  DoctorChatToolBar.m
//  Chat
//
//  Created by 甘伟 on 16/12/26.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "DoctorChatToolBar.h"
#define kSTIBDefaultHeight 50
#define kSTLeftButtonWidth 50
#define kSTLeftButtonHeight 30
#define kSTRightButtonWidth 55
#define kSTTextviewDefaultHeight 34
#define kSTTextviewMaxHeight 80

@interface DoctorChatToolBar()

@end


@implementation DoctorChatToolBar

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self customerView];
    }
    return self;
}
-(void)customerView{
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    //文字输入框
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(kSTLeftButtonWidth, (kSTIBDefaultHeight-kSTTextviewDefaultHeight)/2, CGRectGetWidth(self.frame)-kSTLeftButtonWidth-kSTRightButtonWidth, kSTTextviewDefaultHeight)];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.cornerRadius = 5;
    self.textView.clipsToBounds = YES;
    //    self.textView.textContainerInset = UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f);
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    self.textView.tintColor = [UIColor lightGrayColor];
    self.textView.scrollEnabled = NO;
    self.textView.showsVerticalScrollIndicator = NO;
    
    self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSTLeftButtonWidth+5, CGRectGetMinY(_textView.frame), CGRectGetWidth(_textView.frame), kSTTextviewDefaultHeight)];
    self.placeHolderLabel.adjustsFontSizeToFitWidth = YES;
    self.placeHolderLabel.minimumScaleFactor = 0.9;
    self.placeHolderLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.placeHolderLabel.font = _textView.font;
    self.placeHolderLabel.userInteractionEnabled = NO;
    
    self.scaleButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, (kSTIBDefaultHeight-kSTLeftButtonHeight)/2, kSTLeftButtonWidth, kSTLeftButtonHeight)];
    [self.scaleButton setTitle:@"量表" forState:(UIControlStateNormal)];
    [self.scaleButton setTitleColor:[UIColor colorWithRed:0.62 green:0.63 blue:0.64 alpha:1.0] forState:(UIControlStateNormal)];
    self.scaleButton.titleLabel.font = [UIFont systemFontOfSize:15];
//    [self.scaleButton setImage:[UIImage imageNamed:@"icon_picture.png"] forState:UIControlStateNormal];
    [self.scaleButton addTarget:self action:@selector(scaleClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pictureButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-kSTRightButtonWidth, 0, kSTRightButtonWidth, kSTIBDefaultHeight)];
    [self.pictureButton setImage:[UIImage imageNamed:@"icon_picture.png"] forState:(UIControlStateNormal)];
    [self.pictureButton addTarget:self action:@selector(pictureClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.scaleButton];
    [self addSubview:self.textView];
    [self addSubview:self.placeHolderLabel];
    [self addSubview:self.pictureButton];
}
- (void)layout{
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
    
    self.scaleButton.center = CGPointMake(CGRectGetMidX(self.scaleButton.frame), CGRectGetHeight(addBarFrame)/2.0f);
    self.pictureButton.center = CGPointMake(CGRectGetMidX(self.pictureButton.frame), CGRectGetHeight(addBarFrame)/2.0f);
}
#pragma mark - public
- (BOOL)resignFirstResponder{
    [super resignFirstResponder];
    return [_textView resignFirstResponder];
}
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.textView];
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.textView];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [_textView resignFirstResponder];
}
- (void)textViewDidChange:(UITextView *)textView{
    [self layout];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:self.textView];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        if ([_delegate respondsToSelector:@selector(sendText:)]) {
            [self.delegate sendText:textView.text];
            self.textView.text = @"";
            [textView resignFirstResponder];
            [self layout];
        }
        return NO;
    }
    return YES;
}
#pragma mark -- 量表更新
-(void)scaleClicked:(UIButton *)sender{
    [_textView resignFirstResponder];
    if(_delegate && [_delegate respondsToSelector:@selector(sendScaleUpdate:)]){
        [_delegate sendScaleUpdate:self];
    }
}
#pragma mark -- 发送照片
-(void)pictureClicked:(UIButton *)sender{
    [_textView resignFirstResponder];
    if(_delegate && [_delegate respondsToSelector:@selector(sendPictureActionSheet:)]){
        [_delegate sendPictureActionSheet:self];
    }
}
@end
