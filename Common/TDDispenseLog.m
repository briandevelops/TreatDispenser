//
//  TDDispenseLog.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/20/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDDispenseLog.h"

static NSString * const TDDispenseLogDispenseIdKey = @"dispenseId";
static NSString * const TDDispenseLogTypeKey = @"logType";
static NSString * const TDDispenseLogDateKey = @"date";
static NSString * const TDDispenseLogDispenseConfirmedKey = @"dispenseConfirmed";
static NSString * const TDDispenseLogDispenseCountKey = @"dispenseCount";

static NSString * const TDDispenseLogDateFormat = @"yyyy-MM-dd HH:mm:ss zzz";

@implementation TDDispenseLog

+ (TDDispenseLog *)dispenseLogFromDictionary:(NSDictionary *)dictionary
{
    TDDispenseLog *dispenseLog = [[TDDispenseLog alloc] init];
    
    NSString *dispenseId = dictionary[TDDispenseLogDispenseIdKey];
    dispenseLog.dispenseId = dispenseId;
    
    NSNumber *dispenseLogTypeNumber = dictionary[TDDispenseLogTypeKey];
    TDDispenseLogType logType = TDDispenseLogTypeNotSet;
    switch ([dispenseLogTypeNumber unsignedIntegerValue]) {
        case TDDispenseLogTypeDispense:
            logType = TDDispenseLogTypeDispense;
            break;
        case TDDispenseLogTypeCountReset:
            logType = TDDispenseLogTypeCountReset;
            break;
    }
    dispenseLog.logType = logType;
    
    NSString *dateString = dictionary[TDDispenseLogDateKey];
    dispenseLog.date = [[TDDispenseLog dispenseLogDateFormatter] dateFromString:dateString];
    
    NSNumber *dispenseConfirmedNum = dictionary[TDDispenseLogDispenseConfirmedKey];
    dispenseLog.dispenseConfirmed = [dispenseConfirmedNum boolValue];
    
    NSNumber *dispenseCountNum = dictionary[TDDispenseLogDispenseCountKey];
    dispenseLog.dispenseCount = [dispenseCountNum unsignedIntegerValue];
    
    return dispenseLog;
}

+ (NSDictionary *)dataDictionaryFromLogEvent:(TDDispenseLog *)dispenseLog;
{
    TDDispenseLog *item = dispenseLog;
    
    NSString *dateString = [[TDDispenseLog dispenseLogDateFormatter] stringFromDate:item.date];
    
    NSDictionary *dictionary = @{
                                 TDDispenseLogTypeKey : @(item.logType),
                                 TDDispenseLogDateKey : dateString,
                                 TDDispenseLogDispenseConfirmedKey : @(item.dispenseConfirmed),
                                 TDDispenseLogDispenseCountKey : @(item.dispenseCount)
                                 };
    
    if (item.dispenseId.length > 0) {
        NSMutableDictionary *mutDict = [dictionary mutableCopy];
        mutDict[TDDispenseLogDispenseIdKey] = item.dispenseId;
        dictionary = [mutDict copy];
    }
    return dictionary;
}

#pragma mark - Private

+ (NSDateFormatter *)dispenseLogDateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = TDDispenseLogDateFormat;
    }
    return dateFormatter;
}

@end
