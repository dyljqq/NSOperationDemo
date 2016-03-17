//
//  JQQImageOperation.m
//  JQQWebImage
//
//  Created by 季勤强 on 16/3/17.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import "JQQImageOperation.h"

static const CGFloat TIME_OUT = 15.0;

@interface JQQImageOperation () <NSURLSessionDownloadDelegate>

@property (nonatomic, copy)NSString* urlString;
@property (nonatomic, strong)NSURLSession* session;
@property (nonatomic, strong)NSURLSessionDownloadTask* downloadTask;
@property (nonatomic, strong)NSError* error;
@property (nonatomic)BOOL isFinished;
@property (nonatomic)BOOL isExecuting;

@end

@implementation JQQImageOperation

- (instancetype)initWithUrlString:(NSString *)urlString{
    self = [super init];
    if(self){
        _urlString = urlString;
        [self initParam];
    }
    return self;
}

- (void)initParam{
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    _isExecuting = YES;
    _isFinished = NO;
}

- (void)done{
    self.isFinished = YES;
    self.isExecuting = NO;
    self.session = nil;
    self.downloadTask = nil;
}

#pragma override

- (void)start{
    NSURL* url = [NSURL URLWithString:_urlString];
    if(url == nil){
        NSLog(@"URL CANN'T BE NIL!!!");
        [self done];
        return ;
    }
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

- (void)cancel{
    [super cancel];
    [self.downloadTask cancel];
    [self done];
}

#pragma Delegate

//END DOWNLOAD
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    _data = [NSData dataWithContentsOfURL:location];
    if (_data == nil) {
        NSLog(@"DOWNLOAD DATA IS NIL");
        self.dataBlock(nil, nil);
    }else{
        UIImage* image = [UIImage imageWithData:_data];
        self.dataBlock(image, self.error);
    }
    [self done];
}

//GET THE PROGRESS OF DATA COLLECTION
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"progress %.2f", progress);
    if(self.progressBlock)
        self.progressBlock(progress);
}

#pragma Private Method

- (void)setIsExecuting:(BOOL)isExecuting{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setIsFinished:(BOOL)isFinished{
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

@end
