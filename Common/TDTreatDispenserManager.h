//
//  TDTreatDispenserManager.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/18/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDDispenseLog;

@interface TDTreatDispenserManager : NSObject

@property (nonatomic, strong, readonly) NSArray<TDDispenseLog *> *dispenseLogs;
@property (nonatomic, readonly) NSUInteger remainingCount;

- (void)getDispenseLogsWithCompletion:(void(^)(NSArray<TDDispenseLog *> *dispenseLogs))completion;

- (void)deleteAllDispenseLogsUntilDate:(NSDate *)date;

- (void)getRemainingCountWithCompletionBlock:(void(^)(NSUInteger remainingCount))completion;

- (void)updateRemainingCount:(NSUInteger)remainingCount;

- (void)dispenseTreatWithCompletionBlock:(void(^)(NSUInteger newRemainingCount))completion;



@end
