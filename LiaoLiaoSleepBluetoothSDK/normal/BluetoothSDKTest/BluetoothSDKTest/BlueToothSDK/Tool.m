//
//  Tool.m
//  BluetoothSDKTest
//
//  Created by 诺之嘉 on 2017/12/22.
//  Copyright © 2017年 YBPersonal. All rights reserved.
//

#import "Tool.h"

@implementation Tool
+ (NSData *)Deciphering:(Byte *)chData
{
    Byte chOUTFinal[8];                 //用于存储设备序列号的16进制数的char类型数组

    
    Byte chKey[] = { 0x01, 0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05, 0x01,
        0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05 };
    Byte chOUT[16];
    Byte chC[16];
    
    for (int i = 0; i < 8; i++) {
        chC[2 * i] = (Byte) (chData[i] >> 4);
        chC[2 * i + 1] = (Byte) (chData[i] & 0x0f);
    }
    
    for (int k = 0; k < 16; k++) {
        for (int j = 0; j < 16; j++) {
            if ((((j * chKey[k]) - chC[k]) % 16) == 0) {
                chOUT[k] = (Byte) j;
                j = 15;
            }
        }
    }
    
    for (int g = 0; g < 8; g++)
    {
        chOUTFinal[g] = (Byte) (((chOUT[2 * g] << 4) & 0xf0) + (chOUT[2 * g + 1] & 0x0f));
    }
    return [NSData dataWithBytes:chOUTFinal length:8];
}

//将传入的NSData类型转换成NSString并返回
+ (NSString*)hexadecimalString:(NSData *)data
{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

//将传入的NSString类型转换成NSData并返回
+ (NSData*)dataWithHexstring:(NSString *)hexstring
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for(idx = 0; idx + 2 <= hexstring.length; idx += 2){
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end
