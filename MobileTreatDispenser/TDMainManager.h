//
//  TDMainManager.h
//  TreatDispenser
//
//  Created by Brian Tang on 10/15/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDMainManager;

@protocol TDMainManagerDelegate <NSObject>

- (void)mainManagerWillDispenseTreat:(TDMainManager *)mainManager;

- (void)mainManagerDispensedTreat:(TDMainManager *)mainManager;

@optional

- (void)mainManagerHardwareConnected:(TDMainManager *)mainManager;

- (void)mainManagerHardwareDisconnected:(TDMainManager *)mainManager;

@end

@interface TDMainManager : NSObject

@property (nonatomic, weak) id<TDMainManagerDelegate> delegate;

@property (nonatomic) BOOL isDispenserMode;

- (void)observeForDispense;


#pragma mark - Hardware Methods

- (void)startupHardwareDispenser;

- (void)rotateHardwareDispenserByAmount:(float)amount;

- (void)rotateHardwareDispenser;

- (void)stopHardwareDispenser;

@end
