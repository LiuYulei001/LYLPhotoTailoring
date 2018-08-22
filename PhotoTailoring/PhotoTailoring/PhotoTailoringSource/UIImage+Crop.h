

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

@interface UIImage (Crop)
/*
 * 改变图片size
 */
+ (UIImage*)imageWithImageSimple:(UIImage*)image
                    scaledToSize:(CGSize)newSize;
/**
 * 将image适配屏幕
 */
+ (UIImage *)fitScreenWithImage:(UIImage *)image;
/*
 * 裁剪图片
 */
- (UIImage *)cropImageWithX:(CGFloat)x
                          y:(CGFloat)y
                      width:(CGFloat)width
                     height:(CGFloat)height;

@end
