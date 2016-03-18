//
//  JQQImageCache.m
//  NSOperationDemo
//
//  Created by 季勤强 on 16/3/18.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import "JQQImageCache.h"
#import <CommonCrypto/CommonDigest.h>

FOUNDATION_STATIC_INLINE NSUInteger JQQCacheImageCount(UIImage* image){
    return image.size.width * image.size.height * image.scale * image.scale;
}

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // cache 1 week
static const NSString* FULL_NAME = @"com.jqq.JQQImageCache.STORE_IMAHE";

@interface JQQImageCache ()

@property (nonatomic, copy)NSCache* memCache;
@property (nonatomic, copy)NSString* diskCachePath;
@property (nonatomic, strong)dispatch_queue_t ioQueue;

@end

@implementation JQQImageCache{
    NSFileManager* fileManager;
}

+ (JQQImageCache*)sharedImageCache{
    static dispatch_once_t once;
    static JQQImageCache* imageCache = nil;
    dispatch_once(&once, ^{
        imageCache = [self new];
    });
    return imageCache;
}

- (instancetype)init{
    self = [super init];
    if(self){
        [self initParams];
    }
    return self;
}

- (void)initParams{
    _shouldCacheInMemory = YES;
    _memCache = [[NSCache alloc] init];
    //create IO serial queue
    _ioQueue = dispatch_queue_create("com.jqq.JQQImageCache", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_ioQueue, ^{
        fileManager = [NSFileManager new];
    });
    _diskCachePath = [FULL_NAME copy];
}

- (void)storeImage:(UIImage *)image forkey:(NSString *)key{
    if([self imageInDiskForKey:key] || [self imageInMemoryForKey:key]){
        return ;
    }
    [self storeImage:image forkey:key toDisk:YES];
}

- (void)storeImage:(UIImage *)image forkey:(NSString *)key toDisk:(BOOL)toDisk{
    if((toDisk && [self imageInDiskForKey:key]) || [self imageInMemoryForKey:key]){
        return ;
    }
    if(!image || !key)
        return ;
    if(self.shouldCacheInMemory){
        NSUInteger cost = JQQCacheImageCount(image);
        [self.memCache setObject:image forKey:key cost:cost];
    }
    if(toDisk){
        dispatch_async(self.ioQueue, ^{
            NSData* data = nil;
            if(image){
                int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
                BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                                  alphaInfo == kCGImageAlphaNoneSkipFirst ||
                                  alphaInfo == kCGImageAlphaNoneSkipLast);
                BOOL imageIsPNG = hasAlpha;
                if(imageIsPNG){
                    data = UIImagePNGRepresentation(image);
                }else{
                    data = UIImageJPEGRepresentation(image, 1.0);
                }
            }
            
            if(data){
                if(![fileManager fileExistsAtPath:_diskCachePath]){
                    [fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString* cachePathForKey = [self cachePathForKey:key];
                [fileManager createFileAtPath:cachePathForKey contents:data attributes:nil];
            }
        });
    }
}

- (void)queryImageFromCache:(NSString *)key done:(JQQImageCacheQueryDoneBlock)block{
    if(!block){
        return ;
    }
    if(!key){
        block(nil);
    }
    
    //check if exits in memory
    UIImage* image = [self imageFromMemoryCacheForKey:key];
    if(image){
        block(image);
        return ;
    }
    dispatch_async(self.ioQueue, ^{
        @autoreleasepool {
            UIImage* image = [self imageFromDiskCacheForKey:key];
            if(image && self.shouldCacheInMemory){
                NSUInteger cost = JQQCacheImageCount(image);
                [self.memCache setObject:image forKey:key cost:cost];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image);
            });
        }
    });
}

#pragma Private Method

- (UIImage*)imageFromMemoryCacheForKey:(NSString*)key{
    return [self.memCache objectForKey:key];
}

- (UIImage*)imageFromDiskCacheForKey:(NSString*)key{
    NSString* path = [self cachePathForKey:key];
    NSData* data = [NSData dataWithContentsOfFile:path];
    if(data){
        UIImage* image = [UIImage imageWithData:data];
        return image;
    }
    return nil;
}

- (NSString*)cachePathForKey:(NSString*)key{
    NSString* fileName = [self cachedFileNameForKey:key];
    return [_diskCachePath stringByAppendingPathComponent:fileName];
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}

- (BOOL)imageInDiskForKey:(NSString*)key{
    if([self imageFromDiskCacheForKey:key] == nil){
        return NO;
    }
    return YES;
}

- (BOOL)imageInMemoryForKey:(NSString*)key{
    if([self imageFromMemoryCacheForKey:key] == nil){
        return NO;
    }
    return YES;
}

@end
