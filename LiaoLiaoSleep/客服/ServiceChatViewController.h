//
//  ServiceChatViewController.h
//  Chat
//
//  Created by 甘伟 on 16/12/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ServiceChatToolBar.h"

#import "IMessageModel.h"
#import "EaseMessageModel.h"
#import "EaseBaseMessageCell.h"
#import "EaseMessageTimeCell.h"
#import "EMCDDeviceManager+Media.h"
#import "EMCDDeviceManager+ProximitySensor.h"
#import "UIViewController+HUD.h"
#import "EaseSDKHelper.h"
#import "EaseEmotionManager.h"
#import "EMClient.h"


@interface ServiceChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate,EMChatManagerDelegate, ServiceChatToolbarDelegate,EMCDDeviceManagerDelegate>

@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic)         NSTimeInterval messageTimeIntervalTag;
@property (nonatomic)                   BOOL deleteConversationIfNull; //default YES;
@property (nonatomic)                   BOOL scrollToBottomWhenAppear; //default YES;
@property (nonatomic)                   BOOL isViewDidAppear;
@property (nonatomic)              NSInteger messageCountOfPage; //default 50
@property (nonatomic)                CGFloat timeCellHeight;
@property (nonatomic, strong)     NSMutableArray *messsagesSource;
@property (nonatomic, strong) ServiceChatToolBar *chatToolbar;
@property (nonatomic, strong)     EaseRecordView *recordView;
@property (nonatomic, strong)   UIMenuController *menuController;
@property (nonatomic, strong)        NSIndexPath *menuIndexPath;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong)             UITableView *tableView;
@property (nonatomic, strong)                  UIView *defaultFooterView;
@property (nonatomic, strong)      NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableDictionary *dataDictionary;
@property (nonatomic)            int page;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *HeaderImage;
@property (nonatomic)           BOOL showRefreshHeader;
@property (nonatomic)           BOOL showRefreshFooter;
@property (nonatomic)           BOOL showTableBlankView;

- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel;

- (BOOL)isEmotionMessageFormessageViewController:(ServiceChatViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter;

- (void)tableViewDidTriggerHeaderRefresh;

- (void)tableViewDidTriggerFooterRefresh;

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader
                                 reload:(BOOL)reload;

- (void)takePictureActionSheet:(ServiceChatToolBar *)toolBar;

- (void)didSendFace:(STEmojiKeyboard *)faceLocalPath;

- (void)sendTextMessage:(NSString *)text;

- (void)sendTextMessage:(NSString *)text
                withExt:(NSDictionary*)ext;

- (void)sendImageMessage:(UIImage *)image;

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration;

- (void)sendVideoMessageWithURL:(NSURL *)url;

- (void)addMessageToDataSource:(EMMessage *)message
                      progress:(id)progress;

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType;

- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read;

@end
