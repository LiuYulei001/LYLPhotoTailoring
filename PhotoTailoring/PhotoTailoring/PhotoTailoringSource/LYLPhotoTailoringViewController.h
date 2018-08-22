

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PhotoMaskViewMode) {
    PhotoMaskViewModeCircle = 1, // default
    PhotoMaskViewModeSquare = 2  // square
};

@class LYLPhotoTailoringViewController;

@protocol PhotoViewControllerDelegate <NSObject>

- (void)imageCropper:(LYLPhotoTailoringViewController *)cropperViewController
         didFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(LYLPhotoTailoringViewController *)cropperViewController;

@end

@interface LYLPhotoTailoringViewController : UIViewController

@property (nonatomic,weak) id<PhotoViewControllerDelegate> delegate;
@property (nonatomic,strong) UIImage *oldImage;
@property (nonatomic,assign) PhotoMaskViewMode mode;                 // 圆形 or 正方形
@property (nonatomic,assign) CGFloat cropWidth;                      // 裁剪宽度
@property (nonatomic,assign) CGFloat cropHeight;                     // 裁剪高度
@property (nonatomic,strong) UIColor *lineColor;                     // 线条颜色
@property (nonatomic,assign) BOOL isDark;                            // 是否为虚线 default is NO
@property (nonatomic,strong) UIColor  *btnBackgroundColor;           // 确定按钮颜色

@end
