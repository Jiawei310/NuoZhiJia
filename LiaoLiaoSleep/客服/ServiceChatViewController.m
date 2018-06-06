//
//  ServiceChatViewController.m
//  Chat
//
//  Created by 甘伟 on 16/12/28.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import "ServiceChatViewController.h"
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Define.h"
#import <UMMobClick/MobClick.h>
#import "NSDate+Category.h"
#import "EaseMessageReadManager.h"
#import "EaseEmotionManager.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"
#import "EaseCustomMessageCell.h"
#import "UIImage+EMGIF.h"
#import "EaseLocalDefine.h"
#import "EaseSDKHelper.h"
#import "MJRefresh.h"

@interface ServiceChatViewController ()<EaseMessageCellDelegate>{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UILongPressGestureRecognizer *_lpgr;
    NSMutableArray *_atTargets;
    dispatch_queue_t _messageQueue;
}
@property (strong, nonatomic) id<IMessageModel> playingVoiceModel;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isPlayingAudio;

@end

@implementation ServiceChatViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize timeCellHeight = _timeCellHeight;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
{
    if ([conversationChatter length] == 0)
    {
        return nil;
    }
    if (self == [super init])
    {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:EMConversationTypeChat createIfNotExist:YES];
        _messageCountOfPage = 10;
        _timeCellHeight = 30;
        _deleteConversationIfNull = YES;
        _scrollToBottomWhenAppear = YES;
        _messsagesSource = [NSMutableArray array];
        [_conversation markAllMessagesAsRead:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.navigationItem.title = @"小疗在线";
    
    //添加返回按钮
    UIButton *backLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    backLogin.frame = CGRectMake(12, 30, 23, 23);
    [backLogin setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backLogin addTarget:self action:@selector(backLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backLoginItem = [[UIBarButtonItem alloc] initWithCustomView:backLogin];
    //添加fixedButton是为了让backLoginItem往左边靠拢
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -10;
    self.navigationItem.leftBarButtonItems = @[fixedButton, backLoginItem];
    //添加导航栏右边按钮，设备状态查看
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [btn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"清空" forState:(UIControlStateNormal)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //创建聊天面板
    [self createTableView];
    
    //创建输入工具
    self.chatToolbar = [[ServiceChatToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    self.chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    //添加长按手势
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    
    _messageQueue = dispatch_queue_create("hyphenate.com", NULL);
    
    //注册代理
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    //聊天气泡---------发送者（右边）
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    //聊天气泡---------接收者（左边）
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
    
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_full"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_000"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_001"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_002"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_003"]]];
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing_full"],[UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing000"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing001"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing002"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing003"]]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    [self tableViewDidTriggerHeaderRefresh];
}

//返回按钮点击事件
- (void)backLoginClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- 键盘即将出现
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat transformY = keyboardRect.origin.y - self.parentViewController.view.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}

#pragma mark --- 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat transformY = keyboardRect.origin.y - self.parentViewController.view.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}

#pragma mark -- 清空聊天记录
- (void)deleteClick
{
    __weak ServiceChatViewController *weakSelf = self;
    [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
        if(!aError){
            weakSelf.dataArray = [NSMutableArray array];
            weakSelf.messsagesSource = [NSMutableArray array];
            [weakSelf.tableView reloadData];
            [self showHint:@"聊天记录已删除"];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    if (_imagePicker)
    {
        [_imagePicker dismissViewControllerAnimated:YES completion:nil];
        _imagePicker = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"小疗在线"];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
    if (self.scrollToBottomWhenAppear)
    {
        [self _scrollViewToBottom:NO];
    }
    self.scrollToBottomWhenAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"小疗在线"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isViewDidAppear = NO;
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
}

#pragma mark - getter
- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil)
    {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

#pragma mark - setter
- (void)setIsViewDidAppear:(BOOL)isViewDidAppear
{
    _isViewDidAppear =isViewDidAppear;
    if (_isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        [_conversation markAllMessagesAsRead:nil];
    }
}

- (void)setChatToolbar:(ServiceChatToolBar *)chatToolbar
{
    [_chatToolbar removeFromSuperview];
    _chatToolbar = chatToolbar;
    if (_chatToolbar)
    {
        [self.view addSubview:_chatToolbar];
    }
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - _chatToolbar.frame.size.height;
    self.tableView.frame = tableFrame;
    if ([chatToolbar isKindOfClass:[ServiceChatToolBar class]])
    {
        [(ServiceChatToolBar *)self.chatToolbar setDelegate:self];
        self.recordView = (EaseRecordView*)[(ServiceChatToolBar *)self.chatToolbar recordView];
    }
}

- (void)createTableView
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = self.defaultFooterView;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setShowRefreshHeader:YES];
    [self.view addSubview:_tableView];
    
    _page = 0;
    _showRefreshHeader = YES;
    _showRefreshFooter = NO;
    _showTableBlankView = NO;
}

#pragma mark - setter
- (void)setShowRefreshHeader:(BOOL)showRefreshHeader
{
    if (_showRefreshHeader != showRefreshHeader)
    {
        _showRefreshHeader = showRefreshHeader;
        if (_showRefreshHeader)
        {
            __weak ServiceChatViewController *weakSelf = self;
            self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerHeaderRefresh];
                [weakSelf.tableView.mj_header beginRefreshing];
            }];
        }
        else
        {
            
        }
    }
}

- (void)setShowRefreshFooter:(BOOL)showRefreshFooter
{
    if (_showRefreshFooter != showRefreshFooter)
    {
        _showRefreshFooter = showRefreshFooter;
        if (_showRefreshFooter)
        {
            __weak ServiceChatViewController *weakSelf = self;
            self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerFooterRefresh];
                [weakSelf.tableView.mj_footer beginRefreshing];
            }];
        }
        else
        {
            
        }
    }
}

