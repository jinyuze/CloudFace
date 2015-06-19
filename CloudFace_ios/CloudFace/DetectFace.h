//  DetectFace.h
//  SantaFace
//
//  Created by Tadas Z on 11/30/12.
//  DevBridge

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class DetectFace;
@protocol DetectFaceDelegate <NSObject>
- (void)detectedFaceController:(DetectFace *)controller features:(NSArray *)featuresArray forVideoBox:(CGRect)clap withPreviewBox:(CGRect)previewBox;
@end

@interface DetectFace : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate, UIDocumentInteractionControllerDelegate>{
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t videoDataOutputQueue;
    AVCaptureSession *session;
    @public
    AVCaptureStillImageOutput * stillImageOutput;
    
    @public
    int isFront;
    //被切下的照片
    @public
    UIImage *cuttedImageModel;
}

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UIView *previewView;

- (void)startDetection;
- (void)stopDetection;

- (void) saveImage: (UIImage*)image;
- (UIImage*)loadImage;

+ (CGRect)convertFrame:(CGRect)originalFrame previewBox:(CGRect)previewBox forVideoBox:(CGRect)videoBox isMirrored:(BOOL)isMirrored;

@end
