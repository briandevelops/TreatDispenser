//
//  TDSettingsViewController.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/30/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TDTreatDispenserManager, TDMainManager;

@interface TDSettingsViewController : UIViewController

@property (nonatomic, strong) TDTreatDispenserManager *treatDispenserManager;
@property (nonatomic, strong) TDMainManager *mainManager;

@end
