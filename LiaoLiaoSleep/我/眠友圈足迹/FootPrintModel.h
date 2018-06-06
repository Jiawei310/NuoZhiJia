//
//  FootPrintModel.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/12/15.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SquareModel.h"

@interface FootPrintModel : NSObject

@property (nonatomic, copy)      NSString *PostID;
@property (nonatomic, copy)      NSString *PostTitle;
@property (nonatomic, copy)      NSString *PublicTime;
@property (nonatomic, copy)      NSString *HeaderImage;
@property (nonatomic, copy)      NSString *PatientName;
@property (nonatomic, copy)      NSString *PatientID;
@property (nonatomic, strong) SquareModel *postModel;
@property (nonatomic, assign)        BOOL isReplay;
@property (nonatomic, assign)        BOOL isPublic;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
