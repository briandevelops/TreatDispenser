//
//  TDMainViewController.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/18/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDMainViewController.h"
#import "TDDispenseLogCell.h"
#import "TDDispenseLog.h"
#import "TDMainManager.h"
#import "TDSettingsViewController.h"
#import "TDTreatDispenserManager.h"
#import "TDUserManager.h"
#import <AVFoundation/AVFoundation.h>


@import Firebase;

static NSString * const TDDispenseSoundFilename = @"TreatTone";

static UIColor *TDColorGreen = nil;
static UIColor *TDColorLightGreen = nil;
static UIColor *TDColorYellow = nil;
static UIColor *TDColorOrange = nil;
static UIColor *TDColorRed = nil;

@interface TDMainViewController () <TDMainManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) TDMainManager *mainManager;
@property (nonatomic, strong) TDTreatDispenserManager *treatDispenserManager;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) NSArray<TDDispenseLog *> *dispenseLogs;
@property (nonatomic) NSUInteger remainingCount;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *remainingCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *logTableView;
@property (weak, nonatomic) IBOutlet UIView *remainingCountView;
@property (weak, nonatomic) IBOutlet UIButton *dispenseButton;

@end

@implementation TDMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.remainingCountLabel.text = @" ";
    
    self.mainManager = [[TDMainManager alloc] init];
    self.mainManager.delegate = self;
    
    self.treatDispenserManager = [[TDTreatDispenserManager alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInStatusChanged:) name:TDUserManagerSignInStatusChanged object:nil];
    
    TDColorGreen = [UIColor colorWithRed:64.0/255.0 green:89.0/255.0 blue:82.0/255.0 alpha:1];
    TDColorLightGreen = [UIColor colorWithRed:156.0/255.0 green:155.0/255.0 blue:122.0/255.0 alpha:1];
    TDColorYellow = [UIColor colorWithRed:255.0/255.0 green:89.0/211.0 blue:147.0/255.0 alpha:1];
    TDColorOrange = [UIColor colorWithRed:255.0/255.0 green:151.0/255.0 blue:79.0/255.0 alpha:1];
    TDColorRed = [UIColor colorWithRed:245.0/255.0 green:79.0/255.0 blue:41.0/255.0 alpha:1];

    self.view.backgroundColor = TDColorGreen;
    
    [self.settingsButton makeCircle];
    [self.remainingCountView makeRoundedCorners];
    [self.dispenseButton makeRoundedCorners];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self displayCount];
    [self fetchDispenseLogs];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mainManager observeForDispense];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapDispenseButton:(id)sender
{
    __weak TDMainViewController *weakSelf = self;
    [self.treatDispenserManager dispenseTreatWithCompletionBlock:^(NSUInteger newRemainingCount) {
        TDMainViewController *strongSelf = weakSelf;
        
        // Updates UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.remainingCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)newRemainingCount];
            
            [strongSelf fetchDispenseLogs];
        });
    }];
}

#pragma mark - TDMainManagerDelegate

- (void)mainManagerWillDispenseTreat:(TDMainManager *)mainManager
{
    __weak TDMainViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TDMainViewController *strongSelf = weakSelf;
        NSLog(@"mainManagerWillDispenseTreat");
        // Prepares to play sound by setting up audio player (if needed).
        if (!strongSelf.audioPlayer) {
            NSURL *soundURL = [[NSBundle mainBundle] URLForResource:TDDispenseSoundFilename withExtension:@"wav"];
            NSError *error = nil;
            strongSelf.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
            if (error) {
                NSLog(@"Couldn't initialize audio player: %@", [error localizedDescription]);
            }
        }
        
        // Plays tone.
        [strongSelf.audioPlayer play];
    });
}

- (void)mainManagerDispensedTreat:(TDMainManager *)mainManager
{
    __weak TDMainViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TDMainViewController *strongSelf = weakSelf;
        NSLog(@"mainManagerDispensedTreat");
        [strongSelf displayCount];
        [strongSelf fetchDispenseLogs];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dispenseLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDDispenseLog *dispenseLog = self.dispenseLogs[indexPath.row];
    
    TDDispenseLogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DispenseLogCell" forIndexPath:indexPath];
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd hh:mm a";
    }
    
    if (dispenseLog.logType == TDDispenseLogTypeCountReset) {
        cell.dispenseDateLabel.text = [dateFormatter stringFromDate:dispenseLog.date];
        cell.remainingCountLabel.text = [NSString stringWithFormat:@"Reset to %lu", (unsigned long)dispenseLog.dispenseCount];
    }
    else {
        cell.dispenseDateLabel.text = [dateFormatter stringFromDate:dispenseLog.date];
        cell.remainingCountLabel.text = [NSString stringWithFormat:@"#%lu", (unsigned long)dispenseLog.dispenseCount];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        TDSettingsViewController *settingsViewController = [segue destinationViewController];
        settingsViewController.mainManager = self.mainManager;
        settingsViewController.treatDispenserManager = self.treatDispenserManager;
    }
}

#pragma mark - Private

- (void)signInStatusChanged:(NSNotification *)notification
{
    // TODO: Add sign in status.
    BOOL isSignedIn = [TDUserManager sharedInstance].isSignedIn;
    NSLog(@"signInStatusChanged - isSignedIn = %@", isSignedIn ? @"YES" : @"NO");
}

- (void)displayCount
{
    __weak TDMainViewController *weakSelf = self;
    [self.treatDispenserManager getRemainingCountWithCompletionBlock:^(NSUInteger remainingCount) {
        TDMainViewController *strongSelf = weakSelf;
        
        // Updates UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.remainingCount = remainingCount;
            strongSelf.remainingCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)remainingCount];
        });
    }];
}

- (void)fetchDispenseLogs
{
    __weak TDMainViewController *weakSelf = self;
    [self.treatDispenserManager getDispenseLogsWithCompletion:^(NSArray<TDDispenseLog *> *dispenseLogs) {
        TDMainViewController *strongSelf = weakSelf;
        strongSelf.dispenseLogs = dispenseLogs;
        
        // Updates UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.logTableView reloadData];
        });
    }];
}

@end
