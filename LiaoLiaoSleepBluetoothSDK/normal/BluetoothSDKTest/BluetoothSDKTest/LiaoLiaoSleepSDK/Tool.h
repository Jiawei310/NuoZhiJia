//
//  Tool.h
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject

+ (NSData*)dataWithHexstring:(NSString *)hexstring;
+ (NSString*)hexadecimalString:(NSData *)data;

+ (NSData *)Deciphering:(Byte *)chData;
@end
