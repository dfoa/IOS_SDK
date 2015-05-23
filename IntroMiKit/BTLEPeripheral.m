
#import "BTLEPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import <UIKit/UIKit.h>



@interface BTLEPeripheral () <CBPeripheralManagerDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView       *textView;
@property (strong, nonatomic) IBOutlet UISwitch         *advertisingSwitch;
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (nonatomic) dispatch_queue_t queue;

@end


@implementation BTLEPeripheral

- (instancetype) init{
    
    
    self.queue = dispatch_queue_create("com.ad.AttendMi.BTLEPeripheral", DISPATCH_QUEUE_SERIAL);
   
     
   //  return [self initWithDelegate:nil];
    return self;
}


//    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];



#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    NSString *characId =  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"this is my ID that im going  to present %@", characId);
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:characId]
                                                                      properties:CBCharacteristicPropertyNotify
                                                                           value:nil
                                                                     permissions:CBAttributePermissionsWriteable];

    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                        primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
    [self startAdvertise];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    // Get the data
    self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending

}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}



#pragma mark - TextView Methods








#pragma mark - Switch Methods



/** Start advertising
 */
- (void) startAdvertise;
{
    NSLog(@"start advertizing");
        // All we advertise is our service's UUID
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] ,CBAdvertisementDataLocalNameKey:@"IntroMi"}  ];
    

}

-(void)stopAdvertise {
    
    [self.peripheralManager stopAdvertising];
}

- (BOOL)isAdvertising {
    return [self.peripheralManager isAdvertising];
}
- (void)enableAdvertise {
    
    self.peripheralManager =    [[CBPeripheralManager alloc]  initWithDelegate:self queue:self.queue ];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    
    NSLog(@"recieved write request");
    
    
    
    CBATTRequest       *request = [requests  objectAtIndex:0];
    NSData             *request_data = request.value;
    CBCharacteristic   *write_char = request.characteristic;
    //CBCentral*            write_central = request.central;
    //NSUInteger            multi_message_offset = request.offset;
    
    // Face commands this PWR RX to advertise serno UUID?
    int total_write_requests = 0;
//    if ([ write_char.UUID isEqual:[CBUUID UUIDWithString:YOUR_CHARACTERISTIC_UUID]] )
 //   {

        // Read desired new_state data from central:
        unsigned char *new_state = (unsigned char *)[request_data   bytes];
//  //      my_new_state = new_state[0];
//#endif
//        NSLog(@"- advertise serno UUID: %s", my_new_state ? "TRUE" : "FALSE" );
        
        // Select UUID that includes serno of PWR RX, for advertisements:
        
//        ++total_write_requests;
//    }
    
    if ( total_write_requests )
    {
        [peripheral respondToRequest:request    withResult:CBATTErrorSuccess];  // result = success
    }
    else
    {
        NSLog(@"_no_write_request_FAULT !!");
    }
}



@end
