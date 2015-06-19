//  DetectFace.m
//  SantaFace
//
//  Created by Tadas Z on 11/30/12.
//  DevBridge

#import "DetectFace.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

#pragma mark-

@interface DetectFace () <AVCaptureVideoDataOutputSampleBufferDelegate>

// 视频预览框
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
// 人脸检测
@property (nonatomic, strong) CIDetector * faceDetector;


@end

@implementation DetectFace

// 初始化
- (id)init
{
    self = [super init];
    if (self)
    {
        // 初始是后视摄像头
        isFront = 0;
    }
    return self;
}

- (void)setupAVCapture
{
    if(session)
        [session stopRunning];
    
    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset640x480];

    
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSLog(@"上面的 %d",isFront);
    
    // 判断是否存在前置摄像头
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (isFront == 1) { // 前视摄像头
                if ([d position] == AVCaptureDevicePositionFront) {
                    device = d;
                    isFront = 0;
                    break;
                }
            }
            else { // 后视摄像头
                if ([d position] == AVCaptureDevicePositionBack) {
                    device = d;
                    isFront = 1;
                    break;
                }
            }
        }
        NSLog(@"下面的%d",isFront);
    }
    else {
        // 提示框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"该设备没有前视摄像头."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        // [alert release];
        
        for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            device = d;
            break;
        }
        
    }
    
	NSError *error = nil;
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(error != nil)
    {
        exit(0);
    }	

	if ([session canAddInput:deviceInput])
		[session addInput:deviceInput];
		
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
    
    self->stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [self->stillImageOutput setOutputSettings:outputSettings];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    //NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA)};
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
	
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    if ([session canAddOutput:self->stillImageOutput]) {
        [session addOutput:self->stillImageOutput];
    }
	
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	CALayer *rootLayer = [self.previewView layer];
	[rootLayer setMasksToBounds:YES];
	[self.previewLayer setFrame:[rootLayer bounds]];
	[rootLayer addSublayer:self.previewLayer];
	[session startRunning];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    //uiImage = [[UIImage alloc] initWithCIImage:ciImage];////????
    
	if (attachments)
		CFRelease(attachments);
    

	
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    

	int exifOrientation = 6; //   6  =  0th row is on the right, and 0th column is the top.

    
	NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation)};
    
	NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
	
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
	
    // called asynchronously as the capture output is capturing sample buffers, this method asks the face detector
    // to detect features
	dispatch_async(dispatch_get_main_queue(), ^(void) {
        CGSize parentFrameSize = [self.previewView frame].size;
        NSString *gravity = [self.previewLayer videoGravity];
        
        CGRect previewBox = [DetectFace videoPreviewBoxForGravity:gravity frameSize:parentFrameSize apertureSize:clap.size];
		if([self.delegate respondsToSelector:@selector(detectedFaceController:features:forVideoBox:withPreviewBox:)])
            [self.delegate detectedFaceController:self features:features forVideoBox:clap withPreviewBox:previewBox];
	});
}

- (void)startDetection
{   
    [self setupAVCapture];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
	NSDictionary *detectorOptions = @{CIDetectorAccuracy : CIDetectorAccuracyLow};
	self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}

- (void)stopDetection
{
    [self teardownAVCapture];
}

// clean up capture setup
- (void)teardownAVCapture
{
	if (videoDataOutputQueue)
		videoDataOutputQueue = nil;
}

// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
	//在preview中适配videoBox
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}

// ?????????????这里我需要知道是干什么的

+ (CGRect)convertFrame:(CGRect)originalFrame previewBox:(CGRect)previewBox forVideoBox:(CGRect)videoBox isMirrored:(BOOL)isMirrored
{
    // flip preview width and height
    CGFloat temp = originalFrame.size.width;
    originalFrame.size.width = originalFrame.size.height;
    originalFrame.size.height = temp;
    temp = originalFrame.origin.x;
    originalFrame.origin.x = originalFrame.origin.y;
    originalFrame.origin.y = temp;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = previewBox.size.width / videoBox.size.height;
    CGFloat heightScaleBy = previewBox.size.height / videoBox.size.width;
    originalFrame.size.width *= widthScaleBy;
    originalFrame.size.height *= heightScaleBy;
    originalFrame.origin.x *= widthScaleBy;
    originalFrame.origin.y *= heightScaleBy;
    if(isMirrored)
    {
        originalFrame = CGRectOffset(originalFrame, previewBox.origin.x + previewBox.size.width - originalFrame.size.width - (originalFrame.origin.x * 2), previewBox.origin.y);
    }
    else
    {
        originalFrame = CGRectOffset(originalFrame, previewBox.origin.x, previewBox.origin.y);
    }
    
    return originalFrame;
}



- (void) saveImage: (UIImage*)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          @"test.png" ];
        NSLog(@"写入");
        NSFileManager *fileManager = [NSFileManager defaultManager];

        BOOL isExist = [fileManager fileExistsAtPath: path];
        if (isExist) {
            //删除⽂件
            BOOL success = [fileManager removeItemAtPath:path error:nil];
            if (success) {
                NSLog(@"remove success");
            }
        }

        NSData* data = UIImagePNGRepresentation(image);
        BOOL isSuccess = [data writeToFile:path atomically:YES];
        if(!isSuccess){
            NSLog(@"写入失败");
        }else{
            NSLog(@"写入成功");
        }
    }
}

- (UIImage*)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      @"test.png" ];
    NSLog(@"读取");
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

@end
