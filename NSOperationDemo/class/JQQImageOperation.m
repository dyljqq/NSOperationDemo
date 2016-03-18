//
//  JQQImageOperation.m
//  JQQWebImage
//
//  Created by 季勤强 on 16/3/17.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import "JQQImageOperation.h"

static const CGFloat TIME_OUT = 15.0;
static const CGFloat COMPLETE_DOWNLOAD_PROGRESS = 1.0;

@interface JQQImageOperation () <NSURLSessionDownloadDelegate>

@property (nonatomic, copy)NSString* urlString;
@property (nonatomic, strong)NSURLSession* session;
@property (nonatomic, strong)NSURLSessionDownloadTask* downloadTask;
@property (nonatomic, strong)NSError* error;
@property (strong, atomic) NSThread *thread;
@property (nonatomic)size_t expectLength;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation JQQImageOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

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
    _executing = YES;
    _finished = NO;
}

- (void)done{
    self.isFinished = YES;
    self.isExecuting = NO;
    self.session = nil;
    self.downloadTask = nil;
    self.thread = nil;
}

#pragma override

- (void)start{
    if (self.finished) {
        [self done];
        return ;
    }
    NSURL* url = [NSURL URLWithString:_urlString];
    if(url == nil){
        NSLog(@"URL CANN'T BE NIL!!!");
        [self done];
        return ;
    }
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT];
    self.thread = [NSThread currentThread];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    if(self.downloadTask){
        CFRunLoopRun();
    }
}

- (void)cancel{
    [super cancel];
    NSLog(@"cancel:%@", _urlString);
    [self.downloadTask cancel];
    [self done];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma Delegate

//END DOWNLOAD
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"download url:%@", _urlString);
    _data = [NSData dataWithContentsOfURL:location];
    if (_data == nil) {
        NSLog(@"DOWNLOAD DATA IS NIL");
        if(self.progressBlock)
            self.progressBlock(1.0 * _data.length / self.expectLength);
        self.failedBlock(_urlString);
        self.dataBlock(nil, nil);
    }else{
        UIImage* image = [UIImage imageWithData:_data];
        if(self.progressBlock)
            self.progressBlock(COMPLETE_DOWNLOAD_PROGRESS);
        self.dataBlock(image, self.error);
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
    [self done];
}

//GET THE PROGRESS OF DATA COLLECTION
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    self.expectLength = totalBytesExpectedToWrite;
    NSLog(@"progress %.2f", progress);
    if(self.progressBlock)
        self.progressBlock(progress);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.thread = nil;
    self.downloadTask = nil;
    self.failedBlock(_urlString);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"resume");
}

#pragma Private Method

- (void)setIsExecuting:(BOOL)isExecuting{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setIsFinished:(BOOL)isFinished{
    [self willChangeValueForKey:@"isFinished"];
    _finished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

@end
