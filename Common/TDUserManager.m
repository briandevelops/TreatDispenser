//
//  TDUserManager.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/20/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDUserManager.h"

NSString * const TDUserManagerSignInStatusChanged = @"TDUserManagerSignInStatusChanged";

#if !TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR
@import FirebaseCommunity;
#else
@import Firebase;
#endif

@implementation TDUserManager

+ (instancetype)sharedInstance
{
    static TDUserManager *userManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userManager = [[TDUserManager alloc] init];
    });
    return userManager;
}

- (BOOL)isSignedIn
{
    return [FIRAuth auth].currentUser != nil;
}

- (void)signInDefaultUser
{
    // TODO: Make this configurable, currently hardcoded with a login entered manually in the database.
    NSString *email = @"worker@firebase.com";
    NSString *password = @"worker";
    [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        NSLog(@"Signed in - %@", user.email);
        [[NSNotificationCenter defaultCenter] postNotificationName:TDUserManagerSignInStatusChanged object:nil];
    }];
}

@end
