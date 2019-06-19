//
//  TDSettingsViewController.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/30/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDSettingsViewController.h"
#import "TDTreatDispenserManager.h"
#import "TDMainManager.h"

@interface TDSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *remainingCountView;
@property (weak, nonatomic) IBOutlet UITextField *remainingCountTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetCountButton;

@property (weak, nonatomic) IBOutlet UIView *deleteLogView;
@property (weak, nonatomic) IBOutlet UITextField *deleteLogsDayTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteLogsButton;

@property (weak, nonatomic) IBOutlet UISwitch *dispenserSwitch;
@property (weak, nonatomic) IBOutlet UIView *dispenserViewContainer;

@end

@implementation TDSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.remainingCountView makeRoundedCorners];
    [self.resetCountButton makeRoundedCorners];
    [self.deleteLogView makeRoundedCorners];
    [self.deleteLogsButton makeRoundedCorners];
    [self.dispenserViewContainer makeRoundedCorners];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Intially set the count to what was passed to us and then fetch for the latest count.
    [self updateRemainingCountUI];
    [self fetchRemainingCount];
    self.dispenserSwitch.on = self.mainManager.isDispenserMode;
}

- (IBAction)didTapResetCountButton:(id)sender
{
    [self.remainingCountTextField endEditing:YES];
    
    // Updates Count.
    NSUInteger newCount = MAX(0, [self.remainingCountTextField.text integerValue]);
    [self.treatDispenserManager updateRemainingCount:newCount];
    
    // Confirms update successful.
    NSString *displayMessage = [NSString stringWithFormat:@"Updated count to %lu.", (unsigned long)newCount];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reset Successful"
                                                                             message:displayMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)didTapDeleteLogsButton:(id)sender
{
    [self.deleteLogsDayTextField endEditing:YES];
    
    NSUInteger days = MAX(0, [self.deleteLogsDayTextField.text integerValue]);
    NSDate *daysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                    value:-days
                                                                   toDate:[NSDate date]
                                                                  options:0];
    
    [self.treatDispenserManager deleteAllDispenseLogsUntilDate:daysAgo];
}

- (IBAction)recognizedTapGestureRecognizer:(id)sender
{
    [self.remainingCountTextField endEditing:YES];
    [self.deleteLogsDayTextField endEditing:YES];
}

- (IBAction)dispenserSwitchValueChanged:(id)sender
{
    self.mainManager.isDispenserMode = self.dispenserSwitch.isOn;
}

- (IBAction)didTapDispenserBackwardButton:(id)sender
{
    [self.mainManager rotateHardwareDispenserByAmount:-0.01];
}

- (IBAction)didTapDispenserSkipBackwardButton:(id)sender
{
    [self.mainManager rotateHardwareDispenserByAmount:-0.05];
}

- (IBAction)didTapDispenserForwardButton:(id)sender
{
    [self.mainManager rotateHardwareDispenserByAmount:0.01];
}

- (IBAction)didTapDispenserSkipForwardButton:(id)sender
{
    [self.mainManager rotateHardwareDispenserByAmount:0.05];
}

#pragma mark - Private

- (void)fetchRemainingCount
{
    __weak TDSettingsViewController *weakSelf = self;
    [self.treatDispenserManager getRemainingCountWithCompletionBlock:^(NSUInteger remainingCount) {
        TDSettingsViewController *strongSelf = weakSelf;
        [strongSelf updateRemainingCountUI];
    }];
}

- (void)updateRemainingCountUI
{
    NSUInteger remainingCount = self.treatDispenserManager.remainingCount;
    self.remainingCountTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)remainingCount];
}

@end
