//
//  FunctionHelper.m
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/5.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import "FunctionHelper.h"
#import "NSDate+Category.h"
#import "DataHandle.h"
#import <sys/utsname.h>
#import <zlib.h>

@implementation FunctionHelper

#pragma mark -- 计算年龄
- (NSString *)getAgeWithBirth:(NSString *)birth
{
    //计算年龄
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //生日
    NSDate *birthDay = [dateFormatter dateFromString:birth];
    //当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
    NSTimeInterval time=[currentDate timeIntervalSinceDate:birthDay];
    int age = ((int)time)/(3600*24*365);
    return [NSString stringWithFormat:@"%i",age];
}

- (NSInteger)checkDate:(NSString *)endTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
    NSDate * endDate = [dateFormatter dateFromString:endTime];
    //截止日期大于当天日期
    if ([endDate compare:currentDate] != NSOrderedAscending)
    {
        return 1;
    }
    return 0;
}

- (NSString *)getTimeIntervalWithEndTime:(NSString *)endTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [NSDate date];
    NSDate *date2 = [formatter dateFromString:endTime];
    //    先定义一个遵循某个历法的日历对象
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    根据两个时间点，定义NSDateComponents对象，从而获取这两个时间点的时差
    NSDateComponents *dateComponents = [greCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date1 toDate:date2 options:0];
    return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)dateComponents.hour, (int)dateComponents.minute, (int)dateComponents.second];
}

+ (NSString *)getTimeIntervalWithStartTime:(NSString *)startTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [formatter dateFromString:startTime];
    NSDate *date2 = [NSDate date];
    //先定义一个遵循某个历法的日历对象
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //根据两个时间点，定义NSDateComponents对象，从而获取这两个时间点的时差
    NSDateComponents *dateComponents = [greCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date1 toDate:date2 options:0];
    NSLog(@"%@",[NSString stringWithFormat:@"%02d:%02d:%02d", (int)dateComponents.hour, (int)dateComponents.minute, (int)dateComponents.second]);
    if ((int)dateComponents.hour > 0 && (int)dateComponents.hour < 24)
    {
        return [NSString stringWithFormat:@"%d小时前",(int)dateComponents.hour];
    }
    else if((int)dateComponents.hour >= 24)
    {
        return startTime;
    }
    else if((int)dateComponents.hour == 0 && (int)dateComponents.minute > 0)
    {
        return [NSString stringWithFormat:@"%d分钟前",(int)dateComponents.minute];
    }
    else if((int)dateComponents.hour == 0 && (int)dateComponents.minute == 0 && (int)dateComponents.second > 0)
    {
        return [NSString stringWithFormat:@"%d秒前",(int)dateComponents.second];
    }
    
    return startTime;
}

+ (BOOL)checkDateWithEndTime:(NSString *)endTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [NSDate date];
    NSDate *date2 = [formatter dateFromString:endTime];
    //    先定义一个遵循某个历法的日历对象
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    根据两个时间点，定义NSDateComponents对象，从而获取这两个时间点的时差
    NSDateComponents *dateComponents = [greCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date1 toDate:date2 options:0];
    if ((int)dateComponents.hour >0 || (int)dateComponents.minute > 0 || (int)dateComponents.second > 0)
    {
        return YES;
    }
    return NO;
}

