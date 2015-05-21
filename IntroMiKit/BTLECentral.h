
//
//  BTLECentral.h
//  IntroMiKit
//
//  Created by Doron Foa on 2/27/15.
//  Copyright (c) 2015 introMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Person.h"

@interface BTLECentral : NSObject

@property (nonatomic,strong) CBCentralManager* centralManager;

-(void) scan;

-(void)stopScan;

-(void) enableScan:(void (^)(Person* dataResults))dataCallback;

- (id)initWithToken:(NSString*)token completion:(void (^)(NSError* error))serverError;

typedef void(^ErrorBlock)(int);


@end
