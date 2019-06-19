//
//  TDDispenserInterfaceBLE.m
//  TreatDispenser
//
//  Created by Brian Tang on 10/15/17.
//  Copyright © 2017 Brian Tang. All rights reserved.
//

#import "TDDispenserInterfaceBLE.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const TDDispenserPeripheralUUID = @"98C718CA-D855-F782-D0D5-BDC1F1C5C155";
static NSString * const TDDispenserPeripheralName = @"SH-HC-08";
static NSString * const TDDispenserPeripheralServiceUUID = @"FFE0";
static NSString * const TDDispenserPeripheralServiceCharactisticUUID = @"FFE1";

@interface TDDispenserInterfaceBLE() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *peripheralService;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@end

@implementation TDDispenserInterfaceBLE

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return self;
}

- (void)initialize
{
    [self scanForPeripheral];
}

- (void)rotateByAmount:(float)amount
{
    if (!self.characteristic || !self.peripheral) {
        return;
    }
    
    // Formats the message and sends it.
    NSString *message = [NSString stringWithFormat:@"<%.2f>", amount];
    NSData *dataToSend = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    // Sends the data.
    [self.peripheral writeValue:dataToSend
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithoutResponse];
}

- (void)stop
{
    [self stopAndClearPeripheral];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"BLE - centralManagerDidUpdateState: %ld", (long)central.state);
    switch (central.state) {
        case CBManagerStatePoweredOn:
            break;
        case CBManagerStatePoweredOff:
        case CBManagerStateUnknown:
        case CBManagerStateResetting:
        case CBManagerStateUnsupported:
        case CBManagerStateUnauthorized:
            self.peripheral = nil;
            self.characteristic = nil;
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"BLE - didDiscoverPeripheral: %@", peripheral.name);
    
    if ([peripheral.name isEqualToString:TDDispenserPeripheralName]) {
        NSLog(@"BLE - Found It! %@", peripheral.name);
        [self.centralManager stopScan];
        
        // Must retain this peripheral to be able to connect to it.
        self.peripheral = peripheral;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"BLE - didConnectPeripheral: %@", peripheral.name);
    peripheral.delegate = self;
    
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"BLE - didFailToConnectPeripheral: %@", peripheral.name);
    [self stopAndClearPeripheral];
    
    if ([self.delegate respondsToSelector:@selector(dispenseInterfaceDidDisconnect:)]) {
        [self.delegate dispenseInterfaceDidDisconnect:self];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"BLE - didDisconnectPeripheral: %@", peripheral.name);
    [self stopAndClearPeripheral];
    
    if ([self.delegate respondsToSelector:@selector(dispenseInterfaceDidDisconnect:)]) {
        [self.delegate dispenseInterfaceDidDisconnect:self];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"BLE - didDiscoverServices");
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:TDDispenserPeripheralServiceUUID]) {
            NSLog(@"BLE - Found service: %@", service.UUID.UUIDString);
            self.peripheralService = service;
            
            NSArray<CBUUID *> *characteristicUUIDs = @[[CBUUID UUIDWithString:TDDispenserPeripheralServiceCharactisticUUID]];
            [peripheral discoverCharacteristics:characteristicUUIDs forService:service];
            
            if ([self.delegate respondsToSelector:@selector(dispenseInterfaceDidConnect:)]) {
                [self.delegate dispenseInterfaceDidConnect:self];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"BLE - didDiscoverCharacteristicsForService");
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:TDDispenserPeripheralServiceCharactisticUUID]) {
            NSLog(@"BLE - Found characteristic: %@", characteristic.UUID.UUIDString);
            self.characteristic = characteristic;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"BLE - didWriteValueForCharacteristic");
    if (error) {
        NSLog(@"BLE - Error writing characteristic value: %@", [error localizedDescription]);
    }
}

#pragma mark - Private

- (void)scanForPeripheral
{
    if (self.peripheral) {
        return;
    }
    
    [self stopAndClearPeripheral];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:TDDispenserPeripheralUUID];
    NSArray<CBPeripheral *> *peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]];
    if (peripherals.count == 1) {
        NSLog(@"BLE - Found using retrievePeripherals");
        // Must retain this peripheral to be able to connect to it.
        self.peripheral = [peripherals firstObject];
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
    else {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)stopAndClearPeripheral
{
    if (self.centralManager.isScanning) {
        [self.centralManager stopScan];
    }
    
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
    
    self.peripheral = nil;
    self.characteristic = nil;
}
@end
