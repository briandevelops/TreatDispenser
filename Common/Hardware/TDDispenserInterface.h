//
//  TDDispenserInterface.h
//  TreatDispenser
//
//  Created by Brian Tang on 10/15/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDDispenserInterfaceDelegate <NSObject>

@optional
- (void)dispenseInterfaceDidConnect:(id)dispenserInterface;
- (void)dispenseInterfaceDidDisconnect:(id)dispenserInterface;

@end

@protocol TDDispenserInterface <NSObject>

@property (nonatomic, weak) id<TDDispenserInterfaceDelegate> delegate;

- (void)initialize;
- (void)rotateByAmount:(float)amount;
- (void)stop;

@end
