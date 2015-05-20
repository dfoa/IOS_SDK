//
//  Register.h
//  AttendMi
//
//  Created by Doron Foa on 4/21/15.
//  Copyright (c) 2015 IntroMi. All rights reserved.
//





#import <Foundation/Foundation.h>


@interface Register : NSObject

@property (nonatomic,strong)  NSString* userId;
@property (nonatomic,strong)  NSString* uniqueId;
@property (nonatomic,strong) NSDate *today;
@property (nonatomic,strong) NSString *name;



- (id)initWithUinqueId:(NSString *)uinqueId andCompanyToken:(NSString *)companyToken andName:(NSString*)name andCompletionHandler:(void (^)(int result))completionHandler andConnectionErrors:(void(^)(NSString *error)) connectioErrors;


@end
