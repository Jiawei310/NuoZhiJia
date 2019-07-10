//
//  AESCipher.h
//  AESCipher
//
//  Created by Welkin Xie on 8/13/16.
//  Copyright © 2016 WelkinXie. All rights reserved.
//
//  https://github.com/WelkinXie/AESCipher-iOS
//

#define aes_key_value @"1234567890000000"

#import <Foundation/Foundation.h>

NSString * aesEncryptString(NSString *content, NSString *key);
NSString * aesDecryptString(NSString *content, NSString *key);

NSData * aesEncryptData(NSData *data, NSData *key);
NSData * aesDecryptData(NSData *data, NSData *key);


/*******test
 NSString *plainText = @"IAmThePlainText";
 NSString *key = @"16BytesLengthKey";
 
 NSString *cipherText = aesEncryptString(plainText, key);
 
 NSLog(@"%@", cipherText);
 
 NSString *decryptedText = aesDecryptString(cipherText, key);
 
 NSLog(@"%@", decryptedText);
 */
