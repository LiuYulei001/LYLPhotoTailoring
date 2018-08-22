//
//  ViewController.m
//  PhotoTailoring
//
//  Created by Rainy on 2018/8/22.
//  Copyright © 2018年 Rainy. All rights reserved.
//

#import "ViewController.h"
#import "LYLPhotoTailoringTool.h"

@interface ViewController ()

@property(nonatomic,strong)UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageV.center = self.view.center;
    imageV.backgroundColor = [UIColor lightGrayColor];
    self.imageView = imageV;
    [self.view addSubview:self.imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(choosePhotoAction)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tap];
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 50;
}
- (void)choosePhotoAction
{
    WS(weakSelf)
    [[LYLPhotoTailoringTool sharedTool]photoTailoring:^(UIImage *image) {
       
        weakSelf.imageView.image = image;
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
