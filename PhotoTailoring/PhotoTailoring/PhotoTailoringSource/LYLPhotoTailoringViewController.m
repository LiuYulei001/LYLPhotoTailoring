
#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define Font_17 [UIFont systemFontOfSize:17]

#define Color_ffffff UIColorFromRGBValue(0Xffffff)

#import "LYLPhotoTailoringViewController.h"
#import "PhotoMaskView.h"
#import "UIImage+Crop.h"

@interface LYLPhotoTailoringViewController ()<UIScrollViewDelegate,PhotoMaskViewDelegate>
{
    CGRect            _rect;
    UIImageView      *_imageView;
    UIView           *_cropView;
    UIEdgeInsets      _imageInset;
    CALayer           *_layer;
    CGFloat           _rotate;
}

@property (nonatomic,strong) PhotoMaskView *maskView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton *btn;

@end

@implementation LYLPhotoTailoringViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _rotate = 0;
    self.view.backgroundColor = [UIColor blackColor];
    self.oldImage =  [UIImage fitScreenWithImage:self.oldImage];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _imageView = [[UIImageView alloc] initWithImage:self.oldImage];
    
    _imageView.center = self.view.center;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.oldImage.size;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = YES;
    [self.scrollView addSubview:_imageView];
      [self.view addSubview:self.scrollView];
    // maskView
    CGFloat height = 0;
    CGFloat width = 0;
    self.cropHeight?height = self.cropHeight:0;
    if ( self.mode == PhotoMaskViewModeCircle) {
        if (self.cropWidth) {
            height = self.cropWidth;
            self.cropHeight = self.cropWidth;
            width = height;
        }else{
            width = self.cropHeight;
            self.cropWidth = self.cropHeight;
            height = width;
        }
    }else{
        height = self.cropHeight;
        width = self.cropWidth;
    }
    _maskView = [[PhotoMaskView alloc] initWithFrame:self.view.bounds width:width height:height];
    _maskView.mode = self.mode;
    _maskView.userInteractionEnabled = NO;
  
    _isDark?_maskView.isDark = YES:0;
    _lineColor?_maskView.lineColor = _lineColor:0;
    [self.view addSubview:self.maskView];
    self.maskView.delegate = self;
    [self bottomView];
   
}

-(void)bottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 45)];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:view];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.2];
    [bottomView addSubview:lineView];
    
    [self.view addSubview:bottomView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(1*(SCREEN_WIDTH - 80), 10, 70, 30)];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.titleLabel.font = Font_17;
    [bottomView addSubview:btn];
    [btn setTitleColor:Color_ffffff forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(10, 10, 70, 30);
    cancelBtn.titleLabel.font = Font_17;
    [cancelBtn setTitleColor:Color_ffffff forState:UIControlStateNormal];
    [bottomView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(backBtn)forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)backBtn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageCropperDidCancel:)]) {
        [self.delegate imageCropperDidCancel:self];
    }
}
- (void)buttonClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageCropper:didFinished:)]) {
        [self.delegate imageCropper:self didFinished:[self cropImage]];
    }
}

-(void)layoutScrollViewWithRect:(CGRect)rect
{
    _rect = rect;
    CGFloat top = (self.oldImage.size.height-rect.size.height)/2;
    CGFloat left = (self.oldImage.size.width-rect.size.width)/2;
    CGFloat bottom = self.view.bounds.size.height-top-rect.size.height;
    CGFloat right = self.view.bounds.size.width-rect.size.width-left;
    self.scrollView.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
    CGFloat maskCircleWidth = rect.size.width;
    
    CGSize imageSize = self.oldImage.size;
    //setp 2: setup contentSize:
    CGFloat minimunZoomScale = imageSize.width < imageSize.height ? maskCircleWidth / imageSize.width : maskCircleWidth / imageSize.height;
    CGFloat maximumZoomScale = 1.5;
    self.scrollView.minimumZoomScale = minimunZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
    self.scrollView.zoomScale = self.scrollView.zoomScale < minimunZoomScale ? minimunZoomScale : self.scrollView.zoomScale;
    _imageInset = self.scrollView.contentInset;
    
}
- (UIImage *)cropImage
{
    CGFloat zoomScale = _scrollView.zoomScale;
    
    CGFloat offsetX = _scrollView.contentOffset.x;
    CGFloat offsetY = _scrollView.contentOffset.y;
    CGFloat aX = offsetX>=0 ? offsetX+_imageInset.left : (_imageInset.left - ABS(offsetX));
    CGFloat aY = offsetY>=0 ? offsetY+_imageInset.top : (_imageInset.top - ABS(offsetY));
    
    aX = aX / zoomScale;
    aY = aY / zoomScale;
    
    CGFloat aWidth =  MAX(self.cropWidth / zoomScale, self.cropWidth);
    CGFloat aHeight = MAX(self.cropHeight / zoomScale, self.cropHeight);
    if (zoomScale>1) {
        aWidth = self.cropWidth/zoomScale;
        aHeight = self.cropHeight/zoomScale;
    }
    
    UIImage *image = [self.oldImage cropImageWithX:aX y:aY width:aWidth height:aHeight];
    image = [UIImage imageWithImageSimple:image scaledToSize:CGSizeMake(self.cropWidth, self.cropHeight)];
    return image;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
}
@end
