//  ViewController.h
//  SantaFace
//
//  Created by Tadas Z on 11/30/12.
//  DevBridge

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "recognizeViewController.h"


@interface ViewController : UIViewController{
    
    // 记录前视摄像头or后视摄像头
    int cameraState;
    // 人脸检测频率
    int detectionFrequency;
    // 记录帧数量
    int counter;
    
    @public
    // 选择的图像
    UIImage* pickedImage;
    
    UIButton *recognitionbtn;
    CGRect faceRect;
    CGRect realfaceRect;
    
    recognizeViewController *subvc1;

}
- (void) shutterCamera;
- (UIImage *)imageRotatedByDegrees:(UIImage*)image;

@end

