//
//  Tool.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject
//用于设备解析
+ (NSData *)Deciphering:(Byte *)chData;

//将传入的NSData类型转换成NSString并返回
+ (NSString*)hexadecimalString:(NSData *)data;

//将传入的NSString类型转换成NSData并返回
+ (NSData*)dataWithHexstring:(NSString *)hexstring;
@end
