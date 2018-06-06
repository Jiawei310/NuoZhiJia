//
//  SquareModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/8.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface SquareModel : NSObject

@property (copy, nonatomic) NSString *PostID;
@property (copy, nonatomic) NSString *PatientID;
@property (copy, nonatomic) NSString *HeaderImageUrl;
@property (copy, nonatomic) NSString *Name;
@property (copy, nonatomic) NSString *Time;
@property (copy, nonatomic) NSString *Type;
@property (copy, nonatomic) NSString *Title;
@property (copy, nonatomic) NSString *ImageUrl;
@property (copy, nonatomic) NSString *Content;
@property (copy, nonatomic) NSString *BrowserCount;
@property (copy, nonatomic) NSString *FavorCount;
@property (copy, nonatomic) NSString *CommentCount;
@property (copy, nonatomic) NSString *ImageCount;
@property (copy, nonatomic) NSString *Image1;
@property (copy, nonatomic) NSString *Image2;
@property (copy, nonatomic) NSString *Image3;
@property (copy, nonatomic) NSString *Image4;
@property (copy, nonatomic) NSString *Image5;
@property (copy, nonatomic) NSString *Image6;
@property (nonatomic)           BOOL IsTop;
@property (nonatomic)           BOOL IsHot;
@property (nonatomic)           BOOL IsCollect;
@property (nonatomic)           BOOL IsFavor;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
