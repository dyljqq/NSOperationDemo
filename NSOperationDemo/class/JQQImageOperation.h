//
//  JQQImageOperation.h
//  JQQWebImage
//
//  Created by 季勤强 on 16/3/17.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JQQImageOperationProgressBlock)(CGFloat progress);
typedef void (^JQQImageOperationDataBlock)(UIImage* image, NSError* error);

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
 *  initial with url string
 *
 *  @param urlString
 *
 *  @return self
 */
- (instancetype)initWithUrlString:(NSString*)urlString;

@end
