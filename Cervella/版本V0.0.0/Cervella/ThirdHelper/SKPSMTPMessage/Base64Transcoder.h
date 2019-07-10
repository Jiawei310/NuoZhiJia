//
//  Base64Transcoder.h
//  SMTPSender
//
//  Created by wu xiaoming on 13-1-23.
//  Copyright (c) 2013年 wu xiaoming. All rights reserved.
//

#include <UIKit/UIKit.h>

extern size_t EstimateBas64EncodedDataSize(size_t inDataSize);
extern size_t EstimateBas64DecodedDataSize(size_t inDataSize);

extern bool Base64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize, BOOL wrapped);
extern bool Base64DecodeData(const void *inInputData, size_t inInputDataSize, void *ioOutputData, size_t *ioOutputDataSize);