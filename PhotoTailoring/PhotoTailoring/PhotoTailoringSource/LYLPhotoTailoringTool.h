//
//  LYLPhotoTailoringTool.h
//  PhotoTailoring
//
//  Created by Rainy on 2018/8/22.
//  Copyright © 2018年 Rainy. All rights reserved.
//

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void(^ChoosImageBlock)(UIImage *image);

@interface LYLPhotoTailoringTool : NSObject

+ (instancetype)sharedTool;
/**
 *  选择相册／拍摄
 */
- (void)photoTailoring:(ChoosImageBlock)finished;

@end
