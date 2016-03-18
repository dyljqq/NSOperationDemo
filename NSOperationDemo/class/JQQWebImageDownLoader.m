//
//  JQQWebImageDownLoader.m
//  NSOperationDemo
//
//  Created by 季勤强 on 16/3/18.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import "JQQWebImageDownLoader.h"
#import "JQQImageOperation.h"

@interface JQQWebImageDownLoader ()

@property (nonatomic, strong)NSOperationQueue* downloadQueue;
@property (nonatomic, copy)NSMutableSet* failedUrls;

@end

@implementation JQQWebImageDownLoader

+ (instancetype)sharedManager{
    static dispatch_once_t once;
    static JQQWebImageDownLoader* instance;
    dispatch_once(&once, ^{
        instance = [JQQWebImageDownLoader new];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        [self initParams];
    }
    return self;
}

- (void)initParams{
    _maxConcurrence = 6;
    _downloadQueue = [NSOperationQueue new];
    _downloadQueue.maxConcurrentOperationCount = _maxConcurrence;
    _failedUrls = [NSMutableSet new];
}

- (void)downloadImageWithUrlString:(NSString *)urlString progress:(JQQImageOperationProgressBlock)progressBlock complete:(JQQImageOperationDataBlock)completeBlock{
    BOOL isFailedUrl = NO;
    @synchronized(self.failedUrls) {
        isFailedUrl = [self.failedUrls containsObject:urlString];
    }
    if(urlString.length == 0 || isFailedUrl){
        //防止阻塞主线程
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completeBlock(nil, error);
        });
        return ;
    }
    __weak typeof(self) weakSelf = self;
    [[JQQImageCache sharedImageCache] queryImageFromCache:urlString done:^(UIImage* image){
        //如果图片在缓存中
        if(image){
            completeBlock(image, nil);
            return ;
        }
        __strong typeof(self) strongSelf = weakSelf;
        JQQImageOperation* operation = [[JQQImageOperation alloc] initWithUrlString:urlString];
        [self.downloadQueue addOperation:operation];
        //TODO
        operation.dataBlock = ^(UIImage* image, NSError* error){
            [[JQQImageCache sharedImageCache] storeImage:image forkey:urlString];
            completeBlock(image, error);
        };
        operation.progressBlock = ^(CGFloat progress){
            progressBlock(progress);
        };
        operation.failedBlock = ^(NSString* urlString){
            [strongSelf.failedUrls addObject:urlString];
        };
    }];
}

@end