-(void)tableViewDidTriggerFooterRefresh
{
    
}

- (void)setShowTableBlankView:(BOOL)showTableBlankView
{
    if (_showTableBlankView != showTableBlankView)
    {
        _showTableBlankView = showTableBlankView;
    }
}

#pragma mark - getter
- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableDictionary *)dataDictionary
{
    if (_dataDictionary == nil)
    {
        _dataDictionary = [NSMutableDictionary dictionary];
    }
    return _dataDictionary;
}

- (UIView *)defaultFooterView
{
    if (_defaultFooterView == nil)
    {
        _defaultFooterView = [[UIView alloc] init];
    }
    
    return _defaultFooterView;
}

#pragma mark - private helper
- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (BOOL)_canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)])
        {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    if (_menuController == nil)
    {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil)
    {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSEaseLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil)
    {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSEaseLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
    }
    
    if (messageType == EMMessageBodyTypeText)
    {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else
    {
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)_stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [EMCDDeviceManager dataPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"failed, error:%@.", exportSession.error);
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"cancelled.");
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"completed.");
                    break;
                    
                default:
                    NSLog(@"others.");
                    break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout)
        {
            NSLog(@"timeout.");
        }
        if (wait)
        {
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (EMChatType)_messageTypeFromConversationType
{
    EMChatType type = EMChatTypeChat;
    switch (self.conversation.type)
    {
        case EMConversationTypeChat:
            type = EMChatTypeChat;
            break;
            
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat;
            break;
            
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom;
            break;
            
        default:
            break;
    }
    return type;
}

- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:NSEaseLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
        }
    };
    
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage)
    {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message attachment
            [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error)
                {
                    [weakSelf _reloadTableViewDataWithMessage:message];
                }
                else
                {
                    [weakSelf showHint:NSEaseLocalizedString(@"message.voiceFail", @"voice for failure!")];
                }
            }];
        }
    }
}

- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read
{
    NSString *account = [[EMClient sharedClient] currentUsername];
    if (message.chatType != EMChatTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        return NO;
    }
    
    EMMessageBody *body = message.body;
    if (((body.type == EMMessageBodyTypeVideo) ||
         (body.type == EMMessageBodyTypeVoice) ||
         (body.type == EMMessageBodyTypeImage)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        isSend = [self shouldSendHasReadAckForMessage:message
                                                 read:isRead];
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
        }
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        isMark = NO;
    }
    return isMark;
}

