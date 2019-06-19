//
//  TDTreatDispenserData.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/19/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTreatDispenserData : NSObject

- (void)getRemainingCountWithCompletionBlock:(void(^)(NSUInteger remainingCount))completion;

- (void)updateRemainingCount:(NSUInteger)remainingCount;

- (void)decrementRemainingCountWithCompletionBlock:(void(^)(NSUInteger newRemainingCount))completion;

@end
