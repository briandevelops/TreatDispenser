//
//  TDMacMainManager.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/30/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDMacMainManager;

@protocol TDMacMainManagerDelegate <NSObject>

- (void)mainManagerWillDispenseTreat:(TDMacMainManager *)mainManager;

- (void)mainManagerDispensedTreat:(TDMacMainManager *)mainManager;

@end

@interface TDMacMainManager : NSObject

@property (nonatomic, weak) id<TDMacMainManagerDelegate> delegate;

- (void)observeForDispense;


#pragma mark - Hardware Methods

- (void)startupHardwareDispenser;

- (void)rotateHardwareDispenserByAmount:(float)amount;

- (void)rotateHardwareDispenser;

- (void)stopHardwareDispenser;


#pragma mark - Video Methods

- (void)startRecording;

@end
