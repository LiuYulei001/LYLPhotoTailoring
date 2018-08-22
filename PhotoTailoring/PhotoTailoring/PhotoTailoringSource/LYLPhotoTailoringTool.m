//
//  LYLPhotoTailoringTool.m
//  PhotoTailoring
//
//  Created by Rainy on 2018/8/22.
//  Copyright © 2018年 Rainy. All rights reserved.
//

#import "LYLPhotoTailoringTool.h"
#import "LYLPhotoTailoringViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface LYLPhotoTailoringTool ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,PhotoViewControllerDelegate>
{
    ChoosImageBlock _choosImageBlock;
    UIImagePickerControllerSourceType _photoType;
}


@end

@implementation LYLPhotoTailoringTool

static LYLPhotoTailoringTool *tool = nil;

+ (instancetype)sharedTool
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        tool = [LYLPhotoTailoringTool new];
        
    });
    
    return tool;
}

- (void)photoTailoring:(ChoosImageBlock)finished
{
    _choosImageBlock = finished;
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil message: nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self choosePhoto:NO];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从手机相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self choosePhoto:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [[self getCurrentViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)choosePhoto:(BOOL)photo
{
    WS(weakSelf)
    
    __block UIImagePickerControllerSourceType block_photoType = _photoType;
    
    [self checkCheckPermissionsType:(photo ? CheckPermissionsTypePhoto : CheckPermissionsTypeVideo) permissionGranted:^{

        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = photo ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
        block_photoType = ipc.sourceType;
        [[self getCurrentViewController] presentViewController:ipc animated:YES completion:nil];
        
        ipc.delegate = weakSelf;
        
    } noPermission:^(CheckPermissionsType type) {
        
        NSString *message = @"";
        
        if (type == CheckPermissionsTypePhoto) {
            
            message = @"请在设置中，允许“PhotoTailoring”访问您的照片";
        }
        if (type == CheckPermissionsTypeVideo) {
            
            message = @"请在设置中，允许“PhotoTailoring”访问您的相机";
        }
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
        }]];
        
        [[self getCurrentViewController] presentViewController:alertController animated:YES completion:nil];
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    LYLPhotoTailoringViewController *photoVC = [[LYLPhotoTailoringViewController alloc] init];
    photoVC.oldImage = image;
    photoVC.mode = PhotoMaskViewModeCircle;
    photoVC.cropWidth = CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds);
    photoVC.isDark = YES;
    photoVC.delegate = self;
    photoVC.lineColor = [UIColor redColor];
    [picker pushViewController:photoVC animated:YES];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    }
}
#pragma mark - photoViewControllerDelegate
- (void)imageCropperDidCancel:(LYLPhotoTailoringViewController *)cropperViewController
{
    if (_photoType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [cropperViewController.navigationController popViewControllerAnimated:YES];
    }else{
        [cropperViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)imageCropper:(LYLPhotoTailoringViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    __weak ChoosImageBlock block_choosImageBlock = _choosImageBlock;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        block_choosImageBlock(editedImage);
    }];
}

- (UIViewController *)getCurrentViewController {
    __block UIWindow *normalWindow = [[UIApplication sharedApplication].delegate window];
    if (normalWindow.windowLevel != UIWindowLevelNormal) {
        [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.windowLevel == UIWindowLevelNormal) {
                normalWindow = obj;
                *stop        = YES;
            }
        }];
    }
    
    return [self nextTopForViewController:normalWindow.rootViewController];
}

- (UIViewController *)nextTopForViewController:(UIViewController *)inViewController {
    while (inViewController.presentedViewController) {
        inViewController = inViewController.presentedViewController;
    }
    
    if ([inViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UITabBarController *)inViewController).selectedViewController];
        return selectedVC;
    } else if ([inViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UINavigationController *)inViewController).visibleViewController];
        return selectedVC;
    } else {
        return inViewController;
    }
}

typedef NS_ENUM(NSUInteger, CheckPermissionsType) {
    CheckPermissionsTypePhoto,
    CheckPermissionsTypeVideo,
};

- (void)checkCheckPermissionsType:(CheckPermissionsType)type
                permissionGranted:(void (^)(void))permissionGranted
                     noPermission:(void (^)(CheckPermissionsType type))noPermission
{
    if (type == CheckPermissionsTypePhoto)
    {
        PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
        
        if (photoAuthStatus == PHAuthorizationStatusNotDetermined) {
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    status == PHAuthorizationStatusAuthorized ? permissionGranted() : noPermission(type);
                });
            }];
            
        }else if (photoAuthStatus == PHAuthorizationStatusRestricted || photoAuthStatus == PHAuthorizationStatusDenied){
            
            noPermission(type);
            
        }else
        {
            permissionGranted();
        }
        
    }
    if (type == CheckPermissionsTypeVideo) {
        
        AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    granted ? permissionGranted() : noPermission(type);
                });
            }];
            
        }else if (videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied){
            
            noPermission(type);
            
        }else
        {
            permissionGranted();
        }
    }
}

@end
