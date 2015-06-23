
#import "BTLEPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import <UIKit/UIKit.h>
#import "Person.h"



@interface BTLEPeripheral () <CBPeripheralManagerDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView       *textView;
@property (strong, nonatomic) NSMutableData         *data;
@property (strong, nonatomic) NSString              *foundUser;
@property (strong, nonatomic) NSString              *selfId;
@property (strong, nonatomic) NSString              *token;
@property (strong, nonatomic) IBOutlet UISwitch         *advertisingSwitch;
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic, copy)   void (^dataResult)(Person*);
@property (nonatomic, copy)   void (^dataBlock)(NSError*);

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
    NSLog(@"self.peripheralManager powered ON.");
    NSString *characId =  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"this is my ID that im going  to present %@", characId);
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:characId]
                                                                      properties:CBCharacteristicPropertyWrite
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

- (void)enableAdvertise :(void (^)(Person* dataResults))dataCallback{
    
       _dataResult = dataCallback;
    self.peripheralManager =    [[CBPeripheralManager alloc]  initWithDelegate:self queue:self.queue ];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    
    NSLog(@"recieved write request");
    
    
    
    CBATTRequest       *request = [requests  objectAtIndex:0];
    NSData             *request_data = request.value;
 //   CBCharacteristic   *write_char = request.characteristic;
    //CBCentral*            write_central = request.central;
    //NSUInteger            multi_message_offset = request.offset;
    
    // Face commands this PWR RX to advertise serno UUID?
    int total_write_requests = 0;
//    if ([ write_char.UUID isEqual:[CBUUID UUIDWithString:YOUR_CHARACTERISTIC_UUID]] )
 //   {

        // Read desired new_state data from central:
 //       unsigned char *new_state = (unsigned char *)[request_data   bytes];
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
        NSString *stringFromData = [[NSString alloc] initWithData:request_data encoding:NSUTF8StringEncoding];
        NSLog(@"This is the data i recieved %@" , stringFromData  );
        //now need to ask server about this ID and return the answer to the list
        [self updateServer:stringFromData];
 
    }
     [peripheral respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
}

-(void)updateServer:(NSString*)foundCharacteristic  {
    
    
    self.selfId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.foundUser = foundCharacteristic;
    self.token=@"123";
    
    
    
    //    "source_id": Fiix_unique_id ,
    //    "found_id" :  Fiix_unique_id
    //    "timestamp": "timestamp",
    //    "proximity": "xx" ,
    //    "last_seen": "timestamp",
    
    
    
    
    //////////////
    
    
    
    double today = [[NSDate date] timeIntervalSince1970 ]*1000000;
    
    NSDictionary *dict = @{@"source_id" : self.selfId,
                           @"found_id"  : self.foundUser,
                           @"timestamp" : @(today).stringValue,
                           @"proximity" : @"",
                           @"token"     : self.token};
    NSError *error = nil;
    NSData *json;
    
    // Dictionary convertable to JSON ?
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        // Serialize the dictionary
        json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            
            NSLog(@"found_nearby= %@", jsonString);
            
            NSString *appendString = [ @"found_nearby=" stringByAppendingString:jsonString];
            
            NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
            
            NSURL * url = [NSURL URLWithString:@"http://intromi.biz/exec/user_lookup"];
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
            NSString *params = appendString;
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                   NSLog(@"Response:%@ %@\n", response, error);
                                                                   if(error == nil)
                                                                   {
                                                                       Person *person = [self BuildPersonProfileFromResult:data];
                                                                       NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                                       
                                                                       
                                                                       _dataResult(person);
                                                                       NSLog(@"Data = %@",text);
                                                                       
                                                                   }
                                                                   
                                                               }];
            [dataTask resume];
            
        }
    }
    else
        NSLog(@"json object build error");
}
-(Person*)BuildPersonProfileFromResult:(NSData*)personData {
    
    NSError *error = nil;
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:personData options:0 error:&error];
    
    if (error != nil) {
        NSLog(@"Error: %@", error.description);
        return nil;
    }
    
    Person *p =  [[Person alloc] init];
  //  NSString *personToString = [[NSString alloc] initWithData:[parsedData objectForKey:@"name"] encoding:NSUTF8StringEncoding];
    NSString *personToString = [NSString stringWithCString:[[parsedData objectForKey:@"name"]cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
    p.name       =  personToString;
    NSLog(@"name found  %@", p.name);
    if (p.name == nil) {
        
        p.name=@"Found device but name is not set";
    }
    p.user_id    = [parsedData objectForKey:@"user_id"];
    p.company    = [parsedData objectForKey:@"token"];
    p.phone      = [parsedData objectForKey:@"phone"];
    //           p.url_1       = [parsedData objectForKey:@"url_1"];
    p.address    = [parsedData objectForKey:@"address"];
    p.occupation = [parsedData objectForKey:@"accupation"];
    p.uniqId     = [parsedData objectForKey:@"uniqueId"];
    
    
    return p;
    
}


@end
