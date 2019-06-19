//
//  TDDispenseLog.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/20/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TDDispenseLogType) {
    TDDispenseLogTypeNotSet,
    TDDispenseLogTypeDispense,
    TDDispenseLogTypeCountReset
};

@interface TDDispenseLog : NSObject

@property (nonatomic, strong) NSString *dispenseId;
@property (nonatomic) NSUInteger logType;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL dispenseConfirmed;
@property (nonatomic) NSUInteger dispenseCount;

+ (TDDispenseLog *)dispenseLogFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dataDictionaryFromLogEvent:(TDDispenseLog *)dispenseLog;

@end
