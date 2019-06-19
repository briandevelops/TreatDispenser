//
//  TDDispenserInterfaceUSB.m
//  TreatDispenser
//
//  Created by Brian Tang on 5/13/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDDispenserInterfaceUSB.h"
#import <ORSSerial/ORSSerialPort-umbrella.h>

static NSString * const TDDispenserInterfacePortKeyword = @"usbserial-A600";
static NSUInteger const TDDispenserInterfaceBaudRate = 9600;

@interface TDDispenserInterfaceUSB() <ORSSerialPortDelegate>

@property (nonatomic) int serialFileDescriptor;

@property (nonatomic, strong) ORSSerialPort *serialPort;

@end

@implementation TDDispenserInterfaceUSB

- (BOOL)isSerialPortOpen
{
    return NO;
}

- (void)initialize
{
    ORSSerialPort *serialPort = [self findDispenserSerialPort];
    if (!serialPort) {
        NSLog(@"ERROR - Couldn't find dispenser port.");
        return;
    }
    
    [self setupSerialPort:serialPort];
    self.serialPort = serialPort;
    
    [serialPort open];
}

- (void)rotateByAmount:(float)amount
{
    if (![self.serialPort isOpen]) {
        NSLog(@"ERROR - Can't rotate, serial port isn't open.");
        return;
    }
    
    // Formats the message and sends it.
    NSString *message = [NSString stringWithFormat:@"<%.2f>", amount];
    NSData *dataToSend = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.serialPort sendData:dataToSend];
}

- (void)stop
{
    [self.serialPort close];
}

#pragma mark - ORSSerialPortDelegate

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port opened.");
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port closed.");
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port removed from system");
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Serial port received message: %@", receivedMessage);
}

#pragma mark - Private

- (ORSSerialPort *)findDispenserSerialPort
{
    ORSSerialPort *foundPort = nil;
    
    NSArray<ORSSerialPort *> *ports = [[ORSSerialPortManager sharedSerialPortManager] availablePorts];
    for (ORSSerialPort *port in ports) {
        if ([port.name containsString:TDDispenserInterfacePortKeyword]) {
            foundPort = port;
            break;
        }
    }
    
    return foundPort;
}

- (void)setupSerialPort:(ORSSerialPort *)serialPort
{
    serialPort.baudRate = @(TDDispenserInterfaceBaudRate);
    serialPort.delegate = self;
}

@end
