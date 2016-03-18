//
//  JQQImageCache.h
//  NSOperationDemo
//
//  Created by 季勤强 on 16/3/18.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JQQImageCacheQueryDoneBlock)(UIImage* image);

@interface JQQImageCache : NSObject

/**
 *  default is YES
 */
@property (nonatomic)BOOL shouldCacheInMemory;

/**
 *  Return global JQQImageCache instance
 *
 *  @return global JQQImageCache instance
 */
+ (JQQImageCache*)sharedImageCache;

/**
 *  store image
 *
 *  @param image data
 *  @param key   store path
 * 
 * default also store image in disk
 *
 */
- (void)storeImage:(UIImage*)image forkey:(NSString*)key;

/**
 *  store image
 *
 *  @param image data
 *  @param key   store path
 *  @param toDisk if store image in disk
 */
- (void)storeImage:(UIImage *)image forkey:(NSString *)key toDisk:(BOOL)toDisk;

/**
 *  check if the image is exits
 *
 *  @param key   image store key
 *  @param block done block
 */
- (void)queryImageFromCache:(NSString*)key done:(JQQImageCacheQueryDoneBlock)block;

@end
