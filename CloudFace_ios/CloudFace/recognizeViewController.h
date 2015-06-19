//
//  recognizeViewController.h
//  SantaFace
//
//  Created by 语泽思密达 on 15/6/10.
//  Copyright (c) 2015年 DevBridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface recognizeViewController : UIViewController

@property (nonatomic,strong) UIImage* image;
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,strong) UITextView *textview;
-(void)setImage:(UIImage *)image;
@end