- (void)_videoMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.message.body;
    
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0)
    {
        [self showHint:NSEaseLocalizedString(@"message.videoFail", @"video for failure!")];
        return;
    }
    
    dispatch_block_t block = ^{
        //send the acknowledgement
        [self _sendHasReadResponseForMessages:@[model.message]
                                       isRead:YES];
        
        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:aMessage];
        }
        else
        {
            [weakSelf showHint:NSEaseLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
        }
    };
    
    if (videoBody.thumbnailDownloadStatus == EMDownloadStatusFailed || ![[NSFileManager defaultManager] fileExistsAtPath:videoBody.thumbnailLocalPath])
    {
        [self showHint:@"begin downloading thumbnail image, click later"];
        [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:completion];
        return;
    }
    
    if (videoBody.downloadStatus == EMDownloadStatusSuccessed && [[NSFileManager defaultManager] fileExistsAtPath:localPath])
    {
        block();
        return;
    }
    
    [self showHudInView:self.view hint:NSEaseLocalizedString(@"message.downloadingVideo", @"downloading video...")];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakSelf hideHud];
        if (!error)
        {
            block();
        }
        else
        {
            [weakSelf showHint:NSEaseLocalizedString(@"message.videoFail", @"video for failure!")];
        }
    }];
}

- (void)_imageMessageCellSelected:(id<IMessageModel>)model
{
    __weak ServiceChatViewController *weakSelf = self;
    EMImageMessageBody *imageBody = (EMImageMessageBody*)[model.message body];
    
    if ([imageBody type] == EMMessageBodyTypeImage)
    {
        if (imageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed)
        {
            if (imageBody.downloadStatus == EMDownloadStatusSuccessed)
            {
                //send the acknowledgement
                [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                NSString *localPath = model.message == nil ? model.fileLocalPath : [imageBody localPath];
                if (localPath && localPath.length > 0)
                {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    
                    if (image)
                    {
                        [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
                    }
                    else
                    {
                        NSLog(@"Read %@ failed!", localPath);
                    }
                    return;
                }
            }
            [weakSelf showHudInView:weakSelf.view hint:NSEaseLocalizedString(@"message.downloadingImage", @"downloading a image...")];
            [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                [weakSelf hideHud];
                if (!error)
                {
                    //send the acknowledgement
                    [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                    NSString *localPath = message == nil ? model.fileLocalPath : [(EMImageMessageBody*)message.body localPath];
                    if (localPath && localPath.length > 0)
                    {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        //                                weakSelf.isScrollToBottom = NO;
                        if (image)
                        {
                            [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [weakSelf showHint:NSEaseLocalizedString(@"message.imageFail", @"image for failure!")];
            }];
        }
        else
        {
            //get the message thumbnail
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error)
                {
                    [weakSelf _reloadTableViewDataWithMessage:model.message];
                }
                else
                {
                    [weakSelf showHint:NSEaseLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
                }
            }];
        }
    }
}

- (void)_audioMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading)
    {
        [self showHint:NSEaseLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        return;
    }
    else if (downloadStatus == EMDownloadStatusFailed)
    {
        [self showHint:NSEaseLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:nil];
        return;
    }
    
    // play the audio
    if (model.bodyType == EMMessageBodyTypeVoice)
    {
        //send the acknowledgement
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        __weak ServiceChatViewController *weakSelf = self;
        BOOL isPrepare = [[EaseMessageReadManager defaultManager] prepareMessageAudioModel:model updateViewCompletion:^(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel)
            {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare)
        {
            _isPlayingAudio = YES;
            __weak ServiceChatViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.fileLocalPath completion:^(NSError *error) {
                [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else
        {
            _isPlayingAudio = NO;
        }
    }
}

#pragma mark - pivate data

- (void)_loadMessagesBefore:(NSString*)messageId
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    __weak typeof(self) weakSelf = self;
    void (^refresh)(NSArray *messages) = ^(NSArray *messages) {
        dispatch_async(_messageQueue, ^{
            //Format the message
            NSArray *formattedMessages = [weakSelf formatMessages:messages];
            
            //Refresh the page
            dispatch_async(dispatch_get_main_queue(), ^{
                ServiceChatViewController *strongSelf = weakSelf;
                if (strongSelf)
                {
                    NSInteger scrollToIndex = 0;
                    if (isAppend)
                    {
                        [strongSelf.messsagesSource insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                        //Combine the message
                        id object = [strongSelf.dataArray firstObject];
                        if ([object isKindOfClass:[NSString class]])
                        {
                            NSString *timestamp = object;
                            [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                                if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                                {
                                    [strongSelf.dataArray removeObjectAtIndex:0];
                                    *stop = YES;
                                }
                            }];
                        }
                        scrollToIndex = [strongSelf.dataArray count];
                        [strongSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
                    }
                    else
                    {
                        [strongSelf.messsagesSource removeAllObjects];
                        [strongSelf.messsagesSource addObjectsFromArray:messages];
                        
                        [strongSelf.dataArray removeAllObjects];
                        [strongSelf.dataArray addObjectsFromArray:formattedMessages];
                    }
                    
                    EMMessage *latest = [strongSelf.messsagesSource lastObject];
                    strongSelf.messageTimeIntervalTag = latest.timestamp;
                    
                    [strongSelf.tableView reloadData];
                    
                    [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            });
            
            //re-download all messages that are not successfully downloaded
            for (EMMessage *message in messages)
            {
                [weakSelf _downloadMessageAttachments:message];
            }
            
            //send the read acknoledgement
            [weakSelf _sendHasReadResponseForMessages:messages
                                               isRead:NO];
        });
    };
    
    [self.conversation loadMessagesStartFromId:messageId count:(int)count searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count])
        {
            refresh(aMessages);
        }
    }];
}

#pragma mark - GestureRecognizer

-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataArray objectAtIndex:indexPath.row];
        if (![object isKindOfClass:[NSString class]])
        {
            EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _menuIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    //time cell
    if ([object isKindOfClass:[NSString class]])
    {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        if (timeCell == nil)
        {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        timeCell.title = object;
        
        return timeCell;
    }
    else
    {
        id<IMessageModel> model = object;
        if ([self respondsToSelector:@selector(messageViewController:cellForMessageModel:)])
        {
            UITableViewCell *cell = [self messageViewController:tableView cellForMessageModel:model];
            if (cell)
            {
                if ([cell isKindOfClass:[EaseMessageCell class]])
                {
                    EaseMessageCell *emcell= (EaseMessageCell*)cell;
                    if (emcell.delegate == nil)
                    {
                        emcell.delegate = self;
                    }
                }
                return cell;
            }
        }
        NSString *CellIdentifier = [EaseMessageCell cellIdentifierWithModel:model];
        EaseBaseMessageCell *sendCell = (EaseBaseMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (sendCell == nil)
        {
            sendCell = [[EaseBaseMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sendCell.delegate = self;
        }
        sendCell.model = model;
        
        return sendCell;
    }
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]])
    {
        return self.timeCellHeight;
    }
    else
    {
        id<IMessageModel> model = object;
        return [EaseBaseMessageCell cellHeightWithModel:model];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path])
        {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error)
            {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    }
    else
    {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil)
        {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            [self sendImageMessage:orgImage];
        }
        else
        {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f)
            {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset)
                    {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data.length > 10 * 1000 * 1000)
                            {
                                [self showHint:NSEaseLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one")];
                                return;
                            }
                            if (data != nil)
                            {
                                [self sendImageMessageWithData:data];
                            }
                            else
                            {
                                [self showHint:NSEaseLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one")];
                            }
                        }];
                    }
                }];
            }
            else
            {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset)
                    {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        if (fileData.length > 10 * 1000 * 1000)
                        {
                            [self showHint:NSEaseLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one")];
                            return;
                        }
                        [self sendImageMessageWithData:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark - EaseMessageCellDelegate
- (void)messageCellSelected:(id<IMessageModel>)model
{
    [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
    switch (model.bodyType)
    {
        case EMMessageBodyTypeImage:
        {
            _scrollToBottomWhenAppear = NO;
            [self _imageMessageCellSelected:model];
        }
            break;
            
        case EMMessageBodyTypeLocation:
            break;
            
        case EMMessageBodyTypeVoice:
            [self _audioMessageCellSelected:model];
            break;
            
        case EMMessageBodyTypeVideo:
            break;
            
        case EMMessageBodyTypeFile:
        {
            _scrollToBottomWhenAppear = NO;
            [self showHint:@"Custom implementation!"];
        }
            break;
            
        default:
            break;
    }
}

- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(EaseMessageCell*)messageCell
{
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error)
        {
            [weakself _refreshAfterSentMessage:message];
        }
        else
        {
            [weakself.tableView reloadData];
        }
    }];
    [self.tableView reloadData];
}

- (void)avatarViewSelcted:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
}

#pragma mark - EMChatToolbarDelegate
- (void)inputTextViewWillBeginEditing:(UITextView *)inputTextView
{
    if (_menuController == nil)
    {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0)
    {
        [self sendTextMessage:text];
    }
}

- (BOOL)didInputAtInLocation:(NSUInteger)location
{
    return NO;
}

- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location
{
    ServiceChatToolBar *toolbar = (ServiceChatToolBar*)self.chatToolbar;
    if ([toolbar.textView.text length] == location + 1)
    {
        //delete last character
        NSString *inputText = toolbar.textView.text;
        NSRange range = [inputText rangeOfString:@"@" options:NSBackwardsSearch];
        if (range.location != NSNotFound)
        {
            if (location - range.location > 1)
            {
                NSString *sub = [inputText substringWithRange:NSMakeRange(range.location + 1, location - range.location - 1)];
            }
        }
    }
    
    return NO;
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext
{
    if ([ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT])
    {
        EaseEmotion *emotion = [ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT];
        [self sendTextMessage:emotion.emotionTitle withExt:@{MESSAGE_ATTR_EXPRESSION_ID:emotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)}];
        
        return;
    }
    if (text && text.length > 0)
    {
        [self sendTextMessage:text withExt:ext];
    }
}

- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonTouchDown];
    }
    if ([self _canRecord])
    {
        EaseRecordView *tmpView = (EaseRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error){
            if (error)
            {
                NSLog(@"%@",NSEaseLocalizedString(@"message.startRecordFail", @"failure to start recording"));
            }
        }];
    }
}

- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    
    [self.recordView removeFromSuperview];
}

- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
    }
    [self.recordView removeFromSuperview];
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error)
        {
            [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
        }
        else
        {
            [weakSelf showHudInView:self.view hint:error.domain];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
            });
        }
    }];
}

- (void)didDragInsideAction:(UIView *)recordView
{
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonDragInside];
    }
}

- (void)didDragOutsideAction:(UIView *)recordView
{
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonDragOutside];
    }
}

-(void)takePictureActionSheet:(ServiceChatToolBar *)toolBar
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"相册", @"拍照",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

#pragma mark -- actionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Hide the keyboard
        [self.chatToolbar endEditing:YES];
        
        // Pop image picker
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        
        self.isViewDidAppear = NO;
        [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
    }
    else if (buttonIndex == 1)
    {
        [self.chatToolbar endEditing:YES];
        
#if TARGET_IPHONE_SIMULATOR
        [self showHint:@"模拟器不支持照相"];
#elif TARGET_OS_IPHONE
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        
        self.isViewDidAppear = NO;
        [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
#endif
        
    }
}

#pragma mark - Hyphenate
#pragma mark - EMChatManagerDelegate
- (void)didReceiveMessages:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages)
    {
        if ([self.conversation.conversationId isEqualToString:message.conversationId])
        {
            [self addMessageToDataSource:message progress:nil];
            
            [self _sendHasReadResponseForMessages:@[message]
                                           isRead:NO];
            
            if ([self _shouldMarkMessageAsRead])
            {
                [self.conversation markMessageAsReadWithId:message.messageId error:nil];
            }
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages)
    {
        if ([self.conversation.conversationId isEqualToString:message.conversationId])
        {
            [self showHint:NSEaseLocalizedString(@"receiveCmd", @"receive cmd message")];
            break;
        }
    }
}

- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages)
    {
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages)
    {
        if (![self.conversation.conversationId isEqualToString:message.conversationId])
        {
            continue;
        }
        __block id<IMessageModel> model = nil;
        __block BOOL isHave = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj conformsToProtocol:@protocol(IMessageModel)])
             {
                 model = (id<IMessageModel>)obj;
                 if ([model.messageId isEqualToString:message.messageId])
                 {
                     model.message.isReadAcked = YES;
                     isHave = YES;
                     *stop = YES;
                 }
             }
         }];
        
        if(!isHave)
        {
            return;
        }
        [self.tableView reloadData];
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError
{
    [self _updateMessageStatus:aMessage];
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error
{
    if (!error)
    {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage)
        {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        else if([fileBody type] == EMMessageBodyTypeVideo)
        {
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        else if([fileBody type] == EMMessageBodyTypeVoice)
        {
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }
    else
    {
        
    }
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil)
        {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    
    [audioSession setActive:YES error:nil];
}

#pragma mark - action
- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0)
    {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0)
    {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId error:nil];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0)
        {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count])
            {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]])
            {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - public

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0)
    {
        return formattedArray;
    }
    
    for (EMMessage *message in messages)
    {
        //Calculate time interval
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60)
        {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            timeStr = [messageDate formattedTime];
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //Construct message model
        id<IMessageModel> model = nil;
        model = [[EaseMessageModel alloc] initWithMessage:message];
        //#warning need
        if (model.isSender)
        {
            model.avatarURLPath = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_HeaderImage];
            model.nickname = _nickName;
        }
        else
        {
            model.avatarImage = [UIImage imageNamed:@"company_logo"];
            model.nickname = @"小疗";
        }
        model.failImageName = @"imageDownloadFail";
        if (model)
        {
            [formattedArray addObject:model];
        }
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress
{
    [self.messsagesSource addObject:message];
    __weak ServiceChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArray addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark - public
- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    NSString *messageId = nil;
    if ([self.messsagesSource count] > 0)
    {
        messageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    }
    else
    {
        messageId = nil;
    }
    [self _loadMessagesBefore:messageId count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark - send message
- (void)_refreshAfterSentMessage:(EMMessage*)aMessage
{
    if ([self.messsagesSource count] && [EMClient sharedClient].options.sortMessageByServerTime)
    {
        NSString *msgId = aMessage.messageId;
        EMMessage *last = self.messsagesSource.lastObject;
        if ([last isKindOfClass:[EMMessage class]])
        {
            __block NSUInteger index = NSNotFound;
            index = NSNotFound;
            [self.messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:msgId])
                {
                    index = idx;
                    *stop = YES;
                }
            }];
            if (index != NSNotFound)
            {
                [self.messsagesSource removeObjectAtIndex:index];
                [self.messsagesSource addObject:aMessage];
                
                //格式化消息
                self.messageTimeIntervalTag = -1;
                NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:formattedMessages];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                return;
            }
        }
    }
    [self.tableView reloadData];
}

