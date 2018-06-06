//
//  SleepCircleModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepCircleModel : NSObject

@property (copy, nonatomic) NSString *PostID;
@property (copy, nonatomic) NSString *Title;
@property (copy, nonatomic) NSString *Time;
@property (copy, nonatomic) NSString *ImageUrl;
@property (copy, nonatomic) NSString *Content;
@property (copy, nonatomic) NSString *FavorCount;
@property (copy, nonatomic) NSString *CommentCount;

//add by WYB 2017/2/8 22:06
@property (copy, nonatomic) NSString *ImageName;
@property (copy, nonatomic) NSString *PostUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
