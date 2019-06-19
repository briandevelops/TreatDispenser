//
//  TDMainManager.m
//  TreatDispenser
//
//  Created by Brian Tang on 10/15/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDMainManager.h"

#import "TDDispenserInterfaceBLE.h"
#import "TDDispenseLog.h"
#import "TDHardwareDispenserManager.h"
#import "TDTreatDispenserManager.h"

static NSTimeInterval const TDDelayBeforeDispenseSeconds = 3.0;
static NSString * const TDUserDefaultsDispenserModeKey = @"shouldBeInDispenserMode";

@interface TDMainManager()

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (nonatomic, strong) TDDispenserInterfaceBLE *dispenserInterface;
@property (nonatomic, strong) TDHardwareDispenserManager *hardwareDispenserManager;
@property (nonatomic, strong) TDTreatDispenserManager *treatDispenserManager;

@property (nonatomic, strong) TDDispenseLog *latestDispenseLog;

@property (nonatomic, strong) NSTimer *hardwareStartTimer;

@end

@implementation TDMainManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sessionQueue = dispatch_queue_create("TDMainManagerSessionQueue", DISPATCH_QUEUE_SERIAL);
        
        // Creates the bluetooth interface for the hardware manager.
        _dispenserInterface = [[TDDispenserInterfaceBLE alloc] init];
        _hardwareDispenserManager = [[TDHardwareDispenserManager alloc] initWithDispenserInterface:_dispenserInterface];
        
        _treatDispenserManager = [[TDTreatDispenserManager alloc] init];
        
        BOOL shouldBeInDispenserMode = [[NSUserDefaults standardUserDefaults] boolForKey:TDUserDefaultsDispenserModeKey];
        _isDispenserMode = shouldBeInDispenserMode;
    }
    return self;
}

- (void)setIsDispenserMode:(BOOL)isDispenserMode
{
    if (_isDispenserMode == isDispenserMode) {
        return;
    }
    _isDispenserMode = isDispenserMode;
    [[NSUserDefaults standardUserDefaults] setBool:isDispenserMode forKey:TDUserDefaultsDispenserModeKey];
    
    if (isDispenserMode) {
        [self.hardwareDispenserManager startPolling];
    }
    else {
        [self.hardwareDispenserManager stopPolling];
    }
}

- (void)observeForDispense
{
    if (!self.isDispenserMode) {
        return;
    }
    
    __weak TDMainManager *weakSelf = self;
    
    // Gives it more time to connect.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.sessionQueue, ^{
        TDMainManager *strongSelf = weakSelf;
        if (strongSelf.isDispenserMode) {
            [strongSelf startupHardwareDispenser];
        }
    });
    
    [self.treatDispenserManager getDispenseLogsWithCompletion:^(NSArray<TDDispenseLog *> *dispenseLogs) {
        TDMainManager *strongSelf = weakSelf;
        
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
    __weak TDMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager startPolling];
    });
}

- (void)rotateHardwareDispenserByAmount:(float)amount
{
    NSLog(@"rotateHardwareDispenserByAmount: %f", amount);
    
    __weak TDMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager rotateByAmount:amount];
    });
}

- (void)rotateHardwareDispenser
{
    NSLog(@"rotateHardwareDispenser");
    
    __weak TDMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager rotate];
    });
}

- (void)stopHardwareDispenser
{
    __weak TDMainManager *weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        TDMainManager *strongSelf = weakSelf;
        [strongSelf.hardwareDispenserManager stopPolling];
    });
}

#pragma mark - TDHardwareDispenserManagerDelegate

- (void)hardwareDispenserManager:(TDHardwareDispenserManager *)manager didUpdateState:(TDDispenserState)state
{
    switch (state) {
        case TDDispenserStateReady:
            if ([self.delegate respondsToSelector:@selector(mainManagerHardwareConnected:)]) {
                [self.delegate mainManagerHardwareConnected:self];
            }
            break;
            
        case TDDispenserStateDisconnected:
            if ([self.delegate respondsToSelector:@selector(mainManagerHardwareDisconnected:)]) {
                [self.delegate mainManagerHardwareDisconnected:self];
            }
            break;
    }
}

@end
