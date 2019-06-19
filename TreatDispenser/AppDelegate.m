//
//  AppDelegate.m
//  TreatDispenser
//
//  Created by Brian Tang on 5/13/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "AppDelegate.h"
#import "TDUserManager.h"

@import FirebaseCommunity;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [FIRApp configure];
    [[TDUserManager sharedInstance] signInDefaultUser];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


@end
