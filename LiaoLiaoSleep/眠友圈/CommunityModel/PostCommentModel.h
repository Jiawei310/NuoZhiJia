//
//  PostCommentModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/12.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostCommentModel : NSObject

@property (copy, nonatomic) NSString *PostID;
@property (copy, nonatomic) NSString *PatientID;
@property (copy, nonatomic) NSString *HeaderImageUrl;
@property (copy, nonatomic) NSString *Name;
@property (copy, nonatomic) NSString *CommentTime;
@property (copy, nonatomic) NSString *CommentContent;
@property (copy, nonatomic) NSString *FavorCount;
@property (nonatomic)           BOOL IsHot;

-(instancetype)initWithDictionary:(NSDictionary *)dict;

@end
