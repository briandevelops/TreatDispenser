//
//  TDDispenserInterfaceUSB.h
//  TreatDispenser
//
//  Created by Brian Tang on 5/13/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDDispenserInterface.h"

@interface TDDispenserInterfaceUSB : NSObject<TDDispenserInterface>

@property (nonatomic, weak) id<TDDispenserInterfaceDelegate> delegate;

@end
