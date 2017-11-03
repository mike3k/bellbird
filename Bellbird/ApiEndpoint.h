//
//  ApiEndpoint.h
//  Bellbird
//
//  Created by Mike Cohen on 11/3/17.
//  Copyright © 2017 Mike Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiEndpoint : NSObject

@property (nonatomic,strong) NSString *baseUrlString;

- (void)sendRequest:(NSString*)request method:(NSString*)method body:(NSData*)body completion:(void (^)(NSData *))completion;

- (void)getAlarms: (void (^)(NSArray *))completion;
- (void)createAlarm: (NSString*)body;
- (void)updateAlarm:(int)alarmId votes:(int)votes;
- (void)push:(int)alarmId;

@end