- (void)_sendMessage:(EMMessage *)message
{
    message.chatType = EMChatTypeChat;
    [self addMessageToDataSource:message
                        progress:nil];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
        if (!aError)
        {
            [weakself _refreshAfterSentMessage:aMessage];
        }
        else
        {
            [weakself.tableView reloadData];
        }
    }];
}

- (void)sendTextMessage:(NSString *)text
{
    NSDictionary *ext = nil;
    [self sendTextMessage:text withExt:ext];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                     to:self.conversation.conversationId
                                            messageType:EMChatTypeChat
                                             messageExt:ext];
    
    [self _sendMessage:message];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [EaseSDKHelper sendLocationMessageWithLatitude:latitude
                                                              longitude:longitude
                                                                address:address
                                                                     to:self.conversation.conversationId
                                                            messageType:[self _messageTypeFromConversationType]
                                                             messageExt:nil];
    [self _sendMessage:message];
}

- (void)sendImageMessageWithData:(NSData *)imageData
{
    id progress = nil;
    progress = self;
    
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImageData:imageData
                                                                   to:self.conversation.conversationId
                                                          messageType:[self _messageTypeFromConversationType]
                                                           messageExt:nil];
    [self _sendMessage:message];
}

- (void)sendImageMessage:(UIImage *)image
{
    id progress = nil;
    progress = self;
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                               to:self.conversation.conversationId
                                                      messageType:[self _messageTypeFromConversationType]
                                                       messageExt:nil];
    [self _sendMessage:message];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id progress = nil;
    progress = self;
    EMMessage *message = [EaseSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                             duration:duration
                                                                   to:self.conversation.conversationId
                                                          messageType:[self _messageTypeFromConversationType]
                                                           messageExt:nil];
    [self _sendMessage:message];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id progress = nil;
    progress = self;
    EMMessage *message = [EaseSDKHelper sendVideoMessageWithURL:url
                                                             to:self.conversation.conversationId
                                                    messageType:[self _messageTypeFromConversationType]
                                                     messageExt:nil];
    [self _sendMessage:message];
}

