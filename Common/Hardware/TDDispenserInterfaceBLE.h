//
//  TDDispenserInterfaceBLE.h
//  TreatDispenser
//
//  Created by Brian Tang on 10/15/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDDispenserInterface.h"

@interface TDDispenserInterfaceBLE : NSObject<TDDispenserInterface>

@property (nonatomic, weak) id<TDDispenserInterfaceDelegate> delegate;

@end
