//
//  TDVideoRecorder.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/31/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDVideoRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface TDVideoRecorder() <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureOutput;

@end

@implementation TDVideoRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sessionQueue = dispatch_queue_create("TDVideoRecorderSessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)configureSession
{
    AVCaptureDevice *captureDevice = self.captureDevice;
    
    NSLog(@"Will start recording with %@", captureDevice.localizedName);
    
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
//    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                              error:&error];
    if (!deviceInput || ![captureSession canAddInput:deviceInput]) {
        NSLog(@"Couldn't start a recording session with the device input.");
        return;
    }
    [captureSession addInput:deviceInput];
    
    
    AVCaptureMovieFileOutput *captureFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if (![captureSession canAddOutput:captureFileOutput]) {
        NSLog(@"Couldn't start a recording session with the device output.");
        return;
    }
    self.captureOutput = captureFileOutput;
    [captureSession addOutput:captureFileOutput];
    
    [captureSession startRunning];
}

- (void)startRecording
{
    NSArray<AVCaptureDevice *> *captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSLog(@"%@", captureDevices);
    
    if (captureDevices.count == 0) {
        NSLog(@"Couldn't find video capture devices.");
        return;
    }
    
    self.captureDevice = [captureDevices firstObject];
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
    
    dispatch_async(self.sessionQueue, ^{
        NSString *fileString = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mov"];
        NSLog(@"startRecording to this path: %@", fileString);
        NSURL *fileURL = [NSURL fileURLWithPath:fileString];
        [self.captureOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
    });
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"didFinishRecordingToOutputFileAtURL - %@", outputFileURL.absoluteString);
    if (error) {
        NSLog(@"didFinishRecordingToOutputFileAtURL - error - %@", error.localizedDescription);
    }
}

@end
