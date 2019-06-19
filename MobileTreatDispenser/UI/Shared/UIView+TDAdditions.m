//
//  UIView+TDAdditions.m
//  TreatDispenser
//
//  Created by Brian Tang on 7/30/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "UIView+TDAdditions.h"

@implementation UIView (TDAdditions)

- (void)makeRoundedCorners
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
}

- (void)makeCircle
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
}

@end
