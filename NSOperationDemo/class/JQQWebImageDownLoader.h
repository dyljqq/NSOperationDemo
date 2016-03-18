//
//  JQQWebImageDownLoader.h
//  NSOperationDemo
//
//  Created by 季勤强 on 16/3/18.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JQQImageCache.h"

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

typedef void (^JQQImageOperationProgressBlock)(CGFloat progress);
typedef void (^JQQImageOperationDataBlock)(UIImage* image, NSError* error);
typedef void (^JQQWebImageDownLoaderFailedBlock)(NSString* urlString);

@interface JQQWebImageDownLoader : NSObject

@property (nonatomic)NSInteger maxConcurrence;

/**
 *  Return global JQQWebImageDownLoader instance
 *
 *  @return global JQQWebImageDownLoader instance
 */
+ (instancetype)sharedManager;

/**
 *  download image
 *
 *  @param urlString     url
 *  @param progressBlock progress block
 *  @param completeBlock complete block
 */
- (void)downloadImageWithUrlString:(NSString*)urlString progress:(JQQImageOperationProgressBlock)progressBlock complete:(JQQImageOperationDataBlock)completeBlock;

@end
