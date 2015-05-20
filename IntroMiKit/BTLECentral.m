

#import "BTLECentral.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import  <UIKit/UIKit.h>
#import "TransferService.h"
#import "Person.h"
#import "BTLEPeripheral.h"

@interface BTLECentral () <CBCentralManagerDelegate, CBPeripheralDelegate>


@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;
@property (strong, nonatomic) NSString              *foundUser;
@property (strong, nonatomic) NSString              *selfId;
@property (strong, nonatomic) NSString              *token;
@property (nonatomic, copy)   void (^dataBlock)(NSError*);
@property (nonatomic, copy)   void (^dataResult)(Person*);

@property (nonatomic) dispatch_queue_t queue;


@end



@implementation BTLECentral

- (id)initWithToken:(NSString*)token completion:(void (^)(NSError* error))serverError{
    self.queue = dispatch_queue_create("com.ad.AttendMi.BTLECentral", DISPATCH_QUEUE_SERIAL);

//     return [self initWithDelegate:nil];
       _data = [[NSMutableData alloc] init];
    self.token = token;
    _dataBlock = serverError;
    NSLog(@"init sdk") ;
    return self;
    
}



#pragma mark - Central Methods



/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...

    // ... so start scanning
    [self scan];
}




/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan 
{
       [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];

 //       [self.centralManager scanForPeripheralsWithServices:nil
 //                                                 options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    

    
    
    NSLog(@"Scanning started");
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is, 
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    
    NSLog(@"Discovered peripherial with name %@", peripheral.name);
    // Reject any where the value is above reasonable range
/*    if (RSSI.integerValue > -15) {
        NSLog(@"got -15 RRSI");
        return;
    }
        
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -35) {
            NSLog(@"got -35 RRSI");
        return;
    }
    
 */   NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    // Ok, it's in range - have we already seen it?
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
        
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
//    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
//    [self.centralManager stopScan];
//    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];

    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    NSLog(@"looking for services");
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
   // [peripheral discoverServices:nil];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
//        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
      // Loop through the newly filled peripheral.services array, just in case there's more than one.
    NSLog(@"service has been discovered");
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil
                                 forService:service];       NSLog(@"This is the service that was discovered %@", service.UUID);
        //      [peripheral discoverCharacteristics:nil forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
//        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        NSLog(@"and this is the characteristics %@",characteristic.UUID);
     //   if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        //go to server and update user with information
             [self.centralManager cancelPeripheralConnection:peripheral];
        [self updateServer:[characteristic.UUID UUIDString]];
   
        
        
         
            // If it is, subscribe to it
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}



-(void)stopScan{
 

    [self.centralManager stopScan];

}


-(void) enableScan:(void (^)(Person* dataResults))dataCallback

{
         _dataResult = dataCallback;
         self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.queue];
}




//- (void)updateServer useruui:(NSString *)uinqueId andCompanyToken:(NSString *)companyToken andCompletionHandler:(void (^)(int result))completionHandler andConnectionErrors:(void(^)(NSString *error)) connectioErrors{
-(void)updateServer:(NSString*)foundCharacteristic  {
    
    
        self.selfId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.foundUser = foundCharacteristic;
 
    
        
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
                                                                       NSLog(@"Response:%@ %@\n", response, error); _dataBlock(error);
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
    
            p.name       = [parsedData objectForKey:@"name"];
    NSLog(@"nameeeeeeeeeeee %@", p.name);
    if (p.name == nil) {
        
        p.name=@"Found device but is not set";
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

