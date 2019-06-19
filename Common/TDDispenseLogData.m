//
//  TDDispenseLogData.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/20/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDDispenseLogData.h"
#import "TDDispenseLog.h"

#if !TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR
@import FirebaseCommunity;
#else
@import Firebase;
#endif

static NSString * const TDDispenseLogsKey = @"dispenseLogs";

@interface TDDispenseLogData()

@property (nonatomic, strong) FIRDatabaseReference *databaseRef;
@property (nonatomic, strong) FIRDatabaseReference *dispenseLogsDBRef;

@end

@implementation TDDispenseLogData

- (FIRDatabaseReference *)databaseRef
{
    if (!_databaseRef) {
        _databaseRef = [[FIRDatabase database] reference];
    }
    return _databaseRef;
}

- (FIRDatabaseReference *)dispenseLogsDBRef
{
    if (!_dispenseLogsDBRef) {
        _dispenseLogsDBRef = [self.databaseRef child:TDDispenseLogsKey];
    }
    return _dispenseLogsDBRef;
}

- (void)getAllDispenseLogsWithCompletion:(void(^)(NSArray<TDDispenseLog *> *dispenseLogs))completion
{
    if (!completion) {
        return;
    }
    
    // TODO: Add a handle tracking for notifying changes.
    [self.dispenseLogsDBRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) {
            completion(nil);
            return;
        }
        
        // TODO: Need to validate this dictionary.
        NSDictionary *dispenseLogsDictionary = snapshot.value;
        __block NSMutableArray<TDDispenseLog *> *dispenseLogs = [[NSMutableArray alloc] init];
        [dispenseLogsDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull dictionary, BOOL * _Nonnull stop) {
            
            TDDispenseLog *dispenseLog = [TDDispenseLog dispenseLogFromDictionary:dictionary];
            if (dispenseLog) {
                dispenseLog.dispenseId = key;
                [dispenseLogs addObject:dispenseLog];
            }
            else {
                // Couldn't create a dispense log.
                NSLog(@"ERROR - Couldn't create dispense log for key %@", key);
            }
        }];
        
        // Sorts array in descending date order (most recent).
        NSArray *sortedArray = [dispenseLogs sortedArrayUsingComparator:^NSComparisonResult(TDDispenseLog  * _Nonnull dispenseLog1, TDDispenseLog  * _Nonnull dispenseLog2) {
            // Reverses compare to sort descending.
            return [dispenseLog2.date compare:dispenseLog1.date];
        }];
        
        completion(sortedArray);
    }];
}

- (void)createDispenseLog:(TDDispenseLog *)dispenseLog
{
    // Verify.
    if (!dispenseLog) {
        return;
    }
    
    // Translate.
    NSDictionary *dictionary = [TDDispenseLog dataDictionaryFromLogEvent:dispenseLog];
    
    // Save.
    FIRDatabaseReference *logDBRef = [self.dispenseLogsDBRef childByAutoId];
    [logDBRef setValue:dictionary];
    
    // Sets new key to object.
    NSString *key = logDBRef.key;
    dispenseLog.dispenseId = key;
}

- (void)deleteDispenseLog:(TDDispenseLog *)dispenseLog
{
    // Verify.
    if (!dispenseLog || !dispenseLog.dispenseId) {
        return;
    }
    
    // Translate.
    NSString *key = dispenseLog.dispenseId;
    
    // Delete.
    FIRDatabaseReference *logDBRef = [self.dispenseLogsDBRef child:key];
    [logDBRef removeValue];
}

- (void)deleteDispenseLogs:(NSArray<TDDispenseLog *> *)dispenseLogs
{
    // Verify.
    if (dispenseLogs.count == 0) {
        return;
    }
    
    // Translate.
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dispenseLogs enumerateObjectsUsingBlock:^(TDDispenseLog * _Nonnull dispenseLog, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = dispenseLog.dispenseId;
        if (key.length > 0) {
            dictionary[key] = [NSNull null];
        }
    }];
    
    // Delete.
    [self.dispenseLogsDBRef updateChildValues:[dictionary copy]];
}

#pragma mark - Private

@end
