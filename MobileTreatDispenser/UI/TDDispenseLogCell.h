//
//  TDDispenseLogCell.h
//  TreatDispenser
//
//  Created by Brian Tang on 7/18/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDDispenseLogCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *remainingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dispenseDateLabel;

@end
