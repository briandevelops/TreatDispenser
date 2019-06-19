//
//  TDUserManager.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/20/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TDUserManagerSignInStatusChanged;

@interface TDUserManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) BOOL isSignedIn;

- (void)signInDefaultUser;

@end
