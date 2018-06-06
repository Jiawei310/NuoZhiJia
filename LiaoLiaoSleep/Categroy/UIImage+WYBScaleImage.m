//
//  UIImage+WYBScaleImage.m
//  LiaoLiaoSleep
//
//  Created by 诺之家 on 17/3/6.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "UIImage+WYBScaleImage.h"

@implementation UIImage (WYBScaleImage)

+(UIImage *)scaleImage:(UIImage *)image toKb:(NSInteger)kb
{
    if (!image)
    {
        return image;
    }
    if (kb<1)
    {
        return image;
    }
    
    kb*=1024;
    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > kb && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    NSLog(@"当前大小:%fkb",(float)[imageData length]/1024.0f);
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

@end
