//
//  TDTreatDispenserManager.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/18/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDTreatDispenserManager.h"
#import "TDDispenseLogData.h"
#import "TDDispenseLog.h"
#import "TDTreatDispenserData.h"

@interface TDTreatDispenserManager()

@property (nonatomic, strong) TDTreatDispenserData *treatDispenserData;
@property (nonatomic, strong) TDDispenseLogData *dispenserLogData;

@property (nonatomic, strong) NSArray<TDDispenseLog *> *dispenseLogs;
@property (nonatomic) NSUInteger remainingCount;

@end

@implementation TDTreatDispenserManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _treatDispenserData = [[TDTreatDispenserData alloc] init];
        _dispenserLogData = [[TDDispenseLogData alloc] init];
    }
    return self;
}

- (void)getDispenseLogsWithCompletion:(void(^)(NSArray<TDDispenseLog *> *dispenseLogs))completion
{
    __weak TDTreatDispenserManager *weakSelf = self;
    [self.dispenserLogData getAllDispenseLogsWithCompletion:^(NSArray<TDDispenseLog *> *dispenseLogs) {
        TDTreatDispenserManager *strongSelf = weakSelf;
        strongSelf.dispenseLogs = dispenseLogs;
        
        if (completion) {
            completion(dispenseLogs);
        }
    }];
}

- (void)deleteAllDispenseLogsUntilDate:(NSDate *)date
{
    NSMutableArray<TDDispenseLog *> *deleteDispenseLogs = [[NSMutableArray alloc] init];
    NSCalendar *calender = [NSCalendar currentCalendar];
    [self.dispenseLogs enumerateObjectsUsingBlock:^(TDDispenseLog * _Nonnull dispenseLog, NSUInteger idx, BOOL * _Nonnull stop) {
        NSComparisonResult comparisonResult = [calender compareDate:date
                                                              toDate:dispenseLog.date
                                                   toUnitGranularity:NSCalendarUnitDay];
        if (comparisonResult != NSOrderedAscending) {
            [deleteDispenseLogs addObject:dispenseLog];
        }
    }];
    
    if (deleteDispenseLogs.count > 0) {
        [self.dispenserLogData deleteDispenseLogs:deleteDispenseLogs];
        
        // Remove the objects that are in memory out.
        NSMutableArray *dispenseLogs = [self.dispenseLogs mutableCopy];
        [dispenseLogs removeObjectsInArray:deleteDispenseLogs];
        self.dispenseLogs = [dispenseLogs copy];
    }
}

- (void)getRemainingCountWithCompletionBlock:(void(^)(NSUInteger remainingCount))completion
{
    __weak TDTreatDispenserManager *weakSelf = self;
    [self.treatDispenserData getRemainingCountWithCompletionBlock:^(NSUInteger remainingCount) {
        TDTreatDispenserManager *strongSelf = weakSelf;
        strongSelf.remainingCount = remainingCount;
        
        if (completion) {
            completion(remainingCount);
        }
    }];
}

- (void)updateRemainingCount:(NSUInteger)remainingCount
{
    // Updates remaining count.
    [self.treatDispenserData updateRemainingCount:remainingCount];
    self.remainingCount = remainingCount;
    
    // Creates reset count log.
    TDDispenseLog *dispenseLog = [[TDDispenseLog alloc] init];
    dispenseLog.logType = TDDispenseLogTypeCountReset;
    dispenseLog.date = [NSDate new];
    dispenseLog.dispenseCount = remainingCount;
    [self.dispenserLogData createDispenseLog:dispenseLog];

}

- (void)dispenseTreatWithCompletionBlock:(void(^)(NSUInteger newRemainingCount))completion
{
    if (self.remainingCount == 0) {
        NSLog(@"Can't dispense treat if remaining count is zero.");
        return;
    }
    
    // Decrements treat count.
    __weak TDTreatDispenserManager *weakSelf = self;
    [self.treatDispenserData decrementRemainingCountWithCompletionBlock:^(NSUInteger newRemainingCount) {
        TDTreatDispenserManager *strongSelf = weakSelf;
        
        // Updates remaining count.
        strongSelf.remainingCount = newRemainingCount;
        
        // Creates dispense log.
        TDDispenseLog *dispenseLog = [[TDDispenseLog alloc] init];
        dispenseLog.logType = TDDispenseLogTypeDispense;
        dispenseLog.date = [NSDate new];
        dispenseLog.dispenseCount = newRemainingCount + 1;
        [strongSelf.dispenserLogData createDispenseLog:dispenseLog];
        
        if (completion) {
            completion(newRemainingCount);
        }
    }];
}

@end
