
//
//  BBTLEPeripheral.h
//  IntroMiKit
//
//  Created by Doron Foa on 2/27/15.
//  Copyright (c) 2015 introMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTLEPeripheral : NSObject



- (void) startAdvertise;

- (void) stopAdvertise;

- (BOOL)isAdvertising;

- (void)enableAdvertise;

- (instancetype) init;

@end