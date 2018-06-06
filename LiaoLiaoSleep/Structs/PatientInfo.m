//
//  PatientInfo.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "PatientInfo.h"

@implementation PatientInfo

static PatientInfo *_instance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
    
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [PatientInfo shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [PatientInfo shareInstance] ;
}

@end
