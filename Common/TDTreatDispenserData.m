//
//  TDTreatDispenserData.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/19/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDTreatDispenserData.h"

#if !TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR
@import FirebaseCommunity;
#else
@import Firebase;
#endif

static NSString * const TDDispenseCountKey = @"dispenseCount";
static NSString * const TDRemainingCountKey = @"remainingCount";
static NSString * const TDDefaultCountKey = @"defaultCount";

@interface TDTreatDispenserData()

@property (nonatomic, strong) FIRDatabaseReference *databaseRef;
@property (nonatomic, strong) FIRDatabaseReference *dispenseCountDBRef;

@end

@implementation TDTreatDispenserData

- (FIRDatabaseReference *)databaseRef
{
    if (!_databaseRef) {
        _databaseRef = [[FIRDatabase database] reference];
    }
    return _databaseRef;
}

- (FIRDatabaseReference *)dispenseCountDBRef
{
    if (!_dispenseCountDBRef) {
        _dispenseCountDBRef = [self.databaseRef child:TDDispenseCountKey];
    }
    return _dispenseCountDBRef;
}


- (void)getRemainingCountWithCompletionBlock:(void(^)(NSUInteger remainingCount))completion
{
    if (!completion) {
        return;
    }
    
    [[self.dispenseCountDBRef child:TDRemainingCountKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSUInteger remainingCount = 0;
        NSNumber *number = (NSNumber *)snapshot.value;
        if (number) {
         remainingCount = [number unsignedIntegerValue];
        }
        
        if (completion) {
            completion(remainingCount);
        }
    }];
}

- (void)updateRemainingCount:(NSUInteger)remainingCount
{
    [[self.dispenseCountDBRef child:TDRemainingCountKey] setValue:@(remainingCount)];
}

- (void)decrementRemainingCountWithCompletionBlock:(void(^)(NSUInteger newRemainingCount))completion
{
    [self.dispenseCountDBRef runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *countDict = currentData.value;
        if (!countDict || [countDict isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        NSNumber *num = countDict[TDRemainingCountKey];
        if (num) {
            NSUInteger remainingCount = [num unsignedIntegerValue];
            remainingCount--;
            countDict[TDRemainingCountKey] = @(remainingCount);
            currentData.value = countDict;
        }
        
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        NSMutableDictionary *countDict = snapshot.value;
        NSNumber *num = countDict[TDRemainingCountKey];
        NSUInteger remainingCount = [num unsignedIntegerValue];
        if (completion) {
            completion(remainingCount);
        }
    }];
}

@end
