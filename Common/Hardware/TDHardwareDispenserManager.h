//
//  TDHardwareDispenserManager.h
//  TreatDispenser
//
//  Created by Brian Tang on 5/13/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDDispenserInterface.h"

typedef NS_ENUM(NSUInteger, TDDispenserState) {
    TDDispenserStateReady,
    TDDispenserStateDisconnected
};

@class TDHardwareDispenserManager;

@protocol TDHardwareDispenserManagerDelegate <NSObject>

@optional

- (void)hardwareDispenserManager:(TDHardwareDispenserManager *)manager didUpdateState:(TDDispenserState)state;

@end

@interface TDHardwareDispenserManager : NSObject

- (instancetype)initWithDispenserInterface:(id<TDDispenserInterface>)dispenserInterface;

@property (nonatomic, weak) id<TDHardwareDispenserManagerDelegate> delegate;

@property (nonatomic, readonly) TDDispenserState state;

- (void)startPolling;

- (void)stopPolling;

- (void)rotateByAmount:(float)amount;

- (void)rotate;

@end
