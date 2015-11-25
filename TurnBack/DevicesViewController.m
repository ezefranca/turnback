//
//  DevicesViewController.m
//  TurnBack
//
//  Created by Ezequiel Dev on 11/23/15.
//  Copyright © 2015 Ezequiel Dev. All rights reserved.
//

#import "DevicesViewController.h"
#import "DetailsViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#include <math.h>

@interface DevicesViewController () <CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    CBCentralManager *mgr;
    CBPeripheralManager *manager;
    int devices;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    devices = 0;
    mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    manager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    manager.delegate = self;
    mgr.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (NSNumber *)calculateDistance: (NSNumber*)rssi {
    
    float txPower = -59; //hard coded power value. Usually ranges between -59 to -65
    
    if ([rssi floatValue] == 0) {
        NSLog(@"DISTANCIA: %f", [rssi floatValue]);
        return [NSNumber numberWithFloat:-1.0];
    }
    
    float ratio = [rssi floatValue] * (1.0/txPower);
    if (ratio < 1.0) {
         NSLog(@"DISTANCIA: %f", [[NSNumber numberWithFloat:pow(ratio, 10)]floatValue] / 3.2808);
        return [NSNumber numberWithFloat:pow(ratio, 10)];
    }
    else {
        float distance =  (0.89976)* pow(ratio,7.7095) + 0.111;
         NSLog(@"DISTANCIA: %f", [[NSNumber numberWithFloat:distance]floatValue] / 3.2808);
        return [NSNumber numberWithFloat:distance];
    }
}

#pragma mark - Bluetooth delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *messtoshow;
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
            messtoshow=[NSString stringWithFormat:@"State unknown, update imminent."];
            break;
        }
        case CBCentralManagerStateResetting:
        {
            messtoshow=[NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            messtoshow=[NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            messtoshow=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered off."];
            NSLog(@"%@",messtoshow);
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            
            messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered on and available to use."];
            
            [mgr scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey :@YES}];
            
            NSLog(@"%@",messtoshow);
            break;
            
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    peripheral.delegate = self;
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[advertisementData description]]);
    NSLog(@"%@",[NSString stringWithFormat:@"Discover:%@,RSSI:%@\n",[advertisementData objectForKey:@"kCBAdvDataLocalName"],RSSI]);
    NSLog(@"Nome %@", peripheral.name);
    [peripheral readRSSI];
    [self calculateDistance:RSSI];
    [mgr  connectPeripheral:peripheral options:nil];
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    NSLog(@"caralhoooo");
}

#pragma mark - TableView Delegate and Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (devices == 0) {
        return 1;
    }
    return devices;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailsViewController *dt = [[DetailsViewController alloc]init];
    [[self navigationController]pushViewController:dt animated:YES];
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    int state = peripheral.state;
    NSLog(@"Peripheral manager state =  %d", state);
    
    //Set the UUIDs for service and characteristic
    CBUUID *heartRateServiceUUID = [CBUUID UUIDWithString: @"180D"];
    CBUUID *heartRateCharacteristicUUID = [CBUUID UUIDWithString:@"2A37"];
    CBUUID *heartRateSensorLocationCharacteristicUUID = [CBUUID UUIDWithString:@"0x2A38"];
    
    
    //char heartRateData[2]; heartRateData[0] = 0; heartRateData[1] = 60;
    
    //Create the characteristics
    CBMutableCharacteristic *heartRateCharacteristic =
    [[CBMutableCharacteristic alloc] initWithType:heartRateCharacteristicUUID
                                       properties: CBCharacteristicPropertyNotify
                                            value:nil
                                      permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic *heartRateSensorLocationCharacteristic =
    [[CBMutableCharacteristic alloc] initWithType:heartRateSensorLocationCharacteristicUUID
                                       properties:CBCharacteristicPropertyRead
                                            value:nil
                                      permissions:CBAttributePermissionsReadable];
    //Create the service
    CBMutableService *myService = [[CBMutableService alloc] initWithType:heartRateServiceUUID primary:YES];
    myService.characteristics = @[heartRateCharacteristic, heartRateSensorLocationCharacteristic];
    
    //Publish the service
    NSLog(@"Attempting to publish service...");
    [peripheral addService:myService];
    
    //Set the data
    NSDictionary *data = @{CBAdvertisementDataLocalNameKey:@"iDeviceName",
                           CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:@"180D"]]};
    
    //Advertise the service
    NSLog(@"Attempting to advertise service...");
    [peripheral startAdvertising:data];
    
}

@end
