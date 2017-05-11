//
//  QLQRCodeViewController.m
//  QRCode
//
//  Created by huangyueqi on 2017/5/11.
//  Copyright © 2017年 sjyt. All rights reserved.
//  net.sjyt.www.QRCode

#import "QLQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CGAlertView.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define IOS_8_0 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

//左右间隔
static CGFloat leftRightMargin = 50;

@interface QLQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *scanLineImageView;
@property (nonatomic, assign) BOOL isDisappear;
@property (nonatomic, strong) AVCaptureSession *session;                     //扫描的中间控件
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer; //相机预览图层

@end

@implementation QLQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (TARGET_IPHONE_SIMULATOR) {
        NSLog(@"模拟器");
    } else if (TARGET_OS_IPHONE) {
        NSLog(@"真机");
    }
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.session.isRunning == NO) {
        [self.session startRunning];
    }
    [self annimationForScanLineImageView];
    self.isDisappear = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.session stopRunning];
    self.isDisappear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

#pragma mark - SetupUI
- (void)setupUI {
    
    self.navigationItem.title = @"扫一扫";
    self.view.backgroundColor = [UIColor blackColor];
    
    if ([self judgeCameraJurisdiction]) {
        NSLog(@"有权访问");
        AVCaptureDeviceInput *input = [self createAVInput];
        AVCaptureMetadataOutput *output = [self createAVOutput];
        if (input == nil) {
            return;
        }
        [self.session addInput:input];
        [self.session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)-------注意，必须在添加进session后才能设置
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        [self.session startRunning];
    } else {
        NSString *errorStr = @"应用相机权限受限,请在设置中启用";
        NSLog(@"%@", errorStr);
    }
    [self.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    
    //添加中间镂空的遮盖
    CGFloat topMargin = (SCREEN_HEIGHT - (SCREEN_WIDTH - 2 * leftRightMargin)) * 0.5;
    CGRect loukongRect = CGRectMake(leftRightMargin, topMargin, SCREEN_WIDTH - leftRightMargin * 2, SCREEN_WIDTH - leftRightMargin * 2);
    CAShapeLayer *layer = [self loukongLayerWithMianRect:self.view.bounds loukongRect:loukongRect];
    [self.view.layer insertSublayer:layer atIndex:1];
    self.scanLineImageView.frame = CGRectMake(self.scanLineImageView.frame.origin.x, topMargin + SCREEN_WIDTH - 2 * leftRightMargin - 3, self.scanLineImageView.bounds.size.width, self.scanLineImageView.bounds.size.height);
}

#pragma mark - Action
//扫描框横线动画
- (void)annimationForScanLineImageView {
    
    CGFloat y = (SCREEN_HEIGHT - (SCREEN_WIDTH - 2 * leftRightMargin)) * 0.5;
    [UIView animateWithDuration:1.0 animations:^{
        self.scanLineImageView.frame = CGRectMake(self.scanLineImageView.frame.origin.x, y, self.scanLineImageView.bounds.size.width, self.scanLineImageView.bounds.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.scanLineImageView.frame = CGRectMake(self.scanLineImageView.frame.origin.x, y + (SCREEN_WIDTH - 2 * leftRightMargin) - 3, self.scanLineImageView.bounds.size.width, self.scanLineImageView.bounds.size.height);
        } completion:^(BOOL finished) {
            if (self.isDisappear == NO) {
                [self annimationForScanLineImageView];
            }
        }];
    }];
}

//判断应用是否有使用相机的权限
- (BOOL)judgeCameraJurisdiction {
    
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [[CGAlertView shareInstance] showTitle:@"提示" withMessage:@"此应用无法使用你的相机，请在iPhone的“设置 -> 隐私 -> 相机”选项中开启相机功能!" withCancelButton:IOS_8_0 ? @"去设置" : @"确定" withOtherButton:IOS_8_0 ? @"取消" : nil withHanderBlock:^(CGAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                if (IOS_8_0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        NSLog(@"未开启相机权限!");
        return NO;
    } else {
        return YES;
    }
}

- (AVCaptureDeviceInput *)createAVInput {
    
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"初始化输入设备错误:%@", error.localizedDescription);
        return nil;
    }
    return input;
}

- (AVCaptureMetadataOutput *)createAVOutput {
    
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //扫描区域
    //顶部距离
    CGFloat topMargin = (SCREEN_HEIGHT - (SCREEN_WIDTH - 2 * 50)) * 0.5;
    CGFloat margin = 50;
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        output.rectOfInterest = [self.videoPreviewLayer metadataOutputRectOfInterestForRect:CGRectMake(margin, topMargin, SCREEN_WIDTH - 2 * margin, SCREEN_WIDTH - 2 * margin)];
    }];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    return output;
}

/**
 创建一个中间镂空的layer
 
 @param mainRect    主背景rect
 @param loukongRect 镂空部分的rect
 
 @return 镂空的layer
 */
- (CAShapeLayer *)loukongLayerWithMianRect:(CGRect)mainRect loukongRect:(CGRect)loukongRect {
    
    //背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:mainRect cornerRadius:0];
    //镂空
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:loukongRect cornerRadius:0];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;//中间镂空的关键点 填充规则
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.5;
    return fillLayer;
}

#pragma mark - 懒加载
- (AVCaptureSession *)session {
    
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        //高质量采集率
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    
    if (!_videoPreviewLayer) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoPreviewLayer.frame = self.view.layer.bounds;
    }
    return _videoPreviewLayer;
}


@end
