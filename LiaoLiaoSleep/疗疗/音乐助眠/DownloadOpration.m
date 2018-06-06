//
//  DownloadOpration.m
//  LiaoLiaoSleep
//
//  Created by Justin on 2017/4/27.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "DownloadOpration.h"
#import <AFNetworking.h>
#import "Define.h"
#import "UIButton+Common.h"

@implementation DownloadOpration

- (instancetype)initWithUrl:(NSString *)urlStr typeNum:(NSUInteger)num
{
    if (self == [super init])
    {
        [self downloadTask:urlStr typeNum:num];
    }
    
    return self;
}

- (void)downloadTask:(NSString *)urlStr typeNum:(NSInteger)num
{
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2.确定请求的URL地址
    NSURL *url = [NSURL URLWithString:urlStr];
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        float myProgress = 1.0*downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
        [self.delegate musicDownloadProgress:myProgress typeNum:num];
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        [self creatFolder];
        NSURL *folderPath = [documentsDirectoryURL URLByAppendingPathComponent:@"Music/"];
        NSLog(@"%@",folderPath);
        //返回下载的目录url
        return [folderPath URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //下载完成调用的方法
        NSLog(@"下载完成：");
        NSLog(@"%@--%@",response,filePath);
        
    }];
    
    //开始启动任务
    [task resume];
}

- (void)creatFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *musicPath = [NSString stringWithFormat:@"%@/Documents/Music/",NSHomeDirectory()];
    //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
    if(![fileManager fileExistsAtPath:musicPath])
    {
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *directryPath = [path stringByAppendingPathComponent:@"Music"];
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
