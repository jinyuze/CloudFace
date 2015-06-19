//  ViewController.m
//  SantaFace
//
//  Created by Tadas Z on 11/30/12.
//  DevBridge

#import "ViewController.h"
#import "DetectFace.h"
#import "recognizeViewController.h"

@interface ViewController () <DetectFaceDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *switchView;
@property (strong, nonatomic) DetectFace *detectFaceController;
@property (nonatomic, strong) UIImageView *faceView;

@end

@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 初始化，在这里对吗？
    int previewWidth = self.view.frame.size.width;
    int previewHeight =  previewWidth * 4/3;
    counter = 0;
    detectionFrequency = 1;
    
    //self是视图控制器，视图控制器的背景颜色
    self.view.backgroundColor=[UIColor whiteColor];
    
    //查看试图控制器位置和大小，x和y都是0，在状态栏下面，所以布局时需要考虑状态栏
    NSLog(@"%f,%f,%f,%f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    //新建一个视图控制器类，点击按钮后从本类调转到新建的那个类中，然后再点击一个按钮返回，即从一个view调转到另一个view
    //新建了一个recognizeViewController，继承自ViewController
    //以下是一个按钮，点击后跳转到recognizeViewController的那个视图
    recognitionbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    // 设置按钮大小
    int btnRadius = 40;
    recognitionbtn.frame=CGRectMake(self.view.frame.size.width/2-btnRadius, 0.5*self.view.frame.size.height+0.5*previewHeight-btnRadius, 2*btnRadius, 2*btnRadius);
    recognitionbtn.layer.cornerRadius = btnRadius;
    [recognitionbtn setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:189.0/255.0 blue:204.0/255.0 alpha:1.0]];
    // 设置按钮中字体
    recognitionbtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [recognitionbtn setTitle:@"识别" forState:UIControlStateNormal];
    [recognitionbtn setTintColor:[UIColor whiteColor]];
    // 跳转
    [recognitionbtn addTarget:self action:@selector(startRecognitionButton:) forControlEvents:UIControlEventTouchUpInside];
    // 画出按钮
    [self.view addSubview:recognitionbtn];
    
    // 防止子视图实例化时重复加载
    subvc1 = [[recognizeViewController alloc]init];
    
    // 预览图像显示自适应展现
    [self.previewView setBounds:CGRectMake(0,0,previewWidth,previewHeight)];
    NSLog(@"previewWidth:%d, previewHeight:%d", previewWidth, previewHeight);
    
    // 定义View图层
    self.previewView.layer.zPosition = 1;
    self.switchView.layer.zPosition = 2;
    
	// Do any additional setup after loading the view, typically from a nib.
    self.detectFaceController = [[DetectFace alloc] init];
    self.detectFaceController.delegate = self;
    self.detectFaceController.previewView = self.previewView;
    cameraState = self.detectFaceController->isFront;
    [self.detectFaceController startDetection];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillUnload
{
    [self.detectFaceController stopDetection];
    [super viewWillUnload];
}

- (void)viewDidUnload {
    [self setPreviewView:nil];
    [super viewDidUnload];
}

- (void)detectedFaceController:(DetectFace *)controller features:(NSArray *)featuresArray forVideoBox:(CGRect)clap withPreviewBox:(CGRect)previewBox
{
    // 防止每帧图像都计算人脸检测，导致手机过热
    if(counter < detectionFrequency){
        counter += 1;
        return;
    }
    counter = 0;
    
    if (!self.faceView || cameraState != self.detectFaceController->isFront){
        self.faceView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100,100,100)];
        self.faceView.contentMode = UIViewContentModeScaleToFill;
        [self.previewView addSubview:self.faceView];
        cameraState = self.detectFaceController->isFront;
    }
    self.faceView.layer.borderWidth = 0;
    [recognitionbtn setEnabled:false];
    
    
    for (CIFaceFeature *ff in featuresArray) {
        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        realfaceRect = [ff bounds];///////////////
        
        
        //isMirrored because we are using front camera，但是这里需要注意的是，isFront已经反转
        if (self.detectFaceController->isFront == 1)
            faceRect = [DetectFace convertFrame:realfaceRect previewBox:previewBox forVideoBox:clap isMirrored:NO];
        else
            faceRect = [DetectFace convertFrame:realfaceRect previewBox:previewBox forVideoBox:clap isMirrored:YES];
        
        // add a border around the newly created UIImageView
        self.faceView.layer.borderWidth = 1;
        
        [recognitionbtn setEnabled:true];
        
        self.faceView.layer.borderColor = [[UIColor redColor] CGColor];
        
        
        float face_width = faceRect.size.width;
        float face_height = faceRect.size.height;
        float face_y = faceRect.origin.y;
        float face_x = faceRect.origin.x;
        
        [self.faceView setFrame:CGRectMake(face_x, face_y, face_width, face_height)];
        
    }
}

// 翻转摄像头
- (IBAction)switchCameraTapped:(id)sender {
        [self.detectFaceController startDetection];
}


// 点击“识别”按钮，实现跳转和呈现照片
- (IBAction)startRecognitionButton:(id)sender {
    [self shutterCamera];
}


// 根据检测出人脸的大小，裁剪图片
-(UIImage*)getSubImage:(UIImage*)image Rect:(CGRect)cropRect
{
    //截取图片
    CGImageRef subImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *img = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    return img;

}

- (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

- (void) shutterCamera
{
    AVCaptureConnection * videoConnection = [self.detectFaceController->stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.detectFaceController->stillImageOutput  captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return ;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        NSLog(@"image size = %@",NSStringFromCGSize(image.size));

//       // 调整image大小
//        UIImage *image1 =[self fixrotation:image];
//        NSLog(@"image1 size = %@",NSStringFromCGSize(image1.size));
//        
//        UIImage *image2 = [self scalingImage:image];
//        NSLog(@"image size = %@",NSStringFromCGSize(image2.size));

        //在使用realfaceract进行切割人脸之前，需要根据实际情况对realfacerect进行镜像反转
        realfaceRect.origin.y = 480-(realfaceRect.size.width+realfaceRect.origin.y);
        
        UIImage *cuttedImage = [self getSubImage:image Rect:realfaceRect];
        
        UIImage *rotatedSquareImage = [self imageRotatedByDegrees:cuttedImage];
        
        //这个视图控制器之间的跳转动画，可以设置，一共四种
        //UIModalTransitionStyleCoverVertical-默认的，从下来，往下去
        //UIModalTransitionStyleCrossDissolve-渐变出现和消失
        //UIModalTransitionStyleFlipHorizontal-水平翻转，翻转时可看到底色
        //UIModalTransitionStylePartialCurl-翻书效果
        subvc1.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        subvc1.image = rotatedSquareImage;
        if(subvc1.imageView){
            [subvc1.imageView setImage:subvc1.image];
        }
        [self presentViewController:subvc1 animated:YES completion:^{
        }];
    }];
    
}

//等比例缩放
- (UIImage *)scalingImage:(UIImage *)image {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    
    CGSize newSize;
    newSize.width = self.view.frame.size.width;
    newSize.height = newSize.width * 4/3;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (UIImage *)imageRotatedByDegrees:(UIImage*)image
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(90));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(90));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end

