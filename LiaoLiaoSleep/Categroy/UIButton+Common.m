//
//  UIButton+Common.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/21.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "UIButton+Common.h"
#import <objc/runtime.h>

static const char *ObjectKey = "DownloadKey";
static const char *ObjectBtnFlagKey = "ObjectBtnFlag";

@implementation UIButton (Common)

- (BOOL)downLoad
{
    return [objc_getAssociatedObject(self, ObjectKey) boolValue];
}

- (void)setDownLoad:(BOOL)downLoad
{
    objc_setAssociatedObject(self, ObjectKey, [NSNumber numberWithBool:downLoad], OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)btnFlag
{
    return objc_getAssociatedObject(self, ObjectBtnFlagKey);
}

-(void)setBtnFlag:(NSString *)btnFlag
{
    objc_setAssociatedObject(self, ObjectBtnFlagKey, btnFlag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
