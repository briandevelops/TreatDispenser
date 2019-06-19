//
//  TDHardwareDispenserManager.m
//  TreatDispenser
//
//  Created by Brian Tang on 5/13/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDHardwareDispenserManager.h"

#import "TDDispenserInterfaceBLE.h"
#import "TDDispenserInterfaceUSB.h"

@interface TDHardwareDispenserManager() <TDDispenserInterfaceDelegate>

@property (nonatomic, strong) id<TDDispenserInterface> dispenserInterface;

@property (nonatomic) NSUInteger rotateCount;

@end

@implementation TDHardwareDispenserManager

- (instancetype)initWithDispenserInterface:(id<TDDispenserInterface>)dispenserInterface
{
    NSAssert(dispenserInterface != nil, @"Must have a dispenser interface.");
    self = [super init];
    if (self) {
        _dispenserInterface = dispenserInterface;
        _dispenserInterface.delegate = self;
    }
    return self;
}

- (void)startPolling
{
    NSAssert(self.dispenserInterface != nil, @"Must have a dispenser interface.");
    [self.dispenserInterface initialize];
}

- (void)stopPolling
{
    [self.dispenserInterface stop];
}

- (void)rotateByAmount:(float)amount;
{
    [self.dispenserInterface rotateByAmount:amount];
}

- (void)rotate
{
    float amount = [self getRotateAmount];
    NSLog(@"rotate amount = %f", amount);
    [self.dispenserInterface rotateByAmount:amount];
}

#pragma mark - TDDispenserInterfaceDelegate

- (void)dispenseInterfaceDidConnect:(id)dispenserInterface
{
    if ([self.delegate respondsToSelector:@selector(hardwareDispenserManager:didUpdateState:)]) {
        [self.delegate hardwareDispenserManager:self didUpdateState:TDDispenserStateReady];
    }
}

- (void)dispenseInterfaceDidDisconnect:(id)dispenserInterface
{
    if ([self.delegate respondsToSelector:@selector(hardwareDispenserManager:didUpdateState:)]) {
        [self.delegate hardwareDispenserManager:self didUpdateState:TDDispenserStateDisconnected];
    }
}

#pragma mark - Private

- (float)getRotateAmount
{
    float rotateAmount = 0;
    
    // Accounts for the uneven rotation of the plate or servo.
    if (self.rotateCount % 18 == 0 || self.rotateCount % 14 == 0) {
        rotateAmount = 0.06f;
    }
    else {
        rotateAmount = 0.05f;
    }
    self.rotateCount++;
    return rotateAmount;
}

@end
