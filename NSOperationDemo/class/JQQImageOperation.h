//
//  JQQImageOperation.h
//  JQQWebImage
//
//  Created by 季勤强 on 16/3/17.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JQQImageCache.h"
#import "JQQWebImageDownLoader.h"

@interface JQQImageOperation : NSOperation

/**
 *  Download Image Data
 */
@property (nonatomic, strong, readonly)NSData* data;

/**
 *  Download progress block
 */
@property (nonatomic, strong)JQQImageOperationProgressBlock progressBlock;

/**
 *  Download data block
 */
@property (nonatomic, strong)JQQImageOperationDataBlock dataBlock;

/**
 *  DOWNLOAD FAILED BLOCK
 */
@property (nonatomic, strong)JQQWebImageDownLoaderFailedBlock failedBlock;

/**
 *  initial with url string
 *
 *  @param urlString
 *
 *  @return self
 */
- (instancetype)initWithUrlString:(NSString*)urlString;

@end
