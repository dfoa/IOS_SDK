//
//  Register.m
//  AttendMi
//
//  Created by Doron Foa on 4/21/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Register.h"





@interface Register()


@end


@implementation Register


//initilize the object.





- (instancetype)initWithUinqueId:(NSString *)uinqueId andCompanyToken:(NSString *)companyToken andName:(NSString*)name {

   
    self = [super init];
    if(self) {
    self.userId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.uniqueId =uinqueId;
    self.name = name;
    self.today = [[NSDate date] timeIntervalSince1970 ]*1000000;
        
    }
       return self;
}

-(void)doRegistration:(void (^)(int result))completionHandler andConnectionErrors:(void(^)(NSString *error)) connectioErrors {

        
    NSDictionary *dict = @{@"intromi_id" : self.userId,
                               @"company_id" : self.uniqueId,
                               @"time_stamp" : @(self.today).stringValue,
                               @"name"        :self.name};
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
                completionHandler(2);
                NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                
                NSLog(@"register= %@", jsonString);
                
                NSString *appendString = [ @"register=" stringByAppendingString:jsonString];
//make connection to register this profile
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        
        NSURL * url = [NSURL URLWithString:@"http://intromi.biz/exec/register_user"];
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        NSString *params = appendString;
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                               NSLog(@"Response:%@ %@\n", response, error);
                                                               if(error == nil)
                                                               {
                                                                   NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                                   NSLog(@"Data = %@",text);
                                                                   
                                                               }
                                                               
                                                           }];
        [dataTask resume];
        
    }

    
  
        }
        else
        completionHandler(1);
    

    
}












@end