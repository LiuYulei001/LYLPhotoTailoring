# LYLPhotoTailoring
相册/拍照的照片自定义UI、自定义裁剪（圆形、方形），解决了iOS11原生裁剪不准确的问题

1.设计逻辑：

选择照片来源（拍照、相册）-> 检查访问权限 -> 拍照/相册选择照片 -> 裁剪 -> 裁剪后的图片回调

2.使用方法：

//具体使用见dome

[[PhotoTailoringTool sharedTool]photoTailoring:^(UIImage *image) {
       
        // 裁剪后的image（使用时注意循环引用）
        
}];

3.参数说明：

@property (nonatomic,assign) PhotoMaskViewMode mode;                 // 圆形 or 正方形

@property (nonatomic,assign) CGFloat cropWidth;                      // 裁剪宽度

@property (nonatomic,assign) CGFloat cropHeight;                     // 裁剪高度

@property (nonatomic,strong) UIColor *lineColor;                     // 线条颜色

@property (nonatomic,assign) BOOL isDark;                            // 是否为虚线 default is NO

@property (nonatomic,strong) UIColor  *btnBackgroundColor;           // 确定按钮颜色
