
#import <UIKit/UIKit.h>
#import "LYLPhotoTailoringViewController.h"

@protocol PhotoMaskViewDelegate<NSObject>

- (void)layoutScrollViewWithRect:(CGRect) rect;

@end
@interface PhotoMaskView : UIView
@property (nonatomic, weak) id<PhotoMaskViewDelegate>  delegate;

-(instancetype)initWithFrame:(CGRect)frame width:(CGFloat)cropWidth height:(CGFloat)height;
@property (nonatomic,assign) PhotoMaskViewMode mode;

@property (nonatomic,strong) UIColor *lineColor; // 线条颜色
@property (nonatomic,assign) BOOL    isDark; // 是否为虚线 default is NO
@end