#pragma mark - notifycation
- (void)didBecomeActive
{
    self.dataArray = [[self formatMessages:self.messsagesSource] mutableCopy];
    [self.tableView reloadData];
    
    if (self.isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead:nil];
    }
}

#pragma mark - private
- (void)_reloadTableViewDataWithMessage:(EMMessage *)message
{
    if ([self.conversation.conversationId isEqualToString:message.conversationId])
    {
        for (int i = 0; i < self.dataArray.count; i ++)
        {
            id object = [self.dataArray objectAtIndex:i];
            if ([object isKindOfClass:[EaseMessageModel class]])
            {
                id<IMessageModel> model = object;
                if ([message.messageId isEqualToString:model.messageId])
                {
                    id<IMessageModel> model = nil;
                    model = [[EaseMessageModel alloc] initWithMessage:message];
                    model.failImageName = @"imageDownloadFail";
                    //#warning need
                    if (model.isSender)
                    {
                        model.avatarURLPath = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_HeaderImage];
                        model.nickname = _nickName;
                    }
                    else
                    {
                        model.avatarImage = [UIImage imageNamed:@""];
                        model.nickname = @"小疗";
                    }
                    [self.tableView beginUpdates];
                    [self.dataArray replaceObjectAtIndex:i withObject:model];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
    }
}

- (void)_updateMessageStatus:(EMMessage *)aMessage
{
    BOOL isChatting = [aMessage.conversationId isEqualToString:self.conversation.conversationId];
    if (aMessage && isChatting)
    {
        id<IMessageModel> model = nil;
        model = [[EaseMessageModel alloc] initWithMessage:aMessage];
        //#warning need
        if (model.isSender)
        {
            model.avatarURLPath = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_HeaderImage];
            model.nickname = _nickName;
        }
        else
        {
            model.avatarImage = [UIImage imageNamed:@""];
            model.nickname = @"小疗";
        }
        model.failImageName = @"imageDownloadFail";
        if (model)
        {
            __block NSUInteger index = NSNotFound;
            [self.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
                if ([model conformsToProtocol:@protocol(IMessageModel)])
                {
                    if ([aMessage.messageId isEqualToString:model.message.messageId])
                    {
                        index = idx;
                        *stop = YES;
                    }
                }
            }];
            if (index != NSNotFound)
            {
                [self.dataArray replaceObjectAtIndex:index withObject:model];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }
}

#pragma mark - public refresh
- (void)autoTriggerHeaderRefresh
{
    if (self.showRefreshHeader)
    {
        [self tableViewDidTriggerHeaderRefresh];
    }
}
- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
    __weak ServiceChatViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload)
        {
            [weakSelf.tableView reloadData];
        }
        if (isHeader)
        {
            [weakSelf.tableView.mj_header endRefreshing];
        }
        else
        {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    });
}

#pragma mark - EaseMessageViewControllerDelegate
- (BOOL)messageViewController:(ServiceChatViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(ServiceChatViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]])
    {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
    }
    
    return YES;
}

#pragma mark - EaseMessageViewControllerDataSource
- (id<IMessageModel>)messageViewController:(ServiceChatViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    //#warning need
    if (model.isSender)
    {
        model.avatarURLPath = [NSString stringWithFormat:@"%@%@",HTTPPORTPREFIX,_HeaderImage];
        model.nickname = _nickName;
    }
    else
    {
        model.avatarImage = [UIImage imageNamed:@""];
        model.nickname = @"小疗";
    }
    model.failImageName = @"imageDownloadFail";
    
    return model;
}

- (BOOL)isEmotionMessageFormessageViewController:(ServiceChatViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION])
    {
        return YES;
    }
    
    return flag;
}

- (NSDictionary*)emotionExtFormessageViewController:(ServiceChatViewController *)viewController
                                        easeEmotion:(EaseEmotion*)easeEmotion
{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
