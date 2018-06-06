//
//  CustomerChatViewController.h
//  Chat
//
//  Created by 甘伟 on 16/12/26.
//  Copyright © 2016年 Gwyneth. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHandle.h"
#import "FunctionHelper.h"
#import "EMClient.h"

#import "ConsultQuestionModel.h"
#import "DoctorInfoModel.h"

#import "DoctorChatToolBar.h"

@interface CustomerChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, EMChatManagerDelegate, DoctorChatToolbarDelegate>

//视图部分
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) DoctorChatToolBar *chatToolbar;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIMenuController *menuController;
@property (strong, nonatomic) UIView *timeView;
@property (strong, nonatomic) UILabel *timeLable;
@property (strong, nonatomic) UILabel *timeLeave;
@property (strong, nonatomic) NSTimer *timer; //计时器


//环信
@property (strong, nonatomic) EMConversation *conversation;
@property (copy, nonatomic) DataHandle *handle;  //数据处理对象
@property (copy, nonatomic) ConsultQuestionModel *model;  //问题模型

//属性部分
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *messsagesSource;
@property (strong, nonatomic) NSMutableArray *historyMesssages;
@property (strong, nonatomic) NSIndexPath *menuIndexPath;
@property (nonatomic) NSTimeInterval messageTimeIntervalTag; //事件间隔
@property (nonatomic) NSInteger messageCountOfPage; //default 5
@property (nonatomic) BOOL deleteConversationIfNull; //default YES;
@property (nonatomic) BOOL scrollToBottomWhenAppear; //default YES;
@property (nonatomic) BOOL isViewDidAppear;


@property (nonatomic) BOOL isAsking; //用来标记返回界面
@property (nonatomic) BOOL isWaiting; //用来标记是否处于等待接诊
@property (nonatomic) BOOL isClosed; //用来标记是否关闭
@property (copy, nonatomic) NSString *question;//用户填写问题是的问题
@property (copy, nonatomic) NSString *time;//用户填写问题时的时间
@property (copy, nonatomic) NSString *questionID;//用户填写问题时的问题ID
@property (copy, nonatomic) NSString *doctorID;//用户填写问题时的问题ID
@property (copy, nonatomic) NSString *endTime;//问题截止时间
@property (strong, nonatomic) PatientInfo *patientInfo;//患者信息
@property (copy, nonatomic) NSString *askCount;
@property (copy, nonatomic) NSString *totalCount;
@property (strong, nonatomic) UIButton *continueBtn;


- (instancetype)initWithConversationChatter:(NSString *)conversationChatter;
- (void)tableViewDidTriggerHeaderRefresh;
- (void)sendTextMessage:(NSString *)text;
- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext;
- (void)sendImageMessage:(UIImage *)image;
- (void)addMessageToDataSource:(EMMessage *)message
                      progress:(id)progress;
- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType;
- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read;

@end
