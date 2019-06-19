//
//  TDDispenseLogData.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/20/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDDispenseLog;

@interface TDDispenseLogData : NSObject

- (void)getAllDispenseLogsWithCompletion:(void(^)(NSArray<TDDispenseLog *> *dispenseLogs))completion;

- (void)createDispenseLog:(TDDispenseLog *)dispenseLog;

- (void)deleteDispenseLog:(TDDispenseLog *)dispenseLog;

- (void)deleteDispenseLogs:(NSArray<TDDispenseLog *> *)dispenseLogs;

@end
