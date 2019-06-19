//
//  TDMacMainManager.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/30/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDMacMainManager.h"
#import "TDDispenseLog.h"
#import "TDHardwareDispenserManager.h"
#import "TDTreatDispenserManager.h"
#import "TDVideoRecorder.h"
#import "TDDispenserInterfaceUSB.h"

static NSTimeInterval const TDDelayBeforeDispenseSeconds = 2.0;

@interface TDMacMainManager() <TDHardwareDispenserManagerDelegate>

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (nonatomic, strong) TDHardwareDispenserManager *hardwareDispenserManager;
@property (nonatomic, strong) TDTreatDispenserManager *treatDispenserManager;
@property (nonatomic, strong) TDVideoRecorder *videoRecorder;

@property (nonatomic, strong) TDDispenseLog *latestDispenseLog;

@end

@implementation TDMacMainManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sessionQueue = dispatch_queue_create("TDMacMainManagerSessionQueue", DISPATCH_QUEUE_SERIAL);
        
        TDDispenserInterfaceUSB *dispenserInterface = [[TDDispenserInterfaceUSB alloc] init];
        _hardwareDispenserManager = [[TDHardwareDispenserManager alloc] initWithDispenserInterface:dispenserInterface];
        _hardwareDispenserManager.delegate = self;
        
        _treatDispenserManager = [[TDTreatDispenserManager alloc] init];
        
        _videoRecorder = [[TDVideoRecorder alloc] init];
    }
    return self;
}

- (void)observeForDispense
{
    [self startupHardwareDispenser];
    
    __weak TDMacMainManager *weakSelf = self;
    [self.treatDispenserManager getDispenseLogsWithCompletion:^(NSArray<TDDispenseLog *> *dispenseLogs) {
        TDMacMainManager *strongSelf = weakSelf;
        
        TDDispenseLog *dispenseLog = [dispenseLogs firstObject];
        if (dispenseLog && dispenseLog.logType == TDDispenseLogTypeDispense) {
            // Only dispense if we had pulled before and we see a new dispense.
            BOOL shouldDispenseTreat = NO;
            if(strongSelf.latestDispenseLog
               && ![dispenseLog.dispenseId isEqualToString:strongSelf.latestDispenseLog.dispenseId]) {
                NSLog(@"Dispense Treat!!");
                shouldDispenseTreat = YES;
            }
            
            // Updates latest dispense log.
            strongSelf.latestDispenseLog = dispenseLog;
            
            if (shouldDispenseTreat) {
                // TODO: Need to confirm the dispense log.
                
                // Notifies delegate that we'll be dispensing the treat.
                if ([strongSelf.delegate respondsToSelector:@selector(mainManagerWillDispenseTreat:)]) {
                    [strongSelf.delegate mainManagerWillDispenseTreat:self];
                }
                
                // Rotates the tray after a delay.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TDDelayBeforeDispenseSeconds * NSEC_PER_SEC)), strongSelf.sessionQueue, ^{
                    // Rotates the hardware.
                    [strongSelf rotateHardwareDispenser];
                    
                    // Notifies delegate that we be dispensed the treat.
                    if ([strongSelf.delegate respondsToSelector:@selector(mainManagerDispensedTreat:)]) {
                        [strongSelf.delegate mainManagerDispensedTreat:strongSelf];
                    }
                });

            }
        }
    }];
}

#pragma mark - Hardware Methods

- (void)startupHardwareDispenser
{
    __weak TDMacMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMacMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager startPolling];
    });
}

- (void)rotateHardwareDispenserByAmount:(float)amount
{
    NSLog(@"rotateHardwareDispenserByAmount: %f", amount);
    
    __weak TDMacMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMacMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager rotateByAmount:amount];
    });
}

- (void)rotateHardwareDispenser
{
    NSLog(@"rotateHardwareDispenser");
    
    __weak TDMacMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMacMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager rotate];
    });
}

- (void)stopHardwareDispenser
{
    __weak TDMacMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMacMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager stopPolling];
    });
}

#pragma mark - Video Methods

- (void)startRecording
{
    [self.videoRecorder startRecording];
}

#pragma mark - TDHardwareDispenserManagerDelegate

- (void)treatDispenserManager:(TDHardwareDispenserManager *)manager didUpdateState:(TDDispenserState)state
{
    switch (state) {
        case TDDispenserStateReady:
            break;
            
        case TDDispenserStateDisconnected:
            break;
    }
}

@end
