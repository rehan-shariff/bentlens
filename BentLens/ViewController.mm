//
//  ViewController.mm
//  BentLens
//
//  Created by Rehan Shariff on 1/26/16.
//  Copyright © 2016 Stackhall Learning Services, LLC. All rights reserved.
//

#import "ViewController.h"
#import "VideoCamera.h"
#import "GalleryManager.h"
#import "BentLens-Swift.h"
#import "ColorManager.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

CGFloat const cannyDefault = 50;

using namespace cv;

@interface ViewController() <CvVideoCameraDelegate, LinesAndBackgroundColorPickerViewControllerDelegate>
 {
    Mat _currentImage;
}

@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIView* snapView;

@property (weak, nonatomic) IBOutlet UIButton* snapButton;
@property (weak, nonatomic) IBOutlet UIButton* switchButton;

@property (weak, nonatomic) IBOutlet UIButton* galleryButton;
@property (weak, nonatomic) IBOutlet UIButton* colorButton;

@property (weak, nonatomic) IBOutlet UIView* topControlsView;
@property (weak, nonatomic) IBOutlet UIView* buttonsView;
@property (nonatomic) CGFloat topControlsY;
@property (nonatomic) CGFloat topControlsHeight;
@property (nonatomic) CGFloat buttonsY;
@property (nonatomic) BOOL controlsVisible;

@property (nonatomic, retain) VideoCamera* videoCamera;
@property (nonatomic, strong) ColorManager* colorManager;
@property (nonatomic, strong) GalleryManager* galleryManager;

@property (nonatomic) CGFloat cannyValue;

@end

@implementation ViewController

- (instancetype) initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.galleryManager = [[GalleryManager alloc]init];
        self.colorManager = [[ColorManager alloc]init];
        self.controlsVisible = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupVideoCamera];
    [self.galleryManager loadImagesFromLibrary];
    [self.colorManager loadColors];
    self.cannyValue = cannyDefault;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupControlsInfo];
    [self startCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.videoCamera stop];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma CvVideoCameraDelegate

- (void)processImage:(Mat&)image {
    cvtColor(image, image, COLOR_RGB2GRAY);
    GaussianBlur(image, image, cv::Size(3,3), 0);
    Canny(image, image, self.cannyValue, self.cannyValue * 3);

    Mat tempImage = Mat(image.size(), CV_8UC3, [self scalarFromUIColor:self.colorManager.backgroundColor]);
    tempImage.setTo([self scalarFromUIColor:self.colorManager.linesColor], image);
    
    tempImage.copyTo(_currentImage);
    tempImage.copyTo(image);
    tempImage.release();
}

#pragma LinesAndBackgroundColorPickerViewControllerDelegate

- (void)linesAndBackgroundColorPickerViewController:(UIColor* _Nonnull)linesColor backgroundColor:(UIColor* _Nonnull)backgroundColor {
    [self.colorManager saveLinesColor:linesColor AndBackgroundColor:backgroundColor];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue
                 sender:(id)sender {
    if([segue.identifier  isEqual: @"ChooseColors"]) {
        UINavigationController* navController = segue.destinationViewController;
        LinesAndBackgroundColorPickerViewController* controller = (LinesAndBackgroundColorPickerViewController*)navController.topViewController;
        controller.delegate = self;
        controller.initialLinesColor = self.colorManager.linesColor;
        controller.initalBackgroundColor = self.colorManager.backgroundColor;
    }
}

- (IBAction)snapPressed:(id)sender {
    [self snap];
}

- (IBAction)switchCameraPressed:(id)sender {
    [self.videoCamera switchCameras];
}

- (IBAction)galleryPressed:(id)sender {
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:[self.galleryManager createGallery]];
    navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    navigationController.navigationBar.translucent = NO;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)snapViewTapped:(id)sender {
    CGFloat topControlsY, buttonsY;
    if(self.controlsVisible) {
        topControlsY = -self.topControlsHeight;
        buttonsY = [[UIScreen mainScreen]bounds].size.height;
    }
    else {
        topControlsY = self.topControlsY;
        buttonsY = self.buttonsY;
    }
    
    self.controlsVisible = !self.controlsVisible;
    
    __weak ViewController* weakSelf = self;
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionTransitionFlipFromBottom
                     animations:^(void) {
                         CGRect topControlsFrame =
                         weakSelf.topControlsView.frame;
                         topControlsFrame.origin.y = topControlsY;
                         weakSelf.topControlsView.clipsToBounds = YES;
                         [weakSelf.topControlsView setFrame:topControlsFrame];
                         CGRect buttonsFrame = weakSelf.buttonsView.frame;
                         buttonsFrame.origin.y = buttonsY;
                         weakSelf.buttonsView.clipsToBounds = YES;
                         [weakSelf.buttonsView setFrame:buttonsFrame];
                     }
                     completion:nil];
}

- (IBAction)snapViewLongPressed:(UILongPressGestureRecognizer*)sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        [self snap];
    }
}
- (IBAction)snapViewPan:(UIPanGestureRecognizer*)sender {
    CGPoint translation = [sender translationInView:self.view];
    self.cannyValue = self.cannyValue + translation.y/5;
    if(self.cannyValue > 100) {
        self.cannyValue = 100;
    }
    if(self.cannyValue < 0) {
        self.cannyValue = 0;
    }
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)setupVideoCamera {
    self.videoCamera = [[VideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
}

- (void)setupControlsInfo {
    self.topControlsY = self.topControlsView.frame.origin.y;
    self.topControlsHeight = self.topControlsView.frame.size.height;
    self.buttonsY = self.buttonsView.frame.origin.y;
}

- (void)startCamera {
    [self.videoCamera start];
}

- (void)animateImageSnap {
    __weak ViewController* weakSelf = self;
    [UIView animateWithDuration:0.1f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         weakSelf.snapView.backgroundColor = [UIColor whiteColor];
                     }
                     completion:^(BOOL) {
                         weakSelf.snapView.backgroundColor = [UIColor clearColor];
                     }];
}

- (void)snap {
    [self animateImageSnap];
    [self saveImage];
}

- (Scalar)scalarFromUIColor:(UIColor*) color {
    Scalar scalarColor;
    CGFloat red, green, blue, dummyAlpha;
    [color getRed:&red green:&green blue:&blue alpha:&dummyAlpha];
    scalarColor[0] = red * 255.0;
    scalarColor[1] = green * 255.0;
    scalarColor[2] = blue * 255.0;
    return scalarColor;
}

- (void)saveImage {
    __weak ViewController* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* convertedImage = MatToUIImage(_currentImage);
        UIImageWriteToSavedPhotosAlbum(convertedImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if(!error) {
        [self.galleryManager loadImagesFromLibrary];
    }
}

@end