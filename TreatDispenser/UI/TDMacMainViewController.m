//
//  TDMacMainViewController.m
//  TreatDispenser
//
//  Created by Brian Tang on 5/13/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDMacMainViewController.h"
#import "TDDispenseLog.h"
#import "TDMacMainManager.h"
#import "TDTreatDispenserManager.h"

static NSString * const TDDispenseSoundFilename = @"TreatTone";

@interface TDMacMainViewController () <TDMacMainManagerDelegate>

@property (weak) IBOutlet NSTextField *remainingCountTextField;
@property (weak) IBOutlet NSTextView *dispenseLogsTextView;

@property (nonatomic, strong) TDMacMainManager *mainManager;
@property (nonatomic, strong) TDTreatDispenserManager *treatDispenserManager;

@property (weak) IBOutlet NSTextField *rotateAmountTextField;

@end

@implementation TDMacMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.treatDispenserManager = [[TDTreatDispenserManager alloc] init];
    
    // Sets up main manager.
    self.mainManager = [[TDMacMainManager alloc] init];
    self.mainManager.delegate = self;
    
    // Sets up UI.
    __weak TDMacMainViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TDMacMainViewController *strongSelf = weakSelf;
        [strongSelf.mainManager observeForDispense];
        [strongSelf updateUI];
    });
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (IBAction)didClickStartupButton:(id)sender
{
    [self.mainManager startupHardwareDispenser];
}

- (IBAction)didClickRotateByAmountButton:(id)sender
{
    float amount = [self.rotateAmountTextField.stringValue floatValue];
    [self.mainManager rotateHardwareDispenserByAmount:amount];
}

- (IBAction)didClickStopButton:(id)sender
{
    [self.mainManager stopHardwareDispenser];
}

- (IBAction)didClickRefreshButton:(id)sender
{
    [self updateUI];
}

- (IBAction)didClickRotateButton:(id)sender
{
    [self.mainManager rotateHardwareDispenser];
}

#pragma mark - TDMacMainManagerDelegate

- (void)mainManagerWillDispenseTreat:(TDMacMainManager *)mainManager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"mainManagerWillDispenseTreat");
        // Plays tone.
        NSSound *treatTone = [NSSound soundNamed:TDDispenseSoundFilename];
        [treatTone play];
    });
}

- (void)mainManagerDispensedTreat:(TDMacMainManager *)mainManager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"mainManagerDispensedTreat");
    });
}

#pragma mark - Private

- (void)updateUI
{
    [self getRemainingCount];
    [self getDispenseLogs];
}

- (void)getRemainingCount
{
    __weak TDMacMainViewController *weakSelf = self;
    [self.treatDispenserManager getRemainingCountWithCompletionBlock:^(NSUInteger remainingCount) {
        NSString *remainingCountString = [NSString stringWithFormat:@"%lu Treats Remaining", (unsigned long)remainingCount];
        TDMacMainViewController *strongSelf = weakSelf;
        
        // Updates the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.remainingCountTextField.stringValue = remainingCountString;
        });
    }];
}

- (void)getDispenseLogs
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    }
    
    __weak TDMacMainViewController *weakSelf = self;
    [self.treatDispenserManager getDispenseLogsWithCompletion:^(NSArray<TDDispenseLog *> *dispenseLogs) {
        TDMacMainViewController *strongSelf = weakSelf;
        
        // Translates the logs for the UI.
        NSMutableString *logs = [[NSMutableString alloc] init];
        [dispenseLogs enumerateObjectsUsingBlock:^(TDDispenseLog * _Nonnull dispenseLog, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *log = nil;
            if (dispenseLog.logType == TDDispenseLogTypeCountReset) {
                log = [NSString stringWithFormat:@"Reset count to %lu", (unsigned long)dispenseLog.dispenseCount];
            }
            else {
                log = [NSString stringWithFormat:@"Dispensed #%lu", (unsigned long)dispenseLog.dispenseCount];
            }
            
            NSString *displayString = [NSString stringWithFormat:@"%@ - %@\n",
                                       [dateFormatter stringFromDate:dispenseLog.date], log];
            [logs appendString:displayString];
        }];
        
        // Updates the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.dispenseLogsTextView.string = [logs copy];
        });
        
        // Updates the remaining count view since the logs changed.
        [strongSelf getRemainingCount];
    }];
}

@end