#pragma mark -- 是否为空字符
+ (BOOL)isBlankString:(NSString *)string
{
    if (string == nil || string == NULL)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark -- 上传剩余问题数
+ (BOOL)uploadLeaveNumber:(NSString *)count withQuestionID:(NSString *)patientID
{
    DataHandle * handle = [[DataHandle alloc]init];
    NSData * data =  [handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadLeaveNumber) andDictionary:@{@"LeaveNumber":count,@"PatientID":patientID}];
    if ([[handle objectFromeResponseString:data andType:(DataModelBackTypeUploadLeaveNumber)] isEqualToString:@"OK"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -- 上传追问次数
+ (BOOL)uploadAskCount:(NSString *)count withQuestionID:(NSString *)questionID
{
    DataHandle * handle = [[DataHandle alloc]init];
    NSData * data =  [handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadQuestionAskCount) andDictionary:@{@"count":count,@"questionID":questionID}];
    if ([[handle objectFromeResponseString:data andType:(DataModelBackTypeUploadQuestionAskCount)] isEqualToString:@"OK"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -- 上传聊天记录
+ (BOOL)uploadHistoryChatMessageWithMessage:(EMMessage *)message withQuestionID:(NSString *)questionID
{
    DataHandle * handle = [[DataHandle alloc]init];
    NSDate * messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:messageDate];
    BOOL isSender = message.direction == EMMessageDirectionSend ? YES : NO;
    EMMessageBody *msgBody = message.body;
    NSDictionary * dic = [NSDictionary dictionary];
    switch (msgBody.type)
    {
        case EMMessageBodyTypeText:
        {
            // 收到的文字消息
            EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
            NSString *text = textBody.text;
            if ([text isEqualToString:@"量表已更新"])
            {
                
            }
            else
            {
                dic = @{@"QuestionID":questionID,@"Message":text,@"ImageSize":@"0,0",@"ImageURLPath":@"",@"ThumbnailImageSize":@"0,0",@"ThumbnailImageURLPath":@"",@"MessageType":@"0",@"IsSender":[NSString stringWithFormat:@"%i",isSender],@"ImageName":@"",@"ChatTime":dateTime};
            }
        }
            break;
        case EMMessageBodyTypeImage:
        {
            // 得到一个图片消息
            EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
            NSData * imageData;
            if (isSender)
            {
                UIImage * image = [UIImage imageWithContentsOfFile:body.localPath];
                imageData = UIImageJPEGRepresentation(image, 1);
            }
            else
            {
                imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:body.remotePath]];
            }
            NSString * imageURL = [imageData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
            UIImage * Image = [UIImage imageWithData:imageData];
            CGSize size = Image.size;
            UIImage * thumbnailImage = size.width * size.height > 200 * 200 ? [self scaleImage:Image toScale:sqrt((200 * 200) / (size.width * size.height))] : Image;
            NSData *thumbnailImageData;
            if (UIImagePNGRepresentation(thumbnailImage) == nil)
            {
                thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1);
            }
            else
            {
                thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
            }
            NSString * thumbnailImageURL = [thumbnailImageData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
            if (![thumbnailImageURL isEqualToString:@""])
            {
                
            }
            NSString * imageName = [self getImageName];
            dic = @{@"QuestionID":questionID,@"Message":@"",@"ImageSize":[NSString stringWithFormat:@"%f_%f",Image.size.width,Image.size.height],@"ImageURLPath":imageURL,@"ThumbnailImageSize":[NSString stringWithFormat:@"%f_%f",thumbnailImage.size.width,thumbnailImage.size.height],@"ThumbnailImageURLPath":thumbnailImageURL,@"MessageType":@"1",@"IsSender":[NSString stringWithFormat:@"%i",isSender],@"ImageName":imageName,@"ChatTime":dateTime};
        }
            break;
        default:
            break;
    }
    NSData * data = [handle uploadToNetWorkWithJsonType:(DataModelBackTypeUploadChatMessage) andDictionary:dic];
    if([[handle objectFromeResponseString:data andType:(DataModelBackTypeUploadChatMessage)]isEqualToString:@"OK"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -- 图片名称
+ (NSString *)getImageName
{
    static int kNumber = 5;
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = arc4random() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    
    return resultStr;
}

#pragma mark -- 压缩图片
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark -- 判断是否联网
+ (BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch([reachability currentReachabilityStatus])
    {
        case NotReachable: isExistenceNetwork = FALSE;
            break;
        case ReachableViaWWAN: isExistenceNetwork = TRUE;
            break;
        case ReachableViaWiFi: isExistenceNetwork = TRUE;
            break;
    }
    
    return isExistenceNetwork;
}

// 设置本地通知
+ (void)registerLocalNotification:(NSString *)date alertBody:(NSString *)alertBody userDict:(NSDictionary *)userDict
{
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *fireDate = [formatter dateFromString:date];
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitDay;
    // 通知内容
    notification.alertBody = alertBody;
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    notification.userInfo = userDict;
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSCalendarUnitDay;
    }
    else
    {
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSCalendarUnitDay;
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

// 取消某个本地推送通知
+ (void)cancelLocalNotificationWithKey:(NSString *)key
{
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications)
    {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo)
        {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil)
            {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

+(BOOL)updateAccumulatePointWithPatientID:(NSString *)patient andType:(NSInteger)type
{
    //是否更新积分
    BOOL isUpdate = NO;
    //获取当前时间，日期
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY.MM.dd"];
    NSString * currentdate = [dateFormatter stringFromDate:currentDate];
    //存储patientID对应的积分上传记录
    NSDictionary * dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_AccumulatePoint",patient]];
    //分值
    NSString * point = @"0";
    if (type == 1)//注册
    {
        point = @"";//*******************麻烦补充注册的分值********************
        isUpdate = YES;
    }
    else if (type == 2)//登录
    {
        point = @"";//*******************麻烦补充登录的分值********************
        //获取日期
        NSString * date = [dic objectForKey:@"login"];
        if ([date isEqualToString:currentdate])//若日期与当前日期一致
        {
            isUpdate = NO;//不更新积分
        }
        else
        {
            isUpdate = YES;//更新积分
            //并更新日期
            [[NSUserDefaults standardUserDefaults] setObject:@{@"login":currentdate} forKey:[NSString stringWithFormat:@"%@_AccumulatePoint",patient]];
        }
    }
    else if (type == 3)//评论医生
    {
        point = @"";//*******************麻烦补充评价医生的分值********************
        NSString * date = [dic objectForKey:@"commendDoctor"];
        if ([date isEqualToString:currentdate])
        {
            isUpdate = NO;
        }
        else
        {
            isUpdate = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@{@"commendDoctor":currentdate} forKey:[NSString stringWithFormat:@"%@_AccumulatePoint",patient]];
        }
    }
    else if (type == 4)//评论帖子
    {
        point = @"";//*******************麻烦补充评论帖子的分值********************
        NSString * date = [dic objectForKey:@"CommendPost"];
        if ([date isEqualToString:currentdate])
        {
            isUpdate = NO;
        }
        else
        {
            isUpdate = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@{@"CommendPost":currentdate} forKey:[NSString stringWithFormat:@"%@_AccumulatePoint",patient]];
        }
    }
    else if (type == 5)//发布帖子
    {
        point = @"";//*******************麻烦补充发布帖子的分值********************
        NSString * date = [dic objectForKey:@"PublicPost"];
        if ([date isEqualToString:currentdate])
        {
            isUpdate = NO;
        }
        else
        {
            isUpdate = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@{@"PublicPost":currentdate} forKey:[NSString stringWithFormat:@"%@_AccumulatePoint",patient]];
        }
    }
    else if (type == 6)//帖子被赞
    {
        point = @"";//*******************麻烦补充帖子被赞的分值********************
        isUpdate = YES;
    }
    else if (type == 7) //每日治疗
    {
        point = @"";//*******************麻烦补充每日治疗的分值********************
        NSString * date = [dic objectForKey:@"DailyCure"];
        if ([date isEqualToString:currentdate])
        {
            isUpdate = NO;
        }
        else
        {
            isUpdate = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@{@"DailyCure":currentdate} forKey:[NSString stringWithFormat:@"%@_AccumulatePoint",patient]];
        }
    }
    if (isUpdate)
    {
        DataHandle * handle = [[DataHandle alloc]init];
        NSMutableURLRequest * req = [handle RequestForGetDataFromNetWorkWithJsonType:(DataModelBackTypeUpdateAccumulatePoint) andDictionary:@{@"patientID":patient,@"point":point}];
        req.timeoutInterval = 3.0;
        NSData * data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
        if (data)
        {
            NSString * result = [handle objectFromeResponseString:data andType:(DataModelBackTypeUpdateAccumulatePoint)];
            if ([result isEqualToString:@"OK"])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

+ (void)registerLocalNotificationWithalertBody:(NSString *)alertBody andalertTitle:(NSString *)alertTitle
{
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
    }
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    // 2.设置本地通知的内容
    // 2.1.设置通知发出的时间
    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    // 2.2.设置通知的内容
    localNote.alertBody = alertBody;
    // 2.3.设置滑块的文字（锁屏状态下：滑动来“解锁”）
    localNote.alertAction = @"解锁";
    // 2.4.决定alertAction是否生效
    localNote.hasAction = NO;
    // 2.5.设置点击通知的启动图片
    localNote.alertLaunchImage = @"123Abc";
    // 2.6.设置alertTitle
    localNote.alertTitle = alertTitle;
    // 2.7.设置有通知时的音效
    localNote.soundName = UILocalNotificationDefaultSoundName;
    // 2.8.设置应用程序图标右上角的数字
    //    localNote.applicationIconBadgeNumber = 999;
    // 2.9.设置额外信息
    localNote.userInfo = @{@"key":@"123"};
    // 3.调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
}

//时间戳
+ (NSString *)getNowTimeInterval {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString *str = [NSString stringWithFormat:@"%ld", (long)interval];
    return str;
}

//手机型号
+ (NSString*)iPhoneMode
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone9,1"] || [deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"] || [deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"] || [deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"] || [deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"] || [deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    
    return deviceString;
}

+ (NSString *)iPhoneVersion {
    return [[UIDevice currentDevice] systemVersion];
}

@end
