//
//  ServiceManager.m
//  AttendMi
//
//  Created by Doron Foa on 4/23/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "BTLECentral.h"
#import "BTLEPeripheral.h"
#import "ServiceManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import <CoreLocation/CoreLocation.h>
#import <AdSupport/AdSupport.h>
#import "Person.h"
@interface ServiceManager ()


@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;
@property (strong, nonatomic) BTLECentral           *manager;
@property (strong, nonatomic) BTLEPeripheral        *peripherial;
@property (strong, nonatomic) NSString              *token;

@end



@implementation ServiceManager

-(instancetype)initWith:(NSString*)token andErr:(errors)err {

    self = [super init];
    
    if(self) {
     
        
     //check if this device support BLE
        if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]){
            NSLog(@"Bluetooth LE is supported");
            err(4);
            self.token = token;
            self.manager =[[BTLECentral alloc ] initWithToken:self.token completion:^(NSError* data) {
                
                NSLog(@"This is the error  from server %@", data);
                //ddfdf
            
            }];
             self.peripherial = [[BTLEPeripheral alloc ] init];
            
        }
            else {
                NSLog(@"BLE is not supported on this device");
                err(3);
            }
        
               
               }
    return self;
}

-(void)startScan:(founfUserCallback)data
{
    [self.manager stopScan];
    [self.manager enableScan:^(Person* person){
        data(person);
    }];
    [self createTimer];
  }

-(void)manualScan:(founfUserCallback)data
{
    NSLog(@"start manual scanning");
 //   [self.manager stopScan];
    [self.manager enableScan:^(Person* person){
        data(person);
    }];
    [self.manager scan];

}



-(void)stopScan
 {
     [self.manager stopScan];
     

}
-(void)stopAdvertise
{
    [self.peripherial stopAdvertise];

}

-(void)startAdvertise
{
//   [self createTimerAdvertise];
    if ([self.peripherial isAdvertising])
        [self.peripherial stopAdvertise];
        [self.peripherial enableAdvertise];
 
}


- (void)timerScanStop:(NSTimer*)timer  {

    NSLog(@"stop scanning .....");
    [self.manager stopScan];
//    NSLog(@"start advertise");
//    [self.peripherial startAdvertise];
    
}

- (void)timerAdvStop:(NSTimer*)timer  {
    
    NSLog(@"stop advrtise .....");
    [self.peripherial stopAdvertise];
    
}

- (NSTimer*)StopScanning {
    
    // create timer on run loop
    return [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerScanStop:) userInfo:nil repeats:NO];
  
}

- (NSTimer*)createTimer {
    
    NSLog(@"create timer for scanning..");
    // create timer on run loop
    return [NSTimer scheduledTimerWithTimeInterval:62 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
}

- (NSTimer*)StopAdvTimer {
    
    // create timer on run loop
    return [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerAdvStop:) userInfo:nil repeats:NO];
    
}


- (NSTimer*)createTimerAdvertise {
    
    NSLog(@"create timer for advertising..");
    // create timer on run loop
    return [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timerStartAdv:) userInfo:nil repeats:YES];
}

- (void)timerStartAdv:(NSTimer*)timer  {
    
    
     NSLog(@"start advertise.....");
    [self.peripherial startAdvertise];
    
    [self StopAdvTimer];
    
}
- (void)timerStart:(NSTimer*)timer  {
    
//    NSLog(@"@stop advertise....");
//    [self.peripherial stopAdvertise];
    [self.manager scan];

    NSLog(@"start scan.....");
    
    [self StopScanning];
    
    
    
}



@end
    


